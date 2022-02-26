import 'dart:async';

import 'package:diaring/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauge;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'colorlist.dart';
import 'utils.dart';

class Ring extends StatefulWidget{
  const Ring({Key? key}) : super(key: key);

  @override
  _RingState createState() =>_RingState();

}

class _RingState extends State<Ring>{
  //global keys for tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  final GlobalKey _datepickerkey = GlobalObjectKey("datepicker");
  final GlobalKey _addkey = GlobalObjectKey("add");
  final GlobalKey _cardkey = GlobalObjectKey("card");
  int isFirst=0;

  List<WeekData> _chartData=[];
  Set<WeekData> _chartDataFavorite={};
  final TextEditingController _eventController = TextEditingController();
  double _slideValue=1;
  DateTime _selectedDay=DateTime.now();
  int premonth=1;
  int nextmonth=1;
  int preweek=1;
  int nextweek=1;
  String thismon="2021-01-01";
  String thissun="2021-01-01";
  bool islastweek=false;
  late StreamSubscription _subscription;

  @override
  void initState() {
    initdate(DateTime.now());
    getData();
    isFirstShow();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void isFirstShow() async{
    isFirst= await Preferences.getIsFirst(3);

    if(isFirst==1){
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  void initdate(DateTime date){
    _selectedDay=date;
    thismon=Calendar.getMonday(date);
    thissun=Calendar.getSunday(date);
    preweek=Calendar.getWeekOfDate(DateTime.parse(thismon));
    premonth=int.parse(thismon.substring(5,7));
    nextweek=Calendar.getWeekOfDate(DateTime.parse(thissun));
    nextmonth=int.parse(thissun.substring(5,7));
    if(premonth!=nextmonth){
      islastweek=true;
    }
    else{
      islastweek=false;
    }

  }

  void getData(){
    FirebaseEvents.getWeekStream(thismon, (events) {
      setState(() {
        _chartData=events;
        _chartDataFavorite=_chartData.where((weekdata) => weekdata.isFavoite==true).toSet();
      });}).then((value) => _subscription=value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:[
          const SizedBox(height:5),
          Padding(
            padding:const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.calendar_today, key: _datepickerkey,),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      //초기값
                      firstDate: DateTime(2010),
                      //시작일
                      lastDate: DateTime(2030),
                      //마지막일
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context),
                          child: child!,
                        );
                      },
                    ).then((dateTime) {
                      setState(() {
                        initdate(dateTime!);
                        getData();
                      });
                    });
                  },
                ),
              ],
            ),
          ),
          chart.SfCircularChart(
            title:chart.ChartTitle(text:
              islastweek ? '${thismon.substring(0,4)}${Strings.of(context).get('ring_year')} ${thismon.substring(5,7)}${Strings.of(context).get('ring_month')} ${preweek}${Strings.of(context).get('ring_week')}\n'
                  '~ ${thissun.substring(5,7)}${Strings.of(context).get('ring_month')}  ${nextweek}${Strings.of(context).get('ring_week')} ${Strings.of(context).get('ring_week_challenges')}\n'
                  '(${thismon} ~ ${thissun})' : '${thismon.substring(0,4)}${Strings.of(context).get('ring_year')} ${thismon.substring(5,7)}${Strings.of(context).get('ring_month')} ${preweek}${Strings.of(context).get('ring_week')} ${Strings.of(context).get('ring_week_challenges')}\n'
                  '(${thismon} ~ ${thissun})' ,
              textStyle: Theme.of(context).textTheme.headline1
            ),
            legend:chart.Legend(isVisible: true, overflowMode: chart.LegendItemOverflowMode.wrap),
            annotations: <chart.CircularChartAnnotation>[
              chart.CircularChartAnnotation(
                radius:'0%',
                height:'90%',
                width:'90%',
                widget:Container(
                  child: _chartDataFavorite.isEmpty ?
                  Container(
                      alignment: Alignment.center,
                      child: Text(Strings.of(context).get('main_center_text'), textAlign:TextAlign.center, style: TextStyle(color: Theme.of(context).brightness==Brightness.light ? Colors.black : Colors.white, fontWeight: FontWeight.w700, fontSize: 12 )),
                  )
                  : Container(
                      height: 100.0,
                      width: 100.0,
                      alignment: Alignment.center,
                      child: Text("DIARING",style: Theme.of(context).textTheme.headline1)
                  )
                ),
              ),
            ],
            series:<chart.CircularSeries>[
              chart.RadialBarSeries<WeekData,String>(
                dataSource: _chartDataFavorite.toList(),
                xValueMapper: (WeekData data, _) => data.title,
                yValueMapper: (WeekData data, _) => (data.cur*(7/data.goal)).round(),
                dataLabelSettings: const chart.DataLabelSettings(isVisible: false),
                maximumValue: 7,
                cornerStyle: chart.CornerStyle.bothCurve,
              ),
            ],
            palette: [ColorList.getColor(9),ColorList.getColor(7),ColorList.getColor(8),ColorList.getColor(6)],
          ),
          Container(
            padding: const EdgeInsets.only(left: 25, right:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.of(context).get('ring_this_week'),
                  style: Theme.of(context).textTheme.headline4,
                ),
                IconButton(
                  icon: Icon(Icons.add, key: _addkey,),
                  onPressed: () {
                    if (_chartData.length == 10) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    Strings.of(context).get('ring_add_limit'),
                                    style: Theme.of(context).textTheme.headline5,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Text(Strings.of(context).get('dialog_ok'),),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                ),
                              ],
                            ),
                      );
                    }
                    else {
                      //새로운 채린지 추가
                      alertDialog(false,_chartData.length);
                    }
                    }
                  ),
              ],
            ),
          ),
          Expanded(
            child:GridView.count(
              scrollDirection: Axis.vertical,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              padding: const EdgeInsets.all(20),
              children:List.generate(_chartData.length,(index){
                final alreadySaved=_chartDataFavorite.contains(_chartData[index]);
                return Card(
                    key: index== 0 ? _cardkey : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    clipBehavior:Clip.antiAlias,
                    child:Column(
                        children:[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color:Colors.grey,
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (Context) =>
                                        AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children:[
                                              Text(
                                                Strings.of(context).get('ring_delete_challenge'),
                                                style: Theme.of(context).textTheme.headline5,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text(Strings.of(context).get('dialog_cancel'),),
                                              onPressed: () =>
                                                  Navigator.pop(Context),
                                            ),
                                            TextButton(
                                              child: Text(Strings.of(context).get('dialog_ok'),),
                                              onPressed: () {
                                                setState(() {
                                                  FirebaseEvents.deleteWeekChallenge(thismon, _chartData[index].key);
                                                  _chartDataFavorite.remove(_chartData[index]);
                                                  _chartData.removeAt(index);
                                                });
                                                Navigator.pop(Context);
                                              },
                                            ),
                                          ],
                                        ),
                                  );

                                },
                              ),
                              IconButton(
                                  icon: alreadySaved ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                                  color:Colors.grey,
                                  onPressed: (){
                                    setState(() {
                                      if(alreadySaved){
                                        FirebaseEvents.setWeekChallengeFavorite(thismon, _chartData[index].key, false)
                                            .then((value){
                                          setState((){
                                            _chartDataFavorite.remove(_chartData[index]);
                                          });
                                        });

                                      }
                                      else if(_chartDataFavorite.length==4){
                                        showDialog(context: context,
                                          builder: (context){
                                            return AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(Strings.of(context).get('ring_favorite_limit'),
                                                    style: Theme.of(context).textTheme.headline5,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child:Text(Strings.of(context).get('dialog_ok'),),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      else{
                                        FirebaseEvents.setWeekChallengeFavorite(thismon, _chartData[index].key, true)
                                            .then((value){
                                          setState((){
                                            _chartDataFavorite.add(_chartData[index]);
                                          });
                                        });

                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                          Center(
                            child:GestureDetector(
                              child: Text(
                                  _chartData[index].title,
                                  style: const TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w400), //검정으로 고정
                              ),
                              onTap: () {
                                  _eventController.text= _chartData[index].title;
                                  _slideValue= _chartData[index].goal.toDouble();
                                  alertDialog(true,index);
                                },
                            ),
                          ),
                          Expanded(
                            child:
                            gauge.SfRadialGauge(
                                axes: <gauge.RadialAxis>[
                                  gauge.RadialAxis(
                                      showLabels: false,
                                      showTicks: false,
                                      startAngle: 270,
                                      endAngle: 270,
                                      minimum: 0,
                                      maximum: 7,
                                      radiusFactor: 0.8,
                                      axisLineStyle: const gauge.AxisLineStyle(
                                          thicknessUnit: gauge.GaugeSizeUnit.factor, thickness: 0.15),
                                      annotations: <gauge.GaugeAnnotation>[
                                        gauge.GaugeAnnotation(
                                            angle: 180,
                                            positionFactor: 0.1,
                                            widget: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  _chartData[index].cur.toString(),
                                                  style: const TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w400) //검정으로 고정
                                                ),
                                                Text(
                                                  ' / ${_chartData[index].goal}',
                                                  style: const TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w400) //검정으로 고정
                                                )
                                              ],
                                            )),
                                      ],
                                      pointers: <gauge.GaugePointer>[
                                        gauge.RangePointer(
                                            value: _chartData[index].cur.toDouble()*(7/_chartData[index].goal),
                                            cornerStyle: gauge.CornerStyle.bothCurve,
                                            enableAnimation: true,
                                            animationDuration: 1200,
                                            animationType: gauge.AnimationType.ease,
                                            sizeUnit: gauge.GaugeSizeUnit.factor,
                                            gradient: SweepGradient(
                                                colors: <Color>[ColorList.getColor(9), ColorList.getColor(8)],
                                                stops: <double>[0.25, 0.75]),
                                            width: 0.15),
                                      ]),
                                ]),
                          ),
                        ]),
                    // color:ColorList.getColor(7),
                    color: Colors.grey[100],

                  );
              })
             ),
          ),

        ]
    );
  }

  void alertDialog(isUpdate, index){
    showDialog(
      context: context,
      builder: (context) =>
         AlertDialog(
                  title: Text(Strings.of(context).get('ring_add_event'),
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  content: StatefulBuilder(
                    builder: (context, setstate) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _eventController,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const SizedBox(height:5),
                        Row(
                          children: [
                            Text(Strings.of(context).get('ring_add_goal'),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Slider(
                              activeColor: Theme.of(context).colorScheme.secondary,
                              inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                              value: _slideValue,
                              min: 1.0,
                              max: 7.0,
                              divisions: 6,
                              label: "${_slideValue.round()}",
                              onChanged: (double newValue) {
                                setstate(() {
                                  _slideValue = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(Strings.of(context).get('dialog_cancel')),
                      onPressed: () =>
                          Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text(Strings.of(context).get('dialog_ok'),),
                      onPressed: () {
                        if(_eventController.text.isEmpty){
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
                        else if(_eventController.text.length>30){
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
                        else {
                          if(isUpdate){
                            var text = _eventController
                                .text;
                            FirebaseEvents.updateWeekChallenge(
                                thismon, index.toString(), text, _slideValue.round());
                            setState(() {
                              _chartData[index].goal=_slideValue.round();
                              _chartData[index].title=text;
                            });
                          }
                          else{
                            var text = _eventController
                                .text;
                            FirebaseEvents.setWeekChallenge(
                                thismon,
                                WeekData(_chartData.length.toString(),_eventController.text, 0,
                                    _slideValue.round()));
                            setState(() {
                              _chartData.add(WeekData(_chartData.length.toString(),
                                  text, 0,
                                  _slideValue.floor()));
                            });
                          }
                          Navigator.pop(context);
                        }


                      },
                    )
                  ],
                ),
    ).then((value){
      _eventController.clear();
      _slideValue=1;
    });
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
        await Preferences.setIsFirst(3,0);
      },
      onClickTarget: (target) {

      },
      onClickOverlay: (target) {

      },
      onSkip: () async{
        await Preferences.setIsFirst(3,0);
      },
    )..show();
  }

  void initTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "addEvent",
        keyTarget: _addkey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_ring_add'),
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
        identify: "card",
        keyTarget: _cardkey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_ring_card'),
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
        identify: "datepicker",
        keyTarget: _datepickerkey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_ring_date'),
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
  }

}
