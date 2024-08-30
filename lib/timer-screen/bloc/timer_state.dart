part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;
  final List<String>? screenshotList;
  final List<String>? headshotList;

  const TimerState(this.duration, {this.screenshotList,this.headshotList});

  @override
  // state instants compare each other by duration
  List<Object> get props => [duration];
}

class TimerInitial extends TimerState {
  const TimerInitial(duration) : super(duration);
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(int duration,List<String>? screenshotList,List<String>? headshotList) : super(duration,
  screenshotList: screenshotList,headshotList: headshotList);
}

class TimerRunPause extends TimerState {
  const TimerRunPause(int duration,List<String>? screenshotList,List<String>? headshotList) : super(duration,
  screenshotList: screenshotList,headshotList: headshotList);
}

class TimerRunComplete extends TimerState {
  //at this state, timer's value is 0
  const TimerRunComplete(List<String>? screenshotList,List<String>? headshotList) : super(0,screenshotList: screenshotList,headshotList: headshotList);
}
