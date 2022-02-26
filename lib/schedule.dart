import 'dart:async';
import 'dart:collection';

import 'package:diaring/strings.dart';
import 'package:diaring/utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'monthUtils.dart';
import 'colorlist.dart';


class Schedule extends StatefulWidget{
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() =>_ScheduleState();

}

class _ScheduleState extends State<Schedule>{
  //global keys for tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  final GlobalKey _calendarKey = GlobalObjectKey("calendar");
  final GlobalKey _floatingKey = GlobalObjectKey("floating");
  final GlobalKey _meetingKey = GlobalObjectKey("meeting");
  int isFirst=0;


  DateTime _focusedDay= DateTime.now();
  DateTime _selectedDay=DateTime.now();
  int mon=0;
  int year=2021;
  List<String> weeks=<String>[];

  late final ValueNotifier<List<Meeting>> _selectedEvents;
  late StreamSubscription _subscription;

  CalendarFormat _calendarformat=CalendarFormat.month;

  int indexOfColor=0;
  Color color=Colors.white;

  final Color borderColor = Color(0xffd3d3d3);
  final Color foregroundColor = Color(0xff595959);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  LinkedHashMap<DateTime,List<Meeting>> _meetings=LinkedHashMap<DateTime,List<Meeting>>();

  List<Meeting> _getEventsForDay(DateTime day){
    var localday=DateTime(day.year,day.month,day.day,0,0,0,0);
    if(_meetings.isEmpty || _meetings[localday]==null){
      return [];
    }
    else {
      return _meetings[localday]!;
    }
  }

  void initScream(){
    FirebaseMonth.getMonthStream(year,mon, (events) {
      setState(() {
        _meetings=events;
        _selectedEvents.value=_getEventsForDay(DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day));
      });
    }).then((value) => _subscription=value);
  }

  List<DateTime> _selectedDates=<DateTime>[];
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      print("args ${args.value}");
      _selectedDates=args.value;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    print("schedule initstate");
    mon=_focusedDay.month;
    year=_focusedDay.year;
    initScream();
    _selectedEvents= ValueNotifier(_getEventsForDay(_selectedDay));
    isFirstShow();
    super.initState();
  }

  void isFirstShow() async{
    int isf= await Preferences.getIsFirst(23);
    isFirst=isf;
    if(isFirst==1){
      Future.delayed(Duration.zero, showTutorial);
    }
  }


  @override
  Widget build(BuildContext context) {
    weeks=<String>[Strings.of(context).get('schedule_monday'),Strings.of(context).get('schedule_tuesday'),Strings.of(context).get('schedule_wednesday'),Strings.of(context).get('schedule_thursday'),Strings.of(context).get('schedule_friday'),Strings.of(context).get('schedule_saturday'),Strings.of(context).get('schedule_sunday')];

    print("schedule build");
    return Expanded(
      child: _buildSchedule(),
    );
  }


  Widget _checkOrNot(int index){
    if (indexOfColor == index) {
      return const Icon(Icons.check);
    }
    return Container();
  }


  void _showMeetingDialog(bool isUpdate,String meetingid){
    var initialDates=<DateTime>[];
    if(isUpdate){
      setState(() {
        initialDates=_getSelectedDates(meetingid);
      });
    }
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: StatefulBuilder(
              builder: (context, setstate) {
                return SingleChildScrollView(
                    child:SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.7,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.57,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SfDateRangePicker(
                            initialSelectedDates: isUpdate ? [] : [_selectedDay],
                            selectionColor: color,
                            selectionTextStyle: TextStyle(
                              color: color==Colors.white ? Theme.of(context).primaryColor : Colors.white,
                            ),
                            view: DateRangePickerView.month,
                            monthViewSettings: const DateRangePickerMonthViewSettings(
                                firstDayOfWeek: 1),
                            selectionMode: DateRangePickerSelectionMode
                                .multiple,
                            onSelectionChanged: _onSelectionChanged,
                            initialDisplayDate: _focusedDay,
                            selectableDayPredicate: (DateTime val)=>
                            initialDates.contains(val)?false:true,
                          ),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: Strings.of(context).get('text_title'),
                            ),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 5,),
                          TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              hintText: Strings.of(context).get('text_description'),
                            ),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 9,),
                          SizedBox(
                            height: 35,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                    ColorList.getColorListLength(), (index) {
                                  return GestureDetector(
                                      onTap: () {
                                        setstate(() {
                                          indexOfColor = index;
                                          color = ColorList.getColor(
                                              indexOfColor);
                                        });
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 6, right: 6),
                                          child: Container(
                                              child: CircleAvatar(
                                                child: _checkOrNot(index),
                                                foregroundColor: foregroundColor,
                                                backgroundColor: ColorList
                                                    .getColor(index),
                                              ),
                                              width: 30.0,
                                              height: 30.0,
                                              padding: const EdgeInsets.all(
                                                  1.0),
                                              // border width
                                              decoration: BoxDecoration(
                                                color: borderColor,
                                                // border color
                                                shape: BoxShape.circle,
                                              )
                                          )
                                      )
                                  );
                                })
                            ),
                          ),
                        ],
                      ),
                    )
                );
              },
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
                    if(_titleController.text.isEmpty){
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              content: Text(Strings.of(context).get('text_empty'), style: Theme.of(context).textTheme.headline5),
                              actions: [
                                TextButton(
                                  child: Text(Strings.of(context).get('dialog_ok')),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                ),
                              ],
                            ),
                      );
                    }
                    else if(_titleController.text.length>30){
                      showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                  content: Text(Strings.of(context).get('text_limit'), style: Theme.of(context).textTheme.headline5),
                                  actions: [
                                      TextButton(
                                          child: Text(Strings.of(context).get('dialog_ok')),
                                          onPressed: () =>
                                          Navigator.pop(context),
                                      ),
                                  ],
                              ),
                      );
                    }
                    else{
                      if(isUpdate){
                        FirebaseMonth.updateAllMeeting(initialDates,_selectedDates, Meeting( meetingid,_titleController.text, _descriptionController.text,indexOfColor));
                      }
                      else{
                        if(_selectedDates.isEmpty){ //첫 추가시 선택되어 있는 날짜만 선택한 경우
                          FirebaseMonth.setMeeting([_selectedDay],_titleController.text, _descriptionController.text,indexOfColor);
                        }
                        else{
                          FirebaseMonth.setMeeting(_selectedDates,_titleController.text, _descriptionController.text,indexOfColor);
                        }
                      }
                      setState(() {
                        _titleController.clear();
                        _descriptionController.clear();
                        _selectedDates=<DateTime>[];
                      });
                      Navigator.pop(context);
                    }
                  }
              ),
            ],
          ),
    );
  }

  void _showUpdateOne(String meetingid){
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: StatefulBuilder(
              builder: (context, setstate) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: Strings.of(context).get('text_title'),
                      ),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 15,),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: Strings.of(context).get('text_description'),
                      ),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 20,),
                  ],
                );
              },
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
                    if(_titleController.text.isEmpty){
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              content: Text(Strings.of(context).get('text_empty'), style: Theme.of(context).textTheme.headline5),
                              actions: [
                                TextButton(
                                  child: Text(Strings.of(context).get('dialog_ok')),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                ),
                              ],
                            ),
                      );
                    }
                    else if(_titleController.text.length>30){
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              content: Text(Strings.of(context).get('text_limit'), style: Theme.of(context).textTheme.headline5),
                              actions: [
                                TextButton(
                                  child: Text(Strings.of(context).get('dialog_ok')),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                ),
                              ],
                            ),
                      );
                    }
                    else{
                      FirebaseMonth.updateOneMeeting(_selectedDay, Meeting( meetingid,_titleController.text, _descriptionController.text,indexOfColor));
                      setState(() {
                        _titleController.clear();
                        _descriptionController.clear();
                        _selectedDates=<DateTime>[];
                      });
                      Navigator.pop(context);
                    }

                  }
              ),
            ],
          ),
    );
  }

  List<DateTime> _getSelectedDates(String meetingid){
    var lists=<DateTime>[];
    _meetings.forEach((key, value) {
      for(var v in value){
        if(v.id==meetingid){
          lists.add(key);
        }
      }
    });
    return lists;
  }

  void _showUpdateOption(Meeting meeting){
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content:  Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                    onTap: (){
                      setState(() {
                        _titleController.text=meeting.title;
                        _descriptionController.text=meeting.description;
                      });
                      Navigator.pop(context);
                      _showUpdateOne(meeting.id);
                    },
                    child:Text(Strings.of(context).get('schedule_edit_one'),
                      style:Theme.of(context).textTheme.headline5
                    )
                ),
                const SizedBox(height: 5,),
                const Divider(height: 1,color: Colors.grey,),
                const SizedBox(height: 5,),
                GestureDetector(
                    onTap: (){
                      setState(() {
                        color=ColorList.getColor(meeting.color);
                        indexOfColor=meeting.color;
                        _titleController.text=meeting.title;
                        _descriptionController.text=meeting.description;
                      });
                      Navigator.pop(context);
                      _showMeetingDialog(true,meeting.id);

                    },
                    child:Text(Strings.of(context).get('schedule_edit_all'),
                        style:Theme.of(context).textTheme.headline5
                    )
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSchedule(){
    return Stack(
      children: [
        Column(
            mainAxisSize: MainAxisSize.max,
            children:[
              TableCalendar<Meeting>(
                rowHeight: _getCalendarHeight(),
                daysOfWeekHeight: 45,
                locale:  Localizations.localeOf(context).languageCode,
                calendarFormat: _calendarformat,
                onFormatChanged: (_format){
                  setState(() {
                    _calendarformat=_format;
                  });
                },
                onPageChanged: (focusedDay){
                  _focusedDay=focusedDay;
                  if(mon!=_focusedDay.month){ //달이 바뀌었다면
                    //stream갱신
                    mon=_focusedDay.month;
                    year=_focusedDay.year;
                    initScream();
                  }
                },
                headerStyle: HeaderStyle(
                    titleTextStyle: Theme.of(context).textTheme.headline1!,
                    titleCentered:true,
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Theme.of(context).colorScheme.secondary,
                    ),
                    formatButtonTextStyle: Theme.of(context).textTheme.subtitle2!
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
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
                    if(events.isNotEmpty){
                      return Column(
                        children: [
                          const SizedBox(height: 19.0),
                          Expanded(
                            child: ListView(
                              children: List.generate(events.length, (index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  margin: const EdgeInsets.symmetric(vertical: 0.6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.0),
                                    color: ColorList.getColor(events[index].color),
                                    border: ColorList.getColor(events[index].color)==Colors.white ? Border.all(color:Colors.grey) : Border.all(color:ColorList.getColor(events[index].color)),
                                  ),
                                  child:Text(events[index].title,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: ColorList.getColor(events[index].color)==Colors.white ?Colors.black : Colors.white),
                                  ),
                                );
                              }),

                            ),
                          )
                        ],
                      );
                    }
                  },
                  selectedBuilder: (context,date,events)=>
                      Container(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 17,
                          width: 17,
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                              date.day.toString(),
                              style:Theme.of(context).textTheme.subtitle2
                          ),
                        ),
                      ),
                  todayBuilder: (context,date,events) =>
                      Container(
                        key: _calendarKey,
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 19,
                          width: 19,
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          alignment: Alignment.center,
                          child: Text(
                              date.day.toString(),
                              style:Theme.of(context).textTheme.subtitle1
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
                              style:Theme.of(context).textTheme.bodyText1
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
                              style:Theme.of(context).textTheme.bodyText2
                          ),
                        ),
                      ),
                ),
                focusedDay: _focusedDay,
                firstDay:  DateTime.utc(2010,01,01),
                lastDay: DateTime.utc(2040,01,01),
                eventLoader: (day){
                  return _getEventsForDay(day);
                },
              ),
              const SizedBox(height:18),
              Expanded(
                child: ValueListenableBuilder<List<Meeting>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return Row(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          width: 50,
                          child: Column(
                            children: [
                              Text(weeks[_selectedDay.weekday-1],
                              style: Theme.of(context).textTheme.headline5,
                              ),
                              const SizedBox(height:5),
                              Text(_selectedDay.day.toString(),
                                style:  Theme.of(context).textTheme.headline6,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              return Container(
                                key: index==0 ? _meetingKey : null,
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 3
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.3,
                                    children: [
                                      SlidableAction(
                                        flex:1,
                                        onPressed: (context){
                                          bool isChecked=false;
                                          showDialog(
                                            context: context,
                                            builder: (context) =>AlertDialog(
                                              content:StatefulBuilder(
                                                  builder: (context, setstate) {
                                                    return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(Strings.of(context).get('schedule_delete'),
                                                            style:Theme.of(context).textTheme.headline5
                                                        ),
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                              activeColor: Theme.of(context).colorScheme.secondary,
                                                              value: isChecked,
                                                              onChanged: (newvalue){
                                                                setstate(() {
                                                                  isChecked=newvalue!;
                                                                });
                                                              },
                                                            ),
                                                            Text(Strings.of(context).get('schedule_delete_all'),
                                                                style:const TextStyle(fontSize: 10)
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  }
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
                                                      if(isChecked){
                                                        FirebaseMonth.deleteAllMeeting(_selectedDay.year,_selectedDay.month,value[index].id);
                                                      }
                                                      else{
                                                        FirebaseMonth.deleteMeeting(_selectedDay,value[index].id);
                                                      }
                                                      Navigator.pop(context);
                                                    }
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        backgroundColor: ColorList.getColor(8),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                        autoClose: true,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      _showUpdateOption(value[index]);
                                    },
                                    leading: Container(
                                      width: 20,
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: ColorList.getColor(value[index].color),
                                          shape: BoxShape.circle,
                                          border: ColorList.getColor(value[index].color)==Colors.white ? Border.all(color:Colors.grey) : null,
                                        ),
                                      ),
                                    ),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(value[index].title,
                                            style:const TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w400) //검정으로 고정
                                        ),
                                        Text(value[index].description,
                                            style:Theme.of(context).textTheme.bodyText2
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ]
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
          child: Align(
            alignment: Alignment.bottomRight,
            child: _buildFloatingButton(),
          ),
        )
      ],
    );
  }

  double _getCalendarHeight(){
    return MediaQuery.of(context).size.height < 782 ? 60 : 66;
  }

  Widget _buildFloatingButton(){
    return FloatingActionButton(
      key: _floatingKey,
      child: const Icon(Icons.add),
      onPressed: (){
        setState(() {
          color=ColorList.getColor(0);
          indexOfColor=0;
        });
        _showMeetingDialog(false,"");
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
        await Preferences.setIsFirst(23,0);
      },
      onClickTarget: (target) {

      },
      onClickOverlay: (target) {

      },
      onSkip: () async{
        await Preferences.setIsFirst(23,0);
      },
    )..show();
  }

  void initTargets() {
    targets.clear();

    targets.add(
      TargetFocus(
        identify: "floating",
        keyTarget: _floatingKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_monthly_schedule_add'),
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
      ),
    );

    targets.add(
      TargetFocus(
        identify: "meeting",
        keyTarget: _meetingKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_monthly_schedule_meeting'),
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

