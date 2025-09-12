# Halyk Backend Setup Instructions

## 1. Activate Virtual Environment
```bash
# Activate your existing virtual environment
source venv/bin/activate  # or whatever your venv path is
```

## 2. Install Dependencies (already done)
```bash
pip install -r requirements.txt
```

## 3. Environment Variables
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your settings:
# DATABASE_URL=postgresql://username:password@localhost:5432/halyk_backend
```

## 4. Create and Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

## 5. Create Superuser
```bash
python manage.py createsuperuser
```

## 6. Run Development Server
```bash
python manage.py runserver
```

## 7. Run Tests
```bash
# Django tests
python manage.py test

# Or pytest
pytest
```

## API Endpoints

### Users
- `GET/POST /api/users/` - List/Create users
- `GET/PUT/DELETE /api/users/{id}/` - User detail
- `GET /api/users/phone/{phone_number}/` - Get user by phone

### Applications  
- `GET/POST /api/applications/` - List/Create applications
- `GET/PUT/DELETE /api/applications/{id}/` - Application detail
- `PUT /api/applications/{id}/status/` - Update status
- `GET /api/applications/status/{status}/` - Filter by status
- `GET /api/applications/stats/` - Get statistics
