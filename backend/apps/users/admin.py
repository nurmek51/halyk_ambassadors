from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['phone_number', 'full_name', 'position', 'created_at']
    list_filter = ['position', 'created_at']
    search_fields = ['phone_number', 'name', 'surname', 'position']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Personal Info', {
            'fields': ('phone_number', 'name', 'surname', 'position')
        }),
        ('Address', {
            'fields': ('address',),
            'classes': ('collapse',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
