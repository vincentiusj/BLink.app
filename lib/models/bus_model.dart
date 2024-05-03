import 'package:blink_application/models/location_model.dart';

import '../util/global_contans.dart';

class Bus {
  final String busId;
  final String routeId;
  final String busType;
  final String busColor;
  final String plateNumber;
  late Location? currentLocation;
  late final String? latestETA;
  late final String? driverName;
  late final int? passengerCount;


  Bus({required this.busId, required this.routeId, required this.busType, required this.busColor, required this.plateNumber});

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
    return Bus(
        busId: bus.busId,
        routeId: bus.routeId,
        busType: bus.busType,
        busColor: bus.busColor,
        plateNumber: bus.busColor,

    );
    bus.currentLocation = Location.fromJson(json);
    return bus;
  }

  @override
  String toString() {
    return 'Bus(busId: $busId, routeId: $routeId, busType: $busType, busColor: $busColor, plateNumber: $plateNumber)';
  }

  void setLocation(Location currentLocation){
    this.currentLocation = currentLocation;
  }
  void setDriverName(String driverName){
    this.driverName = driverName;
  }

}