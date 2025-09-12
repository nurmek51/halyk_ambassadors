from rest_framework import serializers
from .models import User
from shared.validators import validate_kazakhstan_phone
from shared.address_service import KazakhstanAddressService

class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.ReadOnlyField()
    address_display = serializers.ReadOnlyField(source='get_address_display')

    class Meta:
        model = User
        fields = [
            'id', 'phone_number', 'name', 'surname', 'position', 
            'address', 'full_name', 'address_display', 
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_phone_number(self, value):
        validate_kazakhstan_phone(value)
        return value

    def validate_address(self, value):
        """Validate address JSON structure"""
        required_fields = [
            'found', 'address', 'city', 'region', 
            'district', 'postcode', 'latitude', 'longitude', 'confidence'
        ]
        
        if not isinstance(value, dict):
            raise serializers.ValidationError("Address must be a JSON object")
        
        for field in required_fields:
            if field not in value:
                raise serializers.ValidationError(f"Address missing required field: {field}")
        
        return value

class UserCreateSerializer(serializers.ModelSerializer):
    address_query = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['phone_number', 'name', 'surname', 'position', 'address_query']

    def validate_phone_number(self, value):
        validate_kazakhstan_phone(value)
        return value

    def create(self, validated_data):
        address_query = validated_data.pop('address_query', None)
        
        if address_query:
            # Use address service to geocode and validate
            address_service = KazakhstanAddressService()
            address_data = address_service.validate_and_geocode_address(address_query)
            validated_data['address'] = address_data
        else:
            validated_data['address'] = {
                'found': False,
                'address': '',
                'city': '',
                'region': '',
                'district': '',
                'postcode': '',
                'latitude': None,
                'longitude': None,
                'confidence': 0
            }

        return User.objects.create(**validated_data)
