import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sphere_checkdust/utils/my_constant.dart';
import 'package:sphere_checkdust/utils/my_dialog.dart';
import 'package:sphere_maps_flutter/sphere_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'content.dart';
import 'widgets/show_title.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double? lat, lng;

  final map = GlobalKey<SphereMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    bool locationService;
    LocationPermission locationPermission;
    locationService = await Geolocator.isLocationServiceEnabled();

    if (locationService) {
      // print('Service Location Open');
      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          MyDialog().alertLocationService(
              context, 'ไม่อนุญาตเเชร์ Location', 'โปรดแชร์ Location');
        } else {
          findLatLng();
        }
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          MyDialog().alertLocationService(
              context, 'ไม่อนุญาตเเชร์ Location', 'โปรดแชร์ Location');
        } else {
          findLatLng();
        }
      }
    } else {
      // print('Service Location Close');
      MyDialog().alertLocationService(context, 'Location Service ปิดอยู่?',
          'กรุณาเปิด Location Service ด้วยครับ');
    }
  }

  Future<void> findLatLng() async {
    print("FindLatLong Work");
    Position? position = await findPosition();
    setState(() {
      lat = position!.latitude;
      lng = position.longitude;
      print("lat = $lat, long = $lng");
    });
  }

  Future<Position?> findPosition() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messenger,
      home: Content(map: map, lng: lng, lat: lat),
    );
  }
}
