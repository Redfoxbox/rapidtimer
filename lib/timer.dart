import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

class TimerPage extends StatefulWidget {
  TimerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  late AnimationController controller;
  int _starttime = 600000;

  var _stopWatchTimer_white = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromMinute(0),
      onChange: (value) {
        final displayTime = StopWatchTimer.getDisplayTime(value);
        //print('displayTime $displayTime');
      });

  var _stopWatchTimer_black = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromMinute(0),
      onChange: (value) {
        final displayTime = StopWatchTimer.getDisplayTime(value);
        //print('displayTime $displayTime');
      });

  @override
  void initState() {
    super.initState();
    // load settings
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //print("callback main");
      _loadStartTime();
    });

    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _starttime),
    )..addListener(() {
        setState(() {});
      });
  }

  void _loadStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _starttime = prefs.getInt('starttime')!;
      _stopWatchTimer_white.setPresetTime(mSec: _starttime);
      _stopWatchTimer_black.setPresetTime(mSec: _starttime);
    });
  }

  @override
  void dispose() async {
    controller.dispose();
    await _stopWatchTimer_white.dispose();
    await _stopWatchTimer_black.dispose();
    super.dispose();
  }

  bool whiteturn = false;
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
              child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ))),
            onPressed: () {
              //amber button
              FlutterBeep.beep();
              if (!_stopWatchTimer_black.isRunning) {
                if (_stopWatchTimer_white.isRunning) {
                  _stopWatchTimer_white.onExecute.add(StopWatchExecute.stop);
                  _stopWatchTimer_black.onExecute.add(StopWatchExecute.start);
                } else {
                  _stopWatchTimer_white.onExecute.add(StopWatchExecute.start);
                }
              }
            },
            child: StreamBuilder<int>(
              stream: _stopWatchTimer_white.rawTime,
              initialData: 0,
              builder: (context, snap) {
                final int? value = snap.data;
                final displayTime = StopWatchTimer.getDisplayTime(value!,
                    hours: false, milliSecond: false);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: RotatedBox(
                          quarterTurns: 2,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                displayTime,
                                style: TextStyle(
                                    fontSize: 100,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.bold),
                              ))),
                    )),
                  ],
                );
              },
            ),
          )),
        ),
        StreamBuilder(
          stream: _stopWatchTimer_white.rawTime,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();
            final int? value = snapshot.data as int?;
            var percent = (value! / _starttime);
            return Center(
              child: LinearProgressIndicator(
                  minHeight: 10,
                  value: percent,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.amber.shade300)),
            );
          },
        ),
        Container(
            color: Colors.black,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: 'Settings',
                    onPressed: () {
                      _stopWatchTimer_white.onExecute
                          .add(StopWatchExecute.stop);
                      _stopWatchTimer_black.onExecute
                          .add(StopWatchExecute.stop);
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                new Settings(title: "Settings")),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.restart_alt, color: Colors.white),
                    tooltip: 'Reset Timer',
                    onPressed: () {
                      if (_stopWatchTimer_black.isRunning) {
                        setState(() {
                          whiteturn = false;
                        });
                      } else {
                        setState(() {
                          whiteturn = true;
                        });
                      }
                      _stopWatchTimer_white.onExecute
                          .add(StopWatchExecute.stop);
                      _stopWatchTimer_black.onExecute
                          .add(StopWatchExecute.stop);
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Time paused'),
                          content:
                              const Text('Would you like to reset the timer?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                if (whiteturn) {
                                  _stopWatchTimer_white.onExecute
                                      .add(StopWatchExecute.start);
                                } else {
                                  _stopWatchTimer_black.onExecute
                                      .add(StopWatchExecute.start);
                                }
                                Navigator.pop(context, 'No');
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                _starttime =
                                    (prefs.getInt('starttime') ?? _starttime);
                                setState(() {
                                  _stopWatchTimer_white.clearPresetTime();
                                  _stopWatchTimer_white.setPresetTime(
                                      mSec: _starttime);
                                  _stopWatchTimer_black.clearPresetTime();
                                  _stopWatchTimer_black.setPresetTime(
                                      mSec: _starttime);
                                });

                                Navigator.pop(context, 'Yes');
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ])),
        StreamBuilder(
          stream: _stopWatchTimer_black.rawTime,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();
            final int? value = snapshot.data as int?;
            var percent = (value! / _starttime);
            return Center(
              child: LinearProgressIndicator(
                  minHeight: 10,
                  value: percent,
                  backgroundColor: Colors.grey,
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.brown.shade300)),
            );
          },
        ),
        Expanded(
            child: Container(
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.brown),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ))),
            onPressed: () {
              //bronw button
              FlutterBeep.beep();
              if (!_stopWatchTimer_white.isRunning &&
                  !_stopWatchTimer_black.isRunning) {
                _stopWatchTimer_white.onExecute.add(StopWatchExecute.start);
              } else {
                if (!_stopWatchTimer_white.isRunning) {
                  if (_stopWatchTimer_black.isRunning) {
                    _stopWatchTimer_black.onExecute.add(StopWatchExecute.stop);
                    _stopWatchTimer_white.onExecute.add(StopWatchExecute.start);
                  } else {
                    _stopWatchTimer_black.onExecute.add(StopWatchExecute.start);
                  }
                }
              }
            },
            child: StreamBuilder<int>(
              stream: _stopWatchTimer_black.rawTime,
              initialData: 0,
              builder: (context, snap) {
                final int? value = snap.data;
                final displayTime = StopWatchTimer.getDisplayTime(value!,
                    hours: false, milliSecond: false);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                displayTime,
                                style: TextStyle(
                                    fontSize: 100,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.bold),
                              ),
                            )))
                  ],
                );
              },
            ),
          ),
        ))
      ],
    ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
