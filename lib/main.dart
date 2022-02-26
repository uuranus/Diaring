import 'package:diaring/stringLocaleDelegate.dart';
import 'package:diaring/strings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'colorlist.dart';
import 'ring.dart';
import 'check.dart';
import 'note.dart';
import 'monthly.dart';
import 'shop.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ColorList.getColorList();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      localizationsDelegates: const [
        StringLocaleDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ko', ''), // Korean, no country code
      ],
      localeResolutionCallback: (locale,supportedLocales){
        if(locale==null) {
          return supportedLocales.first; //영어로 설정
        }

        for(Locale supportedLocale in supportedLocales){
          if(supportedLocale.languageCode==locale.languageCode||
              supportedLocale.countryCode==locale.countryCode){
            return supportedLocale; //지원하는 언어면 지원하는 언어로 설정
          }
        }

        return supportedLocales.first;
      },
      title: 'Diaring',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        fontFamily: 'Pretendard',
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: ColorList.getColor(9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
            brightness: Brightness.light,
            primary: ColorList.getColor(9),
            secondary: ColorList.getColor(8),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w700), //챌린지 제목
          headline2: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.w700), //다이어링 탭 글씨
          headline3: TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w400), //이번주 나의 챌린지,
          headline4: TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w700), //다이얼로그 제목
          headline5: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w400), //다이얼로그 내용, 일정 description, 상점 제목
          headline6: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w700), //월화수목금,
          bodyText1: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w400), //달력 날짜, 상점 가격
          bodyText2: TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.w400), //달력 outside 날짜
          subtitle1: TextStyle(fontSize: 12,color: ColorList.getColor(8),fontWeight: FontWeight.w400), //달력 오늘날짜
          subtitle2: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w400),  //달력 선택된 날짜

        ),
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        unselectedWidgetColor: ColorList.getColor(8),
      ),
      darkTheme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        fontFamily: 'Pretendard',
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: ColorList.getColor(9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
            brightness: Brightness.dark,
            primary: ColorList.getColor(9),
            secondary: ColorList.getColor(8)
        ),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.w700), //챌린지 제목
          headline2: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w700), //다이어링 탭 글씨
          headline3: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.w400), //이번주 나의 챌린지,
          headline4: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.w700), //다이얼로그 제목
          headline5: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w400), //다이얼로그 내용, 일정 description, 상점 제목
          headline6: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w700), //월화수목금,
          bodyText1: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w400), //달력 날짜, 상점 가격
          bodyText2: TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.w400), //달력 outside 날짜
          subtitle1: TextStyle(fontSize: 12,color: ColorList.getColor(8),fontWeight: FontWeight.w400), //달력 오늘날짜
          subtitle2: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w400),  //달력 선택된 날짜

        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        unselectedWidgetColor: ColorList.getColor(8),
      ),
      home:MyHomePage(title:'DIARING'),
    );
  }


}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex=2;
  final List<Widget> _children=[Shop(),Monthly(),Ring(),Check(),StaggeredGridePage()];
  void _onTap(int index){
    setState(() {
      _currentIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:Scaffold(
          body:_children[_currentIndex],
          bottomNavigationBar: ConvexAppBar(
            style: TabStyle.react,
            backgroundColor: ColorList.getColor(9),
           items:[
             TabItem(icon:Icons.shopping_bag_rounded,title:Strings.of(context).get('main_shop')),
             TabItem(icon:Icons.schedule_rounded,title:Strings.of(context).get('main_schedule')),
             TabItem(icon:Icons.radio_button_off_rounded,title:Strings.of(context).get('main_ring')),
             TabItem(icon:Icons.check_circle_outline_rounded,title:Strings.of(context).get('main_check')),
             TabItem(icon:Icons.sticky_note_2_rounded,title:Strings.of(context).get('main_note')),
           ],
            initialActiveIndex: 2,
            onTap:_onTap,
          ) ,
        ));
  }

}





