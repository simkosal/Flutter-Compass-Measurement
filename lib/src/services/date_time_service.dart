import 'package:intl/intl.dart';

class DateTimeServices {
  String? getCurrentDate({String format = 'd,MMM yyyy'}) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat(format);
    final String formattedDate = formatter.format(now);
    return formattedDate;
  }

  String? getFormatTime(DateTime dateTime, {String format = 'h:mm a'}) {
    // final DateFormat hour24Format = DateFormat('HH:mm:ss');
    final DateFormat hour12Format = DateFormat('h:mm:ss a');

    // final String hour24 = hour24Format.format(dateTime);
    final String hour12 = hour12Format.format(dateTime);

    return hour12;
  }
}
