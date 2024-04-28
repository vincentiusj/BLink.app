import 'dart:convert';
import 'package:blink_application/models/stop_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/GlobalConstants.dart';

class ApiService {
  static const String baseUrl = 'http://152.42.192.127:8086/';

  static dynamic _processResponse(http.Response response, [String? requestBody]) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    // Log the request
    logger.i('HTTP GET Request: ${response.request!.url}');
    logger.i('HTTP GET Request: $requestBody');

    // Log the response status code and body
    logger.i('HTTP Response Status Code: $statusCode');
    logger.i('HTTP Response Body: $responseBody');

    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('Failed to load data: $statusCode - $responseBody');
    }

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
      'role': "PASSENGER",
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

  static Future<void> computeRoute(Stop origin, Stop destination) async {
    const apiKey = 'AIzaSyC7uRjGhqPKd-LuW799pNroEqta2c0ER_s';
    final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

    final requestBody = jsonEncode({
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude
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
    logger.i('HTTP Response Status Code: ${response.statusCode}');
    logger.i('HTTP Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

    } else {
      // Handle error
      print('Failed to compute route: ${response.statusCode}');
    }

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

  static Future<List<dynamic>> getPlaceList() async {
    final url = Uri.parse('${baseUrl}places');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  static String _getFutureDateTime(){
    DateTime now = DateTime.now();
    DateTime futureTime = now.add(Duration(minutes: 2));
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSSSSZ").format(futureTime);
    logger.d('_getFutureDateTime $formattedDate');
    return formattedDate;
  }

}
