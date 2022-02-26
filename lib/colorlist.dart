import 'dart:ui';

import 'utils.dart';

class ColorList{
  static List<Color> _curColorList=[];
  static int _cur=0;

  static final colorLists = <List<Color>>[
    //tropical
    [
      Color(0xffffffff),
      Color(0xff765285), //paradise
      Color(0xff64b8b1), //medium turquoise
      Color(0xffe9d59c), //sand
      Color(0xff738b13), //leave
      Color(0xffff406c), //flamingo
      Color(0xfff9968b), //Salmon
      Color(0xfffb9e32), //sunset
      Color(0xfff27348), //tomato
      Color(0xff0192c6), //turquoise
    ],

    //ice cream,
    [
      Color(0xffffffff), // classic white
      Color(0xffe8d6cf), //Dust Storm
      Color(0xffbeb4c5), //Chatelle
      Color(0xffe6a57e), //Tonys Pink
      Color(0xfff6a06a), //Tonys Pink
      Color(0xff9c9359), //Barley Corn
      Color(0xffdc828f), //New York Pink
      Color(0xfff5bfd2), //Azalea
      Color(0xff82584f), //Mountbattern Pink
      Color(0xff56c79f), //Jungle Mist
    ],


    //city
    [
      Color(0xffffffff),
      Color(0xffc8c8d4),
      Color(0xff78c29e),
      Color(0xff90def2),
      Color(0xff4e6981),
      Color(0xff8a8c8d),
      Color(0xffa18c82),
      Color(0xffa7a598),
      Color(0xffc5956a),
      Color(0xff455052),
    ],
    //midnight
    [
      Color(0xffffffff),
      Color(0xffffc857),
      Color(0xff6a87b7),
      Color(0xff5e72eb),
      Color(0xff816796),
      Color(0xfffaa7bb),
      Color(0xff6768ab),
      Color(0xffe56b6f),
      Color(0xffa27bd1),
      Color(0xff2f3275),
    ]

  ];

  static Future<void> getColorList() async{
    await Preferences.getthemeKey().then((value){
      _curColorList=colorLists[value];
      _cur=value;
    });
  }


  static int getCurColorListIndex(){
    return _cur;
  }


  static Color getColor(int index){
    return _curColorList[index];
  }

  static int getColorListLength(){
    return _curColorList.length;
  }
}