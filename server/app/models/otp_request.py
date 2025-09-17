from datetime import datetime, timedelta
from sqlalchemy import Column, String, Boolean, DateTime, Index
from sqlalchemy.ext.hybrid import hybrid_property
from .base import TimestampedMixin


class OTPRequest(TimestampedMixin):
    __tablename__ = "otp_requests"
    
    phone_number = Column(String(15), nullable=False)
    code = Column(String(6), nullable=False, default="1111")
    is_used = Column(Boolean, default=False, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        if not self.expires_at:
            self.expires_at = datetime.utcnow() + timedelta(minutes=5)
    
    # Computed properties
    @hybrid_property
    def is_expired(self) -> bool:
        return datetime.utcnow() > self.expires_at
    
    @hybrid_property
    def is_valid(self) -> bool:
        return not self.is_used and not self.is_expired
    
    # Indexes
    __table_args__ = (
        Index("idx_otp_requests_phone_used", "phone_number", "is_used"),
        Index("idx_otp_requests_expires_at", "expires_at"),
    )
