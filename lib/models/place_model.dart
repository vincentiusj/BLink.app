import 'dart:core';

import 'package:blink_application/models/stop_model.dart';

class Place {
  final String placeId;
  final String placeImage;
  final String stopId;
  final String placeTitle;
  final String placeLocationLink;

  Place({required this.placeId, required this.placeImage, required this.stopId, required this.placeTitle, required this.placeLocationLink});

  factory Place.fromJson(Map<String, dynamic> json) {

    return Place(
        placeId: json['place_id'],
        placeImage: json['place_image'],
        stopId: json['stop_id'],
        placeTitle: json['place_title'],
        placeLocationLink: json['place_location']
    );
  }
}
