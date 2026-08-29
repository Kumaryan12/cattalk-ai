FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/home/cattalk/.cache/huggingface \
    CATTALK_CLASSIFIER_MODEL=wkcn/TinyCLIP-ViT-8M-16-Text-3M-YFCC15M

RUN apt-get update && \
    apt-get install --yes --no-install-recommends libgl1 libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --uid 1000 cattalk

WORKDIR /app

COPY requirements.txt ./requirements.txt
RUN pip install --upgrade pip && \
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu && \
    pip install -r requirements.txt

COPY main.py ./main.py
COPY routes ./routes

# Keep model downloads out of the request path. Both weights are the same
# ones used by the application; packaging them only makes new instances start
# reliably when the upstream model hosts are slow or unavailable.
RUN python -c "from transformers import CLIPModel, CLIPProcessor; model='wkcn/TinyCLIP-ViT-8M-16-Text-3M-YFCC15M'; CLIPProcessor.from_pretrained(model, use_fast=True); CLIPModel.from_pretrained(model)" && \
    python -c "from ultralytics import YOLO; YOLO('yolov8n.pt')"

RUN chown -R cattalk:cattalk /app /home/cattalk
USER cattalk

EXPOSE 7860

# Railway and Hugging Face can continue using 7860. Cloud Run injects PORT.
CMD ["sh", "-c", "exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-7860}"]
