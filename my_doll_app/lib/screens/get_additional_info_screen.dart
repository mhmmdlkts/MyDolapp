import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:my_doll_app/main.dart';
import 'package:my_doll_app/services/cloudfunctions_service.dart';
import 'package:my_doll_app/services/permission_service.dart';
import 'package:my_doll_app/services/person_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruler_picker_bn/ruler_picker_bn.dart';
import 'package:my_doll_app/models/person.dart';

import '../widgets/stepper.dart';

class GetAdditionalInfoScreen extends StatefulWidget {
  final Person person;
  const GetAdditionalInfoScreen(this.person, {super.key});

  @override
  _GetAdditionalInfoScreenState createState() => _GetAdditionalInfoScreenState();
}

class _GetAdditionalInfoScreenState extends State<GetAdditionalInfoScreen> {

  late Person person;
  bool onWeightTap = false;
  bool onHeightTap = false;

  bool isLocationPermissionAsked = false;
  bool isNotificationPermissionAsked = false;

  bool isLocationPermissionGiven = false;
  bool isNotificationPermissionGiven = false;

  bool? usernameIsValid;

  @override
  void initState() {
    super.initState();
    person = Person.copy(widget.person);
    person.email = FirebaseAuth.instance.currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: EJStepper(
            onLastStepConfirmTap: () {
              updateValues(person);
            },
            steps: [
              EJStep(
                  title: Text( 'Email', style: TextStyle(color: Colors.black, fontSize: 16) ),
                  subtitle: person.email?.isNotEmpty ?? false ? Text( person.email!, style: textTheme.subtitle2!.copyWith(color: Colors.grey), ) : null,
                  leftWidget: Icon( Icons.email, size: 30, ),
                  state: EJStepState.complete,
                  content: Container()
              ), //
              EJStep(
                onUnfocused: (int index) {
                  if (widget.person.username==null && person.username != null) {
                    checkIsUsernameValid(person.username!);
                  }
                },
                error: usernameIsValid??true?null:'This username is already taken.',
                title: Text( 'Username', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle: person.username?.isNotEmpty ?? false ? Text( person.username!, style: textTheme.subtitle2!.copyWith(color: Colors.grey), ) : null,
                leftWidget: Icon( Icons.person, size: 30, ),
                state: widget.person.username!=null?EJStepState.complete:(usernameIsValid == null ? EJStepState.enable : (usernameIsValid??false?EJStepState.complete:EJStepState.error)),
                content: widget.person.username!=null?Container():TextField(
                  onChanged: (value) {
                    setState(() {
                      person.username = value;
                    });
                  },
                ),
              ),
              EJStep(
                title: Text( 'Name', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle: person.name?.isNotEmpty ?? false ? Text( person.name!, style: textTheme.subtitle2!.copyWith(color: Colors.grey), ) : null,
                leftWidget: Icon( Icons.badge, size: 30, ),
                state: person.name?.isNotEmpty??false ? EJStepState.complete : EJStepState.enable,
                content: TextField(
                  onChanged: (value) {
                    setState(() {
                      person.name = value;
                    });
                  },
                ),
              ),
              EJStep(
                  title: Text( 'Birthdate', style: TextStyle(color: Colors.black, fontSize: 16) ),
                  subtitle:  person.birthdate != null?Text(Jiffy(person.birthdate!.toDate()).format('MMM, dd yyyy'), style: textTheme.subtitle2!.copyWith(color: Colors.grey), ):null,
                  leftWidget: Icon( Icons.cake, size: 30, ),
                  state: person.birthdate!=null? EJStepState.complete : EJStepState.enable,
                  onStepTap: (index) {
                    showDatePickerDialog();
                  },
                  onStepOpen: (index) {
                    if (person.birthdate!=null) {
                      return;
                    }
                    showDatePickerDialog();
                  },
                  content: Container()
              ),
              EJStep(
                title: Text( 'Height', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle:  person.height != null?Text('${person.height} cm', style: textTheme.subtitle2!.copyWith(color: Colors.grey), ):null,
                leftWidget: Icon( Icons.accessibility, size: 30, ),
                state: person.height!=null? EJStepState.complete : EJStepState.enable,
                onStepOpen: (index) {
                  onHeightTap = true;
                },
                content: SizedBox(
                  height: 70,
                  width: 175,
                  child: RulerPicker(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    onChange: (val) {
                      if (!onHeightTap) {
                        return;
                      }
                      setState(() {
                        person.height = val;
                      });
                    },
                    background: Colors.white,
                    lineColor: Colors.black,
                    direction: Axis.horizontal,
                    maxValue: 250,
                    minValue: 90,
                  ),
                ),
              ),
              EJStep(
                title: Text( 'Weight', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle:  person.weight != null?Text('${person.weight} kg', style: textTheme.subtitle2!.copyWith(color: Colors.grey), ):null,
                leftWidget: Icon( Icons.monitor_weight, size: 30, ),
                state: person.weight!=null? EJStepState.complete : EJStepState.enable,
                onStepOpen: (index) {
                  onWeightTap = true;
                },
                content: SizedBox(
                  height: 70,
                  width: 175,
                  child: RulerPicker(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    onChange: (val) {
                      if (!onWeightTap) {
                        return;
                      }
                      setState(() {
                        person.weight = val;
                      });
                    },
                    background: Colors.white,
                    lineColor: Colors.black,
                    direction: Axis.horizontal,
                    startValue: 70,
                    maxValue: 500,
                    minValue: 20,
                  ),
                ),
              ),
              EJStep(
                title: Text( 'Gender', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle:  person.gender != null?Text(Person.getStringFromGender(person.gender!).toCapitalized(), style: textTheme.subtitle2!.copyWith(color: Colors.grey), ):null,
                leftWidget: Icon(person.gender==Gender.female?Icons.female:Icons.male, size: 30, ),
                state: person.gender!=null? EJStepState.complete : EJStepState.enable,
                content: CustomRadioButton(
                  elevation: 0,
                  selectedBorderColor: Colors.green,
                  unSelectedBorderColor: person.gender != null?Colors.green:Colors.blue,
                  unSelectedColor: Colors.transparent,
                  buttonLables: Gender.values.map(Person.getStringFromGender).toList(),
                  buttonValues: Gender.values,
                  radioButtonValue: (value) {
                    setState(() {
                      person.gender = value;
                    });
                  },
                  selectedColor: Colors.green,
                ),
              ),
              EJStep(
                title: Text( 'Location', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle: Text( isLocationPermissionGiven.toString().toCapitalized(), style: textTheme.subtitle2!.copyWith(color: Colors.grey), ),
                leftWidget: Icon( Icons.location_pin, size: 30, ),
                state: isLocationPermissionAsked ? EJStepState.complete : EJStepState.enable,
                content: Container(),
                onStepTap: isLocationPermissionGiven?null:(index) => getPermission(Permission.locationWhenInUse),
                onStepOpen: isLocationPermissionGiven?null:(index) => getPermission(Permission.locationWhenInUse),
              ),
              EJStep(
                title: Text( 'Notification', style: TextStyle(color: Colors.black, fontSize: 16) ),
                subtitle: Text( isNotificationPermissionGiven.toString().toCapitalized(), style: textTheme.subtitle2!.copyWith(color: Colors.grey), ),
                leftWidget: Icon( Icons.notifications, size: 30, ),
                state: isNotificationPermissionAsked ? EJStepState.complete : EJStepState.enable,
                content: Container(),
                onStepTap: isNotificationPermissionGiven?null:(index) => getPermission(Permission.notification),
                onStepOpen: isNotificationPermissionGiven?null:(index) => getPermission(Permission.notification),
              ),
            ], //
          ),
        ),
      ),
    );
  }

  Future checkIsUsernameValid(String username) async {
    Map result = await CloudfunctionsService.httpCall(CloudfunctionsService.functionExistUsername, body: {'username': username});
    setState(() {
      usernameIsValid = result['val'] == true;
    });
  }

  Future updateValues(Person person) async {
    if (!person.isDataComplete()) {
      print('Data is not complete');
      return;
    }
    Map result = await CloudfunctionsService.httpCall(CloudfunctionsService.functionUpdateUserValues,
      body: {
        'person': person.toJson()
      }
    );
    if (result['val']) {
      PersonService.initPerson().then((value) => {
        setState((){})
      });
    }
  }

  void getPermission(Permission permission) {
    PermissionService.getPermission(permission).then((value) => {
      setState((){
        if (permission == Permission.locationWhenInUse) {
          isLocationPermissionAsked = true;
          isLocationPermissionGiven = value;
        }
        if (permission == Permission.notification) {
          isNotificationPermissionAsked = true;
          isNotificationPermissionGiven = value;
        }
      })
    });
  }

  void showDatePickerDialog() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: person.birthdate!=null?person.birthdate!.toDate():DateTime.now().subtract(Duration(days: 365 * 8)),
        firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
        lastDate: DateTime.now().subtract(Duration(days: 365 * 8))
    );
    if (picked != null && picked != person.birthdate?.toDate()) {
      setState(() {
        person.birthdate = Timestamp.fromDate(picked);
      });
    }
  }
}
