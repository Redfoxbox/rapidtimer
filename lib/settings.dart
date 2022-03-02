import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  Settings({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SettingsState createState() => _SettingsState();
}

class Times {
  const Times(this.name, this.millisecond);

  final String name;
  final int millisecond;
}

class _SettingsState extends State<Settings> {
  int _starttime = 600000;
  Times selectedTimes = const Times('10 minute', 600000);
  List<Times> times = <Times>[
    const Times('1 minute', 60000),
    const Times('5 minute', 300000),
    const Times('10 minute', 600000),
    const Times('15 minute', 900000)
  ];

  @override
  void initState() {
    super.initState();
    _loadStartTime();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //print("callback");
      final prefs = await SharedPreferences.getInstance();
      _starttime = (prefs.getInt('starttime') ?? _starttime);
    });
  }

  void _loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _starttime = (prefs.getInt('starttime') ?? _starttime);
    });
  }

  //Incrementing counter after click
  void _setStartTime(value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('starttime', value);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: Container(
        height: 100.0,
        child: Center(
            child: DropdownButton<Times>(
          value:
              times.where((times) => (times.millisecond == _starttime)).first,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 32,
          elevation: 24,
          style: const TextStyle(color: Colors.black, fontSize: 32, height: 1),
          underline: Container(
            height: 4,
            color: Colors.amber,
          ),
          onChanged: (Times? newValue) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved')),
            );
            setState(() {
              //print("try to save list");
              selectedTimes = newValue!;
              //print(selectedTimes.millisecond);
              _starttime = selectedTimes.millisecond;
              _setStartTime(selectedTimes.millisecond);
            });
          },
          items: times.map((Times times) {
            return new DropdownMenuItem<Times>(
              value: times,
              child: new Text(
                times.name,
                style: new TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }
}
