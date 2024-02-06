import 'package:intl/intl.dart';

class DateTimeUtils {
  static final dateFormat = DateFormat("dd/MM/yyyy, E");
  static final monthFormat = DateFormat.yM();
  static final yearFormat = DateFormat.y();

  /// For Unique Date
  static String getFormattedDateFromMilli(int milliSeconds) {
    var date = DateTime.fromMillisecondsSinceEpoch(milliSeconds);
    return getFormattedDateFromDateTime(date);
  }

  static String getFormattedDateFromDateTime(DateTime dateTime) {
    var formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  /// For Unique Month
  static String getFormattedMonthFromMilli(int milliSeconds) {
    var month = DateTime.fromMillisecondsSinceEpoch(milliSeconds);
    return getFormattedMonthFromDateTime(month);
  }

  static String getFormattedMonthFromDateTime(DateTime dateTime) {
    var formattedMonth = monthFormat.format(dateTime);
    return formattedMonth;
  }

  /// For Unique Year
  static String getFormattedYearFromMilli(int milliSeconds) {
    var year = DateTime.fromMillisecondsSinceEpoch(milliSeconds);
    return getFormattedYearFromDateTime(year);
  }

  static String getFormattedYearFromDateTime(DateTime dateTime) {
    var formattedYear = yearFormat.format(dateTime);
    return formattedYear;
  }

  /// For Unique Category
  static String getFormattedCategoryFromMilli(int milliSeconds) {
    var category = DateTime.fromMillisecondsSinceEpoch(milliSeconds);
    return getFormattedCategoryFromDateTime(category);
  }

  static String getFormattedCategoryFromDateTime(DateTime dateTime) {
    var formattedYear = yearFormat.format(dateTime);
    return formattedYear;
  }
}
