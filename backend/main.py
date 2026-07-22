import asyncio
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.analysis import get_classifier, router as analysis_router

classifier_ready = False


@asynccontextmanager
async def lifespan(_app: FastAPI):
    global classifier_ready
    # Load CLIP once during backend startup so a cat does not have to remain in
    # front of the camera while the model initializes on the first request.
    try:
        await asyncio.to_thread(get_classifier)
        classifier_ready = True
    except Exception:
        # Keep health/debug endpoints available; the analysis route returns a
        # user-facing retry message if the model is unavailable.
        classifier_ready = False
    yield


app = FastAPI(
    title="CatTalk AI API",
    version="2.0.0",
    description="Private, ephemeral cat detection and behavioral-state estimates.",
    lifespan=lifespan,
)

configured_origins = os.getenv("CATTALK_CORS_ORIGINS", "*")
allowed_origins = [origin.strip() for origin in configured_origins.split(",")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

app.include_router(analysis_router)


@app.get("/")
def root():
    return {
        "name": "CatTalk AI API",
        "version": "2.0.0",
        "privacy": "Images are processed in memory and are not retained.",
    }


@app.get("/health")
def health():
    return {"status": "ok", "model_ready": classifier_ready}
