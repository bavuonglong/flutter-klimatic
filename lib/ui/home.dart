import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../util/util.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityName;
  Future _goToNextScreen(BuildContext context) async {
    Map result = await Navigator
        .of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new ChangeCity();
    }));

    if (result != null && result.containsKey('cityName')) {
      _cityName = result['cityName'];
      updateTempWidget(result['cityName']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Klimatic"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () => (_goToNextScreen(context)))
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/umbrella.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text(
              '${_cityName == null ? util.defaultCity : _cityName}',
              style: cityStyle(),
            ),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),
          new Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(20.0, 390.0, 0.0, 0.0),
            child: updateTempWidget(_cityName),
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiURL =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${util.appId}&units=imperial";

    http.Response response = await http.get(apiURL);
    return JSON.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Container(
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      content['main']['temp'].toString() + " F",
                      style: tempStyle(),
                    ),
                    subtitle: new Text(
                        'Humidity: ${content['main']['humidity'].toString()} \n'
                        'Min: ${content['main']['temp_min'].toString() + " F"}\n'
                        'Max: ${content['main']['temp_max'].toString() + " F"}',
                        style: extraData()),
                  ),
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('Change city'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/white_snow.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                    decoration: new InputDecoration(
                      hintText: 'Enter city',
                    ),
                    controller: _cityFieldController,
                    keyboardType: TextInputType.text),
              ),
              new ListTile(
                title: new FlatButton(
                  onPressed: () {
                    Navigator
                        .pop(context, {'cityName': _cityFieldController.text});
                  },
                  child: new Text('Get weather'),
                  color: Colors.red,
                  textColor: Colors.white70,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return new TextStyle(
    color: Colors.white,
    fontSize: 20.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle tempStyle() {
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9,
  );
}

TextStyle extraData() {
  return new TextStyle(
      color: Colors.white70, fontStyle: FontStyle.normal, fontSize: 17.0);
}
