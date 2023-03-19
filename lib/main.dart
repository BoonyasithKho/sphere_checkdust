import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sphere_checkdust/utils/my_constant.dart';
import 'package:sphere_checkdust/utils/my_dialog.dart';
import 'package:sphere_maps_flutter/sphere_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

class Content extends StatefulWidget {
  const Content({
    super.key,
    required this.map,
    required this.lng,
    required this.lat,
  });

  final GlobalKey<SphereMapState> map;
  final double? lng;
  final double? lat;

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool mapZoom = false;
    bool mapSwitch = false;
    var marker;

    String adminBoundary =
        'https://gistdaportal.gistda.or.th/data/rest/services/L05_AdminBoundary/L05_Province_GISTDA_50k/MapServer/0';

    return Scaffold(
      appBar: AppBar(
        title: ShowTitle(
          title: 'ข้อมูลจากดาวเทียม',
          textStyle: MyConstant().h1Style(),
        ),
      ),
      body: Stack(
        children: [
          SphereMapWidget(
            apiKey: "test2022", // use sphere key
            bundleId: "",
            key: widget.map,
            eventName: [
              JavascriptChannel(
                name: 'Ready',
                onMessageReceived: (_) {
                  widget.map.currentState
                      ?.call("Ui.LayerSelector.visible", args: [false]);
                  widget.map.currentState
                      ?.call("Ui.DPad.visible", args: [false]);
                  marker = Sphere.SphereObject(
                    "Marker",
                    args: [
                      {
                        "lon": widget.lng,
                        "lat": widget.lat,
                      },
                      {
                        "icon": {
                          "url":
                              'https://cdn-icons-png.flaticon.com/512/3253/3253113.png',
                          "offset": {
                            "x": 0,
                            "y": 0,
                          },
                          "size": {
                            "width": 20,
                            "height": 20,
                          },
                        },
                        "draggable": true
                      },
                    ],
                  );
                  widget.map.currentState?.call("Overlays.add", args: [marker]);
                  widget.map.currentState?.call("bound", args: [
                    {
                      "minLon": 97.143,
                      "minLat": 5.413,
                      "maxLon": 105.837,
                      "maxLat": 20.665,
                    }
                  ]);

                  final layer = Sphere.SphereObject("Layer", args: [
                    "L05_Province_GISTDA_50k",
                    {
                      "type": Sphere.SphereStatic("LayerType", "WMS"),
                      "url": adminBoundary,
                      "srs": " EPSG:3857",
                      "opacity": 0.5,
                      "zindex": 10,
                      "bound": {
                        "minLon": 97.293700,
                        "minLat": 5.562738,
                        "maxLon": 105.686780,
                        "maxLat": 20.514644
                      }
                    }
                  ]);
                  widget.map.currentState?.call("Layers.add", args: [layer]);
                },
              ),
            ],
          ),
          Positioned(
            top: 15,
            right: 10,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8.0),
              ),
              onPressed: () {
                mapSwitch = !mapSwitch;
                if (mapSwitch == true) {
                  widget.map.currentState?.call("Layers.clear");
                  widget.map.currentState?.call("Layers.add",
                      args: [Sphere.SphereStatic("Layers", "IMAGES")]);
                } else {
                  widget.map.currentState?.call("Layers.clear");
                }
              },
              child: const Icon(
                Icons.layers_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          mapZoom = !mapZoom;
          if (mapZoom == true) {
            widget.map.currentState?.call("goTo", args: [
              {
                'center': {
                  'lon': widget.lng,
                  'lat': widget.lat,
                },
                'zoom': 15,
              }
            ]);
          } else {
            widget.map.currentState?.call("goTo", args: [
              {
                'center': {
                  'lon': widget.lng,
                  'lat': widget.lat,
                },
                'zoom': 5.1,
              }
            ]);
          }
        },
        mini: true,
        child: const Icon(Icons.location_searching_sharp),
      ),
    );
  }
}
