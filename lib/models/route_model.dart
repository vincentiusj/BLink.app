import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/net_models.dart';
import 'package:blink_application/models/stop_model.dart';

class RouteModel {
  final String routeId;
  final String routeName;

  RouteModel({required this.routeId, required this.routeName});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['route_id'],
      routeName: json['route_name']
    );
  }

  factory RouteModel.fromRouteStopResponse(RouteStopResponse routeStopResponse){
    return RouteModel(
      routeId: routeStopResponse.routeId,
      routeName: routeStopResponse.stopList.first.routeName!
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': routeId,
      'routeName': routeName
    };
  }
}