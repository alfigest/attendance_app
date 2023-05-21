import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/blocs/attendance_bloc.dart';
import 'package:attendance_app/blocs/attendance_event.dart';
import 'package:attendance_app/blocs/attendance_state.dart';
import 'package:attendance_app/models/attendance.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'attendance_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE attendances(id INTEGER PRIMARY KEY, date TEXT, checkIn TEXT, checkOut TEXT, lateMinutes INTEGER, earlyOutMinutes INTEGER, overtimeMinutes INTEGER)',
      );
    },
    version: 1,
  );
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final Future<Database> database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Database>(
        future: database,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BlocProvider(
              create: (context) =>
                  AttendanceBloc(snapshot.data!)..add(LoadAttendance()),
              child: AttendanceScreen(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to open database.'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance App'),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AttendanceLoaded) {
            final attendances = state.attendances;
            return ListView.builder(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                final attendance = attendances[index];
                return ListTile(
                  title: Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(attendance.date)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Check In: ${DateFormat('HH:mm').format(attendance.checkIn)}'),
                      Text(
                          'Check Out: ${DateFormat('HH:mm').format(attendance.checkOut)}'),
                      Text('Late: ${attendance.lateMinutes} minutes'),
                      Text('Early Out: ${attendance.earlyOutMinutes} minutes'),
                      Text('Overtime: ${attendance.overtimeMinutes} minutes'),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('Failed to load attendances.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final List<DateTime> picked = await DateRangePicker.showDatePicker(
              context: context,
              initialFirstDate: DateTime.now(),
              initialLastDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100));
          if (picked != null && picked.length == 2) {
            final checkIn = picked[0].add(Duration(hours: 8));
            final checkOut = picked[1].add(Duration(hours: 17));
            final lateMinutes = checkIn.difference(picked[0]).inMinutes;
            final earlyOutMinutes = picked[1].difference(checkOut).inMinutes;
            final overtimeMinutes =
                checkOut.difference(DateTime(2023, 5, 17, 17)).inMinutes;
            final attendance = Attendance(
              date: picked[0],
              checkIn: checkIn,
              checkOut: checkOut,
              lateMinutes: lateMinutes,
              earlyOutMinutes: earlyOutMinutes,
              overtimeMinutes: overtimeMinutes,
            );
            context.read<AttendanceBloc>().add(AddAttendance(attendance));
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
