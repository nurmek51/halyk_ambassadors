from django.db import models
from shared.validators import kazakhstan_phone_validator
from shared.mixins import TimestampedMixin

class User(TimestampedMixin):
    """
    User model with Kazakhstan phone validation and address JSON field
    """
    phone_number = models.CharField(
        max_length=15,
        unique=True,
        validators=[kazakhstan_phone_validator],
        help_text="Kazakhstan phone number (+77xxxxxxxxx, 87xxxxxxxxx, or 7xxxxxxxxx)"
    )
    name = models.CharField(max_length=100)
    surname = models.CharField(max_length=100)
    position = models.CharField(max_length=150)
    
    # Address as JSON field matching the required schema
    address = models.JSONField(
        help_text="Address schema: {found, address, city, region, district, postcode, latitude, longitude, confidence}",
        default=dict
    )

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f"{self.name} {self.surname} ({self.phone_number})"

    @property
    def full_name(self):
        return f"{self.name} {self.surname}"

    def get_address_display(self):
        """Returns formatted address string"""
        if not self.address or not self.address.get('found'):
            return "Адрес не указан"
        return self.address.get('address', 'Адрес не найден')
