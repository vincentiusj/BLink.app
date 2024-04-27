class Stop {
  final String stopId;
  final String routeId;
  final String stopName;
  final String? routeName;
  final String order;
  final String? latitude;
  final String? longitude;

  Stop({required this.stopId, required this.routeId, required this.stopName, this.routeName, required this.order, this.latitude, this.longitude});

  factory Stop.fromJson(Map<String, dynamic> json, String routeId) {
    return Stop(
        stopId: json['stop_id'],
        routeId: routeId,
        stopName: json['stop_name'],
        routeName: json['route_name'],
        order: json['order'],
        latitude: json['latitude'],
        longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': stopId,
      'routeId': routeId,
      'stopName': stopName,
      'order': order,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'Stop{stopId: $stopId, routeId: $routeId, stopName: $stopName, routeName: $routeName, order: $order, latitude: $latitude, longitude: $longitude}';
  }
}