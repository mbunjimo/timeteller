import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_teller_app/pages/inspirations/inspirations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Add timer and time string
  late Timer _timer;
  late Timer _inspirationTimer;
  late String _timeString;
  String _currentInspiration = '';

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime()); // Update every second
    _updateInspiration(); // Initial load
    // Add inspiration timer
    _inspirationTimer = Timer.periodic(Duration(minutes: 10), (Timer t) => _updateInspiration());
  }

  // Dispose of the timer when the widget is disposed which is when the user navigates away from the page
  @override
  void dispose() {
    // Reset to all orientations when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _timer.cancel();
    _inspirationTimer.cancel(); // Cancel inspiration timer
    super.dispose();
  }

  void _getTime() {
    setState(() {
      _timeString = _formatDateTime(DateTime.now());
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<String> _getRandomInspiration() async {
    // get random inspiration from shared preferences
    final prefs = await SharedPreferences.getInstance();
    List<String> quotes = prefs.getStringList('quotes') ?? [];
    return quotes[Random().nextInt(quotes.length)];
  }

  void _updateInspiration() async {
    String inspiration = await _getRandomInspiration();
    setState(() {
      _currentInspiration = inspiration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(_timeString, style: TextStyle(color: Colors.white, fontSize: 160, fontWeight: FontWeight.bold),),
            Text( _currentInspiration.isEmpty ? 'No inspiration yet' : _currentInspiration, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black12,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => InspirationsPage()));
        },
        child: Icon(Icons.add, color: Colors.grey,),
      ),
    );
  }
}
