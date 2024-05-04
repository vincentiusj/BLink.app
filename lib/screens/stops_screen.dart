import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/route_model.dart';
import 'package:blink_application/models/stop_model.dart';
import 'package:blink_application/models/user_model.dart';
import 'package:blink_application/repository/user_data.dart';
import 'package:blink_application/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';
import '../repository/api_service.dart';
import '../repository/database_helper.dart';
import '../util/calculate_distance.dart';

class StopsScreen extends StatefulWidget {
  const StopsScreen({super.key});

  @override
  State<StopsScreen> createState() => _StopsScreenState();
}

class _StopsScreenState extends State<StopsScreen> {
  User? user;
  final TextEditingController _searchBusStopController =
  TextEditingController();

  void initUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: DatabaseHelper.getAllRoutes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              List<RouteModel>? routeList = snapshot.data;
              if(routeList != null){
                return ListView.builder(
                    itemCount: routeList.length,
                    itemBuilder: (context, index) {
                      RouteModel? route = routeList[index];
                      return ExpansionTile(
                        title: Text(route.routeName),
                        children: [
                          FutureBuilder(
                              future: DatabaseHelper.getAllStops(),
                              builder: (context, snapshot){
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else {
                                  List<Stop>? stopList = snapshot.data?.where((e) => e.routeId == route.routeId).toList();
                                  if(stopList != null){


                                    return Column(
                                        children:
                                        stopList.map((stop) =>
                                            ListTile(
                                              onTap: () async {
                                                var nearestStopFromHere = await _getNearestStopFromHere();
                                                navigateToSearchScreen(nearestStopFromHere!, stop);
                                              },
                                              leading: Icon(Icons.bus_alert_sharp),
                                              title: Text(stop.stopName),
                                            )
                                        ).toList()
                                    );
                                  } else {
                                    return const Center(
                                      child: Text('Stops not found'),
                                    );
                                  }
                                }
                              }
                          )
                        ],
                      );
                    }
                );
              } else {
                return const Center(
                  child: Text('User not found'),
                );
              }
            }
          }
      ),
    );
  }

  Widget _buildTextInput(String field, TextEditingController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
                labelText: field,
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                filled: true,
                fillColor: Colors.amber
            ),
            onTap: (){
              // handle search
            },
          ),
        ),
        SizedBox(height: 16.0)
      ],
    );
  }

  void navigateToSearchScreen(Stop nearestStopFromHere, Stop destinationStop) async{

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          origin: nearestStopFromHere,
          destination: destinationStop,
        ),
      ),
    );
  }

  void navigateToStopsScreen() {
    Navigator.pushNamed(context, '/stops');
  }

  Future<Stop?> _getNearestStopFromHere() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    var currentLocation = Location(latitude: position.latitude.toString(), longitude: position.longitude.toString());

    Stop? nearestStop;
    double minDistance = double.infinity;

    List<Stop> stopList = await DatabaseHelper.getAllStops();
    for (Stop stop in stopList) {
      double distance = calculateDistance(
          currentLocation,
          stop.location!
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestStop = stop;
      }
    }
    return nearestStop;
  }

}
