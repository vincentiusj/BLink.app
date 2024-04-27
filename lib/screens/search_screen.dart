import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    logger.d('initState $origin | $destination');
    _updateOriginAndDestination();
  }

  Future<void> _updateOriginAndDestination() async {
    logger.d('_updateOriginAndDestination $origin | $destination');
    if (origin != null && destination != null) {
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
      body: Column(
          children: [
            const SizedBox(height: 16),
            _generateStartEndSearchField(),
            _generateMapsView(),
            _generateBusArrivalList()
          ]
      )
    );
  }

  Padding _generateStartEndSearchField(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose Your Route',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16.0),
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
                  return Column(
                    children: stopList != null
                    ? [
                      _generateOriginField(stopList),
                      const SizedBox(height: 16.0),
                      _generateDestinationField(stopList)
                    ] : [
                      Text('StopList not found')
                    ]
                  );
                }
              }
          ),
        ],
      ),
    );

  }

  Expanded _generateMapsView(){
    var originLatitude = double.tryParse(origin?.latitude ?? '0.0') ?? 0.0;
    var originLongitude = double.tryParse(origin?.longitude ?? '0.0') ?? 0.0;
    var destinationLatitude = double.tryParse(destination?.latitude ?? '0.0') ?? 0.0;
    var destinationLongitude = double.tryParse(destination?.longitude ?? '0.0') ?? 0.0;

      return Expanded(
        child: (origin != null && destination != null)
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

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  DropdownButtonFormField<String> _generateOriginField(List<Stop>? stopList) {
    // List<String>? stopNames = stopList?.map((stop) => stop.stopName).toList();
    logger.d('SearchScreen stoplist $stopList}');

    return DropdownButtonFormField<String>(
      value: origin?.stopId,
      decoration: const InputDecoration(
        labelText: 'Start',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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

  DropdownButtonFormField<String> _generateDestinationField(List<Stop>? stopList) {
    // List<String>? stopNames = stopList?.map((stop) => stop.stopName).toList();
    logger.d('SearchScreen stoplist $stopList}');

    return DropdownButtonFormField<String>(
      value: destination?.stopId,
      decoration: const InputDecoration(
        labelText: 'Destination',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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

  Expanded _generateBusArrivalList() {
    return Expanded(
      child: (origin != null && destination != null)
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



}
