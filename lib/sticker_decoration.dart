import 'dart:async';
import 'dart:collection';

import 'package:diaring/strings.dart';
import 'package:diaring/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'storage.dart';


class StickerDecoration extends StatefulWidget{
  const StickerDecoration({Key? key}) : super(key: key);

  @override
  _StickerDecorationState createState() =>_StickerDecorationState();

}

class _StickerDecorationState extends State<StickerDecoration> {
  //global keys for tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  final GlobalKey _calendarKey = GlobalObjectKey("calendar");
  int isFirst=0;
  
  
  DateTime _focusedDay= DateTime.now();
  DateTime _selectedDay=DateTime.now();
  int mon=0;
  int year=2021;

  LinkedHashMap<DateTime,List<Sticker>> _stickers=LinkedHashMap<DateTime,List<Sticker>>(); //달력에 표시된 스티커들 모음
  List<StickerTitle> _ids= []; //내가 선택하 수 있는 스티커들 리스트

  late final ValueNotifier<List<Sticker>> _selectedSticker; //bottomsheet에 보이는 스티커들
  List<Sticker> _selectedStickers=[];
  int _selectedID=0;
  late StreamSubscription _subscription;
  final CalendarFormat _calendarformat=CalendarFormat.month;


  void getSticker(String groupID) { //다른 스티커 제목을 선택했을 때 해당 스티커들을 가져오는 함수
    StickerStorage.getStickers(groupID,(stickers) {
      setState(() {
        _selectedStickers=stickers;
        _selectedSticker.value=_selectedStickers;
      });
    });
  }

  List<Sticker> _getStickerForDay(DateTime day){
    var localday=DateTime(day.year,day.month,day.day,0,0,0,0);
    if(_stickers.isEmpty || _stickers[localday]==null){
      return [];
    }
    else {
      return _stickers[localday]!;
    }
  }

  void initStream(){
    StickerStorage.getStickerStream(year, mon, (stickers) {
      setState(() {
        _stickers=stickers;
      });
    }).then((value) => _subscription=value);
  }

  void initSticker(){
    StickerStorage.getIDs((groupIDs){
      setState(() {
        _ids=groupIDs;
      });
    }).then((value) => getSticker("0"));
  }


  @override
  void initState() {
    mon=_focusedDay.month;
    year=_focusedDay.year;
    initStream();
    initSticker();
    _selectedSticker=ValueNotifier(_selectedStickers);
    isFirstShow();
    super.initState();
  }

  void isFirstShow() async{
    int isf= await Preferences.getIsFirst(22);
    isFirst=isf;
    if(isFirst==1){
      Future.delayed(const Duration(milliseconds: 2000), showTutorial);
    }
  }


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildDecoration(),
    );
  }

  Widget _buildDecoration(){
    return Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: TableCalendar<Sticker>(
            rowHeight: _getCalendarHeight(),
            daysOfWeekHeight: 65,
            locale:  Localizations.localeOf(context).languageCode,
            calendarFormat: _calendarformat,
            onPageChanged: (focusedDay){
              _focusedDay=focusedDay;

              if(mon!=_focusedDay.month){ //달이 바뀌었다면
                //stream갱신
                mon=_focusedDay.month;
                year=_focusedDay.year;
                initStream();
              }
            },
            headerStyle: HeaderStyle(
              titleTextStyle: Theme.of(context).textTheme.headline1!,
              titleCentered:true,
              formatButtonVisible: false,
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day){
              return isSameDay(_selectedDay,day);
            },
            onDaySelected: (selectedDay,focusedDay){
              setState(() {
                _focusedDay=focusedDay;
                _selectedDay=selectedDay;
              });
              _buildStickerBottomSheet(context);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context,date,events) {
                if(events.isNotEmpty){ //스티커 보여주기
                  return GestureDetector(
                    onLongPress: (){
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(Strings.of(context).get('sticker_delete'),
                                    style: Theme.of(context).textTheme.headline5,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Text(Strings.of(context).get('dialog_cancel')),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                ),
                                TextButton(
                                    child: Text(Strings.of(context).get('dialog_ok')),
                                    onPressed: () {
                                      StickerStorage.removeSticker(date);
                                      Navigator.pop(context);
                                    }
                                ),
                              ],
                            )
                      );
                    },
                    child: Align(
                          alignment: _getAlignment(events[0].position!),
                          child: Stack(
                              children: [
                                Positioned(
                                  child:  ExtendedImage.network(
                                    events[0].path,
                                    height: _getCalendarHeight()*(events[0].size!/6),
                                    fit: BoxFit.fitHeight,
                                  ),
                              ),
                             ],
                        ),
                    ),
                  );
                }
              },
              selectedBuilder: (context,date,events)=>
                  Container(
                    key: _calendarKey,
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 17,
                      width: 17,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                          date.day.toString(),
                          style:Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                  ),
              todayBuilder: (context,date,events) =>
                  Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 19,
                      width: 19,
                      margin:const EdgeInsets.symmetric(vertical: 1),
                      alignment: Alignment.center,
                      child: Text(
                          date.day.toString(),
                          style:Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
              defaultBuilder: (context,date,events) =>
                  Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 19,
                      width: 19,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      alignment: Alignment.center,
                      child: Text(
                          date.day.toString(),
                           style:Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
              outsideBuilder: (context,date,events) =>
                  Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 19,
                      width: 19,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      alignment: Alignment.center,
                      child: Text(
                        date.day.toString(),
                        style:Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
            ),
            focusedDay: _focusedDay,
            firstDay:  DateTime.utc(2010,01,01),
            lastDay: DateTime.utc(2040,01,01),
            eventLoader: (day){
              return _getStickerForDay(day);
            },
          ),

        )
    );
  }

  Alignment _getAlignment(int alignment){
    switch(alignment){
      case 1: return Alignment.topLeft;
      case 2: return Alignment.topCenter;
      case 3: return Alignment.topRight;
      case 4: return Alignment.centerLeft;
      case 5: return Alignment.center;
      case 6: return Alignment.centerRight;
      case 7: return Alignment.bottomLeft;
      case 8: return Alignment.bottomCenter;
      case 9: return Alignment.bottomRight;
      default : return Alignment.center;
    }
  }


  double _getCalendarHeight(){
    return MediaQuery.of(context).size.height < 782 ? 75 : 80;
  }

  void _buildStickerBottomSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setstate) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<List<Sticker>>(
                      valueListenable: _selectedSticker,
                      builder: (context, value, _) {
                        return SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(value.length,
                                  (index) {
                                return GestureDetector(
                                    onTap: (){
                                      //다이어리에 적용
                                      StickerStorage.setSticker(_selectedDay, value[index]);
                                      Navigator.pop(context);
                                    },
                                    child:Container(
                                      margin: const EdgeInsets.all(5),
                                      child: ExtendedImage.network(
                                          value[index].path,
                                      width: 100,
                                      height: 100,),
                                    )
                                );
                              },
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
                      children: List.generate(_ids.length,
                              (index){
                            return GestureDetector(
                                onTap: (){
                                  getSticker(_ids[index].groupID);
                                  setstate(() {
                                    _selectedID=index;
                                  });
                                },
                                child:Container(
                                  margin: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  child: Text(_ids[index].title,
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
        await Preferences.setIsFirst(22,0);
      },
      onClickTarget: (target) {

      },
      onClickOverlay: (target) {

      },
      onSkip: () async{
        await Preferences.setIsFirst(22,0);
      },
    )..show();
  }

  void initTargets() {
    targets.clear();
    
    targets.add(
      TargetFocus(
        identify: "calendar",
        keyTarget: _calendarKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_monthly_sticker'),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
  }

}