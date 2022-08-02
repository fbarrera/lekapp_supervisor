import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lekapp_supervisor/classes/SessionLogin.dart';
import 'package:lekapp_supervisor/screens/login_screen.dart';
import 'package:lekapp_supervisor/screens/specialities_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool _rememberMe = false;
  late SharedPreferences prefs;
  late String? nameText;
  late String? emailText;
  late Future<SessionLogin> sessionLogin;
  late String? activityRegistry;
  late bool onSync;

  @override
  void initState() {
    sessionLogin = _getPrefs();
    nameText = "";
    emailText = "";
    activityRegistry = "";
    onSync = false;

    super.initState();
    //_getPrefs();
  }

  Future<void> _emptyPrefs(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('sessionData');
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(pageBuilder: (
          BuildContext context,
          Animation animation,
          Animation secondaryAnimation,
        ) {
          return LoginScreen();
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }),
        (Route route) => false);
  }

  Future<SessionLogin> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    nameText = prefs.getString('name');
    emailText = prefs.getString('email');
    String t = prefs.getString('sessionData') as String;
    activityRegistry = prefs.getString('activityRegistry');
    Map<String, dynamic> mapSt = json.decode(t);
    return SessionLogin.fromJson(mapSt);
  }

  Future<SessionLogin> _getLoginData() async {
    await Future.delayed(
      Duration(seconds: 2),
    );
    return sessionLogin;
  }

  late int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(
      () {
        activityRegistry = prefs.getString('activityRegistry');
        _selectedIndex = index;
      },
    );
    _pageController.animateToPage(_selectedIndex,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _onPageChanged(int index) {
    setState(
      () {
        activityRegistry = prefs.getString('activityRegistry');
        _selectedIndex = index;
      },
    );
  }

  AppBar myAppBar(BuildContext context) {
    return AppBar(
      //leading: Icon(Icons.close),
      title: Text('supervisor'),
      actions: [
        GestureDetector(
          onTap: () => _emptyPrefs(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.exit_to_app),
          ),
        )
      ],
      backgroundColor: Colors.black87,
    );
  }

  ListView crearBotones(
      BuildContext context, AsyncSnapshot<SessionLogin> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.buildingSites.length,
      itemBuilder: (context, index) {
        Card c;
        c = Card(
          color: Colors.white,
          child: ListTile(
            title: Text(snapshot.data!.buildingSites[index].name),
          ),
        );
        return InkWell(
          child: c,
          splashColor: Colors.amber[200],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpecialitiesScreen(
                    buildingSite: snapshot.data!.buildingSites[index]),
              ),
            );
          },
        );
      },
    );
  }

  final PageController _pageController = PageController();

  Future<String> _getSynchronizationData() async {
    return activityRegistry as String;
  }

  Future<bool> _sendData() async {
    setState(
      () {
        onSync = true;
      },
    );
    await Future.delayed(
      const Duration(seconds: 2),
    );
    String syncData = prefs.getString('activityRegistry') as String;
    final http.Response response = await http.post(
      Uri.parse('https://app.lekapp.cl/api/sync_supervisor'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{'syncData': syncData},
      ),
    );
    if (response.statusCode == 200) {
      prefs.setString(
          'activityRegistry', "{\"" + (emailText as String) + "\": []}");
      setState(
        () {
          activityRegistry = prefs.getString('activityRegistry');
          onSync = false;
        },
      );
      await _getLoginData();
      onSync = false;
      return true;
    } else {
      // If the server did not return a 200 SUCCESS response,
      // then throw an exception.
      setState(
        () {
          onSync = false;
        },
      );
      return Future.error("No pudo sincronizarse");
    }
  }

  FutureBuilder obraBuilder(BuildContext context) {
    return FutureBuilder<String>(
      future: _getSynchronizationData(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children;
        Widget result;
        if (snapshot.hasData && onSync == false) {
          if (activityRegistry != "{\"" + (emailText as String) + "\": []}") {
            result = Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: RichText(
                      text: TextSpan(
                        text: "Sincronización",
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Hay datos pendientes por sincronizar"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                      child: Text("Sincronizar"),
                      onPressed: () => {
                        _sendData().then(
                          (value) => {},
                        )
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            result = Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: RichText(
                      text: TextSpan(
                        text: "Sincronización",
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Actividades al día"),
                  )
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          children = <Widget>[];
          result = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        } else {
          children = const <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Sincronizando información...'),
            )
          ];
          result = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        }
        return result;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context),
      extendBody: true,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Obras"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sync_sharp), label: "Sincronización"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: PageView(
          controller: _pageController,
          children: <Widget>[
            Container(
              child: FutureBuilder<SessionLogin>(
                future: _getLoginData(),
                builder: (BuildContext context,
                    AsyncSnapshot<SessionLogin> snapshot) {
                  List<Widget> children;
                  Widget result;
                  if (snapshot.hasData) {
                    result = Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: RichText(
                              text: TextSpan(
                                text: "Selecciona una obra",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 20),
                              ),
                            ),
                          ),
                          Expanded(
                            child: crearBotones(context, snapshot),
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    children = <Widget>[];

                    result = Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    );
                  } else {
                    children = const <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(),
                        width: 60,
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Cargando obras disponibles...'),
                      )
                    ];
                    result = Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    );
                  }
                  return result;
                },
              ),
            ),
            obraBuilder(context)
          ],
          onPageChanged: _onPageChanged),
    );
  }
}
