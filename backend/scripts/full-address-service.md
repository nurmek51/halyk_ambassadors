# Полный сервис адресов Казахстана с геолокацией

## 🎯 Возможности

✅ **Геокодирование** - поиск координат по адресу  
✅ **Обратное геокодирование** - получение адреса по GPS координатам  
✅ **Автокомплит** - подсказки при вводе адреса  
✅ **Работа с геолокацией** - получение точного адреса устройства  
✅ **Валидация координат** - проверка принадлежности к Казахстану  

## 📋 Установка

```bash
pip install requests flask
```

## 🚀 Полный код сервиса

```python
import requests
import json
import time
from typing import List, Dict, Optional, Tuple

class KazakhstanAddressService:
    """
    Полнофункциональный валидатор и геокодер адресов Казахстана
    
    Возможности:
    1. Поиск адреса по тексту (geocoding)
    2. Получение адреса по координатам (reverse geocoding) 
    3. Автокомплит для подсказок пользователю
    4. Работа с геолокацией устройства
    """
    
    def __init__(self, user_agent: str = "KazakhstanAddressService/1.0"):
        self.base_url = 'https://nominatim.openstreetmap.org/'
        self.headers = {
            'User-Agent': user_agent,
            'Accept-Language': 'ru,kk,en'
        }
        self.country_code = 'kz'
        
    def _make_request(self, endpoint: str, params: dict) -> dict:
        """Выполняет HTTP запрос с соблюдением лимитов"""
        try:
            # Соблюдаем лимит Nominatim - 1 запрос в секунду
            time.sleep(1)
            
            response = requests.get(
                f"{self.base_url}{endpoint}",
                params=params,
                headers=self.headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {'success': True, 'data': response.json()}
            else:
                return {'success': False, 'error': f'HTTP {response.status_code}'}
                
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def geocode_address(self, query: str, limit: int = 5) -> dict:
        """
        Поиск адреса по тексту (координаты по адресу)
        
        Args:
            query: Текст адреса для поиска
            limit: Максимальное количество результатов
            
        Returns:
            dict: Результаты поиска с координатами
        """
        params = {
            'q': query,
            'countrycodes': self.country_code,
            'format': 'jsonv2',
            'limit': limit,
            'addressdetails': 1,
            'extratags': 1,
            'namedetails': 1
        }
        
        result = self._make_request('search', params)
        
        if not result['success']:
            return result
            
        locations = []
        for item in result['data']:
            address = item.get('address', {})
            locations.append({
                'display_name': item.get('display_name', ''),
                'name': item.get('name', ''),
                'latitude': float(item.get('lat', 0)),
                'longitude': float(item.get('lon', 0)),
                'city': address.get('city', address.get('town', address.get('village', ''))),
                'region': address.get('state', ''),
                'district': address.get('county', ''),
                'postcode': address.get('postcode', ''),
                'country': address.get('country', ''),
                'place_type': item.get('type', ''),
                'importance': item.get('importance', 0),
                'osm_id': item.get('osm_id', ''),
                'place_id': item.get('place_id', '')
            })
        
        return {
            'success': True,
            'count': len(locations),
            'locations': locations
        }
    
    def reverse_geocode(self, latitude: float, longitude: float, zoom: int = 18) -> dict:
        """
        Обратное геокодирование (адрес по координатам)
        
        Args:
            latitude: Широта
            longitude: Долгота
            zoom: Уровень детализации (3-18, где 18 - самый детальный)
            
        Returns:
            dict: Адрес для указанных координат
        """
        params = {
            'lat': latitude,
            'lon': longitude,
            'format': 'jsonv2',
            'addressdetails': 1,
            'extratags': 1,
            'namedetails': 1,
            'zoom': zoom
        }
        
        result = self._make_request('reverse', params)
        
        if not result['success']:
            return result
            
        if not result['data']:
            return {'success': False, 'error': 'Адрес не найден для указанных координат'}
        
        item = result['data']
        address = item.get('address', {})
        
        return {
            'success': True,
            'address': {
                'display_name': item.get('display_name', ''),
                'name': item.get('name', ''),
                'house_number': address.get('house_number', ''),
                'road': address.get('road', ''),
                'city': address.get('city', address.get('town', address.get('village', ''))),
                'district': address.get('county', ''),
                'region': address.get('state', ''),
                'postcode': address.get('postcode', ''),
                'country': address.get('country', ''),
                'country_code': address.get('country_code', ''),
                'place_type': item.get('type', ''),
                'confidence': item.get('importance', 0),
                'coordinates': {
                    'latitude': float(item.get('lat', 0)),
                    'longitude': float(item.get('lon', 0))
                }
            }
        }
    
    def autocomplete_suggestions(self, partial_query: str, limit: int = 5) -> dict:
        """
        Автокомплит адресов для подсказок пользователю
        
        Args:
            partial_query: Частичный ввод пользователя
            limit: Количество предложений
            
        Returns:
            dict: Список предложений для автокомплита
        """
        if len(partial_query) < 2:
            return {'success': True, 'suggestions': []}
        
        # Для автокомплита используем более широкий поиск
        params = {
            'q': partial_query,
            'countrycodes': self.country_code,
            'format': 'jsonv2',
            'limit': limit,
            'addressdetails': 1,
            'featureType': 'settlement'  # Фокус на населенных пунктах
        }
        
        result = self._make_request('search', params)
        
        if not result['success']:
            return result
        
        suggestions = []
        for item in result['data']:
            address = item.get('address', {})
            suggestion = {
                'text': item.get('display_name', ''),
                'short_text': item.get('name', ''),
                'city': address.get('city', address.get('town', address.get('village', ''))),
                'region': address.get('state', ''),
                'type': item.get('type', ''),
                'coordinates': {
                    'lat': float(item.get('lat', 0)),
                    'lon': float(item.get('lon', 0))
                }
            }
            suggestions.append(suggestion)
        
        return {
            'success': True,
            'query': partial_query,
            'suggestions': suggestions
        }
    
    def validate_coordinates(self, latitude: float, longitude: float) -> bool:
        """
        Проверяет, находятся ли координаты в пределах Казахстана
        
        Казахстан: примерно 40.5°N-55.5°N, 46.5°E-87.5°E
        """
        return (40.0 <= latitude <= 56.0 and 46.0 <= longitude <= 88.0)
    
    def get_address_from_geolocation(self, latitude: float, longitude: float) -> dict:
        """
        Получает точный адрес из геолокации устройства
        
        Args:
            latitude: Широта из GPS
            longitude: Долгота из GPS
            
        Returns:
            dict: Полная информация об адресе
        """
        # Проверяем, что координаты в пределах Казахстана
        if not self.validate_coordinates(latitude, longitude):
            return {
                'success': False, 
                'error': 'Координаты находятся за пределами Казахстана'
            }
        
        # Получаем детальный адрес с максимальной точностью
        return self.reverse_geocode(latitude, longitude, zoom=18)
```

## 🌐 Flask веб-сервер

```python
from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Разрешаем CORS для фронтенда

# Инициализируем сервис
address_service = KazakhstanAddressService()

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/geocode', methods=['POST'])
def geocode():
    """Поиск координат по адресу"""
    data = request.json
    query = data.get('query', '')
    limit = data.get('limit', 5)
    
    result = address_service.geocode_address(query, limit)
    return jsonify(result)

@app.route('/api/reverse-geocode', methods=['POST'])
def reverse_geocode():
    """Получение адреса по координатам"""
    data = request.json
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    zoom = data.get('zoom', 18)
    
    if not latitude or not longitude:
        return jsonify({'success': False, 'error': 'Координаты обязательны'})
    
    result = address_service.reverse_geocode(latitude, longitude, zoom)
    return jsonify(result)

@app.route('/api/autocomplete', methods=['GET'])
def autocomplete():
    """Автокомплит адресов"""
    query = request.args.get('q', '')
    limit = int(request.args.get('limit', 5))
    
    result = address_service.autocomplete_suggestions(query, limit)
    return jsonify(result)

@app.route('/api/geolocation-address', methods=['POST'])
def geolocation_address():
    """Получение адреса из геолокации устройства"""
    data = request.json
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    
    if not latitude or not longitude:
        return jsonify({'success': False, 'error': 'Координаты обязательны'})
    
    result = address_service.get_address_from_geolocation(latitude, longitude)
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

## 🖥️ HTML интерфейс с геолокацией

```html
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Сервис адресов Казахстана</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        input, button { padding: 10px; margin: 5px; }
        .result { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 3px; }
        .suggestions { border: 1px solid #ccc; max-height: 200px; overflow-y: auto; }
        .suggestion { padding: 8px; cursor: pointer; }
        .suggestion:hover { background: #e0e0e0; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
    <h1>🇰🇿 Сервис адресов Казахстана</h1>
    
    <!-- Геолокация -->
    <div class="section">
        <h3>📱 Получить адрес из геолокации</h3>
        <button onclick="getMyLocation()">Определить мое местоположение</button>
        <div id="location-result"></div>
    </div>
    
    <!-- Поиск адреса -->
    <div class="section">
        <h3>🔍 Поиск координат по адресу</h3>
        <input type="text" id="search-input" placeholder="Введите адрес..." style="width: 70%;">
        <button onclick="searchAddress()">Поиск</button>
        <div id="search-result"></div>
    </div>
    
    <!-- Автокомплит -->
    <div class="section">
        <h3>💡 Автокомплит адресов</h3>
        <input type="text" id="autocomplete-input" placeholder="Начните вводить адрес..." 
               oninput="showSuggestions()" style="width: 70%;">
        <div id="suggestions" class="suggestions" style="display: none;"></div>
    </div>
    
    <!-- Обратное геокодирование -->
    <div class="section">
        <h3>🌐 Получить адрес по координатам</h3>
        <input type="number" id="lat-input" placeholder="Широта" step="any">
        <input type="number" id="lon-input" placeholder="Долгота" step="any">
        <button onclick="reverseGeocode()">Получить адрес</button>
        <div id="reverse-result"></div>
    </div>

    <script>
        const API_BASE = '';
        
        // Получение геолокации
        function getMyLocation() {
            const resultDiv = document.getElementById('location-result');
            
            if (!navigator.geolocation) {
                resultDiv.innerHTML = '<div class="error">Геолокация не поддерживается</div>';
                return;
            }
            
            resultDiv.innerHTML = 'Определение местоположения...';
            
            navigator.geolocation.getCurrentPosition(
                function(position) {
                    const lat = position.coords.latitude;
                    const lon = position.coords.longitude;
                    
                    fetch(`${API_BASE}/api/geolocation-address`, {
                        method: 'POST',
                        headers: {'Content-Type': 'application/json'},
                        body: JSON.stringify({latitude: lat, longitude: lon})
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            const addr = data.address;
                            resultDiv.innerHTML = `
                                <div class="success">
                                    <strong>Ваш адрес:</strong><br>
                                    📍 ${addr.display_name}<br>
                                    🏠 ${addr.road || 'Не определена'}<br>
                                    🏙️ ${addr.city || 'Не определен'}, ${addr.region || ''}<br>
                                    📮 ${addr.postcode || 'Не определен'}<br>
                                    🌐 ${lat.toFixed(6)}, ${lon.toFixed(6)}
                                </div>
                            `;
                        } else {
                            resultDiv.innerHTML = `<div class="error">Ошибка: ${data.error}</div>`;
                        }
                    })
                    .catch(error => {
                        resultDiv.innerHTML = `<div class="error">Ошибка сети: ${error}</div>`;
                    });
                },
                function(error) {
                    resultDiv.innerHTML = `<div class="error">Ошибка геолокации: ${error.message}</div>`;
                }
            );
        }
        
        // Поиск адреса
        function searchAddress() {
            const query = document.getElementById('search-input').value;
            const resultDiv = document.getElementById('search-result');
            
            if (!query.trim()) {
                resultDiv.innerHTML = '<div class="error">Введите адрес для поиска</div>';
                return;
            }
            
            fetch(`${API_BASE}/api/geocode`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({query: query, limit: 5})
            })
            .then(response => response.json())
            .then(data => {
                if (data.success && data.locations.length > 0) {
                    let html = '<div class="success">Найденные адреса:</div>';
                    data.locations.forEach((loc, index) => {
                        html += `
                            <div class="result">
                                <strong>${index + 1}. ${loc.name || loc.display_name}</strong><br>
                                📍 ${loc.display_name}<br>
                                🌐 ${loc.latitude.toFixed(6)}, ${loc.longitude.toFixed(6)}<br>
                                🏙️ ${loc.city}, ${loc.region}
                            </div>
                        `;
                    });
                    resultDiv.innerHTML = html;
                } else {
                    resultDiv.innerHTML = '<div class="error">Адреса не найдены</div>';
                }
            })
            .catch(error => {
                resultDiv.innerHTML = `<div class="error">Ошибка: ${error}</div>`;
            });
        }
        
        // Автокомплит
        let suggestionTimeout;
        function showSuggestions() {
            const query = document.getElementById('autocomplete-input').value;
            const suggestionsDiv = document.getElementById('suggestions');
            
            clearTimeout(suggestionTimeout);
            
            if (query.length < 2) {
                suggestionsDiv.style.display = 'none';
                return;
            }
            
            suggestionTimeout = setTimeout(() => {
                fetch(`${API_BASE}/api/autocomplete?q=${encodeURIComponent(query)}&limit=5`)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.suggestions.length > 0) {
                        let html = '';
                        data.suggestions.forEach(suggestion => {
                            html += `
                                <div class="suggestion" onclick="selectSuggestion('${suggestion.short_text}')">
                                    <strong>${suggestion.short_text}</strong><br>
                                    <small>${suggestion.city}, ${suggestion.region}</small>
                                </div>
                            `;
                        });
                        suggestionsDiv.innerHTML = html;
                        suggestionsDiv.style.display = 'block';
                    } else {
                        suggestionsDiv.style.display = 'none';
                    }
                });
            }, 300);
        }
        
        function selectSuggestion(text) {
            document.getElementById('autocomplete-input').value = text;
            document.getElementById('suggestions').style.display = 'none';
        }
        
        // Обратное геокодирование
        function reverseGeocode() {
            const lat = parseFloat(document.getElementById('lat-input').value);
            const lon = parseFloat(document.getElementById('lon-input').value);
            const resultDiv = document.getElementById('reverse-result');
            
            if (isNaN(lat) || isNaN(lon)) {
                resultDiv.innerHTML = '<div class="error">Введите корректные координаты</div>';
                return;
            }
            
            fetch(`${API_BASE}/api/reverse-geocode`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({latitude: lat, longitude: lon})
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const addr = data.address;
                    resultDiv.innerHTML = `
                        <div class="success">
                            <strong>Адрес:</strong><br>
                            📍 ${addr.display_name}<br>
                            🏠 ${addr.road || 'Не определена'}<br>
                            🏙️ ${addr.city || 'Не определен'}, ${addr.region || ''}<br>
                            📮 ${addr.postcode || 'Не определен'}
                        </div>
                    `;
                } else {
                    resultDiv.innerHTML = `<div class="error">Ошибка: ${data.error}</div>`;
                }
            })
            .catch(error => {
                resultDiv.innerHTML = `<div class="error">Ошибка: ${error}</div>`;
            });
        }
        
        // Скрываем подсказки при клике вне поля
        document.addEventListener('click', function(e) {
            if (!e.target.closest('#autocomplete-input') && !e.target.closest('#suggestions')) {
                document.getElementById('suggestions').style.display = 'none';
            }
        });
    </script>
</body>
</html>
```

## 🚀 Запуск проекта

1. **Сохраните код** в файл `app.py`
2. **Запустите сервер:**
   ```bash
   python app.py
   ```
3. **Откройте браузер:** http://localhost:5000

## 📱 Мобильное использование

```javascript
// Получение геолокации с высокой точностью
navigator.geolocation.getCurrentPosition(
    function(position) {
        const coords = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy
        };
        
        // Отправляем на сервер
        sendLocationToServer(coords);
    },
    function(error) {
        console.error('Ошибка геолокации:', error);
    },
    {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 60000
    }
);
```

## 📚 Полная документация API

**Официальная документация Nominatim:** https://nominatim.org/release-docs/latest/

### Основные endpoints:
- **Search:** `https://nominatim.openstreetmap.org/search`
- **Reverse:** `https://nominatim.openstreetmap.org/reverse` 
- **Lookup:** `https://nominatim.openstreetmap.org/lookup`

### Ограничения:
- ⚠️ **1 запрос в секунду** (для публичного API)
- ⚠️ **Требуется User-Agent**
- ⚠️ **Рекомендуется указать email** для большого объема запросов

### Альтернативы для продакшена:
- **MapBox Geocoding API** (платный, высокое качество)
- **Google Maps Geocoding** (платный, отличное покрытие)
- **Собственный сервер Nominatim** (для больших нагрузок)