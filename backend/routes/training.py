from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import TrainingSample
from schemas import TrainingSampleCreate

router = APIRouter()


@router.post("/training-sample")
def create_training_sample(
    sample: TrainingSampleCreate,
    db: Session = Depends(get_db),
):
    item = TrainingSample(**sample.model_dump())

    db.add(item)
    db.commit()
    db.refresh(item)

    return {
        "success": True,
        "id": item.id,
    }


@router.get("/training-samples")
def get_training_samples(db: Session = Depends(get_db)):
    return db.query(TrainingSample).all()