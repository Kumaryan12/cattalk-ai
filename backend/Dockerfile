FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/home/cattalk/.cache/huggingface

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

RUN chown -R cattalk:cattalk /app /home/cattalk
USER cattalk

EXPOSE 7860

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
