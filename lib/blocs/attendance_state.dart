import 'package:attendance_app/models/attendance.dart';
import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Attendance> attendances;

  const AttendanceLoaded([this.attendances = const []]);

  @override
  List<Object> get props => [attendances];

  @override
  String toString() => 'AttendanceLoaded { attendances: $attendances }';
}

class AttendanceError extends AttendanceState {}
