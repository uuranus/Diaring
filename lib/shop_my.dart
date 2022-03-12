import 'package:diaring/strings.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
  int login=0;
  final TextEditingController _nicknamecontroller = TextEditingController();

  @override
  void initState() {
    _tabController =TabController(length: 3, vsync: this);
    init();
    super.initState();
  }
  void init(){
    initStream();
    groupVal=ColorList.getCurColorListIndex();
    initAccount();
    Preferences.getthemeKey().then((value) => groupVal=value);
  }
  void initAccount(){
    Preferences.getNickname((nick){
      setState(() {
        nickname=nick;
        _nicknamecontroller.text=nickname;
      });
    });
    Preferences.getLoginKey().then((value) {
      setState(() {
        login=value;
      });

    });
    Preferences.getAccountKey().then((value) {
      setState(() {
        id=value;
      });
    });
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
                     radius: 40,
                     backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/diaring-49b35.appspot.com/o/playstore.png?alt=media&token=766d426e-14df-4b59-bde4-b3b4923c8953"),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  content: Text(Strings.of(context).get('shop_my_delete_msg'),
                                    style: Theme.of(context).textTheme.headline5,
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(Strings.of(context).get('dialog_cancel')),
                                      onPressed: () =>
                                          Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text(Strings.of(context).get('dialog_ok')),
                                      onPressed: () {
                                        FirebaseAuth.instance.currentUser!.delete(); //계정 삭제 후 앱 종료
                                        Preferences.setLoginKey(0);
                                        Navigator.pop(context);
                                        SystemNavigator.pop();
                                      }
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Text(Strings.of(context).get('shop_my_delete') ,
                            style: TextStyle(fontSize: 9,color: Colors.grey[500],fontWeight: FontWeight.w400)
                        ),
                      )
                    ],
                  ),
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
                                            content: Text(Strings.of(context).get('text_empty'),
                                              style: Theme.of(context).textTheme.headline5,
                                            ),
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
                                            content: Text(Strings.of(context).get('text_limit'),
                                              style: Theme.of(context).textTheme.headline5,
                                            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      login!=0?
                     Container(
                       width: 15,
                       height:15,
                       child: CircleAvatar(
                         child: Image.asset(
                           login==1 ? "images/google.png" : login==2 ? "images/facebook.png" : "images/apple.png"
                         ),
                         backgroundColor: ColorList.getColor(0),
                        ),
                     ): Container(),
                      const SizedBox(width: 5,),
                      Text(
                          id,
                          style: TextStyle(fontSize: 9,color: Colors.grey[500],fontWeight: FontWeight.w400), //회색으로 고정
                      ),

                    ],
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  List.generate(3, (index) {
                      return GestureDetector(
                          onTap:(){
                            if(login!=0){
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(
                                      content: Text(Strings.of(context).get('shop_my_already_backup'),
                                        style: Theme.of(context).textTheme.headline5,
                                      ),
                                      actions: [
                                        TextButton(
                                            child: Text(Strings.of(context).get('dialog_ok')),
                                            onPressed: () => Navigator.pop(context)
                                        ),
                                      ],
                                    ),
                              );
                              return;
                            }
                            if(index==0){
                              //구글 계정 연결
                              signInWithGoogle();
                            }
                            else if(index==1){
                              signInWithFacebook();
                            }
                            else{
                              showDialog(context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        content: Text(Strings.of(context).get('shop_my_apple'),
                                            style: Theme.of(context).textTheme.headline5
                                        ),
                                        actions: [
                                          TextButton(
                                              child: Text(Strings.of(context).get('dialog_ok'),),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }
                                          ),
                                        ],
                                      )
                              );
                            }
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              child:Container(
                                clipBehavior: Clip.antiAlias,
                                  child: CircleAvatar(
                                    child: Image.asset(
                                      index==0 ? "images/google.png" : index==1 ? "images/facebook.png" : "images/apple.png",
                                      fit: BoxFit.cover,
                                    ),
                                    backgroundColor: ColorList.getColor(0),
                                  ),
                                  width:  25.0,
                                  height:  25.0,
                                  padding: const EdgeInsets.all(1.0), // border width
                                  decoration:  BoxDecoration(
                                    color:  Color(0xffd3d3d3), // border color
                                    shape: BoxShape.circle,
                                  )
                              )
                          )
                      );
                    }),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    Strings.of(context).get('shop_my_backup_msg'),
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

  //로그인 함수
  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    if(credential.accessToken ==null || credential.idToken==null) return;

    // Once signed in, return the UserCredential
    AuthCredential userCredential= GoogleAuthProvider.credential(idToken: credential.idToken, accessToken: credential.accessToken);
    // var userCredential=  await FirebaseAuth.instance.signInWithCredential(credential);

    FirebaseAuth.instance.currentUser!.linkWithCredential(userCredential).then((value){
      print("value ${value}");
      setState(() {
        login=1;
      });
      Preferences.setLoginKey(1);
    })
        .onError((error, stackTrace) {
          //실패했다는 알림문구
          //이미 연결된 계정이 있는 경우에는 그 걸 찾아오기
          showDialog(context: context,
              builder: (context) =>
                  AlertDialog(
                    content: Text(Strings.of(context).get('shop_my_isExisted'),
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
                          onPressed: () async{
                            await FirebaseAuth.instance.currentUser!.delete(); //현재 익명 계정은 삭제하고
                            await FirebaseAuth.instance.signInWithCredential(credential); //기존 계정으로 변경
                            setState(() {
                              login=1;
                              Preferences.setLoginKey(1);
                              init();
                            });

                            Navigator.pop(context);
                          }
                      ),
                    ],
                  )
          );

        });
  }

  Future<void> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    if(facebookAuthCredential.accessToken ==null ) return;

    // Once signed in, return the UserCredential
    FirebaseAuth.instance.currentUser!.linkWithCredential(facebookAuthCredential).then((value){
      print("value ${value}");
      setState(() {
        login=2;
      });
      Preferences.setLoginKey(2);
    })
        .onError((error, stackTrace){
      //실패했다는 알림문구
    });
  }
}

class Themes{
  String title;
  String groupID;
  String thumbnail;

  Themes(this.title,this.groupID,this.thumbnail);
}


