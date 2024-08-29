import 'dart:io';
import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ticker.dart';
import 'bloc/timer_bloc.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  CameraMacOSController? macOSController;
  late CameraMacOSMode cameraMode;
  Uint8List? lastImagePreviewData;
  GlobalKey cameraKey = GlobalKey();
  String? selectedVideoDevice;
  PictureResolution selectedPictureResolution = PictureResolution.max;
  PictureFormat selectedPictureFormat = PictureFormat.png;
  CameraOrientation selectedOrientation = CameraOrientation.orientation0deg;
  File? lastPictureTaken;

  List<CameraMacOSDevice> audioDevices = [];
  String? selectedAudioDevice;

  bool enableAudio = true;
  bool enableTorch = false;
  bool usePlatformView = false;
  bool streamImage = false;

  @override
  void initState() {
    super.initState();
    cameraMode = CameraMacOSMode.photo;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          TimerBloc(ticker: const Ticker(), _screenshotController),
      child: Screenshot(
        controller: _screenshotController,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Timer with Screenshot and Headshot"),
          ),
          body: BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              debugPrint("state $state");
              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Time: ${state.duration} seconds"),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: (size.width * 0.5),
                          height: (size.width * 0.5) * (9 / 16),
                          child: CameraMacOSView(
                            key: cameraKey,
                            deviceId: selectedVideoDevice,
                            fit: BoxFit.fitWidth,
                            cameraMode: CameraMacOSMode.photo,
                            resolution: selectedPictureResolution,
                            pictureFormat: selectedPictureFormat,
                            orientation: selectedOrientation,
                            onCameraInizialized:
                                (CameraMacOSController controller) {
                              setState(() {
                                macOSController = controller;
                              });
                            },
                            onCameraDestroyed: () {
                              return const Text("Camera Destroyed!");
                            },
                            toggleTorch: enableTorch ? Torch.on : Torch.off,
                            enableAudio: enableAudio,
                            usePlatformView: usePlatformView,
                          )),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TimerBloc>()
                                  .add(TimerStarted(state.duration));
                            },
                            child: const Text("Start Timer"),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TimerBloc>()
                                  .add(const TimerPaused());
                            },
                            child: const Text("Stop Timer"),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TimerBloc>().add(TimerReset());
                            },
                            child: const Text("Reset Timer"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if(state is CaptureScreenshot)
                    (state.lastPictureTakenList != null)
                        ? Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: SizedBox(
                        width: 200,
                        height: 500,
                        child: ListView.builder(
                            itemCount: state.lastPictureTakenList!.length,
                            itemBuilder: (context,index) =>
                                Align(
                                  widthFactor: 0.1,
                                  heightFactor: 0.1,
                                  child: InkWell(
                                    onTap: () async {
                                      Uri imageUri = Uri.file(state.lastPictureTakenList![index]);
                                      if (await canLaunchUrl(imageUri)) {
                                        await launchUrl(imageUri);
                                      }
                                      },
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          side: const BorderSide(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: Image.asset(
                                        state.lastPictureTakenList![index],
                                        height: 100,
                                        width: 140,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      )
                    )
                        : const SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
