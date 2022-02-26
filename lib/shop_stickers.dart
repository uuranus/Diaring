import 'package:diaring/purchase.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'storage.dart';
import 'shop_detail.dart';

class ShopStickers extends StatefulWidget{
  const ShopStickers({Key? key}) : super(key: key);


  @override
  _ShopStickersState createState() => _ShopStickersState();
}

class _ShopStickersState extends State<ShopStickers>{

  List<ShopThumbnail> stickers=[];

  @override
  void initState() {
    super.initState();
    initStream();
  }

  void initStream() async{
    List<ShopThumbnail> sti=[];
    sti=await StickerStorage.getAllStickers();
    setState(() {
      for(var title in sti ){
        var productdetail=ShopPurchase.getProductInfo("stickers${title.groupID}");
        if(productdetail!=null){
          if(productdetail.rawPrice==100){
            stickers.add(ShopThumbnail(title.isSticker,title.groupID,title.title,"free",title.path));
          }
          else{
            stickers.add(ShopThumbnail(title.isSticker,title.groupID,title.title,productdetail.price,title.path));
          }
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.all(10),
        itemBuilder: (context,index){
          return GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (ctx) => ShopDetail(stickers[index],true)));
            },
            child: ListTile(

              leading: ExtendedImage.network(
                stickers[index].path,
                height: 70.0,
                width: 70.0,
                fit: BoxFit.contain,
              ),
              title: Column(
                children: [
                  Text(stickers[index].title,
                      style: Theme.of(context).textTheme.headline6
                  ),
                  const SizedBox(height:7),
                  Text(stickers[index].price.toString(),
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
        itemCount: stickers.length
    );
  }
}
