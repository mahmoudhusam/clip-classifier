"""
classify_images.py — Batch image classifier using CLIP
Usage: python classify_images.py --folder ./images --labels "people" "cars" "text/screenshot" "nature" "food"
"""

import argparse
import os
import json
from pathlib import Path
from collections import defaultdict

from PIL import Image
from transformers import pipeline

# ── Supported image extensions ──────────────────────────────────────────────
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif", ".tiff"}


def load_images_from_folder(folder: str) -> list[tuple[str, Image.Image]]:
    """Walk a folder and return (filename, PIL Image) pairs."""
    folder_path = Path(folder)
    if not folder_path.exists():
        raise FileNotFoundError(f"Folder not found: {folder}")

    images = []
    for file in sorted(folder_path.iterdir()):
        if file.suffix.lower() in IMAGE_EXTENSIONS:
            try:
                img = Image.open(file).convert("RGB")
                images.append((file.name, img))
            except Exception as e:
                print(f"  ⚠  Skipping {file.name}: {e}")

    return images


def classify_images(
    images: list[tuple[str, Image.Image]],
    labels: list[str],
    model_name: str = "openai/clip-vit-base-patch32",
    batch_size: int = 8,
) -> list[dict]:
    """Run CLIP zero-shot classification on a list of images."""

    print(f"\n🤖  Loading CLIP model: {model_name}")
    print("    (First run downloads ~350MB — subsequent runs use cache)\n")

    classifier = pipeline(
        task="zero-shot-image-classification",
        model=model_name,
    )

    results = []
    total = len(images)

    for i in range(0, total, batch_size):
        batch = images[i : i + batch_size]
        batch_names = [name for name, _ in batch]
        batch_imgs  = [img  for _, img  in batch]

        print(f"  Processing {i+1}–{min(i+batch_size, total)} / {total} ...", end="\r")

        # Run classification — returns list of [{label, score}, ...] per image
        outputs = classifier(batch_imgs, candidate_labels=labels)

        for name, scores in zip(batch_names, outputs):
            top = max(scores, key=lambda x: x["score"])
            results.append(
                {
                    "file": name,
                    "top_label": top["label"],
                    "top_score": round(top["score"] * 100, 1),
                    "all_scores": {
                        item["label"]: round(item["score"] * 100, 1)
                        for item in scores
                    },
                }
            )

    print()  # newline after \r
    return results


def group_by_label(results: list[dict]) -> dict[str, list]:
    """Group filenames by their top predicted label."""
    groups = defaultdict(list)
    for r in results:
        groups[r["top_label"]].append(r["file"])
    return dict(groups)


def print_summary(results: list[dict], groups: dict):
    """Print a readable summary to the terminal."""
    print("\n" + "─" * 60)
    print("  RESULTS BY CATEGORY")
    print("─" * 60)

    for label, files in sorted(groups.items()):
        print(f"\n📂  {label.upper()}  ({len(files)} image{'s' if len(files) != 1 else ''})")
        for f in files:
            score = next(r["top_score"] for r in results if r["file"] == f)
            print(f"      {f:<40} {score}%")

    print("\n" + "─" * 60)
    print(f"  Total images classified: {len(results)}")
    print("─" * 60 + "\n")


def save_results(results: list[dict], groups: dict, output_path: str):
    """Save full results and grouped summary to a JSON file."""
    payload = {
        "summary": {label: files for label, files in groups.items()},
        "details": results,
    }
    with open(output_path, "w") as f:
        json.dump(payload, f, indent=2)
    print(f"💾  Results saved to: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Classify images locally using CLIP.")
    parser.add_argument(
        "--folder", "-f",
        required=True,
        help="Path to folder containing images",
    )
    parser.add_argument(
        "--labels", "-l",
        nargs="+",
        default=["people", "cars", "text or screenshot", "nature", "food", "animals"],
        help='Labels to classify against, e.g. --labels "people" "cars" "text or screenshot"',
    )
    parser.add_argument(
        "--model", "-m",
        default="openai/clip-vit-base-patch32",
        choices=[
            "openai/clip-vit-base-patch32",   # fastest, ~350MB
            "openai/clip-vit-base-patch16",   # more accurate, ~350MB
            "openai/clip-vit-large-patch14",  # most accurate, ~890MB
        ],
        help="Which CLIP model variant to use",
    )
    parser.add_argument(
        "--output", "-o",
        default="results.json",
        help="Path to save the JSON results file",
    )
    parser.add_argument(
        "--threshold", "-t",
        type=float,
        default=0.0,
        help="Only show results where top score > threshold (0–100)",
    )
    args = parser.parse_args()

    # ── Validate labels ──────────────────────────────────────────────────────
    if len(args.labels) < 2:
        print("❌  Please provide at least 2 labels.")
        return

    print("\n🔎  Image Classifier — CLIP")
    print(f"    Folder : {args.folder}")
    print(f"    Labels : {args.labels}")
    print(f"    Model  : {args.model}\n")

    # ── Load images ──────────────────────────────────────────────────────────
    print("📁  Scanning folder for images...")
    images = load_images_from_folder(args.folder)

    if not images:
        print("❌  No supported images found in the folder.")
        return

    print(f"    Found {len(images)} image(s).\n")

    # ── Classify ─────────────────────────────────────────────────────────────
    results = classify_images(images, labels=args.labels, model_name=args.model)

    # ── Apply threshold filter ───────────────────────────────────────────────
    if args.threshold > 0:
        before = len(results)
        results = [r for r in results if r["top_score"] >= args.threshold]
        print(f"    Filtered to {len(results)} images with score ≥ {args.threshold}% (dropped {before - len(results)})")

    # ── Group & display ──────────────────────────────────────────────────────
    groups = group_by_label(results)
    print_summary(results, groups)

    # ── Save output ──────────────────────────────────────────────────────────
    save_results(results, groups, args.output)


if __name__ == "__main__":
    main()
