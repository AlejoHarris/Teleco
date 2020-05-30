import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:telecoui/widgets/blue.dart';

void main() => runApp(Teleco ());


class Teleco extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teleco',
      theme: ThemeData(
        brightness: Brightness.light,
        backgroundColor: Color(0xFFEFEFEF),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        primaryColor: Color(0xFF6200EE),
        accentColor: Color(0xFF4B00D1),
        secondaryHeaderColor: Color(0xFF03DAC5),
        errorColor: Color(0xFFB00020),
        disabledColor: Color(0xFFCFCFCF),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        primaryColor: Color(0xFF282828),
        backgroundColor: Color(0xEE282828),
        accentColor: Color(0xFFBB86FC),
        secondaryHeaderColor: Color(0xFF03DAC5),
        errorColor: Color(0xFFCF6679),
        disabledColor: Color(0xFF707070)
      ),
      home:StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return Blue();
          }
          return BlueOff(state: state);
        }
      ),
    );
  }
}

class BlueOff extends StatelessWidget {
  const BlueOff({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Theme.of(context).accentColor,
            ),
            Text(
              'El Bluetooth está apagado',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 18
              ),
            )
          ],
        ),
      ),
    );
  }
}