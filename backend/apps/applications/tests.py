from django.test import TestCase
from .models import Application

class ApplicationModelTest(TestCase):
    def test_application_str_method(self):
        """Test Application string representation"""
        application = Application(
            id=1,
            description='Test application',
            status='pending',
            address={'found': True, 'address': 'Test Address'}
        )
        expected = 'Application #1 - Test Address (pending)'
        self.assertEqual(str(application), expected)

    def test_image_count_property(self):
        """Test image_count property"""
        application = Application(
            image_urls=['http://example.com/1.jpg', 'http://example.com/2.jpg']
        )
        self.assertEqual(application.image_count, 2)

    def test_image_count_empty(self):
        """Test image_count property with empty list"""
        application = Application(image_urls=[])
        self.assertEqual(application.image_count, 0)

    def test_status_choices(self):
        """Test status field choices"""
        valid_statuses = ['pending', 'approved', 'rejected']
        
        for status in valid_statuses:
            application = Application(
                description='Test',
                status=status
            )
            application.full_clean()  # Should not raise ValidationError

    def test_address_display_empty(self):
        """Test address display with empty address"""
        application = Application(address={})
        self.assertEqual(application.get_address_display(), 'Адрес не указан')

    def test_address_display_found(self):
        """Test address display with valid address"""
        application = Application(address={
            'found': True,
            'address': 'Алматы, ул. Абая 1'
        })
        self.assertEqual(application.get_address_display(), 'Алматы, ул. Абая 1')
