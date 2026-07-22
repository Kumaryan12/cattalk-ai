# CatTalk

CatTalk is a privacy-first Flutter web app that helps a person interpret broad,
visible cat behavior and choose a gentle interaction. It is an assistive visual
estimate—not an emotion detector, veterinary tool, or diagnosis.

## Product flow

1. Share a clear photo or use live camera detection.
2. Receive a cautious behavioral-state estimate with visible confidence.
3. Choose an interaction goal.
4. Follow a state-aware plan and optionally play one bundled sound.

Images submitted to the API are processed in memory and are not retained. The
app has no account, feedback collection, behavioral history, or training-data
capture.

## Run locally

### Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Backend startup loads the CLIP model before reporting that live analysis is
ready. The web app waits for that readiness signal before requesting camera
access, so a cat never has to remain in frame while the model initializes.

For production, set `CATTALK_CORS_ORIGINS` to a comma-separated list of the
allowed frontend origins. It defaults to `*` for local development.

### Web app

```bash
flutter pub get
flutter run -d chrome --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8000
```

The included build is personalized for Mrunali's birthday. You can override
the recipient or occasion without editing code:

```bash
flutter run -d chrome \
  --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8000 \
  --dart-define=RECIPIENT_NAME="Your friend's name" \
  --dart-define=GIFT_OCCASION="Happy Birthday"
```

For a deployed frontend, set `BACKEND_BASE_URL` to the deployed API origin at
build time.

## Production

- Web app: https://cattalk-for-mrunali.vercel.app
- API: https://cattalk-ai-api-production-bd7f.up.railway.app

The production Flutter bundle is built with the Railway API URL through
`BACKEND_BASE_URL`. The backend uses a CPU-only TinyCLIP model with cached text
embeddings to keep warm classifications fast.

## Checks

```bash
flutter analyze
flutter test
flutter build web
```
