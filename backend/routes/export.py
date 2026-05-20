import csv
import io

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from database import get_db
from models import TrainingSample, InteractionFeedback

router = APIRouter()


@router.get("/export/training-samples.csv")
def export_training_samples(db: Session = Depends(get_db)):
    output = io.StringIO()
    writer = csv.writer(output)

    writer.writerow([
        "id",
        "image_path",
        "hf_predicted_label",
        "hf_confidence",
        "hf_scores_json",
        "fusion_state",
        "fusion_confidence",
        "fusion_scores_json",
        "reasoning_json",
        "corrected_state",
        "timestamp",
    ])

    rows = db.query(TrainingSample).all()

    for row in rows:
        writer.writerow([
            row.id,
            row.image_path,
            row.hf_predicted_label,
            row.hf_confidence,
            row.hf_scores_json,
            row.fusion_state,
            row.fusion_confidence,
            row.fusion_scores_json,
            row.reasoning_json,
            row.corrected_state,
            row.timestamp,
        ])

    output.seek(0)

    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=training_samples.csv"
        },
    )


@router.get("/export/interaction-feedback.csv")
def export_interaction_feedback(db: Session = Depends(get_db)):
    output = io.StringIO()
    writer = csv.writer(output)

    writer.writerow([
        "id",
        "state",
        "goal",
        "sound_used",
        "reaction",
        "outcome",
        "confidence",
        "timestamp",
    ])

    rows = db.query(InteractionFeedback).all()

    for row in rows:
        writer.writerow([
            row.id,
            row.state,
            row.goal,
            row.sound_used,
            row.reaction,
            row.outcome,
            row.confidence,
            row.timestamp,
        ])

    output.seek(0)

    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={
            "Content-Disposition": "attachment; filename=interaction_feedback.csv"
        },
    )