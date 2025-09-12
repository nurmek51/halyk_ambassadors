from django.urls import path
from .views import UserListCreateView, UserDetailView, user_by_phone

urlpatterns = [
    path('', UserListCreateView.as_view(), name='user-list-create'),
    path('<int:pk>/', UserDetailView.as_view(), name='user-detail'),
    path('phone/<str:phone_number>/', user_by_phone, name='user-by-phone'),
]
