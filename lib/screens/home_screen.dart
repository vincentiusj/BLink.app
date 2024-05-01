import 'dart:convert';

import 'package:blink_application/models/GlobalConstants.dart';
import 'package:blink_application/models/user_model.dart';
import 'package:blink_application/res/strings.dart';
import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../repository/api_service.dart';

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
                style: TextStyle(fontSize: 20.0)),
            const SizedBox(height: 10.0),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    navigateToSearchScreen();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.orangeAccent),
                      SizedBox(width: 8.0),
                      Text(
                          'Search bus stop destination',
                          style: TextStyle(color: Colors.orangeAccent)
                      )
                    ],
                  ),
                )
            ),
            const SizedBox(height: 10.0),
            const Text('Places For You', style: TextStyle(fontSize: 20.0)),
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
                  List<Place> placeList = [Place(placeId: 'place123', placeImage:  imageSrcBase64, stopId: 'stop123', placeName: 'Wisma BCA Foresta', placeDesc: 'This is Wisma')];
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
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.memory(
                    base64Decode(imageSrcBase64),
                    width: 400,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  ListTile(
                    title: Text(
                      place.placeName,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                ],
              )
            );
          },
        )
    );
  }

  Future<List<Place>?> _getPlaceList() async {
    try {
      //todo ganti jadi get getPlaceList
      var jsonResponse = await ApiService.getPlaceList();
      List<Place> placeList = jsonResponse.map((json) => Place.fromJson(json)).toList();

      return placeList;
    } catch (e) {
      print('_getPlaceList failed: $e');
    }
  }

  void navigateToSearchScreen() {
    Navigator.pushNamed(context, '/search');
  }

  void navigateToStopsScreen() {
    Navigator.pushNamed(context, '/stops');
  }
}
