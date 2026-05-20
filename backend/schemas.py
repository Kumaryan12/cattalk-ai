from typing import Optional

from pydantic import BaseModel


class TrainingSampleCreate(BaseModel):
    image_path: Optional[str] = None

    hf_predicted_label: Optional[str] = None
    hf_confidence: Optional[float] = None
    hf_scores_json: Optional[str] = None

    fusion_state: str
    fusion_confidence: float
    fusion_scores_json: Optional[str] = None

    reasoning_json: Optional[str] = None
    corrected_state: str

    timestamp: str


class InteractionFeedbackCreate(BaseModel):
    state: str
    goal: str
    sound_used: str
    reaction: str
    outcome: str
    confidence: float
    timestamp: str