from rest_framework import generics, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Application
from .serializers import (
    ApplicationSerializer, 
    ApplicationCreateSerializer,
    ApplicationStatusUpdateSerializer
)

class ApplicationListCreateView(generics.ListCreateAPIView):
    queryset = Application.objects.all()
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status']
    ordering_fields = ['created_at', 'status']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ApplicationCreateSerializer
        return ApplicationSerializer

class ApplicationDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Application.objects.all()
    serializer_class = ApplicationSerializer
    permission_classes = [AllowAny]

class ApplicationStatusUpdateView(generics.UpdateAPIView):
    queryset = Application.objects.all()
    serializer_class = ApplicationStatusUpdateSerializer
    permission_classes = [AllowAny]

@api_view(['GET'])
@permission_classes([AllowAny])
def applications_by_status(request, status):
    """Get applications by status"""
    if status not in ['pending', 'approved', 'rejected']:
        return Response({'error': 'Invalid status'}, status=400)
    
    applications = Application.objects.filter(status=status)
    serializer = ApplicationSerializer(applications, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([AllowAny])
def application_stats(request):
    """Get application statistics"""
    total = Application.objects.count()
    pending = Application.objects.filter(status='pending').count()
    approved = Application.objects.filter(status='approved').count()
    rejected = Application.objects.filter(status='rejected').count()
    
    return Response({
        'total': total,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
        'approval_rate': round((approved / total * 100) if total > 0 else 0, 2)
    })
