import 'dart:async';
import 'dart:collection';

import 'package:diaring/strings.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'storage.dart';
import 'utils.dart';

class Check extends StatefulWidget{
  const Check({Key? key}) : super(key: key);

  @override
  _CheckState createState() => _CheckState();

}

class _CheckState extends State<Check>{
  //global keys for tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  final GlobalKey _dateKey = const GlobalObjectKey("date");
  final GlobalKey _checkKey = const GlobalObjectKey("check");
  final GlobalKey _imageKey = const GlobalObjectKey("image");
  int isFirst=1;


  CalendarFormat format=CalendarFormat.week;
  DateTime _focusedDay=DateTime.now();
  DateTime _selectedDay=DateTime.now();
  late final ValueNotifier<List<Event>> _selectedEvents;

  List<Event> _getEventsForDay(DateTime day){
    var localday=DateTime(day.year,day.month,day.day,0,0,0,0);
    if(_kEvents.isEmpty || _kEvents[localday]==null){
      return [];
    }
    else {
      return _kEvents[localday]!;
    }
  }

  final TextEditingController _eventController = TextEditingController();
  late StreamSubscription _subscription;
  LinkedHashMap<DateTime,List<Event>> _kEvents=LinkedHashMap<DateTime,List<Event>>();

  List<EmojiTitle> _myemojis=<EmojiTitle>[];
  late final ValueNotifier<List<String>> _selectedEmoji;
  List<String> _selectedEmojis=<String>['images/emojis01.png','images/emojis02.png','images/emojis03.png','images/emojis04.png','images/emojis05.png']; //bottomsheet에서 선택시 변경되는 이모티콘을 위한 것들
  List<String> emojis=<String>[];
  bool isdefault=true;
  String old="";
  bool isDone=false; //아직 전 이모티콘 다 가져오기 전에 다른 걸로 바꾸면 섞이므로 다 로딩 후 클릭가능하게 함
  int _selectedID=0; //bottomsheet row 현재 선택중인 거
  String select="선택하기";

  @override
  void initState() {
    var date=Calendar.getStringDate(DateTime.now());
    initStream(date);
    initEmoji();
    initEmojiIDs();
    _selectedEvents= ValueNotifier(_getEventsForDay(_selectedDay));
    _selectedEmoji=ValueNotifier(_selectedEmojis);
    isFirstShow();
    super.initState();
  }

  void isFirstShow() async{
    isFirst= await Preferences.getIsFirst(4);

    if(isFirst==1){
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  void initStream(String date){
    FirebaseEvents.getChallengeStream(date, (events) {
      setState(() {
        _kEvents=events;
        _selectedEvents.value=_getEventsForDay(DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day));
      });
    }).then((value) => _subscription=value);
  }

  void initEmoji(){
    emojis=[]; //초기화
    StickerStorage.getSelectedEmojis((path,isdone,emojikey) {
      if(path==""){
        setState(() {
          emojis=<String>['images/emojis01.png','images/emojis02.png','images/emojis03.png','images/emojis04.png','images/emojis05.png'];
          isDone=isdone;
          old=emojikey;
        });
        isdefault=true;
      }
      else{
        setState(() {
          emojis.add(path);
          isDone=isdone;
          old=emojikey;
        });
        isdefault=false;
      }
    });
  }

  void initEmojiIDs(){ //bottom sheet에 이모티콘 리스트 목록 가져오기
    StickerStorage.getEmojiIDs((titles) {
      setState(() {
        _myemojis=titles;
      });
    });
  }

  void getEmoji(String groupID) { //다른 이모티콘 제목 선택시 해당 이모티콘들 가져오기
    if(groupID=="0"){
      setState(() {
        _selectedEmojis=<String>['images/emojis01.png','images/emojis02.png','images/emojis03.png','images/emojis04.png','images/emojis05.png'];
        _selectedEmoji.value=_selectedEmojis;
      });
    }
    else{
      StickerStorage.getEmojis(groupID,(emojis) {
        setState(() {
          _selectedEmojis=emojis;
          _selectedEmoji.value=_selectedEmojis;
        });
      });
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<Event>(
            key: _dateKey,
            daysOfWeekHeight: 30,
            locale: Localizations.localeOf(context).languageCode,
            calendarFormat: format,
            onFormatChanged: (_format){
              setState(() {
                format=_format;
              });
            },
            onPageChanged: (focusedDay){
              _focusedDay=focusedDay;
              var date=Calendar.getStringDate(focusedDay);
              initStream(date);
            },
            headerStyle: HeaderStyle(
              titleTextStyle: Theme.of(context).textTheme.headline1!,
              titleCentered:true,
              formatButtonVisible: false,
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {CalendarFormat.week:"week"},
            selectedDayPredicate: (day){
              return isSameDay(_selectedDay,day);
            },
            onDaySelected: (selectedDay,focusedDay){
              setState(() {
                _focusedDay=focusedDay;
                _selectedDay=selectedDay;
                _selectedEvents.value=_getEventsForDay(selectedDay);
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context,date,events) {
                double opacity=0.0;
                if(events.isNotEmpty){
                  final completedTasks=
                  events.where((task) => task.isChecked==true).toList();
                  opacity=completedTasks.length/events.length;
                  if(opacity==0){
                    opacity=0.1;
                  }
                }
                return Container(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    ],
                  ),
                );
              },
              selectedBuilder: (context,date,events)=>
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(230, 230, 230, 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                        date.day.toString(),
                        style:const TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w400) //검정으로 고정
                    ),
                  ),
              todayBuilder: (context,date,events) =>
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style:Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
              defaultBuilder: (context,date,events)=>
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style:Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
              outsideBuilder: (context,date,events)=>
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style:Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
            ),
            focusedDay: _focusedDay,
            firstDay:  DateTime.utc(2010,10,16),
            lastDay: DateTime.utc(2030,10,16),
            eventLoader: (day){
              return _getEventsForDay(day);
            },
          ),
          const SizedBox(height:20),
          Expanded(
            flex:2,
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      key: index==0 ? _checkKey : null,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [ BoxShadow(
                            color: Colors.grey.withOpacity(0.35),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(4, 3),
                          ),]
                      ),
                      child: ListTile(
                        title: Text(value[index].title,
                          style: const TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w400), //검정으로 고정
                        ),
                        trailing: Checkbox(
                          tristate: true,
                          activeColor: Theme.of(context).colorScheme.secondary,
                          value: value[index].isChecked,
                          onChanged: (newvalue){
                            setState(() {
                              var pre=value[index].isChecked;
                              FirebaseEvents.setChallenge(Calendar.getStringDate(_selectedDay), value[index].key, pre, newvalue);
                              value[index].isChecked=newvalue;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                int opacity=0;
                if(value.isNotEmpty){
                  final completedTasks=
                  value.where((task) => task.isChecked==true).toList();
                  double per=(completedTasks.length/value.length)*100;
                  if(per==0){
                    opacity=0;
                  }
                  else if(per<=30){
                    opacity=1;
                  }
                  else if(per<=50){
                    opacity=2;
                  }
                  else if(per<=70){
                    opacity=3;
                  }
                  else if(per==100){
                    opacity=4;
                  }
                  return GestureDetector(
                    onTap: () => isDone ? _buildEmojiBottomSheet(context) : null,
                    child: emojis.length<5 ? Container(width: 100, height:100, alignment: Alignment.center, child: Text('Loading...',style: Theme.of(context).textTheme.headline5,)) : Container(
                        key: _imageKey,
                        child: isdefault ?
                        Image.asset(
                          emojis[4-opacity],
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        )
                            :
                        ExtendedImage.network(
                          emojis[4-opacity],
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        )
                    ),
                  );
                }
                else{
                  return Container(

                  );
                }

              },
            ),
          ),
          const SizedBox(height: 20,)
        ],
      ),
    );
  }


  void _buildEmojiBottomSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setstate) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(!_myemojis[_selectedID].isSelected){ //선택하기 버튼일 때
                            StickerStorage.setEmojiSelection(old, _myemojis[_selectedID].groupID).then((value) =>  initEmoji()); //선택된 이모티콘들 다시 가져오기 );
                            setstate(() {
                              _myemojis[_selectedID].isSelected=true;
                            });
                            initEmojiIDs(); //selected바뀐 거 다시 가져오기
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                          margin: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: _myemojis[_selectedID].isSelected ? Theme.of(context).primaryColor : Colors.grey
                          ),
                          child: Text(
                              _myemojis[_selectedID].isSelected ? Strings.of(context).get('check_done') : Strings.of(context).get('check_yet'),
                              style: const TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w400) //흰색으로 고정
                          ),
                        ),
                      )
                    ],
                  ),
                  ValueListenableBuilder<List<String>>(
                      valueListenable: _selectedEmoji,
                      builder: (context, value, _) {
                        return SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(value.length,
                                  (index) => Container(
                                  child: _selectedID==0 ?
                                  Image.asset(
                                    value[index],
                                    width: 100,
                                    height: 100,
                                  )
                                      : ExtendedImage.network(
                                    value[index],
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                            ),
                          ),
                        );
                      }
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height:30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(_myemojis.length,
                              (index){
                            return GestureDetector(
                              onTap: (){
                                setstate(() {
                                  _selectedID=index;
                                });
                                getEmoji(_myemojis[index].groupID);
                              },
                              child:Container(
                                margin: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: Text(_myemojis[index].title,
                                    style:TextStyle(fontSize:16,fontWeight:FontWeight.w400,color: _selectedID==index ? Theme.of(context).primaryColor : Colors.grey)
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  void showTutorial(){
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async{
        await Preferences.setIsFirst(4,0);
      },
      onClickTarget: (target) {

      },
      onClickOverlay: (target) {

      },
      onSkip: () async{
        await Preferences.setIsFirst(4,0);
      },
    )..show();
  }

  void initTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "date",
        keyTarget: _dateKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height /2),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Strings.of(context).get('tutorial_check_date'),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "check",
        keyTarget: _checkKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Strings.of(context).get('tutorial_check_check'),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "image",
        keyTarget: _imageKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Strings.of(context).get('tutorial_check_image'),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

}




