import 'location_model.dart';

class Stop {
  final String stopId;
  final String routeId;
  final String stopName;
  final String? routeName;
  final String order;
  final Location? location;

  Stop({required this.stopId, required this.routeId, required this.stopName, this.routeName, required this.order, this.location});

  factory Stop.fromJson(Map<String, dynamic> json, String routeId) {
    return Stop(
      stopId: json['stop_id'],
      routeId: routeId,
      stopName: json['stop_name'],
      routeName: json['route_name'],
      order: json['order'],
      location: Location.fromJson(json)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': stopId,
      'routeId': routeId,
      'stopName': stopName,
      'order': order,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
    };
  }

  factory Stop.fromMap(Map<String, dynamic> maps){
    return Stop(
      stopId: maps['id'],
      routeId: maps['routeId'],
      stopName: maps['stopName'],
      order: maps['order'],
      location: Location.fromMap(maps),
    );
  }

  @override
  String toString() {
    return 'Stop{stopId: $stopId, routeId: $routeId, stopName: $stopName, routeName: $routeName, order: $order, location: $location}';
  }
}