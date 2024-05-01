import 'GlobalConstants.dart';

class Bus {
  final String busId;
  final String routeId;
  final String busType;
  final String busColor;
  final String plateNumber;
  late final String? currentLatitude;
  late final String? currentLongitude;
  late final String? latestETA;
  late final String? driverName;


  Bus({required this.busId, required this.routeId, required this.busType, required this.busColor, required this.plateNumber, this.currentLatitude, this.currentLongitude});

  factory Bus.fromJson(Map<String, dynamic> json, String routeId) {
    return Bus(
      busId: json['bus_id'],
      routeId: routeId,
      busType: json['bus_type'],
      busColor: json['bus_color'],
      plateNumber: json['plate_number'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': busId,
      'routeId': routeId,
      'busType': busType,
      'busColor': busColor,
      'plateNumber': plateNumber,
    };
  }

  factory Bus.fromMap(Map<String, dynamic> maps){
    return Bus(
      busId: maps['id'],
      routeId: maps['routeId'],
      busType: maps['busType'],
      busColor: maps['busColor'],
      plateNumber: maps['plateNumber'],
    );
  }

  factory Bus.addLocation(Bus bus, Map<String, dynamic> json){
    bus.currentLatitude = json['latitude'];
    bus.currentLongitude = json['longitude'];
    bus.driverName = json['driver_name'];
    return bus;
  }

  factory Bus.addETA(Bus bus, Map<String, dynamic> json){
    bus.driverName = json['driver_name'];
    return bus;
  }

  @override
  String toString() {
    return 'Bus(busId: $busId, routeId: $routeId, busType: $busType, busColor: $busColor, plateNumber: $plateNumber)';
  }

}