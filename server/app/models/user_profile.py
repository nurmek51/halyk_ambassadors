from sqlalchemy import Column, String, Index, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property
from .base import UUIDTimestampedModel


class UserProfile(UUIDTimestampedModel):
    __tablename__ = "user_profiles"
    
    account_id = Column(UUID(as_uuid=True), ForeignKey("accounts.id", ondelete="CASCADE"), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    surname = Column(String(100), nullable=False)
    position = Column(String(150), nullable=False)
    address = Column(JSON, nullable=True)
    
    # Relationships
    account = relationship("Account", back_populates="profile", lazy="selectin")
    applications = relationship("Application", back_populates="user_profile", cascade="all, delete-orphan", lazy="selectin")
    
    # Computed properties
    @hybrid_property
    def full_name(self) -> str:
        return f"{self.name} {self.surname}"
    
    @hybrid_property
    def address_display(self) -> str:
        if self.address and isinstance(self.address, dict):
            return self.address.get("address", "Адрес не указан")
        return "Адрес не указан"
    
    # Indexes
    __table_args__ = (
        Index("idx_user_profiles_account_id", "account_id"),
    )
