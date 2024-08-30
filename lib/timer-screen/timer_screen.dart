import 'dart:io';
import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late CameraMacOSController macOSController;
  late CameraMacOSMode cameraMode;
  Uint8List? lastImagePreviewData;
  GlobalKey cameraKey = GlobalKey();
  String? selectedVideoDevice;
  File? lastPictureTaken;
  List<CameraMacOSDevice> audioDevices = [];
  String? selectedAudioDevice;

  @override
  void initState() {
    super.initState();
    cameraMode = CameraMacOSMode.photo;
    CameraMacOSPlatform.instance
        .initialize(
        cameraMacOSMode: CameraMacOSMode.photo,
        enableAudio: false,
        resolution: PictureResolution.max,
        pictureFormat: PictureFormat.png,
        orientation: CameraOrientation.orientation0deg)
        .then((value) {
      if (value != null) {
        macOSController = CameraMacOSController(value);
      }
    });
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
              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Time: ${state.duration} seconds"),
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
                                  .add(TimerPaused(state.duration));
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
                    (state.screenshotList != null)
                        ? Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: SizedBox(
                        width: 200,
                        height: 500,
                        child: ListView.builder(
                            itemCount: state.screenshotList!.length,
                            itemBuilder: (context,index) =>
                                Align(
                                  heightFactor: 0.048,
                                  child: InkWell(
                                    onTap: () async {
                                      Uri imageUri = Uri.file(state.screenshotList![index]);
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
                                        state.screenshotList![index],
                                        height: 220,
                                        width: 400,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      )
                    )
                        : const SizedBox.shrink(),
                    (state.headshotList != null)
                        ? Positioned(
                        top: 4.0,
                        left: 4.0,
                        child: SizedBox(
                          width: 200,
                          height: 500,
                          child: ListView.builder(
                            itemCount: state.headshotList!.length,
                            itemBuilder: (context,index) =>
                                Align(
                                  heightFactor: 0.048,
                                  child: InkWell(
                                    onTap: () async {
                                      Uri imageUri = Uri.file(state.headshotList![index]);
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
                                        state.headshotList![index],
                                        height: 220,
                                        width: 400,
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
