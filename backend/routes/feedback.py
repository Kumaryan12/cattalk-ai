from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import InteractionFeedback
from schemas import InteractionFeedbackCreate

router = APIRouter()


@router.post("/interaction-feedback")
def create_interaction_feedback(
    feedback: InteractionFeedbackCreate,
    db: Session = Depends(get_db),
):
    item = InteractionFeedback(**feedback.model_dump())

    db.add(item)
    db.commit()
    db.refresh(item)

    return {
        "success": True,
        "id": item.id,
    }


@router.get("/interaction-feedback")
def get_interaction_feedback(db: Session = Depends(get_db)):
    return db.query(InteractionFeedback).all()