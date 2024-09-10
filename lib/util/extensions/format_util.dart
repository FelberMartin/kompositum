import 'package:intl/intl.dart';

String getThousandSeparator(String locale) {
  var format = NumberFormat("#,##0", locale);
  return format.symbols.GROUP_SEP;
}