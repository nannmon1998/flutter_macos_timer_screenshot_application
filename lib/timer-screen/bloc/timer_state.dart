part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;
  final Uint8List? screenshot;
  final String? headshot;

  const TimerState(this.duration, {this.screenshot,this.headshot});

  @override
  // state instants compare each other by duration
  List<Object> get props => [duration];
}

class TimerInitial extends TimerState {
  const TimerInitial(duration) : super(duration);
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(int duration) : super(duration);
}

class TimerRunPause extends TimerState {
  const TimerRunPause(int duration) : super(duration);
}

class CaptureScreenshot extends TimerState {
  const CaptureScreenshot(int duration, Uint8List screenshot)
      : super(duration, screenshot: screenshot);
}

class CaptureHeadshot extends TimerState {
  const CaptureHeadshot(int duration, Uint8List screenshot, String headShot)
      : super(duration, screenshot: screenshot, headshot: headShot);
}


class TimerRunComplete extends TimerState {
  //at this state, timer's value is 0
  const TimerRunComplete() : super(0);
}
