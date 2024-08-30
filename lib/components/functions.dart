import 'package:intl/intl.dart';

String getDayWithSuffix(int day) {
  if (day >= 1 && day <= 31) {
    if (day >= 11 && day <= 13) {
      return '${day}th';  // Special case for 11th, 12th, 13th
    }
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }
  return '$day';  // Fallback for invalid days
}

String formatDate(DateTime date) {
  final DateFormat dayFormat = DateFormat('d');
  final DateFormat monthFormat = DateFormat('MMMM');
  final DateFormat yearFormat = DateFormat('y');

  // Get the day with suffix
  String dayWithSuffix = getDayWithSuffix(date.day);

  // Format the date
  String formattedDate = '$dayWithSuffix ${monthFormat.format(date)}, ${yearFormat.format(date)}';

  return formattedDate;
}

String formatDateFull(DateTime dateTime) {
  // Create a DateFormat for the date part
  final dateFormat = DateFormat("d MMMM yyyy");
  final timeFormat = DateFormat("h:mm a");

  // Format the date and time
  final date = dateFormat.format(dateTime);
  final time = timeFormat.format(dateTime);

  // Get the day of the month to determine the ordinal suffix
  final day = dateTime.day;
  final suffix = getDayWithSuffix(day);

  // Combine date and time with the suffix
  // return "$suffix ${date.replaceFirst('$day', '')}, $time";
  return time;
}