class Attendance {
  int id;
  DateTime date;
  DateTime checkIn;
  DateTime checkOut;
  int lateMinutes;
  int earlyOutMinutes;
  int overtimeMinutes;

  Attendance({
    this.id = 0,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.lateMinutes,
    required this.earlyOutMinutes,
    required this.overtimeMinutes,
  });
}
