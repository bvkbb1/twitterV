/*
  this helper is user to convert the timestamp object into a string

  e.g:
  If the time stamp as : July 24, 2024, 13:00

  it will returns the Staing as : "2024-24-07 13:00"
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimeStamp({required Timestamp timeStamp}){
  DateTime dateTime = timeStamp.toDate();

  final String formattedDate = DateFormat('yyyy-mm-dd').format(dateTime);
  return formattedDate;
}