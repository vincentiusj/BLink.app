import 'package:blink_application/models/location_model.dart';
import 'package:blink_application/models/user_model.dart';
import 'package:blink_application/res/colors.dart';
import 'package:blink_application/screens/search_screen.dart';
import 'package:blink_application/util/global_contans.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/place_model.dart';
import '../models/stop_model.dart';
import '../repository/api_service.dart';
import '../repository/database_helper.dart';
import '../util/calculate_distance.dart';

class HomeScreen extends StatefulWidget {
  final User loggedInUser;

  const HomeScreen({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var user = widget.loggedInUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hi, ${user.fullName}',
                style: const TextStyle(fontSize: 16.0)),
            const Text('Go somewhere?',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10.0),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    navigateToSearchScreen(null, null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.teaBrown),
                      SizedBox(width: 8.0),
                      Text(
                          'Search bus stop destination',
                          style: TextStyle(color: AppColors.teaBrown, fontWeight: FontWeight.w200)
                      )
                    ],
                  ),
                )
            ),
            const SizedBox(height: 10.0),
            const Text('Places For You', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
            _generatePlaceListView(),
          ],
        ),
      )
    );
  }

  Expanded _generatePlaceListView() {
    return Expanded(
        child: FutureBuilder (
            future: _getPlaceList(),
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
                List<Place>? placeList = snapshot.data;
                if(placeList != null){
                  return Column(
                      children: [
                        const SizedBox(height: 16.0),
                        _generatePlaceCards(placeList)
                      ]
                  );
                } else {
                  List<Place> placeList = [Place(placeId: 'place123', placeImage:  imageSrcBase64, stopId: 'stop123', placeTitle: 'Wisma BCA Foresta', placeLocationLink: 'This is Wisma')];
                  return _generatePlaceCards(placeList);
                }
              }
            }
        )
    );
  }

  Expanded _generatePlaceCards(List<Place> placeList) {
    return Expanded(
        child: ListView.builder(
          itemCount: placeList.length,
          itemBuilder: (context, index) {
            Place place = placeList[index];
            return GestureDetector(
              onTap: () async {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                var currentLocation = Location(latitude: position.latitude.toString(), longitude: position.longitude.toString());
                var nearestStopFromHere = await _getNearestStopFromHere(currentLocation);
                var nearestStopFromPlace = await DatabaseHelper.getStopById(place.stopId);

                logger.d('_generatePlaceCards $currentLocation | $nearestStopFromPlace | $nearestStopFromHere');

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: AppColors.teaBrown,
                      actions: <Widget>[
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.close_fullscreen,
                                color: AppColors.orangeSoft,
                              ),
                            ),
                          ],
                        ),
                      ],
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(child: Text(
                            place.placeTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orangeSoft
                            ),
                          )),
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              place.placeImage,
                              fit: BoxFit.cover,
                              height: 200,
                            ),
                          ),
                          SizedBox(height: 8),
                          SizedBox(height: 16),
                          FutureBuilder(
                              future: DatabaseHelper.getStopById(place.stopId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                } else {
                                  Stop? stop = snapshot.data;
                                  if(stop != null){
                                    return ElevatedButton(
                                        onPressed: () {
                                          navigateToSearchScreen(nearestStopFromHere, nearestStopFromPlace);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.orangeSoft,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text('Go To ', style: TextStyle(color: AppColors.teaBrown)),
                                            SizedBox(width: 10,),
                                            Icon(Icons.directions_bus_filled, color: AppColors.teaBrown),
                                            SizedBox(width: 10,),
                                            Text(stop.stopName, style: TextStyle(color: AppColors.teaBrown),),
                                          ],
                                        )
                                    );
                                  } else {
                                    return Text('No Stop Available');
                                  }
                                }
                              }
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Card(
                elevation: 4,
                color: AppColors.orangeSoft,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        place.placeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            place.placeTitle,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.teaBrown
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              var launchMapLink = launch(place.placeLocationLink);
                              logger.d('launchMapLink $launchMapLink | ${place.placeLocationLink}');
                            },
                            child: Icon(Icons.map_sharp, color: AppColors.orangeSoft,),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teaBrown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

          },
        )
    );
  }

  Future<Stop?> _getNearestStopFromHere(Location currentLocation) async {
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


  Future<List<Place>?> _getPlaceList() async {
    try {
      var jsonResponse = await ApiService.getPlaceList();
      List<Place> placeList = jsonResponse.map((json) => Place.fromJson(json)).toList();

      logger.d('_getPlaceList $placeList');
      return placeList;
    } catch (e) {
      print('_getPlaceList failed: $e');
    }
  }

  void navigateToSearchScreen(Stop? originStop, Stop? destinationStop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          origin: originStop,
          destination: destinationStop,
        ),
      ),
    );
  }

  void navigateToStopsScreen() {
    Navigator.pushNamed(context, '/stops');
  }
}
