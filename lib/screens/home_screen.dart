import 'package:blink_application/models/favorite_model.dart';
import 'package:blink_application/models/location_model.dart';
import 'package:blink_application/models/user_model.dart';
import 'package:blink_application/res/colors.dart';
import 'package:blink_application/screens/search_screen.dart';
import 'package:blink_application/util/global_contans.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Stop? nearestStopFromHere;

  @override
  void initState() {
    super.initState();
    _initializeData();

  }
  Future<void> _initializeData() async {
    var nearestStopFromHere = await _getNearestStopFromHere();
    setState(() {
      this.nearestStopFromHere = nearestStopFromHere;
    });
  }
  @override
  Widget build(BuildContext context) {
    var user = widget.loggedInUser;

    logger.d('home $user');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hi, ${user.fullName}',
                style: GoogleFonts.permanentMarker(),),
            const Text('Go somewhere?',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10.0),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ()  {
                    navigateToSearchScreen(nearestStopFromHere, null);
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
                          'Search Bus Stop',
                          style: TextStyle(color: AppColors.teaBrown, fontWeight: FontWeight.w200)
                      )
                    ],
                  ),
                )
            ),
            const SizedBox(height: 10.0),
            _generateFavoriteListView(user),
            const SizedBox(height: 15.0),
            const Text('Around BSD', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
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
                        _generatePlaceCards(placeList),
                        const SizedBox(height: 16.0),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return showPlaceDialog(place);
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

  Future<Stop?> _getNearestStopFromHere() async {
    logger.d('nearestStopFromHere');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    var currentLocation = Location(latitude: position.latitude.toString(), longitude: position.longitude.toString());
    logger.d('nearestStopFromHere $currentLocation');

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

  Widget _generateFavoriteListView(User user){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: FutureBuilder(
          future: _getFavoriteList(user),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              List<Favorite>? favoriteList = snapshot.data;
              if(favoriteList != null && favoriteList.isNotEmpty){
                return Container(
                  height: 40,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteList.length,
                      itemBuilder: (context, index) {
                        Favorite? favorite = favoriteList[index];
                        return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: (){
                                redirectToSearchScreen(favorite);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teaBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.bookmark, color: AppColors.orangeSoft),
                                  SizedBox(width: 8.0),
                                  Text(
                                      favorite.favoriteLabel,
                                      style: TextStyle(color: AppColors.orangeSoft, fontWeight: FontWeight.w300)
                                  )
                                ],
                              ),
                            )
                        );
                      }
                  ),
                );
              }else {
                return Container(height: 0,);
              }
            }
          }),
    );
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

  Future<List<Favorite>?> _getFavoriteList(User user) async {
    try {
      var jsonResponse = await ApiService.getFavorites(userId: user.userId);
      List<Favorite> favoriteList = jsonResponse.map((json) => Favorite.fromJson(json)).toList();
      logger.d('_getFavoriteList $favoriteList');
      return favoriteList;
    } catch (e) {
      print('_getFavoriteList failed: $e');
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

  void redirectToSearchScreen(Favorite favorite) async {
    var originStop = await DatabaseHelper.getStopById(favorite.originStopId);
    var destinationStop = await DatabaseHelper.getStopById(favorite.destinationStopId);

    navigateToSearchScreen(originStop, destinationStop);
  }

  Widget showPlaceDialog(Place place) {
    return FutureBuilder (
        future: _getStopPair(place.stopId),
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
            var stopPair = snapshot.data;
            var nearestStopFromHere = stopPair?['stop1'];
            var nearestStopFromPlace = stopPair?['stop2'];

            if(stopPair != null){
              return AlertDialog(
                backgroundColor: AppColors.teaBrown,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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

            }
            else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        }
    );
  }

  Future<Map<String, Stop?>> _getStopPair(String placeStopId) async {
    var nearestStopFromHere = await _getNearestStopFromHere();
    var nearestStopFromPlace = await DatabaseHelper.getStopById(placeStopId);
    return {'stop1': nearestStopFromHere, 'stop2': nearestStopFromPlace};
  }


}


