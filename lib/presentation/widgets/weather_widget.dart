import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String? _weatherIcon;
  double? _temperature;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      var status = await Permission.location.request();
      if (status == PermissionStatus.denied) {
        print('Location permission denied by user');
      } else if (status == PermissionStatus.granted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        _fetchWeather(position.latitude, position.longitude);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchWeather(double latitude, double longitude) async {
    final apiKey = 'd30ae4971552b57c2ba87a37a4068067';
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

    try {
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String iconCode = data['weather'][0]['icon'];
        double temperature = data['main']['temp'] - 273.15;

        setState(() {
          _weatherIcon = 'http://openweathermap.org/img/wn/$iconCode.png';
          _temperature = temperature;
        });
      } else {
        print('Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_temperature != null)
            Text(
              '${_temperature!.toStringAsFixed(0)}°C',
              style: TextStyle(fontSize: 24.0, color: Colors.black),
            ),
          SizedBox(width: 14.0),
          if (_weatherIcon != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(8.0),
              child: Image.network(
                _weatherIcon!,
                width: 30.0,
                height: 30.0,
              ),
            ),
          SizedBox(width: 20.0),
        ],
      );
  }
}