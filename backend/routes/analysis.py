import io
import os
from functools import lru_cache
from typing import Any, Dict, Optional

import numpy as np
import torch
from fastapi import APIRouter, File, HTTPException, UploadFile
from PIL import Image, UnidentifiedImageError
from transformers import CLIPModel, CLIPProcessor
from ultralytics import YOLO


router = APIRouter(prefix="/api")

MAX_IMAGE_BYTES = 10 * 1024 * 1024
CAT_CLASS_ID = 15
DETECTOR_CONFIDENCE = float(os.getenv("CATTALK_DETECTOR_CONFIDENCE", "0.10"))
DETECTOR_IMAGE_SIZE = int(os.getenv("CATTALK_DETECTOR_IMAGE_SIZE", "768"))

STATE_PROMPTS = {
    "relaxed": "a relaxed calm cat with a comfortable body posture",
    "exploratory_social": "a curious social cat calmly exploring",
    "alert_cautious": "an alert cautious cat carefully observing",
    "playful_active": "a playful active cat ready to play",
    "defensive_stressed": "a defensive stressed cat showing fear or tension",
    "attention_seeking": "a cat actively asking a person for attention",
}

ADVISORY = (
    "This is a visual behavioral estimate, not a diagnosis. Context matters; "
    "give the cat space if it appears uncomfortable or tries to move away."
)

CLASSIFIER_MODEL = os.getenv(
    "CATTALK_CLASSIFIER_MODEL",
    "wkcn/TinyCLIP-ViT-8M-16-Text-3M-YFCC15M",
)


@lru_cache(maxsize=1)
def get_detector() -> YOLO:
    return YOLO("yolov8n.pt")


@lru_cache(maxsize=1)
def get_classifier() -> "CachedClipClassifier":
    return CachedClipClassifier(CLASSIFIER_MODEL)


class CachedClipClassifier:
    def __init__(self, model_name: str):
        torch.set_num_threads(max(1, int(os.getenv("CATTALK_TORCH_THREADS", "2"))))
        self.processor = CLIPProcessor.from_pretrained(model_name, use_fast=True)
        self.model = CLIPModel.from_pretrained(model_name).eval()
        self.labels = list(STATE_PROMPTS.values())

        text_inputs = self.processor(
            text=self.labels,
            return_tensors="pt",
            padding=True,
        )
        with torch.inference_mode():
            features = self.model.get_text_features(**text_inputs)
            self.text_features = features / features.norm(dim=-1, keepdim=True)

    def classify(self, image: Image.Image) -> list[Dict[str, Any]]:
        image_inputs = self.processor(images=image, return_tensors="pt")
        with torch.inference_mode():
            features = self.model.get_image_features(**image_inputs)
            image_features = features / features.norm(dim=-1, keepdim=True)
            logits = self.model.logit_scale.exp() * image_features @ self.text_features.T
            probabilities = logits.softmax(dim=-1)[0].tolist()

        return [
            {"label": label, "score": score}
            for label, score in zip(self.labels, probabilities)
        ]


def _best_cat_detection(image_np: np.ndarray) -> Optional[Dict[str, Any]]:
    # COCO's default 0.25 threshold commonly drops dark-fur cats against dark
    # backgrounds. Restricting inference to the cat class lets us retain those
    # weaker boxes without returning another object class as a cat.
    results = get_detector().predict(
        image_np,
        verbose=False,
        classes=[CAT_CLASS_ID],
        conf=DETECTOR_CONFIDENCE,
        imgsz=DETECTOR_IMAGE_SIZE,
    )
    best: Optional[Dict[str, Any]] = None

    for result in results:
        if result.boxes is None:
            continue

        for box in result.boxes:
            if int(box.cls[0].item()) != CAT_CLASS_ID:
                continue

            confidence = float(box.conf[0].item())
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            area = max(0.0, x2 - x1) * max(0.0, y2 - y1)
            candidate = {
                "bbox": [round(x1, 2), round(y1, 2), round(x2, 2), round(y2, 2)],
                "confidence": confidence,
                "area": area,
            }
            if best is None or candidate["area"] > best["area"]:
                best = candidate

    return best


def _crop(image: Image.Image, bbox: list[float]) -> Image.Image:
    width, height = image.size
    x1 = max(0, min(int(bbox[0]), width - 1))
    y1 = max(0, min(int(bbox[1]), height - 1))
    x2 = max(x1 + 1, min(int(bbox[2]), width))
    y2 = max(y1 + 1, min(int(bbox[3]), height))
    return image.crop((x1, y1, x2, y2))


def classify_state(cat_image: Image.Image) -> Dict[str, Any]:
    results = get_classifier().classify(cat_image)
    return prediction_from_results(results)


def prediction_from_results(results: list[Dict[str, Any]]) -> Dict[str, Any]:
    prompt_to_state = {prompt: state for state, prompt in STATE_PROMPTS.items()}
    scores = {
        prompt_to_state[item["label"]]: round(float(item["score"]), 6)
        for item in results
    }
    best_state = max(scores, key=scores.get)
    confidence = scores[best_state]

    reasons = [
        f"The image most closely matched the visual pattern for {best_state.replace('_', ' ')}.",
        "The estimate was made from a single still image, so sound and recent behavior were not considered.",
    ]
    if confidence < 0.45:
        reasons.append("The visual evidence was mixed, so treat this result as low confidence.")

    return {
        "state": best_state,
        "confidence": confidence,
        "scores": scores,
        "reasons": reasons,
    }


@router.post("/analyze-cat")
async def analyze_cat(file: UploadFile = File(...)):
    if file.content_type and not (
        file.content_type.startswith("image/")
        or file.content_type == "application/octet-stream"
    ):
        raise HTTPException(status_code=415, detail="Please upload an image file.")

    contents = await file.read(MAX_IMAGE_BYTES + 1)
    if not contents:
        raise HTTPException(status_code=400, detail="The uploaded image is empty.")
    if len(contents) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image must be smaller than 10 MB.")

    try:
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except (UnidentifiedImageError, OSError) as exc:
        raise HTTPException(status_code=400, detail="The image could not be decoded.") from exc

    image_np = np.asarray(image)
    try:
        detection = _best_cat_detection(image_np)
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail="The vision model is temporarily unavailable. Please try again.",
        ) from exc

    if detection is None:
        return {
            "cat_detected": False,
            "detection_confidence": 0.0,
            "bbox": None,
            "image_width": image.width,
            "image_height": image.height,
            "prediction": None,
            "advisory": ADVISORY,
        }

    cat_crop = _crop(image, detection["bbox"])
    try:
        prediction = classify_state(cat_crop)
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail="The behavior model is temporarily unavailable. Please try again.",
        ) from exc

    return {
        "cat_detected": True,
        "detection_confidence": round(detection["confidence"], 6),
        "bbox": detection["bbox"],
        "image_width": image.width,
        "image_height": image.height,
        "prediction": prediction,
        "advisory": ADVISORY,
    }


@router.post("/classify-cat-frame")
async def classify_cat_frame(file: UploadFile = File(...)):
    """Classify a browser-cropped cat without running a second detector."""
    if file.content_type and not (
        file.content_type.startswith("image/")
        or file.content_type == "application/octet-stream"
    ):
        raise HTTPException(status_code=415, detail="Please upload an image file.")

    contents = await file.read(MAX_IMAGE_BYTES + 1)
    if not contents:
        raise HTTPException(status_code=400, detail="The camera frame is empty.")
    if len(contents) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image must be smaller than 10 MB.")

    try:
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except (UnidentifiedImageError, OSError) as exc:
        raise HTTPException(
            status_code=400,
            detail="The camera frame could not be decoded.",
        ) from exc

    try:
        prediction = classify_state(image)
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail="The behavior model is still loading. Please try again in a moment.",
        ) from exc

    return {
        "cat_detected": True,
        "detection_confidence": 1.0,
        "bbox": None,
        "image_width": image.width,
        "image_height": image.height,
        "prediction": prediction,
        "advisory": ADVISORY,
    }
