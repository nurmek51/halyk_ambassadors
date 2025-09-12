import requests
import json
import time

class KazakhstanAddressValidator:
    """
    Бесплатный валидатор адресов Казахстана для MVP проектов
    Использует OpenStreetMap Nominatim API
    Не требует регистрации и API ключей
    """
    
    def __init__(self):
        self.base_url = 'https://nominatim.openstreetmap.org/'
        self.headers = {
            'User-Agent': 'KazakhstanAddressValidator/1.0'
        }
        
    def search_address(self, query, max_results=5):
        """
        Поиск адреса в Казахстане
        
        Args:
            query (str): Поисковый запрос (город, улица, адрес)
            max_results (int): Максимальное количество результатов
            
        Returns:
            dict: Результат поиска с информацией об адресе
        """
        params = {
            'q': query,
            'countrycodes': 'kz',  # Только Казахстан
            'format': 'json',
            'limit': max_results,
            'addressdetails': 1,
            'accept-language': 'ru,kk,en'
        }
        
        try:
            # Соблюдаем лимит 1 запрос в секунду
            time.sleep(1)
            
            response = requests.get(
                f"{self.base_url}search", 
                params=params, 
                headers=self.headers, 
                timeout=10
            )
            
            if response.status_code == 200:
                results = response.json()
                
                if results:
                    location = results[0]  # Берем первый результат из списка
                    address = location.get('address', {})
                    
                    return {
                        'found': True,
                        'address': location.get('display_name', ''),
                        'city': address.get('city', address.get('town', address.get('village', ''))),
                        'region': address.get('state', ''),
                        'district': address.get('county', ''),
                        'postcode': address.get('postcode', ''),
                        'latitude': float(location.get('lat', 0)),
                        'longitude': float(location.get('lon', 0)),
                        'confidence': location.get('importance', 0)
                    }
                else:
                    return {'found': False, 'error': 'Адрес не найден'}
                    
            else:
                return {'found': False, 'error': f'HTTP {response.status_code}'}
                
        except Exception as e:
            return {'found': False, 'error': str(e)}
    
    def validate_address(self, address):
        """
        Проверяет существует ли адрес
        
        Args:
            address (str): Адрес для проверки
            
        Returns:
            bool: True если адрес найден, False если нет
        """
        result = self.search_address(address)
        return result.get('found', False)
    
    def get_coordinates(self, address):
        """
        Получает координаты адреса
        
        Args:
            address (str): Адрес
            
        Returns:
            tuple: (latitude, longitude) или (None, None) если не найден
        """
        result = self.search_address(address)
        if result.get('found'):
            return result['latitude'], result['longitude']
        return None, None

# Пример использования
if __name__ == "__main__":
    validator = KazakhstanAddressValidator()
    
    # Тестовые адреса
    test_addresses = [
        "Алматы",
        "улица Абая Алматы", 
        "Астана, улица Лепсы 42/1",
        "Шымкент",
        "несуществующий город"
    ]
    
    for address in test_addresses:
        print(f"\nТестируем: {address}")
        print("-" * 40)
        
        result = validator.search_address(address)
        
        if result['found']:
            print(f"✅ НАЙДЕН: {result['address']}")
            print(f"🏙️ Город: {result['city']}")
            print(f"🏛️ Область: {result['region']}")
            print(f"🌐 Координаты: {result['latitude']:.4f}, {result['longitude']:.4f}")
            print(f"📮 Индекс: {result['postcode']}")
        else:
            print(f"❌ НЕ НАЙДЕН: {result['error']}")

# Создаем валидатор
validator = KazakhstanAddressValidator()

# Проверяем адрес
address = "Алматы проспект Абая"
result = validator.search_address(address)

if result['found']:
    print(f"Адрес найден: {result['address']}")
    print(f"Координаты: {result['latitude']}, {result['longitude']}")
else:
    print(f"Адрес не найден: {result['error']}")

# Простая проверка существования
is_valid = validator.validate_address("Астана")
print(f"Астана существует: {is_valid}")

# Получение координат
lat, lon = validator.get_coordinates("Шымкент")
print(f"Координаты Шымкента: {lat}, {lon}")
