import 'dart:io';
import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:camera/camera.dart';
import '../models/ticker.dart';
import 'bloc/timer_bloc.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => TimerBloc(
          ticker: const Ticker(), _screenshotController),
      child: Screenshot(
        controller: _screenshotController,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Timer with Screenshot and Headshot"),
          ),
          body: BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              debugPrint("state $state");
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Time: ${state.duration} seconds"),
                  const SizedBox(height: 20),
                  if (state.screenshot != null)
                    Image.memory(
                      state.screenshot!,
                      height: 500,
                      width: 600,
                    ),
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
                          context.read<TimerBloc>().add(const TimerPaused());
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
