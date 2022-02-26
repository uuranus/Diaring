
import 'dart:async';

import 'package:diaring/purchase.dart';
import 'package:diaring/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'shop_emojis.dart';
import 'shop_hot.dart';
import 'shop_new.dart';
import 'shop_stickers.dart';
import 'shop_my.dart';


class Shop extends StatefulWidget{
  const Shop({Key? key}) : super(key: key);

  @override
  _ShopState createState() => _ShopState();

}
class _ShopState extends State<Shop> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  late StreamSubscription _subscription;
  List<ProductDetails> _products=[];

  @override
  void initState() {
    super.initState();
    ShopPurchase.initialize((products){
      setState(() {
        _products=products;
      });
    }).then((value) {
      print("_subscription ${value}");
      _subscription=value;
    });

    _tabController=TabController(initialIndex:0,length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    return _buildShop();
  }

  Widget _buildShop(){

    return Scaffold(
      body:Container(
        padding:const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:<Widget>[
            Padding(
              padding:const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon:const Icon(Icons.account_circle_outlined,size: 30),
                    onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (ctx) => const ShopMy())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding:const EdgeInsets.only(left:30.0),
              child:Text(
                  Strings.of(context).get('shop_title'),
                  style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700,color: Theme.of(context).brightness==Brightness.light ? Colors.black : Colors.white,)
              ),
            ),
            const SizedBox(height: 20.0,),
            Expanded(
              child: DefaultTabController(
                  length: 4,
                  child: Column(
                      children:[
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.transparent,
                          labelColor: Theme.of(context).brightness==Brightness.light ? Colors.black : Colors.white,
                          unselectedLabelColor: Colors.grey.withOpacity(0.6),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 35.0),
                          isScrollable: true,
                          tabs: [
                            Tab(
                              child: Text(
                                  Strings.of(context).get('shop_hot'),
                                  style:const TextStyle(fontSize: 16,fontWeight: FontWeight.w700)
                              ),
                            ),
                            Tab(
                              child: Text(
                                  Strings.of(context).get('shop_new'),
                                  style:const TextStyle(fontSize: 16,fontWeight: FontWeight.w700)
                              ),
                            ),
                            Tab(
                              child: Text(
                                  Strings.of(context).get('shop_sticker'),
                                  style:const TextStyle(fontSize: 16,fontWeight: FontWeight.w700)
                              ),
                            ),
                            Tab(
                              child: Text(
                                  Strings.of(context).get('shop_emoji'),
                                  style:const TextStyle(fontSize: 16,fontWeight: FontWeight.w700)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0,),
                        Expanded(
                              child: TabBarView(
                              controller: _tabController,
                              children:  const [
                                ShopHot(),
                                ShopNew(),
                                ShopStickers(),
                                ShopEmojis(),
                              ],
                             ),
                        ),
                      ]
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}