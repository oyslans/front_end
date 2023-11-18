import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_frontend/src/connection/connection.dart';

enum DetectionStatus { noFace, fail, success, scan, noRecog }

var name = "";

Color namColour = Colors.red;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeWebSocket();
  }

  ///============================
  ///       USED VARIABLES
  ///============================

  late String buttonValue;
  bool isClicked = false;
  bool isScanButtonVisible = true;
  bool isAllButtonsVisible = false;
  bool isSignInShow = false;
  bool isSignOutShow = false;
  bool isLunchInShow = false;
  bool isLunchOutShow = false;

  ///===========================================
  ///   USED FOR CHECKING DATA RECEIVED OR NOT
  ///===========================================

  late bool isLoaded;

  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xFF000000);
  CameraController? controller;
  late WebSocketChannel channel;
  late WebSocketChannel channel2;
  DetectionStatus? status;

  String get currentStatus {
    if (status == null) {
      setState(() {
        isAllButtonsVisible = false;
        isClicked = false;
      });
      return "Scanning";
    }
    switch (status!) {
      case DetectionStatus.noFace:
        setState(() {
          isAllButtonsVisible = false;
        });
        return "No face detected";

      case DetectionStatus.fail:
        setState(() {
          isAllButtonsVisible = false;
        });
        return "Attendance already marked";

      case DetectionStatus.success:
        setState(() {
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          print("succcess");
          isAllButtonsVisible = true;
        });
        channel.sink.close();
        if (isClicked == true) {
          retakePicture();
          initializeWebSocket();
          setState(() {
            isAllButtonsVisible = false;
            isClicked = false;
          });
          // if (status == DetectionStatus.success) {
          //   return name;
          // } else {
          //   return "Scanning";
          // }
          return "";
        } else {
          return name;
        }

      case DetectionStatus.scan:
        setState(() {
          isAllButtonsVisible = false;
          isClicked = false;
        });
        return "Scanning";
      case DetectionStatus.noRecog:
        return "No face Recognized";
    }
  }

  Color get currentStatusColor {
    if (status == null) {
      return Colors.white70;
    }
    switch (status!) {
      case DetectionStatus.noFace:
        return Colors.orangeAccent;
      case DetectionStatus.fail:
        return Colors.red;
      case DetectionStatus.success:
        return Colors.green;
      case DetectionStatus.scan:
        return Colors.white70;
      case DetectionStatus.noRecog:
        return Colors.orangeAccent;
    }
  }

  void stopWebsocket() {
    channel.sink.close();
  }

  Future<void> takePicture() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final image = await controller!.takePicture();
        final compressedImageBytes = compressImage(image.path);
        channel.sink.add(compressedImageBytes);
        channel.sink.add(buttonValue);

        setState(() {
          buttonValue = '';
        });
      } catch (_) {}
    });
  }

  Connection connection = Connection();
  Future<void> retakePicture() async {
    channel = IOWebSocketChannel.connect('ws://${connection.conn}');
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final image = await controller!.takePicture();
        final compressedImageBytes = compressImage(image.path);
        channel.sink.add(compressedImageBytes);
        channel.sink.add(buttonValue);

        setState(() {
          buttonValue = '';
        });
      } catch (_) {}
    });
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras[0];

    controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.yuv420, // oppo added
    );

    await controller!.initialize();
    setState(() {});
  }

  void initializeWebSocket() {
    channel = IOWebSocketChannel.connect('ws://${connection.conn}');
    channel.stream.listen((dynamic data) {
      debugPrint(data);
      data = jsonDecode(data);

      print(data['data']);
      print(data['data']);
      print(data['data']);
      print(data['data']);
      print(data['data']);
      print(data['data']);
      print(data['data']);
      print(data['data']);
      print(data['data']);

      if (data['data'] == null) {
        debugPrint('Server error occurred in recognizing face');
        return;
      } else {
        setState(() {
          isLoaded = true;
        });
      }
      if (data['lastatt'] == "") {
        setState(() {
          isSignInShow = false;
          isSignOutShow = false;
          isLunchInShow = false;
          isLunchOutShow = false;
        });
      } else if (data['lastatt'] == "Sign-in") {
        setState(() {
          isSignInShow = false;
          isSignOutShow = true;
          isLunchInShow = false;
          isLunchOutShow = true;
        });
      } else if (data['lastatt'] == null) {
        setState(() {
          isSignInShow = true;
          isSignOutShow = false;
          isLunchInShow = false;
          isLunchOutShow = false;
        });
      } else if (data['lastatt'] == "Sign-out") {
        setState(() {
          isSignInShow = true;
          isSignOutShow = false;
          isLunchInShow = false;
          isLunchOutShow = false;
        });
      } else if (data['lastatt'] == "Lunch-in") {
        setState(() {
          isSignInShow = false;
          isSignOutShow = true;
          isLunchInShow = false;
          isLunchOutShow = false;
        });
      } else if (data['lastatt'] == "Lunch-out") {
        setState(() {
          isSignInShow = false;
          isSignOutShow = true;
          isLunchInShow = true;
          isLunchOutShow = false;
        });
      }
      name = data["name"];
      // print("test : $data['status']");
      switch (data['data']) {
        case 0:
          status = DetectionStatus.noFace;
          break;
        case 1:
          status = DetectionStatus.fail;
          break;
        case 2:
          status = DetectionStatus.success;
          break;
        case 3:
          status = DetectionStatus.scan;
          break;
        case 4:
          status = DetectionStatus.noRecog;
          break;
        default:
          status = DetectionStatus.noFace;
          break;
      }
      setState(() {});
    }, onError: (dynamic error) {
      debugPrint('Error: $error');
    }, onDone: () {
      debugPrint('WebSocket connection closed');
    });
  }

  Uint8List compressImage(String imagePath, {int quality = 85}) {
    final image =
        img.decodeImage(Uint8List.fromList(File(imagePath).readAsBytesSync()))!;
    final compressedImage =
        img.encodeJpg(image, quality: quality); // lossless compression
    return compressedImage;
  }

  @override
  void dispose() {
    controller?.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (!(controller?.value.isInitialized ?? false)) {
      return const SizedBox();
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
              height: screenHeight /1.5,
              width: screenWidth,
              child: CameraPreview(controller!)),
          Container(
            padding: const EdgeInsets.only(top: 20),
            color: Colors.black,
            width: screenWidth,
            alignment: Alignment.center,
            child: Text(
              currentStatus,
              style: TextStyle(
                  fontSize: 20,
                  color: currentStatusColor,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w800),
            ),
          ),
          Visibility(
            visible: isScanButtonVisible,
            child: Container(
              height: screenHeight - (screenHeight / 1.5 + 49),
              width: screenWidth,
              alignment: Alignment.center,
              color: Colors.black,
              child: _scanNow(),
            ),
          ),
          // isAllButtonsVisible == true && isClicked == false
          Visibility(
            visible: isAllButtonsVisible,
            child: Container(
              height: screenHeight - (screenHeight / 1.5 + 49),
              width: screenWidth,
              alignment: Alignment.center,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: screenWidth / 20,
                    runSpacing: 30,
                    children: [
                      _buttonWidget("Sign-in", isSignInShow),
                      _buttonWidget("Lunch-in", isLunchInShow),
                      _buttonWidget("Lunch-out", isLunchOutShow),
                      _buttonWidget("Sign-out", isSignOutShow),

                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            // child: _buildLoader(),
            child: Container(
                color: Colors.black,
                width: screenWidth ,
                // height: screenHeight / 3,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Image.asset("assets/images/facescan2.gif"),
              ),
          //
          //   /// SHOULD SET VISIBILITY, ITS RUNNING AT BOTTOM
          )
        ],
      ),
    );
  }

  Widget _buttonWidget(String text, bool isVisible) {
    return Visibility(
      visible: isVisible,
      child: ElevatedButton(
        onPressed: () {
          retakePicture();
          setState(() {
            buttonValue = text;
            isClicked = true;
            isAllButtonsVisible = false;
          });
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(130, 50),
            backgroundColor: Colors.white,
            side: BorderSide.none,
            shape: const StadiumBorder()),
        child: Text(text, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      color: Colors.black,
      child: const SpinKitCircle(
        size: 140,
        color: Colors.white,
      ),
    );
  }

  Widget _scanNow() {
    return ElevatedButton(
      onPressed: () {
        takePicture();
        setState(() {
          isScanButtonVisible = false;
        });
      },
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(130, 50),
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: const StadiumBorder()),
      child: const Text("Scan Now", style: TextStyle(color: Colors.black)),
    );
  }
}

/**
 * ==================================
 * Removed Parts
 * ==================================
 *
    // Container(
    //   color: Colors.black,
    //   width: screenWidth / 4,
    //   // height: screenHeight / 3,
    //   margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    //   child: status == DetectionStatus.success
    //       ? Image.asset("assets/images/success2.png")
    //       : Image.asset("assets/images/facescan.gif"),
    // ),

    //   Image.asset(
    //   'assets/images/logo/logo-min.png',
    //   height: 100,
    //   width: 200,
    //   fit: BoxFit.fitWidth,
    // ),

 */
