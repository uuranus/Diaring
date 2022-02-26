import 'dart:async';

import 'package:diaring/purchase.dart';
import 'package:diaring/strings.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import 'photo_detail.dart';
import 'theme_detail.dart';
import 'storage.dart';

class ShopDetail extends StatefulWidget{
  ShopThumbnail shop;
  bool isSticker;

  ShopDetail(this.shop,this.isSticker);

  @override
  _ShopDetailState createState() => _ShopDetailState(shop,isSticker);
}

class _ShopDetailState extends State<ShopDetail>{
  ShopThumbnail shop;
  bool isSticker;

  _ShopDetailState(this.shop,this.isSticker);

  List<String> _urls=<String>[];
  final formatCurrency=NumberFormat.simpleCurrency();
  bool isBought=false;


  late StreamSubscription _subscription;
  late ProductDetails? _product;

  @override
  void initState() {
    initStream();
    getPurchaseHistory(); //구매여부 확인

    //상품정보가져오기 (구매를 위해)
    if(shop.groupID!="0"){
      String productid="";
      if(isSticker){
        productid="stickers${shop.groupID}";
      }
      else{
        productid="emojis${shop.groupID}";
      }

      _product=ShopPurchase.getProductInfo(productid);

    }

    if(!isSticker&&shop.groupID=="0"){
      _urls=<String>["images/emojis01.png","images/emojis02.png","images/emojis03.png","images/emojis04.png","images/emojis05.png"];
    }
    else{
      getStickers();
    }

    super.initState();
  }

  void getStickers(){
    StickerStorage.getShopStickers(isSticker,shop.groupID,(path){ //이모티콘, 스티커 통합메소드
      setState(() {
        _urls.add(path);
      });
    });
  }

  void initStream(){
    StickerStorage.getShopDetailStream(isSticker,shop.groupID,(bought){
      setState(() {
        isBought=bought;
      });
    }).then((value) => _subscription=value);
  }

  void getPurchaseHistory() async{
    bool buy=await ShopPurchase.hasPurchased(shop,isSticker);
    setState(() {
      if (buy) { //구매완료상품이면
        isBought = true;
      }
      else {
        isBought = false;
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children:[
            Padding(
              padding: const EdgeInsets.all(10),
              child:Row(
                children:[
                  IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.arrow_back))
                ]
              )
            ),
            const SizedBox(height:50),
            Expanded(
              flex:2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.spaceAround,
                  spacing: 20, //좌우 공간
                  runSpacing: 20, //상하 공간
                  children: List.generate(_urls.length, (index) =>
                      GestureDetector(
                        onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (ctx) => !isSticker&&shop.groupID=="0" ? ThemeDetail(index,_urls) : PhotoDetail(index,_urls)));
                        },
                        child: Hero(
                          tag: _urls[index]+index.toString(),
                          child: !isSticker&&shop.groupID=="0" ?
                            Image.asset(
                              _urls[index],
                              height:getImageSize(),
                              width:getImageSize(),
                            )
                        : ExtendedImage.network(
                            _urls[index],
                            height:getImageSize(),
                            width:getImageSize(),
                          ),
                        ),
                      )
                  ),
                ),
              ),
            ),
            Expanded(
              flex:1,
              child: Column(
                children: [
                  Text(shop.title,
                      style: Theme.of(context).textTheme.headline1
                  ),
                  const SizedBox(height: 15),
                  Text(shop.price=="" ? "" : shop.price=="0" ? "free" : shop.price,
                      style: Theme.of(context).textTheme.headline4
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 30,
                    width: MediaQuery.of(context).size.width-40,
                    child: ElevatedButton(
                      onPressed: () { //인앱 결제 ㄱㄱ
                        print("width ${MediaQuery.of(context).size.width}");
                        if(!isBought && shop.price!="free"){
                          ShopPurchase.buyProduct(_product!);
                        }
                        else if(!isBought && shop.price=="free"){
                          ShopPurchase.buyFreeProduct(shop.isSticker,shop.groupID);
                        } },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(isBought ? Colors.grey : Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(isBought ? Strings.of(context).get('shop_purchased') : Strings.of(context).get('shop_buy'),
                            style: Theme.of(context).textTheme.headline2
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ]
        )
      ),
    );

  }

  double getImageSize(){
    return MediaQuery.of(context).size.width >= 400 ? 110 : 90;
  }



}