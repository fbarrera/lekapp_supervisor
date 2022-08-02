import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lekapp_supervisor/classes/Activity.dart';
import 'package:lekapp_supervisor/classes/SessionLogin.dart';
import 'package:lekapp_supervisor/classes/Speciality.dart';
import 'package:lekapp_supervisor/classes/Zone.dart';
import 'package:lekapp_supervisor/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  final Speciality speciality;
  final Zone zone;

  ActivitiesScreen({required this.speciality, required this.zone}) : super();

  @override
  ActivitiesScreenState createState() => ActivitiesScreenState();
}

class ActivitiesScreenState extends State<ActivitiesScreen> {
  bool _rememberMe = false;
  late SharedPreferences prefs;
  late String? nameText;
  late String? emailText;
  late Future<SessionLogin> sessionLogin;

  @override
  void initState() {
    sessionLogin = _getPrefs();
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
        PageRouteBuilder(pageBuilder: (BuildContext context,
            Animation animation, Animation secondaryAnimation) {
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
    Map<String, dynamic> mapSt = json.decode(t);
    return SessionLogin.fromJson(mapSt);
  }

  Future<SessionLogin> _getLoginData() async {
    await Future.delayed(Duration(seconds: 2));
    return sessionLogin;
  }

  ListView crearBotones(BuildContext context,
      AsyncSnapshot<SessionLogin> snapshot, Speciality speciality, Zone zone) {
    List<Activity> specialityActivities = <Activity>[];
    for (Activity activity in snapshot.data!.activities) {
      if (activity.fk_zone == zone.id) {
        if (activity.fk_speciality == speciality.id) {
          specialityActivities.add(activity);
        }
      }
    }

    if (specialityActivities.isEmpty) {
      return ListView(
        children: <Widget>[
          Padding(
            child: Text(
              'No hay actividades para la especialidad ' +
                  speciality.name +
                  ' en la zona ' +
                  zone.name,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: specialityActivities.length,
        itemBuilder: (context, index) {
          Card c;
          c = Card(
            color: Colors.white,
            child: ListTile(
                title: Column(
              children: [
                Text('[' + specialityActivities[index].activity_code + ']'),
                Text(specialityActivities[index].name),
              ],
            )),
          );
          return InkWell(
            child: c,
            splashColor: Colors.amber[200],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityScreen(
                    activity: specialityActivities[index],
                    completeActivityList: specialityActivities,
                    speciality: widget.speciality,
                    zone: widget.zone,
                  ),
                ),
              );
            },
          );
        },
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(context),
        extendBody: true,
        body: Container(
          child: FutureBuilder<SessionLogin>(
            future: _getLoginData(),
            builder:
                (BuildContext context, AsyncSnapshot<SessionLogin> snapshot) {
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
                                text: "Selecciona una actividad",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 20))),
                      ),
                      Expanded(
                        child: crearBotones(
                          context,
                          snapshot,
                          widget.speciality,
                          widget.zone,
                        ),
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'))
                ];

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
                    child: Text('Cargando actividades disponibles...'),
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
        ));
  }
}