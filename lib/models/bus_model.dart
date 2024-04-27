import 'GlobalConstants.dart';

class Bus {
  final String busId;
  final String routeId;
  final String busType;
  final String busColor;
  final String plateNumber;

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

  @override
  String toString() {
    return 'Bus(busId: $busId, routeId: $routeId, busType: $busType, busColor: $busColor, plateNumber: $plateNumber)';
  }
}