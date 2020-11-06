import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'client.dart';
import 'frontend_widgets/grades.dart';
import 'frontend_widgets/foods.dart';
import 'frontend_widgets/schedule.dart';
import 'googleclassroom.dart';
import 'settings.dart';
import 'package:preferences/preferences.dart';
import 'google_signin/sign_in.dart';

final client = Client();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefService.init(prefix: 'pref_');
  //PrefService.setDefaultValues({'user_description': 'This is my description!'});

  await signInWithGoogle(null, true);

  runApp(MyApp());
}

Widget addVerticalMargin(double size) {
  return Container(margin: EdgeInsets.symmetric(vertical: size, horizontal: 0));
}

class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GvidApp 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(37, 71, 99, 1),
        accentColor: Color.fromRGBO(242, 130, 12, 1),
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex; //starting window

  final divisionTitles = [
    "Nastavení",
    "Jídelna",
    "Suplování",
    "Úkoly",
    "Známky"
  ];

  final indexPages = [
    PageView(
      children: [
        SettingsWidget()
      ],
    ),


    PageView(
      children: [
        Container( //
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          alignment: Alignment.center,
          child: Foods(),
        ),
      ],
    ),

    PageView(
      children: [
        GoogleClassroomSuplyWidget(),
      ]
    ),

    PageView(
      children: [
      ],
    ),

    PageView(
      children: [
        MarksWidget(),
        Schedule()
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == null) {  // těsně po spuštění, dokud si uživatel nic nezvolil, ani se nepoužila hodnota z nastaveni
      // načte se uživatelem definovaná výchozí stránka:
      _currentIndex = PrefService.getInt('home_scr') ?? 2; // 2 == suplování, viz settings.dart, pro případ že uživatel ještě nevlezl do nastavení, a home_scr není definován
    }

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text(divisionTitles[_currentIndex]),
      ),
      body: SafeArea( //aby to nebylo pod notifikacnim barem
        child: indexPages[_currentIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        //selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Nastavení'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              label: 'Jídelna'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Suplování'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Úkoly'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.plus_one),
              label: 'Známky'
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
