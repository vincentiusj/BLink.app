import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/stop_model.dart';

import '../util/global_contans.dart';

class RouteBusResponse{
  final String routeId;
  final List<Bus> busList;

  RouteBusResponse({required this.routeId, required this.busList});

  factory RouteBusResponse.fromJson(Map<String, dynamic> json) {
    var busDataList = json['bus_list'] as List;
    List<Bus> busList = busDataList.map((data) => Bus.fromJson(data, json['route_id'])).toList();

    return RouteBusResponse(
        routeId: json['route_id'],
        // routeName: busList.first.routeId,
        busList: busList
    );
  }
}

class RouteStopResponse{
  final String routeId;
  final List<Stop> stopList;

  RouteStopResponse({required this.routeId, required this.stopList});

  factory RouteStopResponse.fromJson(Map<String, dynamic> json) {
    var stopDataList = json['stop_list'] as List;
    List<Stop> stopList = stopDataList.map((data) => Stop.fromJson(data, json['route_id'])).toList();

    return RouteStopResponse(
      routeId: json['route_id'],
      stopList: stopList,
    );
  }
}

