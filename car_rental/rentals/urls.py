from django.urls import path
from . import views

urlpatterns = [
    path('customers/', views.CustomersView.as_view(), name='customers'),
    path('customers/<int:pk>/', views.CustomersView.as_view(), name='customer'),

    path('vehicles/', views.VehiclesView.as_view(), name='vehicles'),
    path('vehicles/<int:pk>/', views.VehiclesView.as_view(), name='vehicle'),

    path('rides/', views.RidesView.as_view(), name='rides'),
    path('rides/<int:pk>/', views.RidesView.as_view(), name='ride'),

    path('availability/', views.check_availability, name='availability'),
]