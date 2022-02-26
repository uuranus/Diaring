import 'dart:async';
import 'dart:io';

import 'package:diaring/storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


class ShopPurchase{

  static InAppPurchase _iap=InAppPurchase.instance;
  static bool _available =true;
  static bool isSticker=false;
  static ShopThumbnail shop=ShopThumbnail(true, "0", "", "0", "");

  static List<ProductDetails> _products=[];

  static late StreamSubscription _subscription;

  static Future<StreamSubscription> initialize(onData(List<ProductDetails> products)) async{

    _available=await _iap.isAvailable();

    if(_available){
      await _getProducts();
      onData(_products);
    }

    _subscription=_iap.purchaseStream.listen((data){ //구매목록 update될 때 불러옴
      for(var d in data){
        if(d.status==PurchaseStatus.purchased){
          if(isSticker){
            if(d.productID=="stickers${shop.groupID}"){
              //history 추가
              Map<String, String> network = {shop.groupID: shop.title};
              StickerStorage.saveIDs(network);

              //구매 수 증가
              FirebaseDatabase.instance
                  .ref("Diaring")
                  .child("stickers")
                  .child(shop.groupID)
                  .runTransaction((Object? post) {

                    if(post == null){
                      return Transaction.abort();
                    }

                    Map<String,dynamic> _post=Map<String,dynamic>.from(post as Map);
                    _post['buy']=(_post['buy'] ?? 0)+1;

                    return Transaction.success(_post);
                  });
            }

          }
          else{
            if(d.productID=="emojis${shop.groupID}"){
              //history추가
              Map<String,String> network={shop.groupID : shop.title};
              StickerStorage.saveEmojiIDs(network,shop.path);

              //구매 수 증가
              FirebaseDatabase.instance
                  .ref("Diaring")
                  .child("emojis")
                  .child(shop.groupID)
                  .runTransaction((Object? post) {

                    if(post ==null){
                      return Transaction.abort();
                    }

                    Map<String,dynamic> _post=Map<String,dynamic>.from(post as Map);
                    _post['buy']=(_post['buy'] ?? 0)+1;

                    return Transaction.success(_post);
                  });
            }

          }
        }
      }

    }, onDone: ()=> _subscription.cancel());

    return _subscription;
  }

  static List<ProductDetails> getproductlist() {
    return _products;
  }

  static Future<void> _getProducts() async{
    List<String> products=[];

    List<ShopThumbnail> _stickers=[];
    List<ShopThumbnail> _emojis=[];

    _stickers= await StickerStorage.getAllStickers();
    _emojis= await StickerStorage.getAllEmojis();

    for(var sti in _stickers) {
      products.add("stickers${sti.groupID}");
    }

    for(var emo in _emojis) {
      products.add("emojis${emo.groupID}");
    }

    //상품 목록들 가져오기
    Set<String> ids=Set.from(products); //상품 목록 리스트
    ProductDetailsResponse response=await _iap.queryProductDetails(ids); //해당 목록 상품들 플레이스토어에서 가져오기

    _products=response.productDetails;
    print("product ${_products}");

  }

  //특정 상품 정보 가져오기
  static ProductDetails? getProductInfo(String groupID) {
    if(_products.isEmpty){
      return null;
    }

    if(Platform.isAndroid){
      return _products.firstWhere((product) => product.id==groupID,);
    }

  }

  //특정 상품의 구매 여부 확인
  static Future<bool> hasPurchased(ShopThumbnail s,bool iss) async{
    isSticker=iss;
    shop=s;
    bool buy=await StickerStorage.getHistory(shop.groupID, isSticker);

    return buy;
  }


  //상품 구매
  static void buyProduct(ProductDetails prod){
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyConsumable(purchaseParam: purchaseParam);

  }

  static void buyFreeProduct(bool isSticker, String groupID){
    if(isSticker){
        //history 추가
        Map<String, String> network = {shop.groupID: shop.title};
        StickerStorage.saveIDs(network);

        //구매 수 증가
        FirebaseDatabase.instance
            .ref("Diaring")
            .child("stickers")
            .child(shop.groupID)
            .runTransaction((Object? post) {

          if(post == null){
            return Transaction.abort();
          }

          Map<String,dynamic> _post=Map<String,dynamic>.from(post as Map);
          _post['buy']=(_post['buy'] ?? 0)+1;
          print("posttt ${_post['buy']}");
          return Transaction.success(_post);
        });
    }
    else{
        //history추가
        Map<String,String> network={shop.groupID : shop.title};
        StickerStorage.saveEmojiIDs(network,shop.path);

        //구매 수 증가
        FirebaseDatabase.instance
            .ref("Diaring")
            .child("emojis")
            .child(shop.groupID)
            .runTransaction((Object? post) {

          if(post ==null){
            return Transaction.abort();
          }

          Map<String,dynamic> _post=Map<String,dynamic>.from(post as Map);
          _post['buy']=(_post['buy'] ?? 0)+1;
          print("posttt ${_post['buy']}");
          return Transaction.success(_post);
        });

    }
  }

}
