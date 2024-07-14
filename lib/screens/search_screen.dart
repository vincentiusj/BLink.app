import 'dart:ui';

import 'package:blink_application/models/bus_model.dart';
import 'package:blink_application/models/route_model.dart';
import 'package:blink_application/repository/api_service.dart';
import 'package:blink_application/res/colors.dart';
import 'package:blink_application/util/calculate_distance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../dialogs/Info_Item.dart';
import '../models/distance_route.dart';
import '../models/location_model.dart';
import '../models/stop_model.dart';
import '../repository/database_helper.dart';
import '../repository/user_data.dart';
import '../res/strings.dart';
import '../util/global_contans.dart';


class SearchScreen extends StatefulWidget {
  final Stop? origin;
  final Stop? destination;

  const SearchScreen({Key? key, this.origin, this.destination}): super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Stop? origin;
  Stop? destination;
  List<Stop> stopList = [];
  Bus? upcomingBus;
  bool isFavoritePlace = false;
  RouteModel? thisBusRoute;
  Set<Polyline> _polylines = {};
  bool isPolyLinesLoaded = false;

  late GoogleMapController mapController;
  final TextEditingController _favoriteLabelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _searchFilledState() {
    return origin != null && destination != null;
  }
  @override
  void initState() {
    super.initState();

    origin = widget.origin;
    destination = widget.destination;
    logger.d('initState $origin | $destination');
    // _updateOriginAndDestination();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Center(
            child: Image.asset('assets/images/logo_blink_app.png'),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Stack(
                  children: [
                    Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Where to?',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          if(_searchFilledState() && !isFavoritePlace) _buildAddToFavorite(),
                        ],),
                      SizedBox(height: 10.0),
                      _buildStartEndSearchField(),
                      SizedBox(height: 10.0),
                      if(_searchFilledState()) _buildMapsView(),
                    ],),
                    if(_searchFilledState()) _buildBusArrivalListView()
                  ]
              ),
            )
        )

    );
  }


  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Widget _buildStartEndSearchField(){
    return FutureBuilder(
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
                    _buildDestinationFieldView(stopList),
                  ],
                )
            );
          }
        }
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
          isPolyLinesLoaded = false;
          destination = stopList?.firstWhere((element) => element.stopId == value);
        });
      },
    );
  }

  Widget _buildMapsView(){
    var originLatitude = double.tryParse(origin?.location?.latitude ?? '0.0') ?? 0.0;
    var originLongitude = double.tryParse(origin?.location?.longitude ?? '0.0') ?? 0.0;
    var destinationLatitude = double.tryParse(destination?.location?.latitude ?? '0.0') ?? 0.0;
    var destinationLongitude = double.tryParse(destination?.location?.longitude ?? '0.0') ?? 0.0;


    return Container(
      height: MediaQuery.of(context).size.height - 400,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(originLatitude, originLongitude),
            zoom: 20.0,
          ),
          onMapCreated: (controller) {
            logger.d('onMapCreated $origin $destination');
            mapController = controller;
            // setStopListForMaps();
          },
          polylines: _polylines,
          trafficEnabled: true,
          mapType: MapType.hybrid,
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
            // List<Bus>? upcomingBusList = [Bus(busId: 'Bus1', routeId: 'Rute 1', busType: 'Conventional', busColor: 'Oren', plateNumber: 'B 1112 AA')];

            if(upcomingBusList != null && upcomingBusList.isNotEmpty){
              logger.d('onMapCreated2 $origin $destination');

              return Positioned(
                  bottom: 0,
                  top: MediaQuery.of(context).size.height - 280,
                  left: 15,
                  right: 15,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)
                      ),
                      child: ListView.builder(
                        itemCount: upcomingBusList.length,
                        itemBuilder: (context, index) {
                          logger.d('masuk sini');
                          logger.d('_buildBusArrivalListView2 ${upcomingBusList[index]}');
                          Bus? upcomingBus = upcomingBusList[index];
                          this.upcomingBus = upcomingBus;
                          setStopListForMaps();
                          getRouteFromRouteId(upcomingBus.routeId);

                            return Card(
                              elevation: 2,
                               margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                              title: Text(
                                thisBusRoute?.routeName ?? 'Route 1',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Arrived in ${upcomingBus.latestETA}'),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orangeSoft,
                                ),
                                child: const Icon(Icons.info_outline, color: Colors.white,),
                                onPressed: () {
                                  setState(() {
                                    logger.d('onMapCreated3 $origin $destination');

                                    setStopListForMaps();
                                    showBottomSheet(context: context, builder: (context){
                                      return ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                          child: Container(
                                            height: 220,
                                            width: 500,
                                            color: AppColors.orangeSoft.withOpacity(0.9),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(16.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.orangeSoft.withOpacity(0.9), // Set opacity here (0.0 to 1.0)
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(20),
                                                      topRight: Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment.topRight,
                                                        child: Icon(Icons.arrow_downward, color: Colors.black87,),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Route Information',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                            SizedBox(height: 10),
                                                            InfoItem(
                                                              label: 'Route Name',
                                                              value: thisBusRoute?.routeName ?? 'Route 1',
                                                            ),
                                                            InfoItem(
                                                              label: 'Bus Plate Number',
                                                              value: upcomingBus.plateNumber,
                                                            ),
                                                            InfoItem(
                                                              label: 'Bus Color',
                                                              value: 'Red',
                                                            ),
                                                            InfoItem(
                                                              label: 'Bus Type',
                                                              value: upcomingBus.busType,
                                                            ),
                                                            InfoItem(
                                                              label: 'Passenger Count',
                                                              value: '${upcomingBus.passengerCount} Passengers',
                                                            ),
                                                          ],
                                                        )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          )
                                      );
                                    });
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      )
                  )
              );
            } else {
              return Positioned(
                  bottom: 0,
                  child: Text("No Available Bus"));
            }
          }
        }
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

        return busesInRoutesRTLocationList;
        // return busesInRoutesList.first;

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
        // get bus activity info (current location)
        var jsonResponse = await ApiService.getBusActivityInfo(bus);


        bus.setLocation(Location.fromJson(jsonResponse));
        bus.driverName = jsonResponse['driver_name'];
        bus.passengerCount = jsonResponse['passenger_count'];
        // bus.currentLocation = Location.fromJson(jsonResponse);

        logger.d('bus test location ${bus.currentLocation?.longitude}');
        // hit the gmaps api per bus, using current location, get the duration between bus current location and the origin stop
        // if(bus.currentLocation != null){
        var distanceRoute = await _getDistanceRoute(bus.currentLocation!);
        bus.latestETA = secondsToMinutes(distanceRoute?.first.duration ?? '');
        // }else{
        //   throw Exception('No Activity');
        // }

        busRealTimeLocationList.add(bus);
      }
      return busRealTimeLocationList;
    } catch (e) {
      print('getBusActivityInfo failed: $e');
    }
  }

  Future<List<DistanceRoute>?> _getDistanceRoute(Location busCurrentLocation) async {
    try {
      logger.d('_getDistanceRoute masuk sini $busCurrentLocation');

      // var jsonResponse = await ApiService.computeRoute(busCurrentLocation, origin!.location!);
      var jsonResponse = await ApiService.computeRoute(destination!.location!, origin!.location!);
      logger.d('_getDistanceRoute ${jsonResponse['routes']}');
      var distanceRouteList = jsonResponse['routes'] as List;
      List<DistanceRoute> distanceRoute = distanceRouteList.map((data) => DistanceRoute.fromJson(data)).toList();

      logger.d('_getDistanceRoute $distanceRoute');

      return distanceRoute;

      // return busRealTimeLocationList;
    } catch (e) {
      logger.d('_getDistanceRoute failed: $e');
    }
  }

  Widget _buildAddToFavorite(){
    return Align(
        alignment: Alignment.centerRight,
        child: TextButton(
            child: (isFavoritePlace)
                ? Icon(Icons.bookmark, color: AppColors.orangeSoft)
                : Icon(
              Icons.bookmark_add_outlined,
              color: AppColors.orangeSoft,
            ),
            onPressed: () {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(
                                      Icons.close_fullscreen,
                                      color: AppColors.orangeSoft,
                                    ),
                                  )
                              ),
                              TextFormField(
                                controller: _favoriteLabelController,
                                decoration: InputDecoration(
                                  hintText: 'Add favorite trip...',
                                  // prefixIcon: Icon(Icons.email, color: Colors.orange),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.orangeSoft)),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Label cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10,),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _addToFavorites(
                                            _favoriteLabelController.text);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeSoft),
                                    child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 12),)
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
        ));
  }

  Future<void> _addToFavorites(String label) async {
    try {
      var user = await getLoggedInUser();

      var jsonResponse = await ApiService.saveFavorite(
        userId: user.userId,
        originStopId: origin?.stopId ?? '',
        destinationStopId: destination?.stopId ?? '',
        favoriteLabel: label
      );
      logger.d('_addToFavorites successful: $jsonResponse');
      handleAddFavoriteSuccess(label);

    } catch (e) {
      logger.d('_addToFavorites Failed:');
      Navigator.of(context).pop();
      showAddToFavoriteFailedDialog(label, e.toString());
      setState(() {
      });
    }
  }

  void handleAddFavoriteSuccess(String label){
    Navigator.of(context).pop();
    showAddToFavoriteSuccessDialog(label);
    setState(() {
    });
  }

  void showAddToFavoriteSuccessDialog(String label){
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 30),
            content: Text('$label has been added to your favorites!'),
          );
        }
    );
  }

  void showAddToFavoriteFailedDialog(String label, String errorMessage){
    showDialog(
        context: context,
        builder: (BuildContext context){
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Icon(Icons.error, color: Colors.redAccent, size: 30),
            content: Text('Failed adding $label to your favorites. $errorMessage'),
          );
        }
    );
  }

  Future<void> getRouteFromRouteId(String routeId) async{
    try{
      thisBusRoute = await DatabaseHelper.getRouteFromRouteId(routeId);
      logger.d('getRouteFromRouteId $thisBusRoute');

    }catch(e){
      logger.d('getRouteFromRouteId failed $e');
    }
  }

  Future<void> setStopListForMaps() async {

    stopList.clear();

    logger.d('setStopListForMaps $upcomingBus ${origin!.order} ${destination!.order}');


    var stopListFuture = await DatabaseHelper.searchStopsInRoute(upcomingBus!.routeId, origin!.order, destination!.order);

    stopList.addAll(stopListFuture);

    List<Location> stopLocation = [];
    for(var stop in stopList){
      logger.d('setStopListForMaps stop  ${stop.location.toString()}');
      stopLocation.add(stop.location!);
    }
    // stopList.map((e) => e.location ?? Location(latitude: '', longitude: '')).toList();


    var polylineCoordinates = await ApiService.getPolylinesWithDirectionsAPI(stopLocation);

    // var polylineCoordinates = stopList.map((stop) =>
    //     LatLng(
    //         double.tryParse(stop.location?.latitude ?? '0.0')  ?? 0.0,
    //         double.tryParse(stop.location?.longitude ?? '0.0')  ?? 0.0
    //     )
    // ).toList();

    //
    var originLatitude = double.tryParse(origin?.location?.latitude ?? '0.0') ?? 0.0;
    var originLongitude = double.tryParse(origin?.location?.longitude ?? '0.0') ?? 0.0;

    if(!isPolyLinesLoaded){
      setState(() {
        // _buildMapsView();
        mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(originLatitude, originLongitude), zoom: 20.0)));
        isPolyLinesLoaded = true;
        _polylines.add(Polyline(
          polylineId: PolylineId(stopList.first.stopId),
          points: polylineCoordinates!,
          color: AppColors.orangeSoft,
          width: 6,
        ));
      });
    } else {
      _polylines.clear();
    }

    // setState(() {
    //
    // });
  }





}
