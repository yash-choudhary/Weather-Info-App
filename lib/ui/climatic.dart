import 'dart:convert';
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'dart:async';
import 'package:http/http.dart' as http;

class Climatic extends StatefulWidget {
  @override
  _ClimaticState createState() => _ClimaticState();
}

class _ClimaticState extends State<Climatic> {
  void showStuff() async {
    Map data = await getWeather(util.appid, util.defaultCity, util.units);
    print(data.toString());
  }

  String city = "jaipur";
  Future _gotosearch(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new SearchScreen();
    }));
    if (results != null && results.containsKey('city')) {
      city = results['city'];
    } else {
      city = 'jaipur';
    }
  }

  _refreshAction() {
    setState(() {
      city=city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.indigoAccent,
      appBar: new AppBar(
        title: new Text(
          "CLIMATIC",
          style: new TextStyle(color: Colors.white, fontSize: 25.0),
        ),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _refreshAction,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          backgroundColor: Colors.redAccent,
          elevation:10.5,
          highlightElevation: 10.5,
          onPressed: (){_gotosearch(context);}),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigo,
        shape: CircularNotchedRectangle(),
          child: Row(
          children: <Widget>[
            IconButton(icon: Icon(Icons.menu),color: Colors.white, onPressed: null),
          ],
        )

      ),
      body: new Stack(
        children: <Widget>[
//          new Center(
//            child: new Image.asset(
//              "images/heather.jpg",
//              fit: BoxFit.fill,
//              height: double.infinity,
//              width: double.infinity,
//              alignment: Alignment.center,
//            ),
//          ),
          ListView(
            children: <Widget>[
              new Padding(padding: new EdgeInsets.all(10.0)),

//                  new Expanded(
//                    child: new Container(
//                      alignment: Alignment.topLeft,
//                      child: new Image.asset("images/light_rain.png"),
//                    ),
//                  ),
              new Padding(padding: EdgeInsets.all(10.5)),
              new ListTile(
                title: new Container(
                  alignment: Alignment.center,
                  child: new Text(city.toUpperCase(), style: cityStyle()),
                ),
              ),
              new Padding(padding: new EdgeInsets.all(20.0)),
              new Container(
                  alignment: Alignment.center, child: tempWidgetUpdater(city)),
            ],
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appid, String city, String unit) async {
    String apiurl =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$appid&units=$unit";
    http.Response response = await http.get(apiurl);
    return json.decode(response.body);
  }

  Widget tempWidgetUpdater(String city) {
    return new FutureBuilder(
        future: getWeather(util.appid, city, util.units),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            if (content["cod"].toString() == "404") {
              return new Container(
                child: new Text(
                  "City Not Found",
                  style: tempStyle(),
                ),
              );
            } else {
              return Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Container(
                        child: new Text(
                          "${content["main"]["temp"].toString()}°C",
                          style: tempStyle(),
                        ),
                      ),
                      new Column(
                        children: <Widget>[
                          new Container(
                            child: new Text(
                              "Min: ${content["main"]["temp_min"].toString()}°C",
                              style: otherFetStyle(),
                            ),
                          ),
                          new Container(
                            child: new Text(
                              "Max: ${content["main"]["temp_max"].toString()}°C",
                              style: otherFetStyle(),
                            ),
                          ),
                          new Container(
                            child: new Text(
                              "Humidity: ${content["main"]["humidity"].toString()}%",
                              style: otherFetStyle(),
                            ),
                          ),
                        ],
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                  new Padding(padding: EdgeInsets.all(10.5)),
                  new Container(
                    child: new Text(
                      "\"${content["weather"][0]["main"].toString()}\"",
                      style: fetStyle(),
                    ),
                  ),
                ],
              );
            }
          } else {
            return new Container();
          }
        });
  }
}

class SearchScreen extends StatelessWidget {
  final _searchcontroller = new TextEditingController();
  final String cityname;

  SearchScreen({Key key, this.cityname}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.indigoAccent,
      appBar: new AppBar(
        title: new Text("Choose Your City"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: new ListView(
        children: <Widget>[
          new ListTile(
              title: new TextField(
            controller: _searchcontroller,
            cursorColor: Colors.redAccent,
            style: TextStyle(color: Colors.redAccent, fontSize: 20.0),
            decoration: InputDecoration(
                hintText: "Enter Your City Here",
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                )),
          )),
          new ListTile(
              title: new RaisedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, {'city': _searchcontroller.text});
                  },
                  icon: new Icon(Icons.search),
                  label: new Text(
                    "Search",
                    style: new TextStyle(color: Colors.white),
                  ),
                  elevation: 10.5,
                  color: Colors.redAccent))
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.redAccent,
      fontSize: 60.0,
      fontStyle: FontStyle.italic,
      fontFamily: String.fromCharCode(22),
      fontWeight: FontWeight.w400);
}

TextStyle tempStyle() {
  return new TextStyle(
      color: Colors.white,
      fontSize: 60.0,
      fontStyle: FontStyle.normal,
      fontFamily: String.fromCharCode(22),
      fontWeight: FontWeight.w700);
}

TextStyle otherFetStyle() {
  return new TextStyle(
      color: Colors.white70,
      fontSize: 20.0,
      fontStyle: FontStyle.normal,
      fontFamily: String.fromCharCode(22),
      fontWeight: FontWeight.w400);
}

TextStyle fetStyle() {
  return new TextStyle(
      color: Colors.white70,
      fontSize: 55.0,
      fontStyle: FontStyle.normal,
      fontFamily: String.fromCharCode(22),
      fontWeight: FontWeight.w400);
}
