import 'dart:core';

class Place {
  final String placeId;
  final String placeImage;
  final String stopId;
  final String placeName;
  final String placeDesc;

  Place({required this.placeId, required this.placeImage, required this.stopId, required this.placeName, required this.placeDesc});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        placeId: json['place_id'],
        placeImage: json['place_image'],
        stopId: json['stop_id'],
        placeName: json['place_name'],
        placeDesc: json['place_desc']
    );
  }
}
