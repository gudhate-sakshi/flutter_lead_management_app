import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatMonthDayYear(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime); 
  }
}