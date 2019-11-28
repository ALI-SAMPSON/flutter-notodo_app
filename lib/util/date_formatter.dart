import 'package:intl/intl.dart';

String dateFormatted(){

  var now = DateTime.now();
  // data format
  var formatter  = new DateFormat("EEE, MMM d, ''yy");
  // formatting date
  String formatted = formatter.format(now);

  return formatted;

}