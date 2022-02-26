import 'package:diaring/purchase.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'storage.dart';
import 'shop_detail.dart';

class ShopEmojis extends StatefulWidget{
  const ShopEmojis({Key? key}) : super(key: key);


  @override
  _ShopEmojisState createState() => _ShopEmojisState();
}

class _ShopEmojisState extends State<ShopEmojis>{

  List<ShopThumbnail> emojis=[];

  @override
  void initState() {

    super.initState();
    initStream();
  }

  void initStream() async{
    List<ShopThumbnail> emo= await StickerStorage.getAllEmojis();
    for(var title in emo ){
      var productdetail=ShopPurchase.getProductInfo("emojis${title.groupID}");
      if(productdetail!=null){
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
  }


  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.all(10),
        itemBuilder: (context,index){
          return GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (ctx) => ShopDetail(emojis[index],false)));
            },
            child: ListTile(
                leading: ExtendedImage.network(
                  emojis[index].path,
                  height: 70.0,
                  width: 70.0,
                  fit: BoxFit.contain,
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(emojis[index].title,
                        style: Theme.of(context).textTheme.headline6
                    ),
                    const SizedBox(height:7),
                    Text(emojis[index].price.toString(),
                        style: Theme.of(context).textTheme.bodyText1
                    ),
                  ],
                )
            ),
          );
        },
        separatorBuilder: (context,index){
          return const Divider();
        },
        itemCount: emojis.length
    );
  }
}
