import os
import time
import requests
from pathlib import Path
from duckduckgo_search import DDGS

CLASSES = {
    "relaxed": [
        "relaxed cat lying down",
        "calm relaxed cat resting",
    ],
    "alert_cautious": [
        "alert cautious cat standing",
        "cat alert ears forward staring",
    ],
    "playful_active": [
        "playful cat jumping",
        "active playful kitten",
    ],
    "defensive_stressed": [
        "scared cat arched back",
        "angry defensive cat ears back",
    ],
    "attention_seeking": [
        "cat asking for attention",
        "cat meowing at owner",
    ],
}

BASE_DIR = Path("dataset/raw")
IMAGES_PER_QUERY = 30


def download_image(url, path):
    try:
        r = requests.get(url, timeout=10)
        if r.status_code == 200:
            path.write_bytes(r.content)
            return True
    except Exception:
        return False
    return False


def main():
    BASE_DIR.mkdir(parents=True, exist_ok=True)

    with DDGS() as ddgs:
        for label, queries in CLASSES.items():
            label_dir = BASE_DIR / label
            label_dir.mkdir(parents=True, exist_ok=True)

            count = 0

            for query in queries:
                print(f"Searching: {query}")

                try:
                    results = ddgs.images(
                        query,
                        max_results=IMAGES_PER_QUERY,
                        safesearch="moderate",
                    )
                except Exception as e:
                    print(f"Search failed for '{query}': {e}")
                    time.sleep(10)
                    continue

                for item in results:
                    url = item.get("image")
                    if not url:
                        continue

                    filename = f"{label}_{count}.jpg"
                    path = label_dir / filename

                    if download_image(url, path):
                        print(f"Saved: {path}")
                        count += 1

                    time.sleep(1.5)

            print(f"{label}: downloaded {count} images")


if __name__ == "__main__":
    main()