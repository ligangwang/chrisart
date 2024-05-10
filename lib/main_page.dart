import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  List<File> imageList = [];
  bool isFlashOn = false;
  bool isRearCamera = true;

  Future<File> saveImage(XFile image) async {
    final folder = await getApplicationDocumentsDirectory();
    final File file =
        File('${folder.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (_) {}
    return file;
  }

  void takePicture() async {
    XFile? image;
    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) return;
    cameraController.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    image = await cameraController.takePicture();
    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }
    final file = await saveImage(image);
    setState(() {
      imageList.add(file);
    });

    MediaScanner.loadMedia(path: file.path);
  }

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
        floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromRGBO(255, 255, 255, .7),
            shape: CircleBorder(),
            onPressed: takePicture,
            child: const Icon(
              Icons.camera_alt,
              size: 40,
              color: Colors.black87,
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                              width: 100,
                              child: CameraPreview(cameraController))));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          SafeArea(
              child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRearCamera = !isRearCamera;
                      });
                      isRearCamera ? startCamera(0) : startCamera(1);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(50, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: isRearCamera
                                ? Icon(
                                    Icons.camera_rear,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(Icons.camera_front,
                                    color: Colors.white, size: 30))),
                  ),
                ],
              ),
            ),
          )),
          Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                          padding: EdgeInsets.only(left: 7, bottom: 75),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: imageList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                      padding: EdgeInsets.all(2),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image(
                                            width: 100,
                                            height: 100,
                                            image: FileImage(
                                                File(imageList[index].path)),
                                            fit: BoxFit.cover,
                                          )));
                                },
                              ))))
                ],
              )),
        ]));
  }
}
