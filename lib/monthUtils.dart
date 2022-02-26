import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'utils.dart';


class Meeting{
  String id;
  String title="";
  String description="";
  int color=0;

  Meeting(this.id,this.title,this.description,this.color);
  Meeting.fromJson(this.id,Map data){
    title=data['title'];
    description=data['description'];
    color=data['color'];
  }
}

class FirebaseMonth {
  static Future<StreamSubscription<DatabaseEvent>> getMonthStream( int year,int mon,
      void onData(LinkedHashMap<DateTime,List<Meeting>> meetings)) async{
    String accountKey=await Preferences.getAccountKey();

    StreamSubscription<DatabaseEvent> subscription=FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("schedule")
        .child(year.toString())
        .child(mon.toString().padLeft(2,'0'))
        .onValue
        .listen((DatabaseEvent fevent){

      LinkedHashMap<DateTime,List<Meeting>> meetings=LinkedHashMap<DateTime,List<Meeting>>();
      for(var c in fevent.snapshot.children){
          var lists=<Meeting>[];

          for(var c2 in c.children){
            lists.add(Meeting.fromJson(c2.key.toString(),c2.value as Map));
          }
          meetings.putIfAbsent(DateTime.parse(c.key!), () => lists);
      }
      onData(meetings);
      });

    return subscription;
  }

  static Future<void> setMeeting(List<DateTime> dates, String title,String description,int colorindex) async{
    String accountKey=await Preferences.getAccountKey();
    var key=DateTime.now().millisecondsSinceEpoch;

    for(int i=0;i<dates.length;i++){
      var strdate=Calendar.getStringDate(dates[i]);

      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("schedule")
          .child(strdate.substring(0,4))
          .child(strdate.substring(5,7))
          .child(strdate)
          .child(key.toString())
          .set({
            "id": key,
            "title": title,
            "description": description,
            "color": colorindex,
          });
    }


  }

  static Future<void> updateOneMeeting(DateTime date, Meeting meeting) async{
    String accountKey=await Preferences.getAccountKey();

    var strdate=Calendar.getStringDate(date);

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("schedule")
        .child(strdate.substring(0,4))
        .child(strdate.substring(5,7))
        .child(strdate)
        .child(meeting.id.toString())
        .update({
          "title": meeting.title,
          "description": meeting.description,
        });

  }

  static Future<void> updateAllMeeting(List<DateTime> pre,List<DateTime> newmeeting, Meeting meeting) async{
    String accountKey=await Preferences.getAccountKey();

    for(var date in pre){
      var strdate=Calendar.getStringDate(date);

      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("schedule")
          .child(strdate.substring(0,4))
          .child(strdate.substring(5,7))
          .child(strdate)
          .child(meeting.id.toString())
          .update({
              "title": meeting.title,
              "description": meeting.description,
              "color":meeting.color,
          });
    }

    for(var date in newmeeting){
      var strdate=Calendar.getStringDate(date);

      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("schedule")
          .child(strdate.substring(0,4))
          .child(strdate.substring(5,7))
          .child(strdate)
          .child(meeting.id.toString())
          .set({
            "id": meeting.id,
            "title": meeting.title,
            "description": meeting.description,
            "color":meeting.color,
          });
    }
  }

  static Future<void> deleteMeeting(DateTime date,String meetingid) async{

    String accountKey=await Preferences.getAccountKey();
    var strdate=Calendar.getStringDate(date);

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("schedule")
        .child(strdate.substring(0,4))
        .child(strdate.substring(5,7))
        .child(strdate)
        .child(meetingid)
        .remove();
  }

  static Future<void> deleteAllMeeting(int year,int mon,String meetingid) async{

    String accountKey=await Preferences.getAccountKey();
    int last=Calendar.getlastDate(year, mon);

    for(var i=1;i<=last;i++){
      var date=Calendar.getStringDate(DateTime(year,mon,i));
      FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("schedule")
          .child(year.toString())
          .child(mon.toString().padLeft(2,'0'))
          .child(date)
          .child(meetingid)
          .remove();
    }

  }

}