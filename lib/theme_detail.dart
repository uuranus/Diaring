

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

class ThemeDetail extends StatefulWidget{
  int initialPage;
  List<String> urls;

  ThemeDetail(this.initialPage,this.urls);

  @override
  _ThemeDetailState createState()  => _ThemeDetailState(initialPage,urls);
}

class _ThemeDetailState extends State<ThemeDetail>{
  int initialPage;
  List<String> urls;

  _ThemeDetailState(this.initialPage,this.urls);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemBuilder: (BuildContext context, int index) {
        var item = urls[index];
        Widget image = Image.asset(
          item,
          fit: BoxFit.contain,
        );
        image = Container(
          child: image,
          padding: const EdgeInsets.all(5.0),
        );
        if (index == initialPage) {
          return Hero(
            tag: item + index.toString(),
            child: image,
          );
        } else {
          return image;
        }
      },
      itemCount: urls.length,
      onPageChanged: (int index) {
        initialPage = index;
      },
      controller: PageController(
        initialPage: initialPage,
      ),
      scrollDirection: Axis.horizontal,
    );
  }

}