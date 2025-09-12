from django.urls import path
from .views import (
    ApplicationListCreateView, 
    ApplicationDetailView,
    ApplicationStatusUpdateView,
    applications_by_status,
    application_stats
)

urlpatterns = [
    path('', ApplicationListCreateView.as_view(), name='application-list-create'),
    path('<int:pk>/', ApplicationDetailView.as_view(), name='application-detail'),
    path('<int:pk>/status/', ApplicationStatusUpdateView.as_view(), name='application-status-update'),
    path('status/<str:status>/', applications_by_status, name='applications-by-status'),
    path('stats/', application_stats, name='application-stats'),
]
