import re
from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator

def validate_kazakhstan_phone(phone_number):
    """
    Validates Kazakhstan phone numbers.
    
    Formats supported:
    - +77xxxxxxxxx (international format)
    - 87xxxxxxxxx (national format)
    - 7xxxxxxxxx (without country code)
    
    Args:
        phone_number (str): Phone number to validate
        
    Raises:
        ValidationError: If phone number is invalid
    """
    # Remove all non-digit characters except +
    cleaned = re.sub(r'[^\d+]', '', phone_number)
    
    # Kazakhstan phone number patterns
    patterns = [
        r'^\+77\d{9}$',  # +77xxxxxxxxx
        r'^87\d{9}$',    # 87xxxxxxxxx  
        r'^7\d{9}$',     # 7xxxxxxxxx
    ]
    
    if not any(re.match(pattern, cleaned) for pattern in patterns):
        raise ValidationError(
            'Введите корректный номер телефона Казахстана '
            '(формат: +77xxxxxxxxx, 87xxxxxxxxx или 7xxxxxxxxx)'
        )

# Django validator for model fields
kazakhstan_phone_validator = RegexValidator(
    regex=r'^(\+77|87|7)\d{9}$',
    message='Введите корректный номер телефона Казахстана'
)
