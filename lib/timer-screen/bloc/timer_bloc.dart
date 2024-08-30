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
  CameraMacOSController? macOSController ;

  TimerBloc(this._screenshotController, {required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(_duration)) {
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
    }
    );
    on<TimerStarted>(_onStarted);
    on<TimerTicked>(_onTicked);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
  }

  static const _duration = 20;
  // to listen to the ticker stream
  StreamSubscription<int>? _tickerSubscription;
  File? lastPictureTaken;
  File? lastCameraPictureTaken;
  PictureFormat selectedPictureFormat = PictureFormat.png;
  List<String> screenshotList = [];
  List<String> headshotList = [];
  Uint8List? lastImagePreviewData;

  Future<String> get imageFilePath async =>
      pathJoiner.join(
          (await getApplicationDocumentsDirectory()).path,
          "P_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${
              DateTime.now().hour}${DateTime.now().minute}.${selectedPictureFormat.name.replaceAll("PictureFormat.", "")}");

  Future<String> get cameraImageFilePath async =>
      pathJoiner.join(
          (await getApplicationDocumentsDirectory()).path,
          "P_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${
              DateTime.now().hour}${DateTime.now().minute}${DateTime.now().
          second}.${selectedPictureFormat.name.replaceAll("PictureFormat.", "")}");

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    // In case of there is an subscription exists, we have to cancel it
    _tickerSubscription?.cancel();
    takeScreenshot();
    takeHeadShot();
    emit(TimerRunInProgress(event.duration,screenshotList,headshotList));
    // makes the subscription listen to TimerTicked state
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(TimerTicked(duration)));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) async {
    takeScreenshot();
    takeHeadShot();

    emit(event.duration > 0
        ? TimerRunInProgress(event.duration,screenshotList,headshotList)
        :TimerRunComplete(screenshotList,headshotList));

  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    // As the timer pause, we should pause the subscription also
    _tickerSubscription?.pause();
    emit(TimerRunPause(event.duration,screenshotList,headshotList));
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    // As the timer resume, we must let the subscription resume also
    _tickerSubscription?.resume();
    emit(TimerRunInProgress(state.duration,screenshotList,headshotList));
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    // Timer counting finished, so we must cancel the subscription
    _tickerSubscription?.cancel();
    screenshotList.clear();
    headshotList.clear();
    emit(const TimerInitial(_duration));
  }

  void takeHeadShot() async{
    if (macOSController != null) {
      CameraMacOSFile? imageData = await macOSController!.takePicture();
      if (imageData != null) {
        lastImagePreviewData = imageData.bytes;
        saveCameraPicture(lastImagePreviewData!);
      }
    }
  }

  void takeScreenshot() async{
    final screenshot = await _screenshotController.capture();
    savePicture(screenshot!);
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
        screenshotList.add(filePath);
  }

  Future<void> saveCameraPicture(Uint8List photoBytes) async {
      String filename = await cameraImageFilePath;
      File f = File(filename);
      if (f.existsSync()) {
        f.deleteSync(recursive: true);
      }
      f.createSync(recursive: true);
      f.writeAsBytesSync(photoBytes);
      lastCameraPictureTaken = f;
      String filePath = f.path;
      headshotList.add(filePath);
  }

}
