class Favorite{
  final String originStopId;
  final String destinationStopId;
  final String favoriteLabel;


  Favorite({required this.favoriteLabel, required this.originStopId, required this.destinationStopId});

  factory Favorite.fromJson(Map<String, dynamic> json){
    return Favorite(
        favoriteLabel: json['favorite_label'],
        originStopId: json['stop_id_start'],
        destinationStopId: json['stop_id_destination']
    );
  }
}