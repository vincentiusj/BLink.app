import 'dart:convert';

import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/repository/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/GlobalConstants.dart';
import '../models/stop_model.dart';
import '../repository/database_helper.dart';
import '../res/strings.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Stop? origin;
  Stop? destination;

  late GoogleMapController mapController;


  bool _searchFilledState() {
    return origin != null && destination != null;
  }
  @override
  void initState() {
    super.initState();
    logger.d('initState $origin | $destination');
    _updateOriginAndDestination();
  }

  Future<void> _updateOriginAndDestination() async {
    logger.d('_updateOriginAndDestination $origin | $destination');
    if (_searchFilledState()) {
      logger.d('_updateOriginAndDestination masuk sini');

      // try {
      //   var jsonResponse = await ApiService.computeRoute(origin!, destination!);
      //
      // } catch (e) {
      //   logger.d('computeRoute failed $e');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
            children: [
              const SizedBox(height: 16),
              _buildStartEndSearchField(),
              SizedBox(height: 10.0),
              _buildMapsView(),
              _buildBusArrivalListView()
            ]
        ),
      )
    );
  }


  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Widget _buildStartEndSearchField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Where to?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10.0),
        FutureBuilder(
            future: DatabaseHelper.getAllStops(),
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
                List<Stop>? stopList = snapshot.data;
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildOriginFieldView(stopList),
                        _buildDestinationFieldView(stopList)
                      ],
                    )
                );
              }
            }
        ),
      ],
    );
  }

  DropdownButtonFormField<String> _buildOriginFieldView(List<Stop>? stopList) {
    // List<String>? stopNames = stopList?.map((stop) => stop.stopName).toList();
    logger.d('SearchScreen stoplist $stopList}');

    return DropdownButtonFormField<String>(
      value: origin?.stopId,
      decoration: const InputDecoration(
        labelText: 'Start',
        border: InputBorder.none,
        prefixIcon: Icon(Icons.location_on, color: Colors.orange),
      ),
      items: stopList
          ?.map((Stop value) {
        return DropdownMenuItem<String>(
          value: value.stopId,
          child: Text(value.stopName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          origin = stopList?.firstWhere((element) => element.stopId == value);
        });
        _updateOriginAndDestination();
      },
    );
  }

  DropdownButtonFormField<String> _buildDestinationFieldView(List<Stop>? stopList) {
    // List<String>? stopNames = stopList?.map((stop) => stop.stopName).toList();
    logger.d('SearchScreen stoplist $stopList}');

    return DropdownButtonFormField<String>(
      value: destination?.stopId,
      decoration: const InputDecoration(
        labelText: 'Destination',
        border: InputBorder.none,
        prefixIcon: Icon(Icons.location_on, color: Colors.orange),
      ),
      items: stopList
          ?.map((Stop value) {
        return DropdownMenuItem<String>(
          value: value.stopId,
          child: Text(value.stopName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          destination = stopList?.firstWhere((element) => element.stopId == value);
        });
        _updateOriginAndDestination();
      },
    );
  }

  Expanded _buildMapsView(){
    var originLatitude = double.tryParse(origin?.location?.latitude ?? '0.0') ?? 0.0;
    var originLongitude = double.tryParse(origin?.location?.longitude ?? '0.0') ?? 0.0;
    var destinationLatitude = double.tryParse(destination?.location?.latitude ?? '0.0') ?? 0.0;
    var destinationLongitude = double.tryParse(destination?.location?.longitude ?? '0.0') ?? 0.0;

    return Expanded(
        child: (_searchFilledState())
            ?
        Container(
          color: Colors.grey[300],
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(originLatitude, originLongitude),
              zoom: 12.0,
            ),
            onMapCreated: (controller) {
              logger.d('onMapCreated');
              mapController = controller;
            },
            trafficEnabled: true,
            mapType: MapType.satellite,
            markers: {
              Marker(
                  markerId: MarkerId(origin!.stopId),
                  position: LatLng(originLatitude, originLongitude),
                  infoWindow: InfoWindow(title: origin?.stopName),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)
              ),
              Marker(
                markerId: MarkerId(destination!.stopId),
                position: LatLng(destinationLatitude, destinationLongitude),
                infoWindow: InfoWindow(title: destination?.stopName),
              ),
            },
            myLocationEnabled: true,
          ),

        )
            : const Center(child: CircularProgressIndicator())
    );
  }

  Widget _buildBusArrivalListView() {
    return FutureBuilder(
        future: _generateUpcomingArrivals(),
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
            List<Bus>? upcomingBusList = snapshot.data;
            logger.d('_buildBusArrivalListView1 $upcomingBusList');
            if(upcomingBusList != null && upcomingBusList.isNotEmpty){
              logger.d('_buildBusArrivalListView1 ${upcomingBusList.length}');
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Expanded(
                      child: ListView.builder(
                        itemCount: upcomingBusList.length,
                        itemBuilder: (context, index) {
                          logger.d('masuk sini');
                          logger.d('_buildBusArrivalListView2 ${upcomingBusList[index]}');
                          Bus? upcomingBus = upcomingBusList[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                upcomingBus.plateNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(AppStrings.estimatedTimeArrivalLabel + ' ${upcomingBus.busType}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Navigate to details page
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(AppStrings.detailLabel),
                              ),
                            ),
                          );
                        },
                      )
                  )
              );
            } else {
              return Center(child: Text("No Available Bus"));
            }
          }
        }
    );

    return Expanded(
      child: (_searchFilledState())
          ?
      ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: const Text(
                'Route Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(AppStrings.estimatedTimeArrivalLabel),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to details page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(AppStrings.detailLabel),
              ),
            ),
          );
        },
      )
          : const Center(child: CircularProgressIndicator())
    );

  }


  Future<List<Bus>?> _generateUpcomingArrivals() async {
    if(_searchFilledState()){
      try{
        var routeList = await DatabaseHelper.searchRoutes(origin!.stopId, destination!.stopId);
        logger.d('_generateUpcomingArrivals routeList ${routeList}');
        var busesInRoutesFutures = routeList.map((e) => DatabaseHelper.getBusesFromRouteId(e.routeId));
        logger.d('_generateUpcomingArrivals busesInRoutesFutures $busesInRoutesFutures');
        var busesInRoutesList = await Future.wait(busesInRoutesFutures);
        logger.d('_generateUpcomingArrivals busesInRoutesList $busesInRoutesList');

        List<Bus>? busesInRoutesRTLocationList = [];

        for(var busesInRoute in busesInRoutesList){
          var busRTLocation = await _getBusesInRoutesRTLocation(busesInRoute);
          logger.d('_generateUpcomingArrivals busRTLocation $busRTLocation');

          busesInRoutesRTLocationList.addAll(busRTLocation ?? []);
        }
        logger.d( '_generateUpcomingArrivals busesInRoutesRTLocationList $busesInRoutesRTLocationList');
        // return busesInRoutesRTLocationList;
        logger.d( '_generateUpcomingArrivals busesInRoutesList.first ${busesInRoutesList.first}');

        return busesInRoutesList.first;

      } catch(e){
        logger.d('_generateUpcomingArrivals error $e');
      }
    }
  }

  Future<Iterable<Bus>?> _getBusesInRoutesRTLocation(List<Bus> busList) async {
    try {
      logger.d('_getBusesInRoutesRTLocation masuk sini $busList');

      List<Bus> busRealTimeLocationList = [];
      for(var bus in busList){
        var jsonResponse = await ApiService.getBusActivityInfo(bus);
        Bus busRealTimeLocation = jsonResponse.map((json) => Bus.addLocation(bus, json)).toList();

        busRealTimeLocationList.add(busRealTimeLocation);
      }
      return busRealTimeLocationList;
    } catch (e) {
      print('getBusActivityInfo failed: $e');
    }
  }



}
