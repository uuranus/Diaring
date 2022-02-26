import 'package:diaring/strings.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colorlist.dart';
import 'storage.dart';
import 'theme_detail.dart';
import 'shop_detail.dart';
import 'utils.dart';

class ShopMy extends StatefulWidget{
  const ShopMy({Key? key}) : super(key: key);


  @override
  _ShopMyState createState() => _ShopMyState();
}

class _ShopMyState extends State<ShopMy> with SingleTickerProviderStateMixin{

  List<ShopThumbnail> _stickers=[];
  List<ShopThumbnail> _emojis=[];
  final List<Themes> _themes=[Themes("Tropcial","0","images/theme11.jpg"),Themes("Ice Cream","1","images/theme21.jpg"),Themes("City","2","images/theme31.jpg"),Themes("Midnight","3","images/theme41.jpg"),];
  late TabController _tabController;
  int groupVal=0;
  List<String> paths=<String>[];
  String nickname="";
  String id="";
  final TextEditingController _nicknamecontroller = TextEditingController();

  @override
  void initState() {
    _tabController =TabController(length: 3, vsync: this);
    initStream();
    groupVal=ColorList.getCurColorListIndex();
    Preferences.getNickname((nick){
      setState(() {
        nickname=nick;
        _nicknamecontroller.text=nickname;
      });
    });
    Preferences.getAccountKey().then((value) => id=value);
    Preferences.getthemeKey().then((value) => groupVal=value);
    super.initState();
  }


  void initStream(){
    StickerStorage.getMyStickers((titles) {
      setState(() {
        _stickers=titles;
      });
    });
    StickerStorage.getMyEmojis((titles) {
      setState(() {
        _emojis = titles;
      });
    });
  }

  Future<void> getPhotos(String groupID, bool isSticker) async{
    await StickerStorage.getShopStickers(isSticker, groupID, (paths) {
      setState(() {
        paths=paths;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 15),
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  const CircleAvatar(
                     radius: 50,
                     backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/diaring-49b35.appspot.com/o/playstore.png?alt=media&token=766d426e-14df-4b59-bde4-b3b4923c8953"),
                  ),
                  const SizedBox(height: 15,),
                  GestureDetector(
                    onTap: ()=>
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(
                            title: Text(Strings.of(context).get('shop_my_change_nick'),
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            content: TextField(
                              controller: _nicknamecontroller,
                              style: Theme.of(context).textTheme.headline5,
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
                                  if(_nicknamecontroller.text.isEmpty){
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                            content: Text(Strings.of(context).get('text_empty')),
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
                                  else if(_nicknamecontroller.text.length>30){
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                            content: Text(Strings.of(context).get('text_limit')),
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
                                    Preferences.setNickname(_nicknamecontroller.text);
                                    setState(() {
                                      nickname=_nicknamecontroller.text;
                                    });
                                    Navigator.pop(context);
                                  }

                                }
                              ),
                            ],
                          )
                    ),
                    child: Text(
                        nickname,
                      style:Theme.of(context).textTheme.headline1
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                      id,
                      style: TextStyle(fontSize: 9,color: Colors.grey[500],fontWeight: FontWeight.w400), //회색으로 고정
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              const Divider(height: 1,),
              const SizedBox(height: 10,),
              Expanded(
                child: DefaultTabController(
                    length: 3,
                    child:Column(
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
                              Tab(
                                child: Text(
                                    Strings.of(context).get('shop_theme'),
                                    style:const TextStyle(fontSize: 16,fontWeight: FontWeight.w700)
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  ListView.separated(
                                    itemCount: _stickers.length,
                                    itemBuilder: (context,index) =>
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.push(context,MaterialPageRoute(builder: (ctx) => ShopDetail(_stickers[index],true)));
                                          },
                                          child: ListTile(
                                            leading: ExtendedImage.network(
                                              _stickers[index].path,
                                              width: 100,
                                              height: 70,
                                              fit: BoxFit.contain,
                                            ),
                                            title: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  _stickers[index].title,
                                                  style : Theme.of(context).textTheme.headline5
                                              ),
                                            ),
                                          ),
                                        ),
                                    separatorBuilder: (context, index) => const Divider(),
                                  ),
                                  ListView.separated(
                                    itemCount: _emojis.length,
                                    itemBuilder: (context,index) =>
                                        GestureDetector(
                                          onTap:(){
                                            Navigator.push(context,MaterialPageRoute(builder: (ctx) =>  ShopDetail(_emojis[index],false)));
                                          },
                                          child: ListTile(
                                            leading: _emojis[index].groupID=="0" ?
                                            Image.asset(
                                              _emojis[index].path,
                                              width: 100,
                                              height: 70,
                                              fit: BoxFit.contain,
                                            )
                                                : ExtendedImage.network(
                                              _emojis[index].path,
                                              width: 100,
                                              height: 70,
                                              fit: BoxFit.contain,
                                            ),
                                            title: Text(
                                                _emojis[index].title,
                                                style : Theme.of(context).textTheme.headline5,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    separatorBuilder: (context, index) => const Divider(),
                                  ),
                                  ListView.separated(
                                    itemCount: _themes.length,
                                    itemBuilder: (context,index) =>
                                        ListTile(
                                          leading: GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                if(index==0){
                                                  paths=<String>["images/theme11.jpg","images/theme12.jpg","images/theme13.jpg","images/theme14.jpg","images/theme15.jpg"];
                                                }
                                                else if(index==1){
                                                  paths=<String>["images/theme21.jpg","images/theme22.jpg","images/theme23.jpg","images/theme24.jpg","images/theme25.jpg"];
                                                }
                                                else if(index==2){
                                                  paths=<String>["images/theme31.jpg","images/theme32.jpg","images/theme33.jpg","images/theme34.jpg","images/theme35.jpg"];
                                                }
                                                else if(index==3){
                                                  paths=<String>["images/theme41.jpg","images/theme42.jpg","images/theme43.jpg","images/theme44.jpg","images/theme45.jpg"];
                                                }

                                              });
                                              Navigator.push(context,MaterialPageRoute(builder: (ctx) => ThemeDetail(0, paths)));
                                            },
                                            child: Hero(
                                              tag: _themes[index].thumbnail + index.toString(),
                                              child: Image.asset(
                                                _themes[index].thumbnail,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                              _themes[index].title,
                                              style : Theme.of(context).textTheme.headline5
                                          ),
                                          trailing: Radio(
                                            value: index,
                                            groupValue: groupVal,
                                            activeColor: ColorList.getColor(8),
                                            onChanged: (value){
                                              setState(() {
                                                groupVal=value as int;
                                                StickerStorage.setTheme(groupVal);
                                                showDialog(context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          content: Text(Strings.of(context).get('shop_theme_msg'),
                                                            style: Theme.of(context).textTheme.headline5
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
                                                                Navigator.pop(context);
                                                                SystemNavigator.pop();
                                                              }
                                                            ),
                                                          ],
                                                        )
                                                );
                                              });
                                            },
                                          ),
                                        ),
                                    separatorBuilder: (context, index) => const Divider(),
                                  ),
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
      ),
    );
  }

}

class Themes{
  String title;
  String groupID;
  String thumbnail;

  Themes(this.title,this.groupID,this.thumbnail);
}