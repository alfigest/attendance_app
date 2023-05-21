import 'dart:async';
import 'package:attendance_app/models/attendance.dart';
import 'package:attendance_app/blocs/attendance_event.dart';
import 'package:attendance_app/blocs/attendance_state.dart';
import 'package:bloc/bloc.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final Database database;

  AttendanceBloc(this.database) : super(AttendanceLoading());

  @override
  Stream<AttendanceState> mapEventToState(AttendanceEvent event) async* {
    if (event is LoadAttendance) {
      yield* _mapLoadAttendanceToState();
    } else if (event is AddAttendance) {
      yield* _mapAddAttendanceToState(event);
    } else if (event is UpdateAttendance) {
      yield* _mapUpdateAttendanceToState(event);
    } else if (event is DeleteAttendance) {
      yield* _mapDeleteAttendanceToState(event);
    }
  }

  Stream<AttendanceState> _mapLoadAttendanceToState() async* {
    try {
      final List<Map<String, dynamic>> maps =
          await database.query('attendances');
      final List<Attendance> attendances = List.generate(maps.length, (i) {
        return Attendance(
          id: maps[i]['id'],
          date: DateTime.parse(maps[i]['date']),
          checkIn: DateTime.parse(maps[i]['checkIn']),
          checkOut: DateTime.parse(maps[i]['checkOut']),
          lateMinutes: maps[i]['lateMinutes'],
          earlyOutMinutes: maps[i]['earlyOutMinutes'],
          overtimeMinutes: maps[i]['overtimeMinutes'],
        );
      });
      yield AttendanceLoaded(attendances);
    } catch (_) {
      yield AttendanceError();
    }
  }

  Stream<AttendanceState> _mapAddAttendanceToState(AddAttendance event) async* {
    if (state is AttendanceLoaded) {
      final List<Attendance> updatedAttendances =
          List.from((state as AttendanceLoaded).attendances)
            ..add(event.attendance);
      yield AttendanceLoaded(updatedAttendances);
      _saveAttendances(updatedAttendances);
    }
  }

  Stream<AttendanceState> _mapUpdateAttendanceToState(
      UpdateAttendance event) async* {
    if (state is AttendanceLoaded) {
      final List<Attendance> updatedAttendances = (state as AttendanceLoaded)
          .attendances
          .map((attendance) => attendance.id == event.attendance.id
              ? event.attendance
              : attendance)
          .toList();
      yield AttendanceLoaded(updatedAttendances);
      _saveAttendances(updatedAttendances);
    }
  }

  Stream<AttendanceState> _mapDeleteAttendanceToState(
      DeleteAttendance event) async* {
    if (state is AttendanceLoaded) {
      final List<Attendance> updatedAttendances = (state as AttendanceLoaded)
          .attendances
          .where((attendance) => attendance.id != event.attendance.id)
          .toList();
      yield AttendanceLoaded(updatedAttendances);
      _saveAttendances(updatedAttendances);
    }
  }

  Future<void> _saveAttendances(List<Attendance> attendances) async {
    await database.transaction((txn) async {
      await txn.delete('attendances');
      for (final attendance in attendances) {
        await txn.insert(
          'attendances',
          {
            'id': attendance.id,
            'date': attendance.date.toIso8601String(),
            'checkIn': attendance.checkIn.toIso8601String(),
            'checkOut': attendance.checkOut.toIso8601String(),
            'lateMinutes': attendance.lateMinutes,
            'earlyOutMinutes': attendance.earlyOutMinutes,
            'overtimeMinutes': attendance.overtimeMinutes,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
