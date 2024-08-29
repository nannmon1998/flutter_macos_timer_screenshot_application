import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera_macos/camera_macos.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../models/ticker.dart';
import 'package:path/path.dart' as pathJoiner;

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final ScreenshotController _screenshotController;
  static const _duration = 20;

  // to listen to the ticker stream
  StreamSubscription<int>? _tickerSubscription;

  Future<String> get imageFilePath async =>
      pathJoiner.join(
          (await getApplicationDocumentsDirectory()).path,
          "P_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${
              DateTime.now().hour}${DateTime.now().minute}${DateTime.now().
          second}.${selectedPictureFormat.name.replaceAll("PictureFormat.", "")}");
  File? lastPictureTaken;
  PictureFormat selectedPictureFormat = PictureFormat.png;
  List<String> lastPictureTakenList = [];

  TimerBloc(this._screenshotController,
      {required Ticker ticker})
      : _ticker = ticker,

        super(const TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    // In case of there is an subscription exists, we have to cancel it
    _tickerSubscription?.cancel();

    // triggers the TimerRunInProgress state
    emit(TimerRunInProgress(event.duration));

    // makes the subscription listen to TimerTicked state
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration)));

    //capture screenshot
    final screenshot = await _screenshotController.capture();
    savePicture(screenshot!);
    emit(CaptureScreenshot(event.duration, lastPictureTakenList));

    //capture headshot
    List<CameraMacOSDevice> videoDevices =
    await CameraMacOS.instance.listDevices(
      deviceType: CameraMacOSDeviceType.video,
    );
    String selectedVideoDevice = videoDevices.first.deviceId;
    emit(CaptureHeadshot(event.duration, selectedVideoDevice));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) async {
    emit(event.duration > 0
        ? TimerRunInProgress(event.duration)
        : const TimerRunComplete());

    final screenshot = await _screenshotController.capture();
    savePicture(screenshot!);
    emit(CaptureScreenshot(event.duration, lastPictureTakenList));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    // As the timer pause, we should pause the subscription also
    _tickerSubscription?.pause();
    emit(TimerRunPause(state.duration));
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    // As the timer resume, we must let the subscription resume also
    _tickerSubscription?.resume();
    emit(TimerRunInProgress(state.duration));
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    // Timer counting finished, so we must cancel the subscription
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }

  Future<void> savePicture(Uint8List photoBytes) async {
      String filename = await imageFilePath;
      debugPrint(filename);
      File f = File(filename);
      if (f.existsSync()) {
        f.deleteSync(recursive: true);
      }
      f.createSync(recursive: true);
      f.writeAsBytesSync(photoBytes);
      lastPictureTaken = f;
      String filePath = f.path;
        lastPictureTakenList.add(filePath);
  }

}
