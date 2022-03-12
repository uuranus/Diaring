import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'utils.dart';

class Sticker{
  late int id;
  late int? size;
  late int? position;
  late String path;
  late String title;

  Sticker(this.id,this.size,this.position,this.path,this.title);

  Sticker.fromMap(Map map) {
    id = map["id"];
    size=map["size"];
    position=map['position'];
    path = map["path"];
    title=map['title'];
  }

}

class Emoji{
  late int id;
  late String path;
  late String title;

  Emoji(this.id,this.path,this.title);

  Emoji.fromMap(Map map) {
    id = map["id"];
    path = map["path"];
    title=map['title'];
  }

}

class ShopThumbnail{
  bool isSticker=true;
  String groupID;
  String title="";
  String price="";
  String path="";

  ShopThumbnail(this.isSticker,this.groupID,this.title,this.price,this.path);

  ShopThumbnail.fromMap(this.isSticker,this.groupID,Map map){
    title=map["title"];
    price="";
    for(var c in map.keys){
      if(isSticker){
        if(c=="stickers${groupID}1"){
          path=map[c]["path"];
        }
      }
      else{
        if(c=="emojis${groupID}1"){
          path=map[c]["path"];
        }
      }
    }
  }

  ShopThumbnail.from(this.isSticker,this.groupID,Map map,this.path){
    title=map["title"];
  }

}

class StickerTitle{
  String groupID;
  String title="";

  StickerTitle(this.groupID,this.title);
}

class EmojiTitle{
  String groupID;
  String title="";
  bool isSelected=false;

  EmojiTitle(this.groupID,this.title,this.isSelected);

  EmojiTitle.fromMap(this.groupID,Map map){
    title=map["title"];
    isSelected=map["isSelected"];
  }

}

class StickerStorage{

  static Future<StreamSubscription<DatabaseEvent>> getStickerStream( int year,int mon,
      void onData(LinkedHashMap<DateTime,List<Sticker>> stickers)) async{
    String accountKey=await Preferences.getAccountKey();

    StreamSubscription<DatabaseEvent> subscription=FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("decoration")
        .child(year.toString())
        .child(mon.toString().padLeft(2,'0'))
        .onValue
        .listen((DatabaseEvent fevent){

      LinkedHashMap<DateTime,List<Sticker>> stickers=LinkedHashMap<DateTime,List<Sticker>>();

      for(var c in fevent.snapshot.children){
        List<Sticker> list=[];
        list.add(Sticker.fromMap(c.value as Map));
        stickers.putIfAbsent(DateTime.parse(c.key!), () =>list);
      }
      onData(stickers);
    });

    return subscription;
  }

  static Future<void> setSticker(DateTime date,  Sticker sticker) async{ //다이어리 스티커 기록 저장하기
    String accountKey=await Preferences.getAccountKey();
    var strdate=Calendar.getStringDate(date);

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("decoration")
        .child(strdate.substring(0,4))
        .child(strdate.substring(5,7))
        .child(strdate)
        .set({
          "id": sticker.id,
          "size":sticker.size,
          "position":sticker.position,
          "title": sticker.title,
          "path": sticker.path,
        });

  }

  static Future<void> removeSticker(DateTime date) async{
    String accountKey=await Preferences.getAccountKey();
    var strdate=Calendar.getStringDate(date);

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("decoration")
        .child(strdate.substring(0,4))
        .child(strdate.substring(5,7))
        .child(strdate)
        .remove();

  }

  static Future<void> getIDs(void onData(List<StickerTitle> titles)) async{ //해당 스티커의 정보를 가져올 때
    String accountKey=await Preferences.getAccountKey();

    FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("history")
          .child("stickers")
          .once()
          .then((snapshot){
            List<StickerTitle> lists=[];
            for(var data in snapshot.snapshot.children){
              lists.add(StickerTitle(data.key!, data.value as String));
            }

            onData(lists);
          });
  }

  static Future<void> saveIDs(Map<String,String> network) async{ //구매내역을 저장할 때
    String accountKey=await Preferences.getAccountKey();

    var key=network.keys.elementAt(0);

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("stickers")
        .child(key)
        .set(network[key]);
  }

  static Future<void> getStickers(String id, void onData(List<Sticker> stickers)) async{ //해당 스티커의 정보를 가져올 때

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("stickers")
        .child(id)
        .once()
        .then((snapshot){
          List<Sticker> lists=[];
          for(var data in snapshot.snapshot.children){
            if(data.key.toString()!="title"&&data.key.toString()!="price"&&data.key.toString()!="buy"){
              lists.add(Sticker.fromMap(data.value as Map));
            }
          }

          onData(lists);
        });
  }

  //이모티콘 설정
  static Future<void> getSelectedEmojis(  //내가 설정해놓은 이모티콘 이미지들 가져오기
      void onData( path,isdone, emojikey)) async{
    String accountKey=await Preferences.getAccountKey();

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("emojis")
        .orderByChild("isSelected")
        .equalTo(true)
        .once()
        .then((value) {
          String emojikey="";
          for( var c in value.snapshot.children){
            emojikey=c.key.toString();
          }

          FirebaseStorage.instance.ref().child("emojis/${emojikey}").listAll().then((value) async {
            bool isdone=false;

            if(value.items.isEmpty) {
              onData("",true,emojikey);
              return;
            }
            for(var item in value.items){
              if(value.items.last==item)  isdone=true;

              await item.getDownloadURL().then((url) {
                onData(url,isdone,emojikey);
              });
            }

          });

        });

  }

  static Future<void> setEmojiSelection(String old, String neww) async{ //설정한 이모티콘 저장하기
    String accountKey=await Preferences.getAccountKey();

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("emojis")
        .child(old)
        .update({
          "isSelected" : false,
        });

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("emojis")
        .child(neww)
        .update({
          "isSelected" : true,
        });

  }

  static Future<void> getEmojiIDs(void onData(List<EmojiTitle> titles)) async{ //가지고 있는 이모티콘 리스트들 가져오기
    String accountKey=await Preferences.getAccountKey();


    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("emojis")
        .once()
        .then((snapshot){
          List<EmojiTitle> lists=[];
          for(var data in snapshot.snapshot.children){
            lists.add(EmojiTitle.fromMap(data.key!, data.value as Map));
          }

          onData(lists);
        });
  }

  static Future<void> saveEmojiIDs(Map<String,String> network,String path) async{ //구매내역을 저장할 때
    String accountKey=await Preferences.getAccountKey();

    var key=network.keys.elementAt(0);

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("emojis")
        .child(key)
        .set({
          "title":network[key],
          "isSelected":false,
        });
  }

  static Future<void> getEmojis(String id, void onData(List<String> emojis)) async{ //해당 이모티콘 정보를 가져올 때

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("emojis")
        .child(id)
        .once()
        .then((snapshot){

          List<String> list=[];
          for(var data in snapshot.snapshot.children){
            if(data.key.toString()!="title"&&data.key.toString()!="price"&&data.key.toString()!="buy"){ //Firestorage에서 가져오기 해도 되는게 이게 더 빠름
              var map=data.value as Map;
              list.add(map["path"]);
            }
          }
          onData(list);
        });
  }


  //상점
  static Future<StreamSubscription<DatabaseEvent>> getShopDetailStream( bool isSticker,String groupID,
      void onData(bool isBought)) async{
    String accountKey=await Preferences.getAccountKey();

    String parent="";
    bool isFound=false;

    if(isSticker){
      parent="stickers";
    }
    else{
      parent="emojis";
    }

    StreamSubscription<DatabaseEvent> subscription=FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child(parent)
        .onValue
        .listen((DatabaseEvent fevent){

          for(var c in fevent.snapshot.children){
            if(c.key==groupID){
              onData(true);
              isFound=true;
              break;
            }
          }
          if(!isFound){
            onData(false);
          }
        });

    return subscription;
  }


  static Future<void> getHotStickers(void onData(List<ShopThumbnail> titles)) async{ //인기 스티커의 정보를 가져올 때

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("stickers")
        .orderByChild("buy")
        .limitToFirst(5)
        .once()
        .then((snapshot){
          List<ShopThumbnail> lists=[];
          for(var i=snapshot.snapshot.children.length-1;i>=0;i--){
            var data= snapshot.snapshot.children.elementAt(i);
            if(data.key!="0"){
              lists.add(ShopThumbnail.fromMap(true, data.key!, data.value as Map));
            }
          }

          onData(lists);
        });
  }

  static Future<void> getHotEmojis(void onData(List<ShopThumbnail> titles)) async{ //인기 이모티콘 정보를 가져올 때

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("emojis")
        .orderByChild("buy")
        .limitToFirst(5)
        .once()
        .then((snapshot){
          List<ShopThumbnail> lists=[];
          for(var i=snapshot.snapshot.children.length-1;i>=0;i--){
            var data= snapshot.snapshot.children.elementAt(i);
            lists.add(ShopThumbnail.fromMap(false, data.key!, data.value as Map));
          }

          onData(lists);
        });
  }

  static Future<void> getNewStickers(void onData(List<ShopThumbnail> titles)) async{ //신규 스티커의 정보를 가져올 때

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("stickers")
        .orderByKey()
        .limitToLast(5)
        .once()
        .then((snapshot){
          List<ShopThumbnail> lists=[];
          for(var i=snapshot.snapshot.children.length-1;i>=0;i--){
            var data= snapshot.snapshot.children.elementAt(i);
            if(data.key!="0"){
              lists.add(ShopThumbnail.fromMap(true, data.key!, data.value as Map));
            }

          }

          onData(lists);
        });
  }

  static Future<void> getNewEmojis(void onData(List<ShopThumbnail> titles)) async{ //신규 이모티콘 정보를 가져올 때

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("emojis")
        .orderByKey()
        .limitToLast(5)
        .once()
        .then((snapshot){
          List<ShopThumbnail> lists=[];
          for(var i=snapshot.snapshot.children.length-1;i>=0;i--){
            var data= snapshot.snapshot.children.elementAt(i);
            lists.add(ShopThumbnail.fromMap(false, data.key!, data.value as Map));
          }

          onData(lists);
        });
  }


  static Future<List<ShopThumbnail>> getAllStickers() async{ //모든 스티커의 정보를 가져올 때
    List<ShopThumbnail> lists=[];

    await FirebaseDatabase.instance
        .ref("Diaring")
        .child("stickers")
        .orderByKey()
        .once()
        .then((snapshot){

          for(var data in snapshot.snapshot.children){
            if(data.key!="0"){
              lists.add(ShopThumbnail.fromMap(true, data.key!, data.value as Map));
            }
          }
        });

    return lists;
  }

  static Future<List<ShopThumbnail>> getAllEmojis() async{ //모든 이모티콘 정보를 가져올 때
    List<ShopThumbnail> lists=[];

    await FirebaseDatabase.instance
        .ref("Diaring")
        .child("emojis")
        .orderByKey()
        .once()
        .then((snapshot){

          for(var data in snapshot.snapshot.children){
            lists.add(ShopThumbnail.fromMap(false, data.key!, data.value as Map));
          }


        });
    return lists;
  }


  static Future<void> getShopStickers(bool isSticker, String groupID,void onData( path)) async{ //해당 스티커의 정보를 가져올 때 모든 스티커 사진들 보여주려고
    String path="";

    if(isSticker) {
       path="stickers/${groupID}";
    }
    else{
      path="emojis/${groupID}";
    }

   FirebaseStorage.instance.ref().child(path).listAll().then((value) async{

      for(var item in value.items){
         await item.getDownloadURL().then((url) {
           onData(url);
         });
      }

    });
   ;
  }


  static Future<void> getMyStickers(void onData(List<ShopThumbnail> titles)) async {
    //상점의 마이페이지에서 내 구매 스티커 리스트를 가져올 때
    String accountKey = await Preferences.getAccountKey();

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("stickers")
        .once()
        .then((snapshot) async{
          List<ShopThumbnail> lists = [];
          for (var data in snapshot.snapshot.children) {
            await FirebaseStorage.instance.ref()
                  .child("stickers/${data.key}")
                  .listAll()
                  .then((value) async {
                await value.items.elementAt(0).getDownloadURL().then((value) {
                  lists.add(ShopThumbnail(
                      true, data.key!, data.value as String, "", value));
                });
              });
          }
          onData(lists);
        });
  }

  static Future<void> getMyEmojis(void onData(List<ShopThumbnail> titles)) async{ //모든 이모티콘 정보를 가져올 때
    //상점의 마이페이지에서 내 구매 이모티콘 리스트를 가져올 때
    String accountKey = await Preferences.getAccountKey();

    FirebaseDatabase.instance
        .ref("Diaring")
        .child("userData")
        .child(accountKey)
        .child("history")
        .child("emojis")
        .once()
        .then((snapshot) async {
      List<ShopThumbnail> lists = [];
      for (var data in snapshot.snapshot.children) {
        if (data.key.toString() == "0") {
          lists.add(ShopThumbnail(
              true, "0", "조랭냥이 이모티콘", "", "images/emojis01.png"));
        }
        else {
          await FirebaseStorage.instance.ref()
              .child("emojis/${data.key}")
              .listAll()
              .then((value) async {
            await value.items.elementAt(0).getDownloadURL().then((value) {
              lists.add(ShopThumbnail.from(
                  true, data.key!, data.value as Map, value));
            });
          });
        }
      }
      onData(lists);
    });
  }


  static Future<bool> getHistory(String groupID, bool isSticker) async {
    String accountKey = await Preferences.getAccountKey();

    bool isBought=false;
    if(isSticker){
      await FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("history")
          .child("stickers")
          .once()
          .then((snapshot) {
              for(var c in snapshot.snapshot.children){
                if(c.key==groupID){
                  isBought=true;
                  break;
                }
              }
          });
    }
    else{
      await  FirebaseDatabase.instance
          .ref("Diaring")
          .child("userData")
          .child(accountKey)
          .child("history")
          .child("emojis")
          .once()
          .then((snapshot) {
            print("snapshot ${snapshot.snapshot.value}");
            for(var c in snapshot.snapshot.children){
              if(c.key==groupID){
                isBought=true;
                break;
              }
            }

          });
    }

    return isBought;

  }


  static Future<void> setTheme(int themeKey) async {
    await Preferences.setThemeKey(themeKey);
  }
}