import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    // initializeCamera();
    _checkPermissions();

    super.onInit();
  }

  @override
  void dispose() {
    cameraController?.dispose();

    super.dispose();
  }

  RxBool isCompassLock = false.obs;
  updateCompassLock(bool value) {
    isCompassLock.value = value;
    update();
  }

  ScreenshotController screenshotController = ScreenshotController();

  CameraController? cameraController;
  Future<void>? initializeControllerFuture;

  Stream<DateTime> timeStream() {
    return Stream<DateTime>.periodic(const Duration(seconds: 1), (count) {
      return DateTime.now();
    });
  }

  Future<bool> initializeCamera() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    if (cameras.isEmpty) return false;

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    initializeControllerFuture = cameraController!.initialize();
    update();
    return true;
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    await Geolocator.isLocationServiceEnabled();
  }
}
