import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getStringList("notification_data") ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    display_date(date){
      DateTime a = date;
      DateTime b = DateTime.now();

      int years = b.year - a.year;
      int months = b.month - a.month;
      int days = b.day - a.day;
      int hours = b.hour - a.hour;
      int minutes = b.minute - a.minute;
      int seconds = b.second - a.second;

      if (seconds < 0) {
        seconds += 60;
        minutes--;
      }

      if (minutes < 0) {
        minutes += 60;
        hours--;
      }

      if (hours < 0) {
        hours += 24;
        days--;
      }

      if (days < 0) {
        final prevMonth = a.month == 1 ? 12 : a.month - 1;
        final prevYear = a.month == 1 ? a.year - 1 : a.year;
        final daysInPrevMonth = daysInMonth(prevYear, prevMonth);
        days += daysInPrevMonth;
        months--;
      }

      if (months < 0) {
        months += 12;
        years--;
      }
      if(years > 0){
        return years.toString() + " year ago".toString();
      }
      else if(months > 0){
        return months.toString() + " month ago".toString();
      }
      else if(days > 0){
        return days.toString() + " days ago".toString();
      }
      else if(hours > 0){
        return  hours.toString() + " hours ago".toString();
      }
      else if(minutes > 0){
        return minutes.toString() + " minutes ago".toString();
      }
      else {
        return seconds.toString() + " seconds ago".toString();
      }
    //  print("$years year(s) $months month(s) $days day(s) $hours hour(s) $minutes minute(s) $seconds second(s).");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body:

      notifications.length == 0 ? Center(
        child: Text("No Notification Found"),
      ):
      ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          //final notification = notifications[index];
          var notification = json.decode(notifications[index]);
             String time = display_date(DateTime.parse(notification['notification_time']));
          return Card(
            elevation: 2.0, // Add elevation for a card-like appearance
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              leading: Icon(Icons.notifications),
              title: Text(
                notification["notification_title"],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification["notification_body"],
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '$time ', // Assuming you have a "time" key in your notification data
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
int daysInMonth(int year, int month) {
  if (month == 2) {
    if (year % 4 == 0) {
      if (year % 100 != 0 || (year % 400 == 0)) {
        return 29; // Leap year
      }
    }
    return 28; // Non-leap year
  }

  if ([4, 6, 9, 11].contains(month)) {
    return 30; // April, June, September, November
  }

  return 31; // January, March, May, July, August, October, December
}
