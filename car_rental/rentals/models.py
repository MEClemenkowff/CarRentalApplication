from django.db import models

class Customer(models.Model):
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    email = models.EmailField(unique=True, null=True)
    phone = models.CharField(max_length=20, null=True)
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
    
class Vehicle(models.Model):
    FUEL_TYPES = [
        ('gasoline', 'Gasoline'),
        ('diesel', 'Diesel'),
        ('ev', 'Electric'),
    ]
    
    make = models.CharField(max_length=50)
    model = models.CharField(max_length=50)
    year = models.IntegerField()
    registration = models.CharField(max_length=50, unique=True)
    seats = models.IntegerField()
    fuel = models.CharField(max_length=50, choices=FUEL_TYPES)
    available = models.BooleanField(default=True)
    odometer = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.make} {self.model} ({self.year})"
    
class Ride(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('active', 'Active'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    vehicle = models.ForeignKey(Vehicle, on_delete=models.PROTECT)
    customer = models.ForeignKey(Customer, on_delete=models.SET_NULL, null=True)
    start_date = models.DateField()
    end_date = models.DateField()
    odometer_start = models.IntegerField(null=True, blank=True)
    odometer_end = models.IntegerField(null=True, blank=True)
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default='pending')

    def __str__(self):
        return f"Ride {self.id}: {self.vehicle} for {self.customer}"