import io
import os
import uuid
from typing import Dict

import cv2
import numpy as np
from fastapi import APIRouter, File, UploadFile
from PIL import Image
from ultralytics import YOLO

router = APIRouter()

UPLOAD_DIR = "uploads"
CROP_DIR = "uploads/crops"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(CROP_DIR, exist_ok=True)

# YOLOv8 nano. It will download weights first time.
yolo_model = YOLO("yolov8n.pt")


def clamp(value, low, high):
    return max(low, min(value, high))


def detect_and_crop_cat(image_np: np.ndarray):
    results = yolo_model(image_np, verbose=False)

    best_cat = None

    # COCO class id for cat is 15
    cat_class_id = 15

    for result in results:
        boxes = result.boxes
        if boxes is None:
            continue

        for box in boxes:
            cls_id = int(box.cls[0].item())
            confidence = float(box.conf[0].item())

            if cls_id != cat_class_id:
                continue

            x1, y1, x2, y2 = box.xyxy[0].tolist()

            area = (x2 - x1) * (y2 - y1)

            candidate = {
                "bbox": [x1, y1, x2, y2],
                "confidence": confidence,
                "area": area,
            }

            if best_cat is None or candidate["area"] > best_cat["area"]:
                best_cat = candidate

    if best_cat is None:
        return None, None

    height, width = image_np.shape[:2]

    x1, y1, x2, y2 = best_cat["bbox"]

    x1 = int(clamp(x1, 0, width - 1))
    y1 = int(clamp(y1, 0, height - 1))
    x2 = int(clamp(x2, 0, width - 1))
    y2 = int(clamp(y2, 0, height - 1))

    crop = image_np[y1:y2, x1:x2]

    best_cat["bbox"] = [x1, y1, x2, y2]

    return best_cat, crop


def extract_basic_visual_features(crop: np.ndarray) -> Dict[str, float]:
    """
    Feature extractor v1.

    This is intentionally conservative. It gives placeholder/heuristic scores
    until we replace each feature with trained models.

    Output values are 0.0 to 1.0.
    """
    if crop is None or crop.size == 0:
        return {
            "ear_back": 0.0,
            "tail_puffed": 0.0,
            "crouched": 0.0,
            "eyes_wide": 0.0,
            "body_tense": 0.0,
            "arched_back": 0.0,
        }

    h, w = crop.shape[:2]
    aspect_ratio = w / max(h, 1)

    gray = cv2.cvtColor(crop, cv2.COLOR_RGB2GRAY)

    edges = cv2.Canny(gray, 80, 160)
    edge_density = float(np.sum(edges > 0)) / float(edges.size)

    # Heuristic features:
    # These are NOT final scientific features. They are a structured scaffold.
    crouched = clamp((aspect_ratio - 1.0) / 1.2, 0.0, 1.0)
    body_tense = clamp(edge_density * 8.0, 0.0, 1.0)
    arched_back = clamp((edge_density * 5.0) + (0.2 if aspect_ratio > 1.1 else 0), 0.0, 1.0)

    return {
        "ear_back": 0.35,
        "tail_puffed": 0.20,
        "crouched": round(crouched, 3),
        "eyes_wide": 0.45,
        "body_tense": round(body_tense, 3),
        "arched_back": round(arched_back, 3),
    }


def predict_mood_from_features(features: Dict[str, float]):
    scores = {
        "relaxed": 0.0,
        "exploratory_social": 0.0,
        "alert_cautious": 0.0,
        "playful_active": 0.0,
        "defensive_stressed": 0.0,
        "attention_seeking": 0.0,
    }

    reasons = []

    if features["body_tense"] < 0.35 and features["crouched"] < 0.35:
        scores["relaxed"] += 1.5
        reasons.append("Low body tension and low crouch score increased relaxed score.")

    if features["eyes_wide"] > 0.4:
        scores["alert_cautious"] += 1.0
        reasons.append("Eye alertness increased alert/cautious score.")

    if features["crouched"] > 0.45:
        scores["alert_cautious"] += 1.2
        scores["defensive_stressed"] += 0.8
        reasons.append("Crouched body increased alert/cautious and defensive/stressed scores.")

    if features["body_tense"] > 0.55:
        scores["alert_cautious"] += 1.2
        scores["defensive_stressed"] += 1.0
        reasons.append("Body tension increased alert/cautious and defensive/stressed scores.")

    if features["arched_back"] > 0.55:
        scores["alert_cautious"] += 1.0
        scores["defensive_stressed"] += 0.8
        reasons.append("Arched-back estimate increased alert/cautious and defensive/stressed scores.")

    if features["tail_puffed"] > 0.6 or features["ear_back"] > 0.7:
        scores["defensive_stressed"] += 2.0
        reasons.append("Strong defensive cue increased defensive/stressed score.")

    total = sum(scores.values())

    if total == 0:
        return {
            "predicted_state": "unknown",
            "confidence": 0.0,
            "scores": scores,
            "reasoning": ["Not enough feature evidence was available."],
        }

    normalized = {
        key: value / total
        for key, value in scores.items()
    }

    predicted_state = max(normalized, key=normalized.get)

    return {
        "predicted_state": predicted_state,
        "confidence": normalized[predicted_state],
        "scores": normalized,
        "reasoning": reasons,
    }


@router.post("/vision-feature-prediction")
async def vision_feature_prediction(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)

    original_filename = file.filename or "cat.jpg"
    extension = os.path.splitext(original_filename)[1] or ".jpg"

    image_name = f"{uuid.uuid4()}{extension}"
    image_path = os.path.join(UPLOAD_DIR, image_name)
    image.save(image_path)

    cat_detection, crop = detect_and_crop_cat(image_np)

    if cat_detection is None:
        return {
            "cat_detected": False,
            "image_path": image_path,
            "crop_path": None,
            "bbox": None,
            "cat_confidence": 0.0,
            "features": None,
            "prediction": {
                "predicted_state": "unknown",
                "confidence": 0.0,
                "scores": {},
                "reasoning": ["No cat was detected by YOLO."],
            },
        }

    crop_name = f"{uuid.uuid4()}_crop.jpg"
    crop_path = os.path.join(CROP_DIR, crop_name)

    crop_pil = Image.fromarray(crop)
    crop_pil.save(crop_path)

    features = extract_basic_visual_features(crop)
    prediction = predict_mood_from_features(features)

    return {
        "cat_detected": True,
        "image_path": image_path,
        "crop_path": crop_path,
        "bbox": cat_detection["bbox"],
        "cat_confidence": cat_detection["confidence"],
        "features": features,
        "prediction": prediction,
    }