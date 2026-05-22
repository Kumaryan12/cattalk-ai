from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from transformers import pipeline
import io
from routes.export import router as export_router
from database import Base, engine
from routes.vision_features import router as vision_features_router
from routes.training import router as training_router
from routes.feedback import router as feedback_router
from routes.upload import router as upload_router
Base.metadata.create_all(bind=engine)

app = FastAPI(title="CatTalk AI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

classifier = pipeline(
    task="zero-shot-image-classification",
    model="openai/clip-vit-base-patch32",
)

LABELS = [
    "a relaxed calm cat",
    "a curious exploratory cat",
    "a playful active cat",
    "a stressed anxious cat",
    "a defensive aggressive cat",
    "an attention seeking cat",
]

app.include_router(training_router)
app.include_router(feedback_router)
app.include_router(export_router)
app.include_router(upload_router)
app.include_router(vision_features_router)
@app.get("/")
def root():
    return {"message": "CatTalk AI backend is running"}


@app.post("/predict-cat-state")
async def predict_cat_state(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    results = classifier(image, candidate_labels=LABELS)

    scores = {
        item["label"]: float(item["score"])
        for item in results
    }

    best = results[0]

    return {
        "predicted_label": best["label"],
        "confidence": float(best["score"]),
        "scores": scores,
        "warning": "This is a weak zero-shot behavioral estimate, not a confirmed cat emotion.",
    }