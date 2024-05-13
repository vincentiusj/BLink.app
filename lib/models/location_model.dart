class Location {
  final String latitude;
  final String longitude;
  late final String? latestETA;

  Location({required this.latitude, required this.longitude, this.latestETA});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }

  factory Location.fromMap(Map<String, dynamic> maps) {
    return Location(
        latitude: maps['latitude'],
        longitude: maps['longitude']
    );
  }

  @override
  String toString() {
    return 'Location: latitude: $latitude , longitude: $longitude';
  }
}
