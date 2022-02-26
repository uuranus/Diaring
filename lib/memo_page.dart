import 'package:diaring/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'colorlist.dart';
import 'memo.dart';

class MemoPage extends StatefulWidget {
  final Memo memo;
  bool isSaved;
  MemoPage(this.memo,this.isSaved);

  @override
  _MemoPageState createState() => _MemoPageState(isSaved);
}

class _MemoPageState extends State<MemoPage> {
  bool isSaved;
  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _contentController=TextEditingController();


  int indexOfColor=0;
  Color color=Colors.white;

  final Color borderColor = Color(0xffd3d3d3);
  final Color foregroundColor = Color(0xff595959);

  _MemoPageState(this.isSaved);

  @override
  void initState() {
    if(isSaved){
      _titleController.text=widget.memo.title;
      _contentController.text=widget.memo.content;
      color=ColorList.getColor(widget.memo.indexOfColor);
      indexOfColor=widget.memo.indexOfColor;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: color,
        body:Column(
          children: [
            Padding(
                padding:const EdgeInsets.symmetric(horizontal: 20.0,vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon : const Icon(
                          Icons.arrow_back,
                          size:30.0,
                          color:Colors.black,
                      ),
                      onPressed: (){
                        alertNoteBack();
                      },
                    ),
                    IconButton(
                      icon : const Icon(
                        Icons.save,
                        size:30.0,
                        color:Colors.black,
                      ),
                      onPressed: (){
                        alertTextLimit();
                      },
                    ),
                  ],
                ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    TextField(
                      decoration:InputDecoration(
                        border: InputBorder.none,
                        hintText: Strings.of(context).get('memo_note_title'),
                        hintStyle: const TextStyle(fontSize: 28.0,color: Colors.grey, fontWeight: FontWeight.w700), //검정으로 고정
                      ),
                      style: const TextStyle(fontSize: 28.0,fontWeight: FontWeight.w700,color: Colors.black),//검정으로 고정
                      controller: _titleController,
                    ),
                    Expanded(
                        child: GestureDetector(
                          onVerticalDragUpdate: (detail){
                            if(detail.delta.dy<0){
                              _buildColorSlide(context);
                            }
                          },
                          child: TextField(
                              style: const TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w400), //검정으로 고정
                              decoration:InputDecoration(
                                border: InputBorder.none,
                                hintText: Strings.of(context).get('memo_note_content'),
                                hintStyle: const TextStyle(fontSize: 14,color: Colors.grey, fontWeight: FontWeight.w400), //검정으로 고정
                              ),
                              maxLines: null,
                              controller: _contentController,
                            ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildColorSlide(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setstate) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                       GestureDetector(
                        onTap: (){
                          if(isSaved){
                            Navigator.pop(context);
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        Strings.of(context).get('memo_note_delete_msg'),
                                        style: Theme.of(context).textTheme.headline5,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(Strings.of(context).get('dialog_cancel'),),
                                    onPressed: () =>
                                        Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text(Strings.of(context).get('dialog_ok'),),
                                    onPressed: () {
                                      FirebaseNotes.deleteNote(widget.memo.id.toString());
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children:[
                              const Icon(
                                Icons.delete,
                                size: 38.0,
                              ),
                              const SizedBox(width: 5,),
                              Text(Strings.of(context).get('memo_note_delete'),
                                  style: Theme.of(context).textTheme.headline5
                              ),
                            ],
                          ),
                        ),
                       ),
                       const Divider(
                         height: 1,
                        color: Colors.grey,
                       ),
                      GestureDetector(
                        onTap: (){
                          alertTextLimit();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children:[
                              const Icon(
                                Icons.save,
                                size: 38.0,
                              ),
                              const SizedBox(width: 5,),
                              Text(Strings.of(context).get('memo_note_save'),
                                  style: Theme.of(context).textTheme.headline5
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height:70,
                        child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(ColorList.getColorListLength(), (index) {
                          return GestureDetector(
                            onTap:(){
                              setstate((){
                                indexOfColor=index;
                              });
                              setState((){
                                color=ColorList.getColor(indexOfColor);
                              });
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(left: 7, right: 7),
                                child:Container(
                                    child: CircleAvatar(
                                      child: _checkOrNot(index),
                                      foregroundColor: foregroundColor,
                                      backgroundColor: ColorList.getColor(index),
                                    ),
                                    width: 38.0,
                                    height: 38.0,
                                    padding: const EdgeInsets.all(1.0), // border width
                                    decoration: BoxDecoration(
                                      color: borderColor, // border color
                                      shape: BoxShape.circle,
                                    )
                                )
                            )
                          );
                        })
                        ),
                      ),
                    ],
                  );
              });
          },
    );
  }

  void alertNoteBack(){
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: Text(Strings.of(context).get('memo_note_back'), style: Theme.of(context).textTheme.headline5),
            actions: [
              TextButton(
                child: Text(Strings.of(context).get('dialog_ok')),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              ),
            ],
          ),
    );
  }

  void alertTextLimit(){
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
      if(isSaved){
        FirebaseNotes.updateNote(Memo(widget.memo.id,_titleController.text,_contentController.text,DateTime.now(),DateTime.now(),indexOfColor));
      }
      else{
        FirebaseNotes.setNote(Memo(widget.memo.id,_titleController.text,_contentController.text,DateTime.now(),DateTime.now(),indexOfColor));
      }
      Navigator.pop(context);
    }
  }

  Widget _checkOrNot(int index){
    if (indexOfColor == index) {
      return const Icon(Icons.check);
    }
    return Container();
  }

}
