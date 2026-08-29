# Deploy the CatTalk API to Google Cloud Run

Cloud Run runs the existing Docker image and the exact YOLOv8n and TinyCLIP
models used on Railway. The suggested settings are 2 vCPU, 2 GiB RAM, one
concurrent request per instance, and scale-to-zero when idle.

## One-time deployment

1. Create or select a Google Cloud project and attach a billing account.
2. Open Google Cloud Shell from the Google Cloud console.
3. Clone this repository and switch to the branch containing the current app.
4. From the repository's `backend` directory, run:

```bash
gcloud run deploy cattalk-ai-api \
  --source . \
  --region asia-south1 \
  --allow-unauthenticated \
  --cpu 2 \
  --memory 2Gi \
  --concurrency 1 \
  --min-instances 0 \
  --max-instances 1 \
  --timeout 180 \
  --set-env-vars CATTALK_TORCH_THREADS=2 \
  --set-env-vars CATTALK_CORS_ORIGINS=https://cattalk-for-mrunali.vercel.app
```

Accept the prompts to enable the Cloud Run, Cloud Build, and Artifact Registry
APIs. The command prints an HTTPS service URL when deployment succeeds.

## Verify the API

Replace `SERVICE_URL` with the URL printed by Cloud Run:

```bash
curl -f https://SERVICE_URL/health
```

The expected response is:

```json
{"status":"ok","model_ready":true}
```

## Point the web app to Cloud Run

In the Vercel project, replace `BACKEND_BASE_URL` with the Cloud Run service
URL and redeploy the production site. If Vercel's build command does not
already pass the variable to Flutter, use:

```bash
flutter build web --release \
  --dart-define=BACKEND_BASE_URL=$BACKEND_BASE_URL
```

Finally, perform one photo scan and one live-camera scan. The first visit after
an idle period can take longer because `--min-instances 0` allows Cloud Run to
scale to zero. Set the minimum to 1 only if avoiding cold starts is worth the
ongoing charge:

```bash
gcloud run services update cattalk-ai-api \
  --region asia-south1 \
  --min-instances 1
```
