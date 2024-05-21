import 'package:OneTask/widgets/appbar.dart';
import 'package:OneTask/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class OTCalendar extends StatefulWidget {
  const OTCalendar({super.key});

  @override
  State<OTCalendar> createState() => OTCalendarState();
}

class OTCalendarState extends State<  OTCalendar> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(),
      drawer: OTDrawer(),
      body: TableCalendar(
          headerStyle: const HeaderStyle(
            titleCentered: true,
          ),
          focusedDay: DateTime.now(), 
          firstDay: DateTime(2024), 
          lastDay: DateTime(2100),
      ),
    );
  }

}