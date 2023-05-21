import 'package:equatable/equatable.dart';
import 'package:attendance_app/models/attendance.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendance extends AttendanceEvent {}

class AddAttendance extends AttendanceEvent {
  final Attendance attendance;

  const AddAttendance(this.attendance);

  @override
  List<Object> get props => [attendance];

  @override
  String toString() => 'AddAttendance { attendance: $attendance }';
}

class UpdateAttendance extends AttendanceEvent {
  final Attendance attendance;

  const UpdateAttendance(this.attendance);

  @override
  List<Object> get props => [attendance];

  @override
  String toString() => 'UpdateAttendance { attendance: $attendance }';
}

class DeleteAttendance extends AttendanceEvent {
  final Attendance attendance;

  const DeleteAttendance(this.attendance);

  @override
  List<Object> get props => [attendance];

  @override
  String toString() => 'DeleteAttendance { attendance: $attendance }';
}
