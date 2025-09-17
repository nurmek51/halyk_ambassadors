from sqlalchemy import Column, String, Text, Index, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property
from .base import UUIDTimestampedModel


class Application(UUIDTimestampedModel):
    __tablename__ = "applications"
    
    user_profile_id = Column(UUID(as_uuid=True), ForeignKey("user_profiles.id", ondelete="CASCADE"), nullable=False)
    address = Column(JSON, nullable=False)
    description = Column(Text, nullable=False)
    image_urls = Column(ARRAY(String), nullable=False, default=list)
    status = Column(String(20), default="pending", nullable=False)
    
    # Relationships
    user_profile = relationship("UserProfile", back_populates="applications", lazy="selectin")

    # Computed properties
    @hybrid_property
    def address_display(self) -> str:
        if self.address and isinstance(self.address, dict):
            return self.address.get("address", "Адрес не указан")
        return "Адрес не указан"
    
    @hybrid_property
    def image_count(self) -> int:
        return len(self.image_urls) if self.image_urls else 0
    
    # Indexes
    __table_args__ = (
        Index("idx_applications_user_profile_id", "user_profile_id"),
        Index("idx_applications_status", "status"),
        Index("idx_applications_created_at", "created_at"),
    )
