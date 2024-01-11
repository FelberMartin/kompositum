extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }
}

/// Returns the next day before the given [maxDate] date in the given [inMonth]
/// that is not in the [excludeList].
/// E.g. if [maxDate] is today and it is in the [excludeList] and yesterday is
/// not, yesterday is returned.
DateTime? findNextDateInMonthNotInList({
  required DateTime maxDate,
  required List<DateTime> excludeList,
  required DateTime inMonth,
}) {
  if (inMonth.year > maxDate.year ||
      (inMonth.year == maxDate.year && inMonth.month > maxDate.month)) {
    return null;
  }

  var startDay = maxDate;
  if (inMonth.year < maxDate.year ||
      (inMonth.year == maxDate.year && inMonth.month < maxDate.month)) {
    startDay = DateTime(inMonth.year, inMonth.month + 1, 0);
  }

  for (var i = startDay.day; i > 0; i--) {
    final day = DateTime(inMonth.year, inMonth.month, i);
    if (!excludeList.any((datetime) => datetime.isSameDate(day))) {
      return day;
    }
  }
}