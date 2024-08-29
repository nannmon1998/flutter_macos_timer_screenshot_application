import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import '../../models/ticker.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final ScreenshotController _screenshotController;
  static const _duration = 20;

  // to listen to the ticker stream
  StreamSubscription<int>? _tickerSubscription;

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
    emit(CaptureScreenshot(event.duration, screenshot!));

  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) async {
    emit(event.duration > 0
        ? TimerRunInProgress(event.duration)
        // triggers the TimerRunInProgress state

        : const TimerRunComplete());
    // triggers TimerRunComplete state

    // not a good solution
    final screenshot = await _screenshotController.capture();
    emit(CaptureScreenshot(event.duration, screenshot!));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    // As the timer pause, we should pause the subscription also
    _tickerSubscription?.pause();
    emit(TimerRunPause(state.duration));
    // triggers the TimerRunPause state
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    // As the timer resume, we must let the subscription resume also
    _tickerSubscription?.resume();
    emit(TimerRunInProgress(state.duration));
    // triggers the TimerRunInProgress state
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    // Timer counting finished, so we must cancel the subscription
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
    //triggers the TimerInitial state
  }
}
