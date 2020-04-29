import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_file.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:preferences/preferences.dart';

const int index2hour_offset = 6;
const double t_time_width = 69.0;
const double t_space_width = 4.0;
const double t_text_height = 16.0;
const String base_url = "https://www.tklhalle.de/";
const int smaxdate = 1686123940;
const int smindate = 1569189600;
const List<String> weekday = const ['Xx', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

const Map<String, int> price = const {
 	    '7': 21,
	    '8': 21,
	    '9': 21,
	   '10': 21,
	   '11': 21,
	   '12': 21,
	   '13': 21,
	   '14': 21,
	   '15': 21,
	   '16': 21,
	   '17': 21,
	   '18': 21,
	   '19': 21,
	   '20': 21,
	   '21': 21,
	   '22': 21,
	   '23': 21,
	  '107': 18,
	  '108': 18,
	  '109': 18,
	  '110': 18,
	  '111': 18,
	  '112': 18,
	  '113': 18,
	  '114': 21,
	  '115': 21,
	  '116': 21,
	  '117': 26,
	  '118': 26,
	  '119': 26,
	  '120': 26,
	  '121': 18,
	  '122': 18,
	  '123': 18,
	  '207': 18,
    '208': 18,
    '209': 18,
    '210': 18,
    '211': 18,
    '212': 18,
    '213': 18,
    '214': 21,
    '215': 21,
    '216': 21,
    '217': 26,
    '218': 26,
    '219': 26,
    '220': 26,
    '221': 18,
    '222': 18,
    '223': 18,
    '307': 18,
    '308': 18,
    '309': 18,
    '310': 18,
    '311': 18,
    '312': 18,
    '313': 18,
    '314': 21,
    '315': 21,
    '316': 21,
    '317': 26,
    '318': 26,
    '319': 26,
    '320': 26,
    '321': 18,
    '322': 18,
    '323': 18,
    '407': 18,
    '408': 18,
    '409': 18,
    '410': 18,
    '411': 18,
    '412': 18,
    '413': 18,
    '414': 21,
    '415': 21,
    '416': 21,
    '417': 26,
    '418': 26,
    '419': 26,
    '420': 26,
    '421': 18,
    '422': 18,
    '423': 18,
    '507': 18,
    '508': 18,
    '509': 18,
    '510': 18,
    '511': 18,
    '512': 18,
    '513': 18,
    '514': 21,
    '515': 21,
    '516': 21,
    '517': 26,
    '518': 26,
    '519': 26,
    '520': 26,
    '521': 18,
    '522': 18,
    '523': 18,
    '607': 21,
    '608': 21,
    '609': 21,
    '610': 21,
    '611': 21,
    '612': 21,
    '613': 21,
    '614': 21,
    '615': 21,
    '616': 21,
    '617': 21,
    '618': 21,
    '619': 21,
    '620': 21,
    '621': 21,
    '622': 21,
    '623': 21,
};

AuthSettings auth;
Session session = Session();

void main() //=> initializeDateFormatting('de_DE', null).then((_) 
    => runApp(MyApp());

class Session {
  Map<String, String> headers = {};
  bool loggedin = false;

  Future<String> get(String url) async {
    // print("url="+url);
    http.Response response = await http.get(url, headers: headers);
    updateCookie(response);
    return utf8.decode(response.bodyBytes);
  }

  Future<String> post(String url, dynamic data) async {
    // print("url="+url);
    http.Response response = await http.post(url, body: data, headers: headers);
    updateCookie(response);
    // print("header.cookie="+headers['cookie']);
    return utf8.decode(response.bodyBytes);
  }

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // print("rawCookie="+rawCookie);
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print("start   ="+(DateTime(2019, 9, 23).millisecondsSinceEpoch ~/ 1000).toString());
    // print("smindate="+smindate.toString());
    // print("end     ="+(DateTime(2020, 4, 5, 23, 59).millisecondsSinceEpoch ~/ 1000).toString());
    // print("smaxdate="+smaxdate.toString());

    // calc todays start and end
    DateTime dt = DateTime.now()
      // .add(new Duration(days: 100))    // for testing end of saison
    ;
    DateTime from = dt.subtract(new Duration(
        // days: dt.weekday - 1,
        hours: dt.hour,
        minutes: dt.minute,
        seconds: dt.second,
        milliseconds: dt.millisecond,
        microseconds: dt.microsecond));
    DateTime end = from.add(new Duration(days: 1));

    return MaterialApp(
      title: 'TKL Halle Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // supportedLocales: [
      //     const Locale('de', 'DE'),
      // ],
      home: new DayPage(from: from, end: end),
    );
  }
}

class Settings extends StatefulWidget {
  // final AuthSettings defaultAuth;

  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // AuthSettings auth = AuthSettings();
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text("Einstellungen"), backgroundColor: Colors.red[500]),
      body: SingleChildScrollView(child:
        Container(
          padding: EdgeInsets.all(16),
          child: Form(key: key, child: Column(children: <Widget>[
              ListTile(title: TextFormField(decoration: InputDecoration(labelText: "Benutzer:"),
                initialValue: auth.user,
                onSaved: (v)=>auth.user=v,
              )),
              ListTile(title: TextFormField(decoration: InputDecoration(labelText: "Passwort:"),
                initialValue: auth.pw,
                obscureText: true,
                onSaved: (v)=>auth.pw=v,
              )),
              // Text("Leeres Passwort bedeutet: Nicht Admin"),
              ListTile(title: RaisedButton(child: Text("Login", style: TextStyle(fontSize: t_text_height)),
                onPressed: () async {
                  // print("Einstellungen speichern");
                  if (key.currentState.validate()) {
                    key.currentState.save();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user', auth.user);
                    await prefs.setString('pw', auth.pw);
                    
                    // print("user="+auth.user+", pw="+auth.pw+",");

                    String content = await session.post("https://www.tklhalle.de/cal.php?action=login&uid="+auth.user+"&pwd="+auth.pw, "");
                    print("cookie: "+content);
                    session.loggedin = (content == "1");
                    if (session.loggedin) { print("Loggedin"); }

                    Navigator.pop(context, 1);
                  }})),

          ])))
      ));
  }
}

class EventDetail extends StatefulWidget {
  final Event e;

  const EventDetail(this.e, {Key key}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  String firstname;
  String lastname;
  String typ;
  String telnumber;
  String comment;
  final key = GlobalKey<FormState>();

  @override
  void initState() {
    typ = "1";
    super.initState();
  }

  Future<void> _bookingFailed(BuildContext context, String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fehler beim Buchen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Fehler:'),
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
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
    if (widget.e.id > 0) {
      typ = widget.e.typ.toString();
    }
    return Scaffold(
      appBar:  AppBar(title: Text( ( widget.e.id <= 0 ? "Neue Buchung" : "Buchung bearbeiten" )
                                  + " Platz " + (widget.e.userID + 1).toString() ), backgroundColor: Colors.red[500]),
      body: SingleChildScrollView(child:
        Container(
          padding: EdgeInsets.all(16),
          child: Form(key: key, child: Column(children: <Widget>[
              ListTile(title: Text("Datum: "+DateFormat('dd.MM.yyyy').format(widget.e.start)),),
              ListTile(title: Text("Zeit: "+DateFormat('HH:mm').format(widget.e.start)+" - "+DateFormat('HH:mm').format(widget.e.end))),
              // ListTile(title: Text("End: "+DateFormat('HH:mm').format(widget.e.end)),),
              ListTile(title: DropdownButton<String>(
                value: typ,
                onChanged: (String newValue) {
                  setState(() {
                    typ = newValue;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: "0",
                    child: Text("Einzelbuchung Erwachsene"),
                  ),
                  DropdownMenuItem<String>(
                    value: "1",
                    child: Text("Freie Jugend-Buchung"),
                  ),
                  // DropdownMenuItem<String>(
                  //   value: "2",
                  //   child: Text("Abo"),
                  // ),
                  // DropdownMenuItem<String>(
                  //   value: "3",
                  //   child: Text("Training"),
                  // ),
                ],
              ),),
              ListTile(title: TextFormField(decoration: InputDecoration(labelText: "Vorname:"),
                initialValue: widget.e.firstname,
                onSaved: (v)=>firstname=v,
              ),),
              ListTile(title: TextFormField(decoration: InputDecoration(labelText: "Name:"),
                initialValue: widget.e.lastname,
                onSaved: (v)=>lastname=v,
                validator: (v)=> v.isEmpty ? "Nachname darf nicht leer sein." : null,
              ),),
              ListTile(title: TextFormField(decoration: InputDecoration(labelText: "Code:"),
                initialValue: widget.e.telnumber,
                onSaved: (v)=>telnumber=v,
                // validator: (v)=> v.isEmpty ? "Nachname darf nicht leer sein." : null,
              ),),
              ListTile(title: TextFormField(decoration: InputDecoration(labelText: "Kommentar:"),
                initialValue: widget.e.body,
                onSaved: (v)=>comment=v,
              ),),
              ListTile(title: Divider()),
              ListTile(title: RaisedButton(child: Text(widget.e.id <= 0 ? "Buchen" : "Ändern", style: TextStyle(fontSize: t_text_height)),
                onPressed: () async {
                  print("Buchen...");
                  if (key.currentState.validate()) {
                    key.currentState.save();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('firstname', firstname);
                    await prefs.setString('lastname', lastname);
                    // AuthSettings auth = AuthSettings();
                    // auth.user = prefs.getString('user');
                    // if (auth.user == null) {
                    //   auth.user = "";
                    // }
                    // auth.pw = prefs.getString('pw');
                    // if (auth.pw == null) {
                    //   auth.pw = "";
                    // }
                    // if (auth.pw != "") {
                    //   print("save auth="+auth.user+":"+auth.pw);
                    // }

                    String url =
                      base_url + "cal.php?action=save&id=" + widget.e.id.toString() +
                      "&start=" +
                        (widget.e.start.millisecondsSinceEpoch ~/ 1000).toString() +
                      "&end=" + (widget.e.end.millisecondsSinceEpoch ~/ 1000).toString() +
                      "&firstname=" + Uri.encodeComponent(firstname) +
                      "&lastname="  + Uri.encodeComponent(lastname) +
                      "&telnumber=" + Uri.encodeComponent(telnumber) +
                      "&body="      + Uri.encodeComponent(comment) +
                      "&typ="       + Uri.encodeComponent(typ) +
                      "&uid="       + Uri.encodeComponent(widget.e.userID.toString());
                    String content;
                    try {
                      // http.Response response;
                      // response = await http.get(url);
                      // await Future.delayed(Duration(seconds: 5));   // make it slow to show ProgressIndicator
                      // String content = utf8.decode(response.bodyBytes);
                      content = await session.get(url);
                    } catch (e) {
                      print("catch http get save "+e);
                    }
                    // print("url=$url");
                    // String content="123"; //content="Keine Buchung möglich!";
                    int newId = int.tryParse(content) ?? 0;
                    print("newId="+newId.toString());
                    if (newId == 0) {
                      print("Fehler: "+content);
                      _bookingFailed(context, content);
                    } else {
                      Navigator.pop(context, Event(widget.e.id, widget.e.title, firstname, lastname, widget.e.telnumber, widget.e.body, widget.e.start, widget.e.end,
                        widget.e.typ, widget.e.userID, false));
                    }
                  }
                }),
              ),
              ListTile(title: Divider()),
              widget.e.id <= 0 ? ListTile(title: Divider()) :
              ListTile(title: RaisedButton(child: Text(widget.e.id <= 0 ? "XXX" : "Löschen", style: TextStyle(fontSize: t_text_height)),
                onPressed: () async {
                  print("Löschen...");
                  // _bookingFailed(context, "Löschen noch nicht implementiert !!!");
                  if (key.currentState.validate()) {
                    key.currentState.save();
                    String url =
                      base_url + "cal.php?action=delete&id=" + widget.e.id.toString() +
                      "&telnumber=" + Uri.encodeComponent(telnumber) +
                      "&typ="       + Uri.encodeComponent(typ);
                    // http.Response response = await http.get(url);
                    // // await Future.delayed(Duration(seconds: 5));   // make it slow to show ProgressIndicator
                    // String content = utf8.decode(response.bodyBytes);
                    String content = await session.get(url);
                    // print("url=$url");
                    print("content response=$content");
                    // String content="123"; //content="Keine Buchung möglich!";
                    int newId = int.tryParse(content) ?? 0;
                    print("newId="+newId.toString());
                    if (newId == 0) {
                      print("Fehler: "+content);
                      _bookingFailed(context, content);
                    } else {
                      Navigator.pop(context, Event(widget.e.id, widget.e.title, firstname, lastname, widget.e.telnumber, widget.e.body, widget.e.start, widget.e.end,
                        widget.e.typ, widget.e.userID, false));
                    }
                  }
                }),
              ),
            ],),
          ),
        )));
  }
}

class DayPage extends StatefulWidget {
  const DayPage({
    Key key,
    @required this.from,
    @required this.end,
    // this.initialScrollOffset = 130,
  }) : super(key: key);

  final DateTime from;
  final DateTime end;
  // final double initialScrollOffset;

  @override
  _DayPageState createState() => _DayPageState();
}

class AuthSettings {
  String user;
  String pw;
}

class _DayPageState extends State<DayPage> {
  // DateFormat dateFormat;
  // String fromText;
  // double initialScrollOffset;

  void _onHorizontalDragUpdate(BuildContext context, DragUpdateDetails details) {
    // print("onHorizontalDragUpdate");
    if (details.primaryDelta.compareTo(0) == 1) {
      // print('dragged from left offset='+details.primaryDelta.toString());
    } else {
      // print('dragged from right offset='+details.primaryDelta.toString());
    }
  }

  void _onHorizontalDragEnd(BuildContext context, DragEndDetails details) {
    if (details.primaryVelocity == 0)
      return; // user have just tapped on screen (no dragging)

    if (details.primaryVelocity.compareTo(0) == 1) {
      // print('dragged from left offset=');
      DateTime from2 = widget.from.add(new Duration(days: -1));
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return DayPage(from: from2, end: widget.from);
      }));
    } else {
      // print('dragged from right');
      DateTime end2 = widget.end.add(new Duration(days: 1));
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return DayPage(from: widget.end, end: end2);
      }));
    }
  }

  void loadAuthSettings() async {
    auth = AuthSettings();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    auth.user = prefs.getString('user');
    if (auth.user == null) {
      auth.user = "";
    }
    auth.pw = prefs.getString('pw');
    if (auth.pw == null) {
      auth.pw = "";
    }
  }

  @override
  void initState() {
    // initializeDateFormatting('de_DE', null).then((_) => fromText = DateFormat('EE dd.MM.yyyy', "de_DE").format(widget.from));
    // initializeDateFormatting("de_DE", null).then((_) {dateFormat = DateFormat('EE dd.MM.yyyy', "de_DE");});
    loadAuthSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Day ";
    
    title = weekday[widget.from.weekday]+" ";
    // print("title="+title);
    // print("weekday:"+weekday[widget.from.weekday]);
    // print("weekday: "+widget.from.weekday.toString());
    // print("smindate="+smindate.toString());
    // print("from="+(widget.from.millisecondsSinceEpoch / 1000).toString());
    // print("diff="+(widget.from.millisecondsSinceEpoch / 1000 - smindate).toString());
    if (widget.from.millisecondsSinceEpoch / 1000 - smindate < 0) {
      // Navigator.pop(context);
      return Text("Fehler vor Saison");
    }
    if (widget.from.millisecondsSinceEpoch / 1000 - smaxdate > 0) {
      // Navigator.pop(context);
      return Text("Fehler nach Saison 2");
    }

    // print(MediaQuery.of(context).size.width);
    var fontScaling = MediaQuery.of(context).textScaleFactor;
    if (MediaQuery.of(context).size.width < 300 * fontScaling) { title = "";}
    return Scaffold(
        appBar: AppBar(
          title: Text(title + DateFormat('dd.MM.yyyy').format(widget.from), textScaleFactor: 0.9,),
          backgroundColor: Colors.red[600],
          leading: 
          // Row(children: [IconButton(
          //   icon: const Icon(Icons.navigate_before),
          //   tooltip: 'Prev page',
          //   onPressed: () {
          //     DateTime from2 = widget.from.add(new Duration(days: -1));
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (BuildContext context) {
          //       return DayPage(from: from2, end: widget.from);
          //     }));
          //   },
          // ),
          Image.asset('images/icon-4x.jpg')
          // ])
          ,
          actions: <Widget>[

            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return DayPage(from: widget.from, end: widget.end);
                }));
              },
            ),

            IconButton(
              icon: const Icon(Icons.adjust),   //calendar_today),
              tooltip: 'Today',
              onPressed: () {
                DateTime dt = DateTime.now();
                DateTime from = dt.subtract(new Duration(
                    hours: dt.hour,
                    minutes: dt.minute,
                    seconds: dt.second,
                    milliseconds: dt.millisecond,
                    microseconds: dt.microsecond));
                DateTime end = from.add(new Duration(days: 1));
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return DayPage(from: from, end: end);
                }));
              },
            ),

            // IconButton(
            //   icon: const Icon(Icons.settings),
            //   tooltip: 'Settings',
            //   onPressed: () async {
            //     auth = await Navigator.push(context,
            //         MaterialPageRoute(builder: (BuildContext context) {
            //       return Settings(auth);
            //       }
            //     ));
            //     if (auth != null) {
            //       print("auth.user="+auth.user);
            //     }
            //   },
            // ),

            IconButton(
              icon: const Icon(Icons.settings),  // more_vert),   //navigate_next),
              tooltip: 'More', //'Next page',
              onPressed: () async {
                int res = await Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return Settings();
                  }
                ));
                if (res != null) {
                  // print("auth.user="+auth.user);
                }
              },
              // onPressed: () {
              // DateTime end2 = widget.end.add(new Duration(days: 1));
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (BuildContext context) {
              //     return DayPage(from: widget.end, end: end2);
              //   }));
              // },
            ),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) => _onHorizontalDragEnd(context, details),
          onHorizontalDragUpdate: (DragUpdateDetails details) => _onHorizontalDragUpdate(context, details),
          child: EventList(from: widget.from, end: widget.end),
        ));
  }
}

class Event {
  final int id;
  final String title;
  final String firstname;
  final String lastname;
  final String telnumber;
  final String body;
  final DateTime start;
  final DateTime end;
  final int typ;
  final int userID;
  final bool readOnly;

  Event(this.id, this.title, this.firstname, this.lastname, this.telnumber,
      this.body, this.start, this.end, this.typ, this.userID, this.readOnly);

  Event.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        title = json['tle'],
        firstname = json['firstname'],
        lastname = json['lastname'],
        telnumber = json['telnumber'],
        body = json['body'],
        start = DateTime.parse(json['start']),
        end = DateTime.parse(json['end']),
        typ = json['typ'],
        userID = json['userId'][0],
        readOnly = json['readOnly'];

  @override
  String toString() {
    return "id=$id, uid=$userID, typ=$typ, start=$start, end=$end, lastname=$lastname";
  }
}

class EventList extends StatefulWidget {
  const EventList({
    @required this.from,
    @required this.end,
    this.initialScrollOffset,
  });
  final DateTime from;
  final DateTime end;
  final double initialScrollOffset;

  @override
  State<StatefulWidget> createState() {
    return _EventListState();
  }
}

class _EventListState extends State<EventList> {
  bool _loadingInProgress = true;
  List<Event> events = const [];
  ScrollController _controller;
  String defaultFirstname;
  String defaultLastname;
  String defaultUsername;
  double initialScrollOffset;

  // sort(int i, List<Event> fe) {
  //   fe.sort((a, b) {
  //     int v;
  //     if (i > 0) {
  //       v = a.lastname.compareTo(b.lastname);
  //       if (v != 0) return v;
  //       v = a.firstname.compareTo(b.firstname);
  //       if (v != 0) return v;
  //     }
  //     v = a.start.compareTo(b.start);
  //     if (v != 0) return v;
  //     return a.userID.compareTo(b.userID);
  //   });
  //   return fe;
  // }

  Future loadEventList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // // key.currentState.setState(() {
    defaultFirstname = prefs.getString('firstname');
    defaultLastname = prefs.getString('lastname');
    if (defaultFirstname == null) { defaultFirstname= ""; }
    if (defaultLastname == null) { defaultLastname= ""; }
    // defaultUsername = prefs.getString('user');
    // if (defaultUsername == null) { defaultUsername= ""; }

    // String url = "http://www.mocky.io/v2/5ddf97d3310000cb723ae893";
    // String url = "https://www.sge-tennis.de/hallenbuchung/winter/cal.php?action=get_events&start="+
    String url =
        base_url + "cal.php?action=get_events&start=" +
            (widget.from.millisecondsSinceEpoch / 1000).round().toString() +
            "&end=" +
            (widget.end.millisecondsSinceEpoch / 1000).round().toString();
    print("url="+url);
    // http.Response response = await http.get(url);
    // // await Future.delayed(Duration(seconds: 5));   // make it slow to show ProgressIndicator
    // String content = utf8.decode(response.bodyBytes);
    String content = await session.get(url);
    Map m = jsonDecode(content);
    List l = m['events'];
    List<Event> le = l.map((json) => Event.fromJson(json)).toList();
    // List<Event> fe = le.where((e) => e.typ < 2).toList();    // filter only single bookings
    setState(() {
      events = le;
      _loadingInProgress = false;
    });
    // print(events);
  }

  _scrollListener() {
    // print("offset="+_controller.offset.toString());
    // initialScrollOffset = _controller.offset;
  }

  @override
  void initState() {
    // initialScrollOffset = widget.initialScrollOffset;
    double offset = DateTime.now().hour - 9.0;
    offset *= 682.0 / 9.0;
    if (offset > 682.0) { offset = 682.0; }
    _controller = ScrollController(initialScrollOffset: offset);
    _controller.addListener(_scrollListener);
    loadEventList();
    super.initState();
    _loadingInProgress = true;
  }

  Color calcColor(int typ) {
    return typ == 0
        ? Colors.blue[300] //.fromRGBO(0x46, 0x82, 0xb4, 1) //.blue[200]
        : // Einzel
        typ == 1
            ? Colors.green[300]
            : // Jugend
            typ == 2
                ? Color.fromRGBO(0xcd, 0xb7, 0xb5, 1) //red[200]  // grey[400]  // red[500]
                : // Abo
                typ == 3
                    ? Color.fromRGBO(0xcd, 0xb7, 0xb5, 1) // red[100]  // grey[300]  // yellow[600]
                    : // Training
                    Colors.white; // frei
  }

  Event calcEvent(int uid, int stunde) {
    List<Event> e1 = events
        .where((e) =>
            e.userID == uid && e.start.hour <= stunde && (e.end.hour > stunde || (e.end.hour == stunde && e.end.minute > 0)))
        .toList();
    // print("e1="+e1.toString());
    if (e1.length == 0) {
      DateTime start = widget.from.add(Duration(hours: stunde));
      DateTime end = start.add(Duration(hours: 1));
      return Event(
          0, '', defaultFirstname, defaultLastname, '', '', start, end, -1, uid, true);
    } // frei
    return e1[0];
  }

  String nametext(String lastname, String firstname) {
    String r = lastname.trim();
    if (firstname.length > 0) { r += ", "+firstname.trim(); }
    return r;
  }

  List calcStatus(int stunde) {
    // print("calcStatus $stunde:00");
    List<Event> e = [
      calcEvent(0, stunde),
      calcEvent(1, stunde),
      calcEvent(2, stunde)
    ];
    int wday = e[1].start.weekday;
    if (wday == 7) {wday = 0; }
    String p = price[(wday*100+stunde).toString()].toString();
    Color pricecolor = p == "18" ? Colors.yellow[700] //.fromRGBO(0xff, 0xec, 0xb4, 1) //.yellow
                     : p == "21" ? Colors.green[600]
                     : Colors.red;
    return [
      {
        'e': e[0],
        'color': calcColor(e[0].typ), // Platz 1
        'text': nametext(e[0].lastname, e[0].firstname),
        'price': p,
        'pricecolor': pricecolor,
      },
      {
        'e': e[1],
        'color': calcColor(e[1].typ), // Platz 2
        'text': nametext(e[1].lastname, e[1].firstname),
        'price': p,
        'pricecolor': pricecolor,
      },
      {
        'e': e[2],
        'color': calcColor(e[2].typ), // Platz 3
        'text': nametext(e[2].lastname, e[2].firstname),
        'price': p,
        'pricecolor': pricecolor,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double tColWidth =
        ((MediaQuery.of(context).size.width - t_time_width - 3 * t_space_width) / 3 - 0.5).round().toDouble();

    return _loadingInProgress
      ? new Center(
          child: new CircularProgressIndicator(),
      ) : ListView.separated(
        itemCount: 17, // should be 18 but 23-0 h doesn't work so far 
        controller: _controller,

        separatorBuilder: (BuildContext context, int index) {
          DateTime dt = DateTime.now();
          DateTime nowHour = dt.subtract(new Duration(
              minutes: dt.minute,
              seconds: dt.second,
              milliseconds: dt.millisecond,
              microseconds: dt.microsecond));
          dt = widget.from.add(Duration(hours: index + 1 + index2hour_offset));
          bool now = nowHour == dt;
          // print("from="+widget.from.toString());
          // print("nowHour="+nowHour.toString()+" dt="+dt.toString());
          return Divider(
            thickness: now ? 1.5 : 0.5,
            color: now ? Colors.red[600] : Colors.grey,
          );
        },

        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // Header
            return Row(children: [
              Container(
                margin: EdgeInsets.only(right: t_space_width, top: 2.0, bottom: 2.0),
                // padding: const EdgeInsets.all(8.0),
                // color: Colors.grey[300],
                child: RaisedButton(
                  elevation: 0.0,
                  onPressed: () {},
                  color: session.loggedin ? Colors.green[500] : Colors.red[600], //fromRGBO(0x8b, 0x00, 0x00, 1),  //red[500],  //Colors.grey[300],
                  child: Text("Zeit", style: TextStyle(fontSize: t_text_height, color: Colors.white)),
                ),
                width: t_time_width,
                alignment: Alignment.center,
              ),
              Container(
                margin: EdgeInsets.only(right: t_space_width),
                padding: const EdgeInsets.all(8.0),
                color: Colors.red[600],  //Colors.blue[200],
                child: Text("Platz 1", style: TextStyle(fontSize: t_text_height, color: Colors.white)),
                width: tColWidth,
                alignment: Alignment.center,
              ),
              Container(
                margin: EdgeInsets.only(right: t_space_width),
                padding: const EdgeInsets.all(8.0),
                color: Colors.red[600],  //Colors.blue[200],
                child: Text("Platz 2", style: TextStyle(fontSize: t_text_height, color: Colors.white)),
                width: tColWidth,
                alignment: Alignment.center,
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.red[600],  //Colors.blue[200],
                child: Text("Platz 3", style: TextStyle(fontSize: t_text_height, color: Colors.white)),
                width: tColWidth,
                alignment: Alignment.center,
              ),
            ]);
          } else {
            // Data
            List status = calcStatus(index + index2hour_offset);
            return Row(children: [
              Container(
                margin: EdgeInsets.only(right: t_space_width),
                padding: const EdgeInsets.all(8.0),
                color: Colors.red[600], //.fromRGBO(0x8b, 0x00, 0x00, 1),  // red[500],  //Colors.grey[300],
                child: Text((index + index2hour_offset).toString() + ":00", style: TextStyle(fontSize: 16, color: Colors.white)),
                width: t_time_width,
                alignment: Alignment.center,
              ),
              buildContainerCourt(context, status, tColWidth, 0),
              buildContainerCourt(context, status, tColWidth, 1),
              buildContainerCourt(context, status, tColWidth, 2),
            ]);
          }
        },
      );
  }

  Container buildContainerCourt(BuildContext context, List status, double tColWidth, int uid) {
    return Container(
            margin: EdgeInsets.only(right: uid == 2 ? 0 : t_space_width),
            padding: const EdgeInsets.all(2.0),
            // color: status[uid]['color'],
            width: tColWidth,
              child: status[uid]['e'].id  <= 0 
                ? Container(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
                    // decoration: BoxDecoration(border: Border.all(width: 2.0, color: Colors.blue),
                    //   borderRadius: BorderRadius.all(Radius.circular(20.0))
                    // ),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () async {              // onTap Platz
                        Event e = await Navigator.push(context, MaterialPageRoute(builder: (context) {return  EventDetail(status[uid]['e']); }));
                        if (e != null) {
                          defaultFirstname = e.firstname;
                          defaultLastname = e.lastname;
                          // Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Gebucht.")));
                          // sleep(Duration(seconds: 1));

                          Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                              return DayPage(from: widget.from, end: widget.end);
                          }));

                          // print("lastname="+e.lastname);
                        }
                      },
                      color: status[uid]['pricecolor'],
                      child: CircleAvatar(child: 
                        // Icon(Icons.add)
                        Text(status[uid]['price']+"€"),
                        backgroundColor: status[uid]['pricecolor'],
                      ))
                 ) : status[uid]['e'].typ  <= 1 ?
                   RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () async {              // onTap Platz
                        Event e = await Navigator.push(context, MaterialPageRoute(builder: (context) {return  EventDetail(status[uid]['e']); }));
                        if (e != null) {
                          // print("Buchung bearbeitet");
                          // defaultFirstname = e.firstname;
                          // defaultLastname = e.lastname;
                          // // print("lastname="+e.lastname);

                          // Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Geändert.")));

                          Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                            return DayPage(from: widget.from, end: widget.end);
                          }));
                        }
                      },
                    padding: const EdgeInsets.all(1.0),
                    child: Text(status[uid]['text'], style: TextStyle(fontSize: t_text_height), textAlign: TextAlign.center,),
                    color: status[uid]['color'],
                 ) :
                   RaisedButton(
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                     onPressed: () async {},              // onTap Platz
                     // margin: EdgeInsets.only(right: uid == 2 ? 0 : t_space_width),
                     padding: const EdgeInsets.all(1.0),
                    //  alignment: Alignment.center,
                     color: status[uid]['color'],
                     child: Text(status[uid]['text'], style: TextStyle(fontSize: t_text_height),
                                textAlign: TextAlign.center,
                     )),
          );
  }
}