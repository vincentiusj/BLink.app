import 'dart:convert';

import 'package:blink_application/models/GlobalConstants.dart';
import 'package:blink_application/models/user_model.dart';
import 'package:blink_application/repository/user_data.dart';
import 'package:blink_application/res/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/place_model.dart';
import '../repository/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  // final bloc = BlocProvider.of<BlocType>(context);

  @override
  void initState() {
    _scrollController = ScrollController();
      // ..addListener(() {
      //   context.bloc<>().setOffset(_scrollController.offset);
      // });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Image.asset('assets/images/logo_blink_app.png'),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          logger.d('HomeScreen connectionState ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            User? user = snapshot.data;
            logger.d('HomeScreen user $user}');
            if (user != null) {
              return Padding(
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
                    const SizedBox(height: 20.0),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('User not found'),
              );
            }
          }
        },
      ),
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

                  return const Center(child: CircularProgressIndicator());
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
      print('Get user info failed: $e');
    }
  }

  Future<User?> _getUserInfo() async {
    Map<String, String?> loggedInUserKey = await getLoggedInUserKey();
    print('login $loggedInUserKey');
    try {
      var jsonResponse = await ApiService.getUserInfo(
        userId: loggedInUserKey['userId']!,
        role: loggedInUserKey['role']!,
      );
      return User.fromJson(jsonResponse);
    } catch (e) {
      print('Get user info failed: $e');
    }
  }

  void navigateToSearchScreen() {
    Navigator.pushNamed(context, '/search');
  }

  void navigateToStopsScreen() {
    Navigator.pushNamed(context, '/stops');
  }
}
