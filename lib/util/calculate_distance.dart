import 'dart:math';

import '../models/location_model.dart';

double calculateDistance(Location startLocation, Location endLocation) {
  const int earthRadius = 6371000; // in meters
  double startLat = double.tryParse(startLocation.latitude) ?? 0;
  double startLng = double.tryParse(startLocation.longitude) ?? 0;

  double endLat = double.tryParse(endLocation.latitude) ?? 0;
  double endLng = double.tryParse(endLocation.longitude) ?? 0;

  double latDistance = (endLat - startLat).toRadians();
  double lngDistance = (endLng - startLng).toRadians();
  double a = pow(sin(latDistance / 2), 2) +
      pow(sin(lngDistance / 2), 2) *
          cos(startLat.toRadians()) *
          cos(endLat.toRadians());
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

extension on num {
  double toRadians() {
    return degreesToRadians(this.toDouble());
  }
}

String secondsToMinutes(String secondsString) {
  String numericPart = secondsString.substring(0, secondsString.length - 1);
  int seconds = int.parse(numericPart);
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  return '$minutes,${remainingSeconds.toString().padLeft(2, '0')} min';
}