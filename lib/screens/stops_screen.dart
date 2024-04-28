import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/route_model.dart';
import 'package:blink_application/models/stop_model.dart';
import 'package:blink_application/models/user_model.dart';
import 'package:blink_application/repository/user_data.dart';
import 'package:flutter/material.dart';

import '../repository/api_service.dart';
import '../repository/database_helper.dart';

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

  void navigateToSearchScreen() {
    Navigator.pushNamed(context, '/search');
  }

  void navigateToStopsScreen() {
    Navigator.pushNamed(context, '/stops');
  }
}
