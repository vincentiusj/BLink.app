import 'dart:convert';
import 'package:blink_application/models/location_model.dart';
import 'package:blink_application/models/stop_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../util/global_contans.dart';
import '../models/bus_model.dart';

class ApiService {
  static const String baseUrl = 'http://152.42.192.127:8086/';

  static dynamic _processResponse(http.Response response, [String? requestBody]) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    // Log the request
    logger.i('HTTP ${response.request}');
    logger.i('HTTP Request: $requestBody');

    // Log the response status code and body
    logger.i('HTTP Response Status Code: $statusCode');
    logger.i('HTTP Response Body: $responseBody');



    final jsonBody = jsonDecode(responseBody);

    if (jsonBody.containsKey('output_schema')) {
      return jsonBody['output_schema'];
    } else if (jsonBody.containsKey('error_schema')) {
      throw Exception('API Error: ${jsonBody['error_schema']}');
    } else {
      throw Exception('Invalid JSON response: $jsonBody');
    }

  }

  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    String? phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse(baseUrl + 'register');
    final requestBody = jsonEncode({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
      'role': "DRIVER",
    });

    final response = await http.put(
      url,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return _processResponse(response, requestBody);
  }

  static Future<Map<String, dynamic>> loginUser({
    required String emailOrPhone,
    required String password,
  }) async {
    final url = Uri.parse(baseUrl + 'login');
    final requestBody = jsonEncode({
      'email': emailOrPhone,
      'password': password,
    });
    final response = await http.post(
      url,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return _processResponse(response, requestBody);
  }

  static Future<Map<String, dynamic>> getUserInfo({
    required String userId,
    required String role
  }) async {
    final url = Uri.parse('${baseUrl}info/$userId?role=$role' );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return _processResponse(response);

  }

  static Future<List<dynamic>> getRouteBusList() async {
    final url = Uri.parse('${baseUrl}get-route-bus');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  static Future<List<dynamic>> getRouteStopList() async {
    final url = Uri.parse('${baseUrl}get-route-stop');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> computeRoute(Location currentBusLocation, Location originStop) async {
    const apiKey = 'AIzaSyC7uRjGhqPKd-LuW799pNroEqta2c0ER_s';
    final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

    logger.d('compute route');
    final requestBody = jsonEncode({
      'origin': {
        'location': {
          'latLng': {
            'latitude': currentBusLocation.latitude,
            'longitude': currentBusLocation.longitude
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': originStop.latitude,
            'longitude': originStop.longitude
          }
        }
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      "departureTime": _getFutureDateTime(),
      "computeAlternativeRoutes": false,
      "routeModifiers": {
        "avoidTolls": false,
        "avoidHighways": false,
        "avoidFerries": false
      },
      "languageCode": "en-US",
      "units": "IMPERIAL"
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
      },
      body: requestBody
    );
    // Log the request
    logger.i('HTTP GET Request: ${response.request!.url}');
    logger.i('HTTP GET Request: ${requestBody}');
    logger.i('HTTP Response Status Code: ${response.statusCode}');
    logger.i('HTTP Response Body: ${response.body}');


    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);

  }

  static Future<Map<String, dynamic>> tapIn({
    required String busId,
    required String userId,
    required String role
  }) async {
    final url = Uri.parse(baseUrl + 'tap-in');
    final requestBody = jsonEncode({
      'bus_id': busId,
      'user_id': userId,
      'role': role,
    });
    final response = await http.post(
      url,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response, requestBody);
  }

  static Future<Map<String, dynamic>> tapOut({
    required String busId,
    required String userId,
    required String role,
    required String transactionId
  }) async {
    final url = Uri.parse(baseUrl + 'tap-out');
    final requestBody = jsonEncode({
      'bus_id': busId,
      'user_id': userId,
      'role': role,
      'transaction_id': transactionId
    });
    final response = await http.post(
      url,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response, requestBody);
  }

  static Future<List<dynamic>> getPlaceList() async {
    final url = Uri.parse('${baseUrl}recommendation/all');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  static Future<dynamic> getBusActivityInfo(Bus bus) async {
    final url = Uri.parse('${baseUrl}bus-activity-info/${bus.busId}');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  static Future<dynamic> busActivityCheck({
    required String busId,
    required String userId,
    required String latitude,
    required String longitude
  }) async {
    final url = Uri.parse('${baseUrl}bus-activity-check');
    final requestBody = jsonEncode({
      'bus_id': busId,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody
    );
    return _processResponse(response);
  }

  static Future<dynamic> saveFavorite({
    required String userId,
    required String originStopId,
    required String destinationStopId,
    required String favoriteLabel
  }) async {
    final url = Uri.parse('${baseUrl}favorite/save');
    final requestBody = jsonEncode({
      'user_id': userId,
      'stop_id_start': originStopId,
      'stop_id_destination': destinationStopId,
      'favorite_label': favoriteLabel,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody
    );
    return _processResponse(response, requestBody);
  }

  static Future<List<dynamic>> getFavorites({
    required String userId
  }) async {
    final url = Uri.parse('${baseUrl}favorite/$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  static Future<dynamic> submitFeedback({
    required String userId,
    required String feedback,
    required int rating
  }) async {
    final url = Uri.parse('${baseUrl}feedback/save');
    final requestBody = jsonEncode({
      'passenger_id': userId,
      'feedback': feedback,
      'rating': rating,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody
    );
    return _processResponse(response);
  }

  static Future<dynamic> clearAllFavorites({
    required String userId,
  }) async {
    final url = Uri.parse('${baseUrl}favorite/delete');
    final requestBody = jsonEncode({
      'user_id': userId,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody
    );
    return _processResponse(response);
  }

  static Future<dynamic> editProfile({
    required String userId,
    required String role,
    required String profileImage,
  }) async {
    final url = Uri.parse('${baseUrl}profile/edit');
    final requestBody = jsonEncode({
      'user_id': userId,
      'role': role,
      'profile_image': profileImage,
    });
    final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody
    );
    return _processResponse(response, requestBody);
  }

  static String _getFutureDateTime(){
    logger.d('_getFutureDateTime masuk');
    DateTime now = DateTime.now();
    DateTime futureTime = now.add(Duration(minutes: 2));
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'").format(futureTime);
    logger.d('_getFutureDateTime $formattedDate');
    return formattedDate;
  }
}
