import 'dart:convert';
import 'dart:core';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:resus_test/Utility/utils/constants.dart';

import '../AppStation/Protect/Incident_report/submit_incident.dart';

class CameraPreviewScreen extends StatefulWidget {
  @override
  _CameraPreviewState createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreviewScreen> {
  late ScaffoldMessengerState scaffoldMessenger;

  List<CameraDescription>? cameras;
  List<CameraLensDirection>? front; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for captured image
  bool _isRearCameraSelected = true;
  bool _isCameraInitialized = true;
  bool _toggleCamera = false;

  bool isLoading = false;
  List<String> imageList = <String>[];

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 10,
          title: Transform(
            // you can forcefully translate values left side using Transform
            transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
            child: const Text(
              "Take Photo",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined,
                color: kReSustainabilityRed),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: [],
        ),
        body: Center(
          child: SizedBox(
              width: 420,
              child: controller == null
                  ? const Center(child: Text("Loading Camera..."))
                  : !controller!.value.isInitialized
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : CameraPreview(controller!)),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: kReSustainabilityRed,
          onPressed: () async {
            try {
              if (controller != null) {
                controller!.setFlashMode(FlashMode.off);
                if (controller!.value.isInitialized) {
                  image = await controller!.takePicture();

                  final result = await FlutterImageCompress.compressWithFile(
                    image!.path,
                    quality: 20,
                    minWidth: 600,
                    minHeight: 600,
                    rotate: 360,
                  );
                  String fileInBase64 = base64Encode(result!);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(
                      context,
                      CapturedImageDetails(
                          imageName: image!.name, image: fileInBase64));
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print(e);
              } //show error
            }
          },
          child: const Icon(
            Icons.camera,
            color: Colors.white,
          ),
        ));
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(
        cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
      );
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      if (kDebugMode) {
        print("NO any camera found");
      }
    }
  }

  void onCameraSelected(camera) {}
}
