import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;

  void startCamera(int camera) {
    cameraController = CameraController(
      widget.cameras[camera],
      ResolutionPreset.max,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(children: [
      FutureBuilder(
          future: cameraValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                  height: size.height,
                  width: size.width,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                          width: 100, child: CameraPreview(cameraController))));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    ]));
  }
}
