from django.db import models
from django.contrib.postgres.fields import ArrayField
from shared.mixins import TimestampedMixin

class Application(TimestampedMixin):
    """
    Application model with address JSON field and image URLs array
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    # Address as JSON field matching the required schema
    address = models.JSONField(
        help_text="Address schema: {found, address, city, region, district, postcode, latitude, longitude, confidence}",
        default=dict
    )
    
    description = models.TextField()
    
    # Array field for multiple image URLs
    image_urls = ArrayField(
        models.URLField(max_length=500),
        blank=True,
        default=list,
        help_text="Array of image URLs"
    )
    
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )

    class Meta:
        db_table = 'applications'
        verbose_name = 'Application'
        verbose_name_plural = 'Applications'
        ordering = ['-created_at']

    def __str__(self):
        address_display = self.get_address_display()
        return f"Application #{self.id} - {address_display} ({self.status})"

    def get_address_display(self):
        """Returns formatted address string"""
        if not self.address or not self.address.get('found'):
            return "Адрес не указан"
        return self.address.get('address', 'Адрес не найден')

    @property
    def image_count(self):
        return len(self.image_urls) if self.image_urls else 0
