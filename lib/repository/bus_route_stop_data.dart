import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/net_models.dart';
import 'package:blink_application/repository/database_helper.dart';
import '../util/global_contans.dart';
import 'dart:convert';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import 'api_service.dart';

initBusRouteStopData() async {

  // todo check time condition for inquiry

  insertBuses();
  insertStops();
  insertRoutes();

  // DatabaseHelper.captureDatabase();

  List<Stop> stops = await DatabaseHelper.getAllStops();
  logger.d('getAllStops ${stops}');

  List<Bus> bus = await DatabaseHelper.getAllBus();
  logger.d('getAllBus $bus');

  List<RouteModel> routes = await DatabaseHelper.getAllRoutes();
  logger.d('getAllRoutes $routes');
}

Future<void> insertBuses() async {
  try{
    List<RouteBusResponse>? routeBusList = await _getRouteBusList();
    for(var route in routeBusList!){
      await DatabaseHelper.insertOrUpdateBuses(route.busList);
    }
    logger.d('insertBuses success');
  }catch(e){
    logger.d('insertBuses failed with $e');
  }
}

Future<void> insertStops() async{
  try{
    List<RouteStopResponse>? routeStopList = await _getRouteStopList();
    for(var route in routeStopList!){
      await DatabaseHelper.insertOrUpdateStops(route.stopList);
    }
    logger.d('insertStops success');
  }catch(e){
    logger.d('insertStops failed with $e');
  }
}

Future<void> insertRoutes() async {
  try{
    List<RouteStopResponse>? routeStopResponseList = await _getRouteStopList();

    var routeList = routeStopResponseList?.map((e) => RouteModel.fromRouteStopResponse(e));
    await DatabaseHelper.insertOrUpdateRoutes(routeList!.toList());

    logger.d('insertRoutes success');

  }catch(e){
    logger.d('insertRoutes failed with $e');
  }
}

Future<List<RouteBusResponse>?> _getRouteBusList() async {
  try {
    var jsonResponse = await ApiService.getRouteBusList();

    List<RouteBusResponse> routeBusList = jsonResponse.map((json) => RouteBusResponse.fromJson(json)).toList();

    return routeBusList;
  } catch (e) {
    logger.d('_getRouteBusList failed ${e}');
  }
}

Future<List<RouteStopResponse>?>  _getRouteStopList() async {
  try {
    var jsonResponse = await ApiService.getRouteStopList();

    logger.d('_getRouteStopList success');

    List<RouteStopResponse> routeStopList = jsonResponse.map((json) => RouteStopResponse.fromJson(json)).toList();

    return routeStopList;
  } catch (e) {
    logger.d('_getRouteStopList failed $e');
  }
}

