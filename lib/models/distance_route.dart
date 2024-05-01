import 'package:blink_application/models/location_model.dart';

class DistanceRoute {
  final Location originLocation;
  final Location destinationLocation;
  late final String? distanceMeters;
  late final String? duration;
  late final String? polyline;

  DistanceRoute({required this.originLocation, required this.destinationLocation, this.distanceMeters, this.duration, this.polyline});

  factory DistanceRoute.fromJson(Map<String, dynamic> json) {
    return DistanceRoute(
        originLocation: Location.fromJson(json),
        longitude: json['longitude']
    );
  }
}
