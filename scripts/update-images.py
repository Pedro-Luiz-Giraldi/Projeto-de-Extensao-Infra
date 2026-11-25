#!/usr/bin/env python3
import json
import os
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin
from urllib.request import Request, urlopen

NAMESPACE = "pedrogiraldi"
REPOSITORIES = ("sax-alertas", "sax-ia", "sax-front", "sax-back", "sax-db")
API_URL = f"https://hub.docker.com/v2/repositories/{NAMESPACE}/{{repository}}/tags?page_size=100"
OUTPUT_PATH = Path(__file__).resolve().parents[1] / "iac" / "Ansible" / "images.yml"
REQUEST_TIMEOUT = 30


def fetch_json(url):
    request = Request(
        url,
        headers={
            "Accept": "application/json",
            "User-Agent": "sax-images-updater",
        },
    )
    try:
        with urlopen(request, timeout=REQUEST_TIMEOUT) as response:
            return json.load(response)
    except (HTTPError, URLError, TimeoutError, ValueError) as error:
        raise RuntimeError(f"failed to fetch {url}: {error}") from error


def parse_timestamp(value):
    if not value:
        return None
    try:
        timestamp = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    if timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)
    return timestamp


def get_latest_tag(repository):
    url = API_URL.format(repository=repository)
    seen_urls = set()
    latest = None

    while url:
        if url in seen_urls:
            raise RuntimeError(f"pagination loop detected for {repository}")
        seen_urls.add(url)

        payload = fetch_json(url)
        results = payload.get("results")
        if not isinstance(results, list):
            raise RuntimeError(f"unexpected API response for {repository} at {url}")

        for tag in results:
            if tag.get("tag_status", "active") != "active":
                continue

            name = tag.get("name")
            timestamp = parse_timestamp(
                tag.get("tag_last_pushed") or tag.get("last_updated")
            )
            if not name or timestamp is None:
                continue

            if latest is None or timestamp > latest[0]:
                latest = (timestamp, name)

        next_url = payload.get("next")
        url = urljoin(url, next_url) if next_url else None

    if latest is None:
        raise RuntimeError(f"no active tags with a push date found for {repository}")

    return latest[1]


def write_images(images):
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    content = "images:\n" + "".join(
        f"  {repository}: {image}\n" for repository, image in images.items()
    )

    with tempfile.NamedTemporaryFile(
        "w",
        encoding="utf-8",
        dir=OUTPUT_PATH.parent,
        prefix=".images.yml.",
        delete=False,
    ) as temporary_file:
        temporary_file.write(content)
        temporary_path = Path(temporary_file.name)

    os.replace(temporary_path, OUTPUT_PATH)


def main():
    images = {}
    for repository in REPOSITORIES:
        tag = get_latest_tag(repository)
        images[repository] = f"{NAMESPACE}/{repository}:{tag}"
        print(f"{repository}: {images[repository]}")

    write_images(images)
    print(f"wrote {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
