import 'package:diaring/strings.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'colorlist.dart';
import 'storage.dart';
import 'shop_detail.dart';
import 'package:diaring/purchase.dart';


class ShopNew extends StatefulWidget{
  const ShopNew({Key? key}) : super(key: key);


  @override
  _ShopNewState createState() => _ShopNewState();
}

class _ShopNewState extends State<ShopNew>{
  late PageController _pageController;
  late PageController _pageController2;

  List<ShopThumbnail> stickers=[];
  List<ShopThumbnail> emojis=[];
  String currencyCode="";

  @override
  void initState() {
    super.initState();
    _pageController=PageController(initialPage: 0,viewportFraction: 0.7);
    _pageController2=PageController(initialPage: 0,viewportFraction: 0.7);
    initStream();
  }

  void initStream(){
    StickerStorage.getNewStickers((titles) {
      for(var title in titles ){
        var productdetail=ShopPurchase.getProductInfo("stickers${title.groupID}");
        if(productdetail!=null) {
          setState(() {
            if(productdetail.rawPrice==100){
              stickers.add(ShopThumbnail(title.isSticker,title.groupID,title.title,"free",title.path));
            }
            else{
              stickers.add(ShopThumbnail(title.isSticker,title.groupID,title.title,productdetail.price,title.path));
            }
          });
        }
      }

    });

    StickerStorage.getNewEmojis((titles) {
      for(var title in titles ){
        var productdetail=ShopPurchase.getProductInfo("emojis${title.groupID}");
        if(productdetail!=null) {
          setState(() {
            if(productdetail.rawPrice==100){
              emojis.add(ShopThumbnail(title.isSticker,title.groupID,title.title,"free",title.path));
            }
            else{
              emojis.add(ShopThumbnail(title.isSticker,title.groupID,title.title,productdetail.price,title.path));
            }
          });
        }
      }

    });
  }

  _plantSelector(int index){
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context,widget){
        double value = 1;
        if(_pageController.position.haveDimensions){
          value=(_pageController.page!-index.toDouble());
          value=(1-(value.abs()*0.3).clamp(0.0,1.0));
        }
        return Center(
          child:SizedBox(
            height: Curves.easeInOut.transform(value)*270, //250은 박스 높이
            width: Curves.easeInOut.transform(value)*300, //380은 박스 길이
            child:widget,
          ),
        );
      },
      child: Stack(
          alignment: Alignment.center,
          children:[
            GestureDetector(
              onTap:(){
                Navigator.push(context, MaterialPageRoute(builder: (ctx) => ShopDetail(stickers[index],true)));
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorList.getColor(7).withOpacity(0.7),
                        ColorList.getColor(7)
                      ]
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                margin:const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
                child: Stack(
                  children: [
                    Center(
                      child: ExtendedImage.network(
                        stickers[index].path,
                        height: 110.0,
                        width: 140.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      left:18,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stickers[index].title,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            stickers[index].price,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]
      ),
    );
  }

  _plantSelector2(int index){
    return AnimatedBuilder(
      animation: _pageController2,
      builder: (context,widget){
        double value = 1;
        if(_pageController2.position.haveDimensions){
          value=(_pageController2.page!-index.toDouble());
          value=(1-(value.abs()*0.3).clamp(0.0,1.0));
        }
        return Center(
          child:SizedBox(
            height: Curves.easeInOut.transform(value)*270,
            width: Curves.easeInOut.transform(value)*300,
            child:widget,
          ),
        );
      },
      child: Stack(
          alignment: Alignment.center,
          children:[
            GestureDetector(
              onTap:(){
                Navigator.push(context, MaterialPageRoute(builder: (ctx) => ShopDetail(emojis[index],false)));
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorList.getColor(7).withOpacity(0.7),
                        ColorList.getColor(7)
                      ]
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                margin:const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
                child: Stack(
                  children: [
                    Center(
                      child: ExtendedImage.network(
                        emojis[index].path,
                        height: 110.0,
                        width: 140.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      left:18,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emojis[index].title,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            emojis[index].price,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
          children:[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child:Row(
                children: [
                  Text(Strings.of(context).get('shop_sticker'),
                      style: Theme.of(context).textTheme.headline4
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              height: 235.0,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: stickers.length ,
                itemBuilder: (context,index){
                  return _plantSelector(index);
                },
              ),
            ),
            const SizedBox(height: 10.0,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child:Row(
                children: [
                  Text(Strings.of(context).get('shop_emoji'),
                      style: Theme.of(context).textTheme.headline4
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              height: 235.0,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController2,
                itemCount: emojis.length,
                itemBuilder: (context,index){
                  return _plantSelector2(index);
                },
              ),
            ),
          ]
      ),
    );
  }

}
