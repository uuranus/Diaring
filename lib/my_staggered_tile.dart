import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'memo.dart';
import 'memo_page.dart';
import 'colorlist.dart';

class MyStaggeredTile extends StatefulWidget {
  final Memo memo;
  MyStaggeredTile(this.memo);
  @override
  _MyStaggeredTileState createState() => _MyStaggeredTileState();
}

class _MyStaggeredTileState extends State<MyStaggeredTile> {

  late String _content;
  late double _fontSize;
  late Color tileColor;
  late String title;

  @override
  Widget build(BuildContext context) {

    _content = widget.memo.content;
    _fontSize=_determineFontSizeForContent();
    tileColor = ColorList.getColor(widget.memo.indexOfColor);
    title = widget.memo.title;

    return GestureDetector(
      onTap: ()=> _noteTapped(context),
      child: Container(
        decoration: BoxDecoration(
            border: tileColor == Colors.white ?   Border.all(color:Colors.grey) : null,
            color: tileColor,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.all(8),
        child:  constructChild(),) ,
    );
  }

  void _noteTapped(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(builder: (ctx) => MemoPage(widget.memo,true)));
  }

  Widget constructChild() {
    List<Widget> contentsOfTiles = [];

    if(widget.memo.title.isNotEmpty) {
      contentsOfTiles.add(
        AutoSizeText(title,
          style: TextStyle(fontSize: _fontSize,fontWeight: FontWeight.bold,color: Colors.black),
          maxLines: widget.memo.title.isEmpty ? 1 : 3,
          textScaleFactor: 1.5,
        ),
      );
      contentsOfTiles.add(const Divider(color: Colors.transparent,height: 6,),);
    }

    contentsOfTiles.add(
        AutoSizeText(
          _content,
          style: TextStyle(fontSize: _fontSize,color: Colors.black),
          maxLines: 10,
          textScaleFactor: 1.5,)
    );
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: contentsOfTiles
    );
  }

  double _determineFontSizeForContent() {
    int charCount = widget.memo.content.length + widget.memo.title.length ;
    double fontSize = 20 ;
    if (charCount > 110 ) { fontSize = 12; }
    else if (charCount > 80) {  fontSize = 14;  }
    else if (charCount > 50) {  fontSize = 16;  }
    else if (charCount > 20) {  fontSize = 18;  }
    return fontSize;
  }

}