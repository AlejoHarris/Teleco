import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:sensors/sensors.dart';
import 'package:telecoui/widgets/card.dart';

const String CHARACTERISTICR_UUID =  "0FF80DFD-8536-4E36-B3C8-D88466E184E0";
const String CHARACTERISTICW_UUID =  "3B0B89F6-8329-4DD1-86C4-43E9499D0595";
const String SERVICE_UUID         =  "DB69FECC-945E-4269-800C-AAB2A8BD356B";

class Blue extends StatefulWidget {
  @override
  _BlueState createState() => _BlueState();
}

class _BlueState extends State<Blue> {

  final FlutterBlue fb = FlutterBlue.instance;
  BluetoothDevice finalDevice;
  BluetoothCharacteristic writer;
  bool isConnected;
  bool isFound;
  bool buttonAvailable;
  var red, green, blue, alpha, servo;
  String buttonText;
  Timer timer;
  IconData blueIcon = Icons.bluetooth;
  Color blueColor;
  Stream<List<int>> stream;
  List<double> accelValues;
  List<double> gyroValues;
  List<StreamSubscription<dynamic>> streamSubs = <StreamSubscription<dynamic>>[];

  @override
  void dispose(){
    super.dispose();
    for (StreamSubscription<dynamic> subscription in streamSubs){
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    streamSubs.add(accelerometerEvents.listen((AccelerometerEvent onData){
      setState((){
        accelValues = <double>[onData.x, onData.y, onData.z];
      });
    }));
    streamSubs.add(gyroscopeEvents.listen((GyroscopeEvent onData){
      setState((){
        gyroValues = <double>[onData.x, onData.y, onData.z];
      });
    }));
    buttonText = "BUSCAR DISPOSITIVO";
    isFound = false;
    isConnected = false;
    finalDevice = null;
    blueIcon = Icons.bluetooth;
    buttonAvailable = true;
    blueColor = Color(0xFF4B00D1);
    discoverServices();
    red = 0.0;
    blue = 0.0;
    green = 0.0;
    alpha = 0.0;
    servo =  10.0;
  }
  
  startScan(){
    fb.scan(timeout: Duration(seconds: 5)).listen((scanResult) {
      var device = scanResult.device;
      setState(() {
          buttonAvailable = false;
      });
      if (device.name == "Bluetooth Shit"){
        setState(() {
          blueColor = Theme.of(context).disabledColor;
          buttonText = "CONECTAR DISPOSITIVO";
          isFound = true;
          finalDevice = device;
          blueIcon = Icons.bluetooth_connected;
        });
        fb.stopScan();
      }
      else {
        setState(() {
          isFound? buttonText = "CONECTAR DISPOSITIVO" : buttonText = "BUSCAR DISPOSITIVO ";
          device = null;
          blueIcon = Icons.bluetooth;
        });
      }
    },
    onDone: (){
      !isFound? _popDialog(true) : _popDialog(false);
      setState(() {
        buttonAvailable = true;
        blueColor = Theme.of(context).accentColor;
      });
    });
  }
  
  connectDevice() async {
    await finalDevice.connect();
    setState((){
      isConnected = true;
      blueIcon = Icons.bluetooth_disabled;
      buttonText = "DESCONECTAR DISPOSITIVO";
    });
    discoverServices();
  }

  disconnectDevice() async {
    await finalDevice.disconnect();
    setState((){
      buttonText = "BUSCAR DISPOSITIVO";
      isConnected = false;
      isFound = false;
      finalDevice = null;
      blueIcon = Icons.bluetooth;
    });
  }

  
  writeData(List<String> accel, List<String> gyro) async {
    if (writer != null){
      await writer.write(utf8.encode(
        (accel.reduce((value, element) => value + ',' + element)) + ',' + (gyro.reduce((value, element) => value + ',' + element) + ',' + red.toStringAsFixed(0) + ',' + green.toStringAsFixed(0) + ',' + blue.toStringAsFixed(0) + ',' + alpha.toStringAsFixed(0) + ',' + servo.toStringAsFixed(0)))
      );
    }
  }

  String dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  discoverServices() async {
    if (finalDevice == null || !isConnected){
      return;
    }

    List<BluetoothService> services = await finalDevice.discoverServices();
    services.forEach((service){
      if(service.uuid.toString().toUpperCase() == SERVICE_UUID){
        service.characteristics.forEach((characteristic){
          if(characteristic.uuid.toString().toUpperCase() == CHARACTERISTICR_UUID){
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
          }
          if(characteristic.uuid.toString().toUpperCase() == CHARACTERISTICW_UUID){
            setState((){
              writer = characteristic;
            });
          }
        });
      }
    });
  }

  Future<void> _popDialog(bool alert) {
    String text;
    alert? text = 'Dispositivo no encontrado' : text = 'Dispositivo encontrado';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta', style: TextStyle(fontSize: 24, ),),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ACEPTAR', style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFound && isConnected) {
      blueColor = Theme.of(context).errorColor;
    }
    else{
      blueColor = Theme.of(context).accentColor;
    }
    if (!buttonAvailable){
      blueColor = Theme.of(context).disabledColor;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Shit'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: dashboard(),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(buttonText),
        icon: Icon(blueIcon),
        backgroundColor: blueColor,
        disabledElevation: 0,
        onPressed: () {
          if (!buttonAvailable) {
            return null;
          }
          if (!isFound ){
            startScan();
          } 
          else if (isFound && !isConnected){
            connectDevice();
          } 
          else if (isFound && isConnected){
            disconnectDevice();
          }
        }, 
        ) ,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }

  Widget _screenData(){
    if (!buttonAvailable){
      return SpinKitPulse(
        color:  Theme.of(context).accentColor,
        size: 200,
      );
    }
    else if (isFound){
      return SpinKitPulse(
        color:  Theme.of(context).accentColor,
        size: 200,
      );
    }
    return SpinKitFadingGrid(
      color:  Theme.of(context).accentColor,
      size: 200,
    );
  }



  Widget dashboard() {
    final List<String> accel = accelValues?.map((double r) => r.toStringAsFixed(1))?.toList();
    final List<String> gyro = gyroValues?.map((double r) => r.toStringAsFixed(1))?.toList();
    writeData(accel, gyro);
    var showData;
    if (isConnected){
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AnimationLimiter(
            child: StreamBuilder<List<int>>(
              stream: stream,
              builder: (context, snapshot){
                if (snapshot.hasError){
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.active){
                  var currentData = dataParser(snapshot.data);
                  showData = currentData.split(",");
                }
                if (snapshot.data != null){
                  return Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 1000),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: MediaQuery.of(context).size.width / 2,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        EmptyCard(
                          width: MediaQuery.of(context).size.width,
                          height: 170.0,
                          icon: Icons.brightness_4,
                          data: 'Temperatura',
                          blueData: showData[0]
                        ),
                        EmptyCard(
                          width: MediaQuery.of(context).size.width,
                          height: 170.0,
                          icon: Icons.opacity,
                          data: 'Humedad',
                          blueData: showData[1],
                        ),
                        SlidderCard(
                          width: MediaQuery.of(context).size.width,
                          height: 400.0,
                          icon: Icons.wb_incandescent,
                          data: 'RGB',
                          sliderDatR: Slider.adaptive(
                            value: red,
                            onChanged: (newValue){
                              setState(() {
                                red = newValue;
                              });
                            },
                            min: 0,
                            max: 255,
                            activeColor: Color(0xFFff1744),
                            inactiveColor: Color(0xFFc4001d),
                          ),
                          sliderDatG: Slider.adaptive(
                            value: green,
                            onChanged: (newValue){
                              setState(() {
                                green = newValue;
                              });
                            },
                            min: 0,
                            max: 255,
                            activeColor: Color(0xFF2979ff),
                            inactiveColor: Color(0xFF004ecb),
                          ),
                          sliderDatB: Slider.adaptive(
                            value: blue,
                            onChanged: (newValue){
                              setState(() {
                                blue = newValue;
                              });
                            },
                            min: 0,
                            max: 255,
                            activeColor: Color(0xFF00e676),
                            inactiveColor: Color(0xFF00b248),
                          ),
                          sliderDatA: Slider.adaptive(
                            value: alpha,
                            onChanged: (newValue){
                              setState(() {
                                alpha = newValue;
                              });
                            },
                            min: 0,
                            max: 255,
                            activeColor: Color(0xFF607d8b),
                            inactiveColor: Color(0xFF34515e),
                          ),
                        ),
                        ServoCard(
                          width: MediaQuery.of(context).size.width,
                          height:200.0,
                          icon: Icons.rotate_right,
                          data: 'Servo',
                          sliderDat: Slider.adaptive(
                            value: servo,
                            onChanged: (newValue){
                              setState(() {
                                servo = newValue;
                              });
                            },
                            min: 10,
                            max: 170,
                            activeColor: Theme.of(context).accentColor,
                            inactiveColor: Theme.of(context).disabledColor,
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(child: EmptyCard(
                              height: 170.0,
                              icon: Icons.memory,
                              data: 'Acelerómetro',
                              blueData: '$accel'),
                              
                            ),
                            Flexible(child: EmptyCard(
                              height: 170.0,
                              icon: Icons.autorenew,
                              data: 'Giroscopio',
                              blueData: '$gyro',),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(28.0),
                        )
                      ],
                    ),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SpinKitPulse(
                        color:  Theme.of(context).accentColor,
                        size: 200,
                      )
                    ]
                  )
                );
              },
            ),
          ),
        )
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _screenData()
        ]
      )    
    );
  }
}
