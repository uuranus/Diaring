import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

class PhotoDetail extends StatefulWidget{
  int initialPage;
  List<String> urls;

  PhotoDetail(this.initialPage,this.urls);

  @override
  _PhotoDetailState createState()  => _PhotoDetailState(initialPage,urls);
}

class _PhotoDetailState extends State<PhotoDetail>{
  int initialPage;
  List<String> urls;

  _PhotoDetailState(this.initialPage,this.urls);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemBuilder: (BuildContext context, int index) {
        var item = urls[index];
        Widget image = ExtendedImage.network(
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