import 'package:blink_application/models/location_model.dart';

class DistanceRoute {
  // final Location originLocation;
  // final Location destinationLocation;
  late final int distanceMeters;
  late final String duration;
  late final String? polyline;

  // DistanceRoute({required this.originLocation, required this.destinationLocation, this.distanceMeters, this.duration, this.polyline});
  DistanceRoute({required this.distanceMeters, required this.duration, this.polyline});

  factory DistanceRoute.fromJson(Map<String, dynamic> json) {
    return DistanceRoute(
        distanceMeters: json['distanceMeters'],
        duration: json['duration'],
        // polyline: json['polyline'],
    );
  }
}
