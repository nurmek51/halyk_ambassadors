from sqlalchemy import Column, String, Boolean, Index
from sqlalchemy.orm import relationship
from .base import UUIDTimestampedModel


class Account(UUIDTimestampedModel):
    __tablename__ = "accounts"
    
    phone_number = Column(String(15), unique=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    
    # Relationships
    profile = relationship("UserProfile", back_populates="account", uselist=False, cascade="all, delete-orphan", lazy="selectin")
    
    # Indexes
    __table_args__ = (
        Index("idx_accounts_phone_number", "phone_number"),
        Index("idx_accounts_is_verified", "is_verified"),
    )
