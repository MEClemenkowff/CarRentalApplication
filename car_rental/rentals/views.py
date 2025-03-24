from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework import status
from django.utils.dateparse import parse_date

from rentals.models import Customer, Vehicle, Ride
from rentals.serializers import CustomerSerializer, VehicleSerializer, RideSerializer

class BaseView(APIView):
    def get_object(self, model, pk):
        try:
            return model.objects.get(pk=pk)
        except model.DoesNotExist:
            return None
    
    def get_serializer_class(self):
        raise NotImplementedError("You need to define get_serializer_class method in subclass")
    
    def get_model(self):
        raise NotImplementedError("You need to define get_model method in subclass")

    def apply_filters(self, queryset, request):
        """
        This method applies filters to the queryset based on the request parameters.
        """
        # Example filter for status
        filter_params = request.query_params

        for field, value in filter_params.items():
            if hasattr(queryset.model, field):
                queryset = queryset.filter(**{field: value})
        
        return queryset

    def get(self, request, pk=None):
        if pk:
            obj = self.get_object(self.get_model(), pk)
            if obj is None:
                return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
            serializer = self.get_serializer_class()(obj)
            return Response(serializer.data)
        else:
            objects = self.get_model().objects.all()
            # Apply filters based on query parameters
            objects = self.apply_filters(objects, request)
            serializer = self.get_serializer_class()(objects, many=True)
            return Response(serializer.data)

    def post(self, request, pk=None):
        serializer = self.get_serializer_class()(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk=None):
        if not pk:
            return Response({"detail": "PK is required for PUT requests."}, status=status.HTTP_400_BAD_REQUEST)
        
        obj = self.get_object(self.get_model(), pk)
        if obj is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = self.get_serializer_class()(obj, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def patch(self, request, pk=None):
        if not pk:
            return Response({"detail": "PK is required for PATCH requests."}, status=status.HTTP_400_BAD_REQUEST)
        
        obj = self.get_object(self.get_model(), pk)
        if obj is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = self.get_serializer_class()(obj, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk=None):
        if not pk:
            return Response({"detail": "PK is required for DELETE requests."}, status=status.HTTP_400_BAD_REQUEST)
        
        obj = self.get_object(self.get_model(), pk)
        if obj is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        
        obj.delete()
        return Response({"detail": "Deleted successfully."}, status=status.HTTP_204_NO_CONTENT)

class CustomersView(BaseView):
    def get_model(self):
        return Customer
    
    def get_serializer_class(self):
        return CustomerSerializer
    
class VehiclesView(BaseView):
    def get_model(self):
        return Vehicle
    
    def get_serializer_class(self):
        return VehicleSerializer
    
class RidesView(BaseView):
    def get_model(self):
        return Ride
    
    def get_serializer_class(self):
        return RideSerializer

    def patch(self, request, pk=None):
        if not pk:
            return Response({"detail": "PK is required for PATCH requests."}, status=status.HTTP_400_BAD_REQUEST)

        obj = self.get_object(self.get_model(), pk)
        if obj is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)

        status = request.data.get('status', obj.status)
        odometer_start = request.data.get('odometer_start', obj.odometer_start)
        odometer_end = request.data.get('odometer_end', obj.odometer_end)
        vehicle = obj.vehicle

        # Update vehicle mileage
        if vehicle and odometer_start is not None and odometer_end is not None:
            if obj.status != 'completed' and status == 'completed':
                new_mileage = odometer_end - odometer_start
            elif obj.status == 'completed' and status == 'completed':
                old_ride_mileage = obj.odometer_end - obj.odometer_start
                new_mileage = odometer_end - odometer_start - old_ride_mileage
            vehicle.odometer = vehicle.odometer + new_mileage
            vehicle.save()


        serializer = self.get_serializer_class()(obj, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(["GET"])
def check_availability(request):
    vehicle = request.GET.get('vehicle')
    start_date = request.GET.get('start_date')
    end_date = request.GET.get('end_date')
    excluded_ride = request.GET.get('excluded_ride')

    if not vehicle or not start_date or not end_date:
        return Response({"error": "Missing parameters"}, status=status.HTTP_400_BAD_REQUEST)

    start_date = parse_date(start_date)
    end_date = parse_date(end_date)

    if not start_date or not end_date:
        return Response({"error": "Invalid date format"}, status=status.HTTP_400_BAD_REQUEST)

    conflicting_rides = Ride.objects.filter(
        vehicle=vehicle,
        start_date__lte=end_date,
        end_date__gte=start_date
    )

    if excluded_ride:
        conflicting_rides = conflicting_rides.exclude(id=excluded_ride)

    is_available = not conflicting_rides.exists()

    return Response({"available": is_available})