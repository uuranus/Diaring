import 'package:diaring/strings.dart';
import 'package:diaring/utils.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'schedule.dart';
import 'sticker_decoration.dart';

class Monthly extends StatefulWidget{
  const Monthly({Key? key}) : super(key: key);

  @override
  _MonthlyState createState() =>_MonthlyState();

}

class _MonthlyState extends State<Monthly>{
  //global keys for tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  final GlobalKey _modeKey = GlobalObjectKey("mode");
  int isFirst=0;


  String _mode="Decoration";

  @override
  void initState() {
    isFirstShow();
    super.initState();
  }

  void isFirstShow() async{
    int isf= await Preferences.getIsFirst(21);
    isFirst=isf;
    if(isFirst==1){
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.only(top:10,left:10,right:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children:[
                GestureDetector(
                  key: _modeKey,
                  onTap: (){
                    setState(() {
                      if(_mode=="Schedule"){
                        _mode="Decoration";
                      }
                      else{
                        _mode="Schedule";
                      }
                    });
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Theme.of(context).primaryColor),
                      color: Colors.grey[100]
                    ),
                    child: Text(_mode,
                      style: const TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w400), //검정으로 고정
                    )
                  ),
                )
              ]
            ),
          ),
          Container(
            child : _mode=="Schedule" ? const Schedule() : const StickerDecoration(),
          ),
      ],
      ),
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
        await Preferences.setIsFirst(21,0);
      },
      onClickTarget: (target) {

      },
      onClickOverlay: (target) {

      },
      onSkip: () async{
        await Preferences.setIsFirst(21,0);
      },
    )..show();
  }

  void initTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "mode",
        keyTarget: _modeKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Strings.of(context).get('tutorial_monthly_btn'),
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
