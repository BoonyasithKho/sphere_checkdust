import 'package:flutter/material.dart';
import 'package:sphere_maps_flutter/sphere_maps_flutter.dart';

import 'utils/my_constant.dart';
import 'widgets/show_title.dart';

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
  bool mapPM = false;

  @override
  Widget build(BuildContext context) {
    String adminBoundary =
        'https://gistdaportal.gistda.or.th/data/services/L05_AdminBoundary/L05_Province_GISTDA_50k/MapServer/WMSServer';
    String pmMap =
        'https://gistdaportal.gistda.or.th/data/services/pm_check/pm25_hourly_raster/MapServer/WMSServer';
    Size size = MediaQuery.of(context).size;
    bool mapZoom = false;
    bool mapSwitch = false;
    var marker;

    final layerPM = Sphere.SphereObject("Layer", args: [
      "0",
      {
        "url": pmMap,
        "type": Sphere.SphereStatic("LayerType", "WMS"),
        "opacity": 0.8,
        "zIndex": 5,
        "id": "unique_1",
      }
    ]);

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
                  widget.map.currentState?.call("Layers.setBase",
                      args: [Sphere.SphereStatic("Layers", "SIMPLE")]);
                  // widget.map.currentState
                  //     ?.call("Ui.LayerSelector.visible", args: [false]);
                  // widget.map.currentState
                  //     ?.call("Ui.DPad.visible", args: [false]);

                  // ปิด Zoombar ตามคำแนะนำ
                  // widget.map.currentState
                  //     ?.call("Ui.Zoombar.visible", args: [false]);
                  // widget.map.currentState?.run("map.Ui.Zoombar.visible(false)");

                  // ปิดการหมุน map ของผู้ใช้
                  widget.map.currentState
                      ?.call("Renderer.touchZoomRotate.disableRotation");

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
                      },
                    ],
                  );
                  if (marker != null) {
                    widget.map.currentState
                        ?.call("Overlays.add", args: [marker]);
                  }
                  widget.map.currentState?.call("bound", args: [
                    {
                      "minLon": 97.143,
                      "minLat": 5.413,
                      "maxLon": 105.837,
                      "maxLat": 20.665,
                    }
                  ]);

                  final layer2 = Sphere.SphereObject("Layer", args: [
                    "0",
                    {
                      "type": Sphere.SphereStatic("LayerType", "WMS"),
                      "opacity": 0.5,
                      "url": adminBoundary,
                      "zIndex": 10,
                      "id": "unique_2",
                      "bound": {
                        "minLon": 97.293700,
                        "minLat": 5.562738,
                        "maxLon": 105.686780,
                        "maxLat": 20.514644
                      },
                    },
                  ]);
                  if (layer2 != null) {
                    widget.map.currentState?.call("Layers.add", args: [layer2]);
                  }
                },
              ),
            ],
            options: {
              "ui": Sphere.SphereStatic("UiComponent", "None"),
            },
          ),
          Positioned(
              top: 40,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    mapPM = !mapPM;
                  });
                  if (mapPM == true) {
                    widget.map.currentState
                        ?.call("Layers.add", args: [layerPM]);
                  } else {
                    widget.map.currentState
                        ?.call("Layers.remove", args: [layerPM]);
                  }
                },
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.layers,
                  color: Colors.white,
                  size: 20,
                ),
              )),
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
