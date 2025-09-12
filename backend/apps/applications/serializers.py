from rest_framework import serializers
from .models import Application
from shared.address_service import KazakhstanAddressService

class ApplicationSerializer(serializers.ModelSerializer):
    address_display = serializers.ReadOnlyField(source='get_address_display')
    image_count = serializers.ReadOnlyField()

    class Meta:
        model = Application
        fields = [
            'id', 'address', 'description', 'image_urls', 'status',
            'address_display', 'image_count', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

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

    def validate_image_urls(self, value):
        """Validate image URLs array"""
        if not isinstance(value, list):
            raise serializers.ValidationError("Image URLs must be an array")
        
        if len(value) > 10:  # Limit to 10 images
            raise serializers.ValidationError("Maximum 10 images allowed")
        
        return value

class ApplicationCreateSerializer(serializers.ModelSerializer):
    address_query = serializers.CharField(write_only=True, required=False)
    latitude = serializers.FloatField(write_only=True, required=False)
    longitude = serializers.FloatField(write_only=True, required=False)

    class Meta:
        model = Application
        fields = ['description', 'image_urls', 'address_query', 'latitude', 'longitude']

    def validate(self, data):
        # Must provide either address_query OR coordinates
        has_query = 'address_query' in data
        has_coords = 'latitude' in data and 'longitude' in data
        
        if not has_query and not has_coords:
            raise serializers.ValidationError(
                "Either address_query or latitude/longitude coordinates must be provided"
            )
        
        return data

    def create(self, validated_data):
        address_query = validated_data.pop('address_query', None)
        latitude = validated_data.pop('latitude', None)
        longitude = validated_data.pop('longitude', None)
        
        address_service = KazakhstanAddressService()
        
        if latitude and longitude:
            # Use reverse geocoding
            address_data = address_service.reverse_geocode_to_model_format(latitude, longitude)
        elif address_query:
            # Use forward geocoding
            address_data = address_service.validate_and_geocode_address(address_query)
        else:
            # Default empty address
            address_data = {
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

        validated_data['address'] = address_data
        return Application.objects.create(**validated_data)

class ApplicationStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Application
        fields = ['status']
