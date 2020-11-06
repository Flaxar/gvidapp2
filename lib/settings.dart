import 'dart:core';
//import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
//import 'client.dart';
import 'package:preferences/preferences.dart';
import 'google_signin/login_widget.dart';

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return SettingsPage(title: 'Nastavení');
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[850],
      body: PreferencePage([
        PreferenceTitle(
          'Přihlašování:',
          // style: TextStyle(
          //   fontSize: 25,
          //   color: Colors.white,
          //   decoration: TextDecoration.underline
//          ),
        ),

        PreferencePageLink(
          'Google služby (classroom atd.)',
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('Přihlašovací údaje pro Google:'),
            GoogleSignInOutWidget(),
          ])
        ),

        PreferencePageLink(
            'Škola online',
            trailing: Icon(Icons.keyboard_arrow_right),
            page: PreferencePage([
              PreferenceTitle('Přihlašovací údaje pro aplikace.skolaonline.cz:'),
              TextFieldPreference(
                  'Login', 'sol_login'
              ),
              TextFieldPreference(
                'Heslo', 'sol_password',
                obscureText: true,
              )
            ])
        ),

        PreferencePageLink(
            'Jídelna',
            trailing: Icon(Icons.keyboard_arrow_right),
            page: PreferencePage([
              PreferenceTitle('Přihlašovací údaje pro jidelna.gvid.cz:'),
              TextFieldPreference(
                  'Login', 'food_login'
              ),
              TextFieldPreference(
                'Heslo', 'food_password',
                obscureText: true,
              )
            ])
        ),

        Divider(
          thickness: 3,
        ),

        // Notifications are controlled on demand, check commit logs

        DropdownPreference(
            "Domovská obrazovka",
            "home_scr",
            defaultVal: 2,  // 2 == suplování, viz main.dart
            displayValues: ['Nastavení', 'Jídelna', 'Suplování', 'Úkoly', 'Známky'],
            values: [0, 1, 2, 3, 4],
        ),
      ]),
    );
  }
}
