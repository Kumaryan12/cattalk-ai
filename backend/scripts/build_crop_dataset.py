import os
import shutil
from pathlib import Path

import cv2
from ultralytics import YOLO

RAW_DIR = Path("dataset/raw")
CROPPED_DIR = Path("dataset/cropped")

MODEL = YOLO("yolov8n.pt")

CAT_CLASS_ID = 15


def crop_cat(image_path: Path):
    image = cv2.imread(str(image_path))

    if image is None:
        print(f"Could not read {image_path}")
        return None

    results = MODEL(image, verbose=False)

    best_box = None
    best_area = 0

    for result in results:
        if result.boxes is None:
            continue

        for box in result.boxes:
            cls_id = int(box.cls[0].item())
            conf = float(box.conf[0].item())

            if cls_id != CAT_CLASS_ID or conf < 0.35:
                continue

            x1, y1, x2, y2 = box.xyxy[0].tolist()
            area = (x2 - x1) * (y2 - y1)

            if area > best_area:
                best_area = area
                best_box = (int(x1), int(y1), int(x2), int(y2), conf)

    if best_box is None:
        print(f"No cat found: {image_path}")
        return None

    x1, y1, x2, y2, conf = best_box

    h, w = image.shape[:2]

    x1 = max(0, x1)
    y1 = max(0, y1)
    x2 = min(w, x2)
    y2 = min(h, y2)

    crop = image[y1:y2, x1:x2]

    return crop


def main():
    print("CatTalk AI dataset cropper")
    print("Put raw images inside:")
    print(RAW_DIR)
    print()

    label = input(
        "Enter label for this batch "
        "(relaxed / alert_cautious / playful_active / defensive_stressed / attention_seeking): "
    ).strip()

    output_dir = CROPPED_DIR / label

    if not output_dir.exists():
        raise ValueError(f"Invalid label folder: {output_dir}")

    image_paths = []
    for ext in ["*.jpg", "*.jpeg", "*.png", "*.webp"]:
        image_paths.extend(RAW_DIR.glob(ext))

    if not image_paths:
        print("No images found in dataset/raw")
        return

    print(f"Found {len(image_paths)} images")

    saved = 0

    for image_path in image_paths:
        crop = crop_cat(image_path)

        if crop is None:
            continue

        output_path = output_dir / f"{image_path.stem}_crop.jpg"

        cv2.imwrite(str(output_path), crop)
        saved += 1

        print(f"Saved: {output_path}")

    print()
    print(f"Done. Cropped {saved}/{len(image_paths)} images into {output_dir}")


if __name__ == "__main__":
    main()