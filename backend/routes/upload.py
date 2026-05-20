import os
import uuid

from fastapi import APIRouter, File, UploadFile

router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    extension = os.path.splitext(file.filename or "")[1]

    if extension == "":
        extension = ".jpg"

    file_name = f"{uuid.uuid4()}{extension}"
    file_path = os.path.join(UPLOAD_DIR, file_name)

    contents = await file.read()

    with open(file_path, "wb") as f:
        f.write(contents)

    return {
        "success": True,
        "image_path": file_path,
    }