import 'dart:async';
import 'package:diaring/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'memo.dart';
import 'memo_page.dart';
import 'my_staggered_tile.dart';
import 'utils.dart';

class StaggeredGridePage extends StatefulWidget{

  const StaggeredGridePage({Key? key}) : super(key: key);

  @override
  _StaggeredGridePage createState() => _StaggeredGridePage();
}

class _StaggeredGridePage extends State<StaggeredGridePage> {
  //global keys for tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  final GlobalKey _noteKey = GlobalObjectKey("note");
  int isFirst=1;



  List<Memo> _listTile = <Memo>[];

  late StreamSubscription _subscription;

  @override
  void initState() {
    initStream();
    isFirstShow();
    super.initState();
  }

  void isFirstShow() async{
    int isf= await Preferences.getIsFirst(5);
    isFirst=isf;
    if(isFirst==1){
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  void initStream(){
    FirebaseNotes.getNoteStream((events) {
      setState(() {
        _listTile=events;
      });
    }).then((value) => _subscription=value);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StaggeredGrid.count(
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            axisDirection: AxisDirection.down,
            crossAxisCount: _colForStaggeredView(context),
            children: List.generate(_listTile.length, (index) => _memoGenerator(index))
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _noteKey,
        child: const Icon(Icons.add),
        onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (ctx) => MemoPage(Memo(_listTile.length,"","",DateTime.now(),DateTime.now(),0),false)));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  StaggeredGridTile _memoGenerator(int i) {
    return StaggeredGridTile.fit(crossAxisCellCount: 1, child: MyStaggeredTile(Memo(
        _listTile[i].id, _listTile[i].title, _listTile[i].content,
        _listTile[i].date_created, _listTile[i].date_last_edited,
        _listTile[i].indexOfColor))
    );
  }

  int _colForStaggeredView(BuildContext context) {
    // for width larger than 600, return 3 irrelevant of the orientation to accommodate more notes horizontally
    return MediaQuery
        .of(context)
        .size
        .width > 600 ? 3 : 2;
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
        await Preferences.setIsFirst(5,0);
      },
      onClickTarget: (target) {

      },
      onClickOverlay: (target) {

      },
      onSkip: () async{
        await Preferences.setIsFirst(5,0);
      },
    )..show();
  }

  void initTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "note",
        keyTarget: _noteKey,
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
                      Strings.of(context).get('tutorial_note_note'),
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
