import 'package:flutter/material.dart';

class EmptyCard extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final String data;
  final String blueData;
  
  EmptyCard({
    Key key,
    this.width,
    this.height,
    this.data,
    this.icon,
    this.blueData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  size: 60,
                  color: Theme.of(context).accentColor,
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data,
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
              ),Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  blueData,
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              )
            ],
          )
        ],
      ),
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
    );
  }
}

class SlidderCard extends EmptyCard{
  Slider sliderDatR;
  Slider sliderDatG;
  Slider sliderDatB;
  Slider sliderDatA;

  SlidderCard({
    double width,
    double height,
    IconData icon,
    String data,
    this.sliderDatR,
    this.sliderDatG,
    this.sliderDatB,
    this.sliderDatA,
    Key key,
  }) : super(key: key, width: width, height: height, data: data, icon: icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  size: 60,
                  color: Theme.of(context).accentColor,
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data,
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
              ),Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    sliderDatR, sliderDatB, sliderDatG, sliderDatA,
                  ]
                )
              )
            ],
          )
        ],
      ),
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
    );
  }
}

class ServoCard extends EmptyCard{
  Slider sliderDat;

  ServoCard({
    double width,
    double height,
    IconData icon,
    String data,
    this.sliderDat,

    Key key,
  }) : super(key: key, width: width, height: height, data: data, icon: icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  icon,
                  size: 60,
                  color: Theme.of(context).accentColor,
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data,
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
              ),Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    sliderDat
                  ]
                )
              )
            ],
          )
        ],
      ),
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
    );
  }
}