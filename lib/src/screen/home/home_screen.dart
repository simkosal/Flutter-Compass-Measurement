import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:compass_measurement/src/controllers/home_controller.dart';
import 'package:compass_measurement/src/painter/custom_painter.dart';
import 'package:compass_measurement/src/services/date_time_service.dart';
import 'package:compass_measurement/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getCardinalDirection(double heading) {
    heading = heading % 360;
    if (heading < 0) heading += 360;

    String direction;
    if (heading >= 315 || heading < 45) {
      direction = 'N';
    } else if (heading >= 45 && heading < 135) {
      direction = 'E';
    } else if (heading >= 135 && heading < 225) {
      direction = 'S';
    } else {
      direction = 'W';
    }

    return '${heading.toInt()}° $direction';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GetBuilder(
          init: HomeController(),
          builder: (controller) {
            return StreamBuilder<CompassEvent>(
              stream:
                  controller.isCompassLock.value ? null : FlutterCompass.events,
              builder: (context, snapshot) {
                final size = MediaQuery.of(context).size;

                double? direction;
                if (snapshot.data == null) {
                  direction = 0.0;
                } else {
                  direction = snapshot.data!.heading;
                }
                return Screenshot(
                  controller: controller.screenshotController,
                  child: Stack(
                    children: [
                      if (controller.cameraController != null)
                        Align(
                          alignment: Alignment.center,
                          child: AspectRatio(
                            aspectRatio: controller
                                    .cameraController?.value.aspectRatio ??
                                1.0,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: size.width,
                                height: size.height,
                                child:
                                    CameraPreview(controller.cameraController!),
                              ),
                            ),
                          ),
                        ),
                      _compassBuilder(direction, context, controller),
                      _headerInformation(controller),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }

  Widget _headerInformation(HomeController controller) {
    final theme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          color: Colors.black26,
          child: Wrap(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder(
                        future: LocationServices().getCurrentLocation(),
                        builder: (context, snapshot) {
                          Position? position = snapshot.data;
                          return ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Latitude',
                                    style: theme.bodySmall
                                        ?.copyWith(color: Colors.white)),
                                Text(
                                  "${position?.latitude.toStringAsFixed(6)} ${LocationServices().getLatitudeDirection(position?.latitude ?? 0)}",
                                  style: theme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Longitude',
                                    style: theme.bodySmall
                                        ?.copyWith(color: Colors.white)),
                                Text(
                                  "${position?.longitude.toStringAsFixed(6)} ${LocationServices().getLatitudeDirection(position?.longitude ?? 0)}",
                                  style: theme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: theme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              DateTimeServices().getCurrentDate() ?? 'NA',
                              style: theme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        trailing: StreamBuilder<DateTime>(
                          stream: controller.timeStream(),
                          builder: (context, snapshot) {
                            DateTime? currentTime = snapshot.data;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Time',
                                  style: theme.bodySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                                Text(
                                  currentTime != null
                                      ? DateTimeServices()
                                              .getFormatTime(currentTime) ??
                                          ''
                                      : '-:-',
                                  style: theme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        shareIcon(controller),
      ],
    );
  }

  Align shareIcon(HomeController controller) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              try {
                await controller.screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((Uint8List? image) async {
                  if (image != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final imagePath =
                        await File('${directory.path}/image.png').create();
                    await imagePath.writeAsBytes(image);

                    await Share.shareXFiles([XFile(imagePath.path)]);
                  }
                });
              } catch (e) {
                debugPrint(e.toString());
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.lock, color: Colors.red.shade500),
            onPressed: () async {
              try {
                controller.updateCompassLock(!controller.isCompassLock.value);
              } catch (e) {
                debugPrint(e.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  SizedBox _compassBuilder(
      double? direction, BuildContext context, HomeController controller) {
    return SizedBox(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: CompassPainter(direction ?? 0),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(getCardinalDirection(direction ?? 0),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 35,
                      width: 7,
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
