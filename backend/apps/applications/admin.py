from django.contrib import admin
from .models import Application

@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ['id', 'get_address_display', 'status', 'image_count', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['description']
    readonly_fields = ['created_at', 'updated_at', 'image_count']
    
    fieldsets = (
        ('Application Info', {
            'fields': ('description', 'status')
        }),
        ('Address', {
            'fields': ('address',),
            'classes': ('collapse',)
        }),
        ('Images', {
            'fields': ('image_urls', 'image_count'),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    actions = ['approve_applications', 'reject_applications']
    
    def approve_applications(self, request, queryset):
        count = queryset.update(status='approved')
        self.message_user(request, f'{count} applications approved.')
    approve_applications.short_description = "Approve selected applications"
    
    def reject_applications(self, request, queryset):
        count = queryset.update(status='rejected')
        self.message_user(request, f'{count} applications rejected.')
    reject_applications.short_description = "Reject selected applications"
