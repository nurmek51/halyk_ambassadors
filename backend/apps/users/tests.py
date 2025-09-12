from django.test import TestCase
from django.core.exceptions import ValidationError
from .models import User
from shared.validators import validate_kazakhstan_phone

class UserModelTest(TestCase):
    def test_valid_phone_numbers(self):
        """Test valid Kazakhstan phone numbers"""
        valid_phones = ['+77771234567', '87771234567', '77771234567']
        
        for phone in valid_phones:
            user = User(
                phone_number=phone,
                name='Test',
                surname='User',
                position='Developer'
            )
            user.full_clean()  # Should not raise ValidationError

    def test_invalid_phone_numbers(self):
        """Test invalid phone numbers"""
        invalid_phones = [
            '+1234567890',  # Wrong country code
            '123456789',    # Too short
            '+77771234567890',  # Too long
            'not_a_phone',  # Invalid format
        ]
        
        for phone in invalid_phones:
            with self.assertRaises(ValidationError):
                validate_kazakhstan_phone(phone)

    def test_user_str_method(self):
        """Test User string representation"""
        user = User(
            phone_number='+77771234567',
            name='Test',
            surname='User'
        )
        expected = 'Test User (+77771234567)'
        self.assertEqual(str(user), expected)

    def test_full_name_property(self):
        """Test full_name property"""
        user = User(name='Test', surname='User')
        self.assertEqual(user.full_name, 'Test User')

    def test_address_display_empty(self):
        """Test address display with empty address"""
        user = User(address={})
        self.assertEqual(user.get_address_display(), 'Адрес не указан')

    def test_address_display_found(self):
        """Test address display with valid address"""
        user = User(address={
            'found': True,
            'address': 'Алматы, ул. Абая 1'
        })
        self.assertEqual(user.get_address_display(), 'Алматы, ул. Абая 1')
