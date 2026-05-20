from sqlalchemy import Column, Float, Integer, String, Text

from database import Base


class TrainingSample(Base):
    __tablename__ = "training_samples"

    id = Column(Integer, primary_key=True, index=True)
    image_path = Column(String, nullable=True)

    hf_predicted_label = Column(String, nullable=True)
    hf_confidence = Column(Float, nullable=True)
    hf_scores_json = Column(Text, nullable=True)

    fusion_state = Column(String, nullable=False)
    fusion_confidence = Column(Float, nullable=False)
    fusion_scores_json = Column(Text, nullable=True)

    reasoning_json = Column(Text, nullable=True)
    corrected_state = Column(String, nullable=False)

    timestamp = Column(String, nullable=False)


class InteractionFeedback(Base):
    __tablename__ = "interaction_feedback"

    id = Column(Integer, primary_key=True, index=True)

    state = Column(String, nullable=False)
    goal = Column(String, nullable=False)
    sound_used = Column(String, nullable=False)
    reaction = Column(String, nullable=False)
    outcome = Column(String, nullable=False)
    confidence = Column(Float, nullable=False)

    timestamp = Column(String, nullable=False)