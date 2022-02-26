import 'dart:async';
import 'dart:collection';

import 'package:diaring/monthUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'memo.dart';

/// Example event class.
class Event {
  String key;
  String title="";
  bool? isChecked=null;

  Event.fromJson(this.key,Map data){
    title=data['title'];
    if(data['isChecked']==0){
      isChecked=null;
    }
    else if(data['isChecked']==1){
      isChecked=false;
    }
    else if(data['isChecked']==2){
      isChecked=true;
    }
  }
}

class WeekData{
  String key;
  String title="";
  int cur=0;
  int goal=0;
  bool isFavoite=false;

  WeekData(this.key,this.title,this.cur,this.goal);
  WeekData.fromJson(this.key,Map data){
    title=data['title'];
    cur=data['cur'];
    goal=data['goal'];
    isFavoite=data['isFavorite'];
}
}



class FirebaseEvents{
  static Future<StreamSubscription<DatabaseEvent>> getChallengeStream(String selectDay,
      void onData(LinkedHashMap<DateTime,List<Event>> events)) async{
    String accountKey=await Preferences.getAccountKey();
    var mon=Calendar.getMonday(DateTime.parse(selectDay));
    var week=Calendar.getWeekOfYear(DateTime.parse(mon));

    StreamSubscription<DatabaseEvent> subscription=FirebaseDatabase.instance
    .ref("Diaring")
    .child("userData")
    .child(accountKey)
    .child("challenges")
    .child(mon.substring(0,4))
    .child(week.toString())
    .onValue
    .listen((DatabaseEvent fevent){

      LinkedHashMap<DateTime,List<Event>> events=LinkedHashMap<DateTime,List<Event>>();
      for(var c in fevent.snapshot.children){

        if(c.key.toString()!="weekdata") {
          var lists=<Event>[];
          var c2=c.value as List;
          for(var i=0;i<c2.length;i++){
            lists.add(Event.fromJson(i.toString(),c2[i] as Map));
          }
          events.putIfAbsent(DateTime.parse(c.key!), () => lists);
        }
      }
      onData(events);
    });

    return subscription;
  }


  static Future<StreamSubscription<DatabaseEvent>> getWeekStream(String thismon,
      void onData(List<WeekData> events)) async{
    String accountKey=await Preferences.getAccountKey();
    var week=Calendar.getWeekOfYear(DateTime.parse(thismon));

    StreamSubscription<DatabaseEvent> subscription=FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(thismon.substring(0,4))
        .child(week.toString())
        .child("weekdata")
        .onValue
        .listen((DatabaseEvent fevent){

      List<WeekData> events=<WeekData>[];
      for(var c in fevent.snapshot.children){
        events.add(WeekData.fromJson(c.key!,c.value as Map));
      }
      onData(events);
    });

    return subscription;
  }

  static Future<void> setWeekChallenge(String thismon, WeekData weekdata) async{
    String accountKey=await Preferences.getAccountKey();

    var tm=DateTime.parse(thismon);
    var week=Calendar.getWeekOfYear(DateTime.parse(thismon));

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(thismon.substring(0,4))
        .child(week.toString())
        .child("weekdata")
        .child(weekdata.key)
        .set({
          "title":weekdata.title,
          "cur":weekdata.cur,
          "goal":weekdata.goal,
          "isFavorite":false,
        });

    for(var i=0;i<7;i++){
      var date=Calendar.getStringDate(DateTime(tm.year,tm.month,tm.day+i));
      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("challenges")
          .child(thismon.substring(0,4))
          .child(week.toString())
          .child(date)
          .child(weekdata.key)
          .set({
            "title":weekdata.title,
            "isChecked": 1,
          });
    }
  }

  static Future<void> updateWeekChallenge(String thismon, String key,String newtitle, int newgoal) async{
    String accountKey=await Preferences.getAccountKey();

    var tm=DateTime.parse(thismon);
    var week=Calendar.getWeekOfYear(DateTime.parse(thismon));

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(thismon.substring(0,4))
        .child(week.toString())
        .child("weekdata")
        .child(key)
        .update({
          "title":newtitle,
          "goal":newgoal,
        }); //다시 추가

    for(var i=0;i<7;i++){
      var date=Calendar.getStringDate(DateTime(tm.year,tm.month,tm.day+i));
      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("challenges")
          .child(thismon.substring(0,4))
          .child(week.toString())
          .child(date)
          .child(key)
          .update({
            "title":newtitle,
          });
    }
  }

  static Future<void> deleteWeekChallenge(String thismon, key) async{
    String accountKey=await Preferences.getAccountKey();

    var tm=DateTime.parse(thismon);
    var week=Calendar.getWeekOfYear(DateTime.parse(thismon));

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(thismon.substring(0,4))
        .child(week.toString())
        .child("weekdata")
        .child(key)
        .remove();

    for(var i=0;i<7;i++){
      var date=Calendar.getStringDate(DateTime(tm.year,tm.month,tm.day+i));
      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("challenges")
          .child(thismon.substring(0,4))
          .child(week.toString())
          .child(date)
          .child(key)
          .remove();
    }
  }

  static Future<void> setWeekChallengeFavorite(String thismon, String key, bool isFavorite) async{
    String accountKey=await Preferences.getAccountKey();
    var week=Calendar.getWeekOfYear(DateTime.parse(thismon));

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(thismon.substring(0,4))
        .child(week.toString())
        .child("weekdata")
        .child(key)
        .update({
          "isFavorite":isFavorite,
        });
  }

  static Future<void> setChallenge(String date, String key, bool? precheck, bool? isChecked) async{ //만든 챌린지 데일리 체크 메소드
    String accountKey=await Preferences.getAccountKey();
    var mon= Calendar.getMonday(DateTime.parse(date));
    var week=Calendar.getWeekOfYear(DateTime.parse(mon));

    var ischecked=0;
    var increment=0;

    if(precheck==null||precheck==false){
      if(isChecked==true){
        increment=1;
      }
    }
    else{
      if(isChecked!=true){
        increment=-1;
      }
    }

    if(isChecked==null){
      ischecked=0;
    }
    else if(isChecked==false){
      ischecked=1;
    }
    else if(isChecked==true){
      ischecked=2;
    }

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(date.substring(0,4))
        .child(week.toString())
        .child(date)
        .child(key)
        .update({
          "isChecked":ischecked,
        }); //체크값 저장

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("challenges")
        .child(date.substring(0,4))
        .child(week.toString())
        .child("weekdata")
        .child(key)
        .runTransaction((value) {
          var v=value as Map;
          value['cur']=v['cur']+increment;
          // value=v+increment;
          return Transaction.success(value);
        }); //weekdata의 cur값도 갱신
  }
}

class FirebaseNotes {
  static Future<StreamSubscription<DatabaseEvent>> getNoteStream(
      void onData(List<Memo> memos)) async{
    String accountKey=await Preferences.getAccountKey();
  
    StreamSubscription<DatabaseEvent> subscription=FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("notes")
        .onValue
        .listen((DatabaseEvent fevent){

      List<Memo> memos=<Memo>[];
      for(var c in fevent.snapshot.children){
          memos.add(Memo.fromJson(int.parse(c.key!),c.value as Map));
      }
      onData(memos);
    });

    return subscription;
  }

  static Future<void> setNote(Memo memo) async{
    String accountKey=await Preferences.getAccountKey();
    
    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("notes")
        .child(memo.id.toString())
        .set({
            "id": memo.id,
            "title": memo.title,
            "content": memo.content,
            "date_created": memo.date_created.toString(),
            "date_last_edited": memo.date_last_edited.toString(),
            "indexOfColor": memo.indexOfColor,
        });

  }

  static Future<void> updateNote(Memo memo) async{
    String accountKey=await Preferences.getAccountKey();

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("notes")
        .child(memo.id.toString())
        .update({
          "title": memo.title,
          "content": memo.content,
          "date_last_edited": memo.date_last_edited.toString(),
          "indexOfColor": memo.indexOfColor
        });

  }

  static Future<void> deleteNote(String memoid) async{
   
    String accountKey=await Preferences.getAccountKey();

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("notes")
        .child(memoid)
        .remove();
  }
  
}


class Preferences{
  static const String ACCOUNT_KEY="accountkey";
  static const String SELECTED_EMOJI="0";
  static const String SELECTED_THEME="-1";
  static const String TWOONE="21";
  static const String TWOTWO="22";
  static const String TWOTHREE="23";
  static const String THREE="3";
  static const String FOUR="4";
  static const String FIVE="5";

  static Future<bool> setAccountKey(String accountkey) async{
    SharedPreferences pref= await SharedPreferences.getInstance();
    pref.setString(ACCOUNT_KEY,accountkey);
    return pref.commit();
  }

  static Future<void> setNickname(String nickname) async{
    await FirebaseAuth.instance.currentUser!.updateDisplayName(nickname);
  }


  static Future<void> getNickname(onData(String nickname)) async{
    String? nick=await FirebaseAuth.instance.currentUser!.displayName;

    if(nick==null||nick.isEmpty){
      nick="익명";
    }
    onData(nick);
  }

  static Future<String> getAccountKey() async{
    User? fu= await FirebaseAuth.instance.currentUser;

    if(fu==null){
      //로그인 함
      UserCredential userCredential= await FirebaseAuth.instance.signInAnonymously();

      fu= await FirebaseAuth.instance.currentUser;
      await FirebaseDatabase.instance //기본 스티커랑
          .ref("Diaring")
          .child("userData")
          .child(fu!.uid)
          .child("history")
          .child("stickers")
          .child("0")
          .set("조랭냥이 스티커");
      await FirebaseDatabase.instance //기본 이모티콘 저장
          .ref("Diaring")
          .child("userData")
          .child(fu.uid)
          .child("history")
          .child("emojis")
          .child("0")
          .set({
            "isSelected":true,
            "title" :"조랭냥이 이모티콘",
          });


      var thismon=Calendar.getMonday(DateTime.now());
      await FirebaseEvents.setWeekChallenge(thismon, WeekData("0","Diaring",0,7)); //튜토리얼을 위해서 초기챌린지 설정
      await FirebaseMonth.setMeeting(<DateTime>[DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)], "Diaring", "Hello", 7); //튜토리얼을 위해서 오늘 날짜의 일정 추가

    }

    return fu.uid;
  }

  static Future<bool> setEmojiKey(String emojikey) async{
    SharedPreferences pref= await SharedPreferences.getInstance();
    pref.setString(SELECTED_EMOJI,emojikey);
    return pref.commit();
  }

  static Future<String> getEmojiKey() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    String? emojikey=pref.getString(SELECTED_EMOJI);

    emojikey ??= "0";

    return emojikey;
  }

  static Future<bool> setThemeKey(int themekey) async{
    SharedPreferences pref= await SharedPreferences.getInstance();
    pref.setInt(SELECTED_THEME,themekey);
    return pref.commit();
  }

  static Future<int> getthemeKey() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    int? themekey=pref.getInt(SELECTED_THEME);

    themekey ??= 0;

    return themekey;
  }

  static Future<bool> setIsFirst(int num, int isf) async{
    SharedPreferences pref= await SharedPreferences.getInstance();
    switch(num){
      case 21:{
        pref.setInt(TWOONE,isf);
        break;
      }
      case 22:{
        pref.setInt(TWOTWO,isf);
        break;
      }
      case 23:{
        pref.setInt(TWOTHREE,isf);
        break;
      }
      case 3:{
        pref.setInt(THREE,isf);
        break;
      }
      case 4:{
        pref.setInt(FOUR,isf);
        break;
      }
      case 5:{
        pref.setInt(FIVE,isf);
        break;
      }
      default :{

      }
    }

    return pref.commit();
  }

  static Future<int> getIsFirst(int num) async{
    SharedPreferences pref= await SharedPreferences.getInstance();

    int? isFirst=null;
    switch(num){
      case 21:{
        isFirst=pref.getInt(TWOONE);
        break;
      }
      case 22:{
        isFirst=pref.getInt(TWOTWO);
        break;
      }
      case 23:{
        isFirst=pref.getInt(TWOTHREE);
        break;
      }
      case 3:{
        isFirst=pref.getInt(THREE);
        break;
      }
      case 4:{
        isFirst=pref.getInt(FOUR);
        break;
      }
      case 5:{
        isFirst=pref.getInt(FIVE);
        break;
      }
      default :{

      }
    }

    if(isFirst==null){
      isFirst=1;
    }

    return isFirst;
  }
}

class Calendar{
  static String getMonday(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(DateTime(date.year,date.month,date.day-(date.weekday-1)));
  }

  static String getSunday(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(DateTime(date.year,date.month,date.day+(7-date.weekday)));
  }

  static int getWeekOfDate(DateTime date) {
    var firstday=DateTime(date.year,date.month,1);
    return (date.day+firstday.weekday-1)~/7+1;
  }

  static int getWeekOfYear(DateTime date){
    var day=int.parse(DateFormat('DD').format(date));
    var firstday=DateTime(date.year,1,1);
    return (day+firstday.weekday-1)~/7+1;
  }


  static String getStringDate(DateTime date){
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static int getlastDate(int year,int month){
    return DateTime(year,month+1,0).day;
  }

}
