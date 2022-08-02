import 'dart:convert';
import 'dart:io';
import 'package:lekapp_supervisor/screens/main_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lekapp_supervisor/classes/Activity.dart';
import 'package:lekapp_supervisor/classes/ActivityRegistries.dart';
import 'package:lekapp_supervisor/classes/ActivityRegistry.dart';
import 'package:lekapp_supervisor/classes/SessionLogin.dart';
import 'package:lekapp_supervisor/classes/Speciality.dart';
import 'package:lekapp_supervisor/classes/SpecialityRole.dart';
import 'package:lekapp_supervisor/classes/Zone.dart';
import 'package:lekapp_supervisor/screens/login_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ActivityScreen extends StatefulWidget {
  final Activity activity;
  final Speciality speciality;
  final Zone zone;
  final List<Activity> completeActivityList;

  ActivityScreen({
    required this.activity,
    required this.completeActivityList,
    required this.speciality,
    required this.zone,
  }) : super();

  @override
  ActivityScreenState createState() => ActivityScreenState();
}

class ActivityScreenState extends State<ActivityScreen> {
  bool _rememberMe = false;
  late SharedPreferences prefs;
  late String? nameText;
  late String? emailText;
  late Future<SessionLogin> sessionLogin;
  late List<Activity> relatedActivityList;
  late List<SpecialityRole> relatedSpecialityRoleList;
  late ActivityRegistries activityRegistries;
  late ActivityRegistry activityRegistry;
  late String? _chosenSpecialityRoleValue;
  late TextEditingController machinery;
  late TextEditingController comment;
  late TextEditingController p_avance;
  late bool hasImage;
  late File _image;
  late Image image;
  final picker = ImagePicker();
  late List<dynamic> dataList = <dynamic>[];
  late List<int> imageBytes;

  @override
  void initState() {
    sessionLogin = _getPrefs();
    relatedActivityList = <Activity>[];
    relatedSpecialityRoleList = <SpecialityRole>[];
    activityRegistries = new ActivityRegistries(activityRegistries: []);
    hasImage = false;
    imageBytes = <int>[];
    sessionLogin.then(
      (value) {
        widget.completeActivityList.forEach(
          (actElement) {
            if (actElement.activity_code == widget.activity.activity_code) {
              relatedActivityList.add(actElement);
              value.specialityRoles.forEach(
                (srElement) {
                  if (srElement.id == actElement.fk_speciality_role) {
                    relatedSpecialityRoleList.add(srElement);
                  }
                },
              );
            }
          },
        );
        //value.
      },
    );
    _chosenSpecialityRoleValue = null;
    machinery = new TextEditingController();
    comment = new TextEditingController();
    p_avance = new TextEditingController();
    super.initState();
  }

  Future getImage(String _chosenZoneValue, bool fromCamera) async {
    dataList.clear();
    dataList.add(_chosenZoneValue);
    dataList.add(_chosenSpecialityRoleValue);
    dataList.add(machinery.text);
    dataList.add(comment.text);
    dataList.add(p_avance.text);
    final pickedFile;
    if (fromCamera) {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }
    setState(
      () {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          image = Image.file(_image);
          imageBytes = _image.readAsBytesSync();
          dataList.add(image);
          dataList.add(_image);
          hasImage = true;
        } else {
          dataList.add(null);
          dataList.add(null);
          hasImage = false;
          imageBytes.clear();
        }
      },
    );
    _chosenZoneValue = dataList[0];
    _chosenSpecialityRoleValue = dataList[1];
    machinery.text = dataList[2];
    comment.text = dataList[3];
    p_avance.text = dataList[4];
  }

  Future<void> _emptyPrefs(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('sessionData');
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return LoginScreen();
          },
          transitionsBuilder: (BuildContext context,
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
          },
        ),
        (Route route) => false);
  }

  Future<SessionLogin> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    nameText = prefs.getString('name');
    emailText = prefs.getString('email');
    String t = prefs.getString('sessionData') as String;
    Map<String, dynamic> mapSt = json.decode(t);
    String aR = prefs.getString('activityRegistry') as String;
    Map<String, dynamic> mapAR = json.decode(aR);
    mapAR.forEach(
      (key, value) {
        if (key == emailText) {
          List<dynamic> arList = value;
          List<ActivityRegistry> tarList = <ActivityRegistry>[];
          for (int index = 0; index < arList.length; index++) {
            ActivityRegistry t = new ActivityRegistry(
              id: arList[index]['id'],
              hh: arList[index]['hh'],
              fk_building_site: arList[index]['fk_building_site'],
              fk_activity: arList[index]['fk_activity'],
              fk_speciality: arList[index]['fk_speciality'],
              fk_speciality_role: arList[index]['fk_speciality_role'],
              base64_image: arList[index]['base64_image'],
              workers: "0",
              activity_date: arList[index]['activity_date'],
              activity_date_f: arList[index]['activity_date_f'],
              p_avance: arList[index]['p_avance'],
              machinery: arList[index]['machinery'],
              comment: arList[index]['comment'],
              activity_code: arList[index]['activity_code'],
            );
            tarList.add(t);
          }
          activityRegistries =
              new ActivityRegistries(activityRegistries: tarList);
        }
      },
    );
    return SessionLogin.fromJson(mapSt);
  }

  Future<SessionLogin> _getLoginData() async {
    await Future.delayed(
      Duration(seconds: 2),
    );
    return sessionLogin;
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
            title: Text(
              snapshot.data!.buildingSites[index].name,
            ),
          ),
        );
        return InkWell(
          child: c,
          splashColor: Colors.amber[200],
          onTap: () {},
        );
      },
    );
  }

  void _goBack(List<ActivityRegistry> arList) {
    setState(() {
      activityRegistries = new ActivityRegistries(activityRegistries: arList);
      prefs.setString(
        'activityRegistry',
        json.encode(
          activityRegistries
              .toInternalDatabase(prefs.getString('email') as String),
        ),
      );
    });
    Alert(
      context: context,
      type: AlertType.none,
      title: "¡Éxito!",
      desc: "Actividad registrada. No olvide sincronizar.",
      buttons: [
        DialogButton(
          child: Text(
            "Continuar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => {
            Navigator.of(context).popUntil((route) => route.isFirst),
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    ).show();
  }

  void _onAlertButtonsPressed(BuildContext context, String _chosenZoneValue) {
    Alert(
      context: context,
      type: AlertType.none,
      title: "¿De donde deseas traer la imagen?",
      desc: "Puede ser desde tu cámara, o tu galería de imágenes",
      buttons: [
        DialogButton(
          child: Text(
            "Cámara",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => {
            getImage(_chosenZoneValue, true),
            Navigator.pop(context),
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "Galería",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => {
            getImage(_chosenZoneValue, false),
            Navigator.pop(context),
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0),
          ]),
        )
      ],
    ).show();
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
              List<ActivityRegistry> arList = activityRegistries.toList();
              List<ActivityRegistry> definiteArList = <ActivityRegistry>[];
              DateFormat dateFormat = new DateFormat('yyyy-MM-dd');
              String date = dateFormat.format(
                DateTime.now(),
              );
              DateTime dateNoTime = DateTime.parse(date);
              Timestamp ts = Timestamp.fromDate(dateNoTime);
              String dateF = ((ts.seconds) ~/ 86400).toString();
              bool activityToday = false;
              arList.forEach((arEntry) {
                if (arEntry.fk_building_site ==
                        widget.activity.fk_building_site &&
                    arEntry.activity_code == widget.activity.activity_code &&
                    arEntry.activity_date ==
                        dateFormat.format(DateTime.now())) {
                  definiteArList.add(arEntry);
                  activityToday = true;
                }
              });
              ActivityRegistry arValue = new ActivityRegistry(
                  id: (arList.length + 1).toString(),
                  hh: "0",
                  fk_building_site: widget.activity.fk_building_site,
                  fk_activity: widget.activity.id,
                  fk_speciality: widget.activity.fk_speciality,
                  fk_speciality_role: "0",
                  base64_image: "",
                  workers: "0",
                  activity_date: date,
                  activity_date_f: dateF,
                  p_avance: "0",
                  machinery: "",
                  comment: "",
                  activity_code: widget.activity.activity_code);
              if (!activityToday) {
                result = Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: RichText(
                          text: TextSpan(
                            text: "[" +
                                widget.activity.activity_code +
                                "] " +
                                widget.activity.name,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                              text:
                                  "Actividad válida, pero aún no abierta el día de hoy. Para comenzar la actividad y desplegar el código de asistencia de trabajadores, presione el siguiente botón.",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        child: Text("Iniciar actividad"),
                        onPressed: () => {
                          arList.add(arValue),
                          definiteArList.add(arValue),
                          activityRegistries = new ActivityRegistries(
                              activityRegistries: arList),
                          prefs.setString(
                            'activityRegistry',
                            json.encode(
                              activityRegistries.toInternalDatabase(
                                  prefs.getString('email') as String),
                            ),
                          ),
                          setState(
                            () => {},
                          )
                        },
                      )
                    ],
                  ),
                );
              } else {
                String bsc = widget.activity.fk_building_site;
                String code = widget.activity.activity_code;
                String zoneCode = widget.zone.id;
                List<int> data =
                    utf8.encode(date + "|" + bsc + "|" + code + "|" + zoneCode);
                String base64Code = base64.encode(data);
                result = SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: RichText(
                            text: TextSpan(
                              text: "[" +
                                  widget.activity.activity_code +
                                  "] " +
                                  widget.activity.name,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 20),
                            ),
                          ),
                        ),
                        QrImage(
                          data: base64Code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButton<String>(
                            items: relatedSpecialityRoleList.map(
                              (SpecialityRole value) {
                                return new DropdownMenuItem<String>(
                                  value: value.id,
                                  child: new Text(value.name),
                                );
                              },
                            ).toList(),
                            onChanged: (String? changedValue) {
                              definiteArList.forEach(
                                (arEntry) {
                                  if (arEntry.fk_speciality_role == "0" ||
                                      arEntry.fk_speciality_role ==
                                          widget.activity.fk_speciality_role) {
                                    setState(
                                      () {
                                        _chosenSpecialityRoleValue =
                                            changedValue;
                                        machinery.text = arEntry.machinery;
                                        comment.text = arEntry.comment;
                                        p_avance.text = arEntry.p_avance;
                                        hasImage = arEntry.base64_image != ""
                                            ? true
                                            : false;
                                      },
                                    );
                                  }
                                },
                              );
                            },
                            value: _chosenSpecialityRoleValue,
                            hint: Text("Seleccione un rol de especialidad"),
                            isExpanded: true,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            maxLines: 3,
                            controller: machinery,
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                                hintText: "Maquinaria"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            maxLines: 3,
                            controller: comment,
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                                hintText: "Notas"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: p_avance,
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                                hintText: "Avance (Total: " +
                                    num.tryParse(widget.activity.qty)
                                        .toString() +
                                    " [" +
                                    widget.activity.unt +
                                    "])"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(hasImage == true
                              ? "Imagen adjunta"
                              : "Sin imagen"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: ElevatedButton(
                            child: Text("Obtener registro fotográfico"),
                            onPressed: () => {
                              _onAlertButtonsPressed(context, widget.zone.id),
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: ElevatedButton(
                            child: Text("Guardar registro"),
                            onPressed: () => {
                              activityRegistry = new ActivityRegistry(
                                  id: "0",
                                  hh: "0",
                                  fk_building_site:
                                      widget.activity.fk_building_site,
                                  fk_activity: widget.activity.id,
                                  fk_speciality: widget.activity.fk_speciality,
                                  fk_speciality_role:
                                      _chosenSpecialityRoleValue ?? "0",
                                  base64_image: base64.encode(imageBytes),
                                  workers: "0",
                                  activity_date: date,
                                  activity_date_f:
                                      (num.tryParse(dateF)).toString(),
                                  p_avance: p_avance.text,
                                  comment: comment.text,
                                  machinery: machinery.text,
                                  activity_code: widget.activity.activity_code),
                              definiteArList.forEach(
                                (arEntry) {
                                  if (arEntry.activity_date ==
                                          dateFormat.format(
                                            DateTime.now(),
                                          ) &&
                                      (arEntry.fk_speciality_role ==
                                              _chosenSpecialityRoleValue ||
                                          arEntry.fk_speciality_role == "0")) {
                                    arList.remove(arEntry);
                                    definiteArList.remove(arEntry);
                                    arList.add(activityRegistry);
                                    definiteArList.add(activityRegistry);
                                  }
                                },
                              ),
                              _goBack(arList)
                            },
                          ),
                        )
                      ],
                    ),
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
                  child: Text('Cargando información disponible...'),
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
    );
  }
}
