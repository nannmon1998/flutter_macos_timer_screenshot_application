part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;
  final String? headshot;
  final List<String>? lastPictureTakenList;

  const TimerState(this.duration, {this.lastPictureTakenList,this.headshot});

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
  const CaptureScreenshot(int duration, List<String> lastPictureTakenList)
      : super(duration, lastPictureTakenList: lastPictureTakenList);
}

class CaptureHeadshot extends TimerState {
  const CaptureHeadshot(int duration, String headShot)
      : super(duration, headshot: headShot);
}

class TimerRunComplete extends TimerState {
  //at this state, timer's value is 0
  const TimerRunComplete() : super(0);
}
