import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
//import 'package:flutter_luban/flutter_luban.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:collection';
import 'dart:convert';


class CacheMe extends StatelessWidget {

  final String imagePath;

  CacheMe({
    this.imagePath,
  });


  //ImageCache imageCache;
//
//  Future<String> getCompressedImage(String path) async{
//    //debugPrint("getting cached img for "+path);
//    String cached = await imageCache.getCached(path);
//    if(cached != null){
//      debugPrint("Cache found");
//      return Future(() => cached);
//    }
//    debugPrint("Cache not found");
//
//    Directory appDir = await getApplicationDocumentsDirectory();
//    String cachePath = p.join(appDir.path,'.cache');
//    Directory cacheDir = Directory(cachePath);
//    bool cacheDirExists = await cacheDir.exists();
//    if(!cacheDirExists){
//      await cacheDir.create();
//    }
//
//    CompressObject compressObject = CompressObject(
//      imageFile:File(path), //image
//      path:cacheDir.path, //compress to path
//      quality: 85,//first compress quality, default 80
//      step: 9,//compress quality step, The bigger the fast, Smaller is more accurate, default 6
//      mode: CompressMode.LARGE2SMALL,//default AUTO
//    );
//    String compressedImgPath = await Luban.compressImage(compressObject);
//
//    imageCache.storeCache(path, compressedImgPath);
//    debugPrint("Cache created");
//
//    return compressedImgPath;
//  }

  Future<Uint8List> loadImage(String path) async {
    //String compressedImgPath = await getCompressedImage(path);
    //print(compressedImgPath);
    Uint8List bytes = await File(path).readAsBytes();
    return bytes;
  }

//  @override
//  void initState() {
//    super.initState();
//    imageCache = ImageCache.getInstance();
//  }
//
//  @override
//  void dispose() {
//    if(imageCache != null){
//      imageCache.writeCacheToStorage();
//      debugPrint("disposing imagecache");
//    }
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {

    //imageCache = ImageCache.getInstance();

    return Container(
      child: FutureBuilder(
        future: loadImage(imagePath),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData && snapshot.data != null){
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MemoryImage(
                    snapshot.data,
                    scale: 1.0,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
          else{
            return SizedBox(
              height: 5.0,
              width: 5.0,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          }
        },
      ),
    );
  }
}

//
//
//class CacheMeImageLoader extends StatefulWidget {
//
//  final String imagePath;
//
//  CacheMeImageLoader({
//    this.imagePath,
//  });
//
//  @override
//  _CacheMeImageLoaderState createState() => _CacheMeImageLoaderState();
//}
//
//class _CacheMeImageLoaderState extends State<CacheMeImageLoader> {
//
//  ImageCache imageCache;
//
//  Future<String> getCompressedImage(String path) async{
//
//    String cached = await imageCache.getCached(path);
//    if(cached != null){
//      debugPrint("Cache found");
//      return Future(() => cached);
//    }
//
//    Directory appDir = await getApplicationDocumentsDirectory();
//    String cachePath = p.join(appDir.path,'.cache');
//    Directory cacheDir = Directory(cachePath);
//    bool cacheDirExists = await cacheDir.exists();
//    if(!cacheDirExists){
//      await cacheDir.create();
//    }
//
//    CompressObject compressObject = CompressObject(
//      imageFile:File(path), //image
//      path:cacheDir.path, //compress to path
//      quality: 85,//first compress quality, default 80
//      step: 20,//compress quality step, The bigger the fast, Smaller is more accurate, default 6
//      mode: CompressMode.LARGE2SMALL,//default AUTO
//    );
//    String compressedImgPath = await Luban.compressImage(compressObject);
//
//    imageCache.storeCache(path, compressedImgPath);
//    debugPrint("Cache created");
//
//    return compressedImgPath;
//  }
//
//  Future<Uint8List> loadImage(String path) async {
//    String compressedImgPath = await getCompressedImage(path);
//    print(compressedImgPath);
//    Uint8List bytes = await File(compressedImgPath).readAsBytes();
//    return bytes;
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    imageCache = ImageCache.getInstance();
//  }
//
//  @override
//  void dispose() {
//    if(imageCache != null){
//      imageCache.writeCacheToStorage();
//      debugPrint("disposing imagecache");
//    }
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      child: FutureBuilder(
//        future: loadImage(widget.imagePath),
//        builder: (BuildContext context, AsyncSnapshot snapshot){
//          if(snapshot.hasData && snapshot.data != null){
//            return Container(
//              decoration: BoxDecoration(
//                image: DecorationImage(
//                  image: MemoryImage(snapshot.data),
//                  fit: BoxFit.cover,
//                ),
//              ),
//            );
//          }
//          else{
//            return SizedBox(
//              height: 5.0,
//              width: 5.0,
//              child: CircularProgressIndicator(
//                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
//              ),
//            );
//          }
//        },
//      ),
//    );
//  }
//}
//
//class ImageCache{
//
//  //private constructor
//  ImageCache._internal() {
//    getApplicationDocumentsDirectory().then((Directory appDir){
//      String cachePath = p.join(appDir.path,'.cache');
//      Directory cacheDir = Directory(cachePath);
//      cacheDir.exists().then((bool exists){
//        if(!exists){
//          cacheDir.createSync();
//        }
//        _imageCacheFile = File(p.join(cacheDir.path,'.cache_mapping.json'));
//        if(!_imageCacheFile.existsSync()){
//          _imageCacheFile.createSync();
//          debugPrint("ImageCacheFile created");
//        }
//        _syncCacheFromStorage();
//      });
//    });
//  }
//
//  static ImageCache instance;
//
//  static ImageCache getInstance(){
//    if(instance == null){
//      instance = ImageCache._internal();
//    }
//    return instance;
//  }
//
//  HashMap<String, String> _map;
//  File _imageCacheFile;
//  bool isInitialized = false;
//
//  Future<String> getCached(String key) async {
//    debugPrint('getting cached '+key);
//    while(!this.isInitialized){
//      await Future.delayed(const Duration(seconds: 1));
//      debugPrint('waiting '+key);
//    }
//    if(_map.containsKey(key)){
//      debugPrint("contains key "+ key);
//      return _map[key];
//    }
//    debugPrint("not contains key "+key);
//    return null;
//  }
//
//  storeCache(String key, String value){
//    _map[key] = value;
//    //writeCacheToStorage();
//  }
//
//  _syncCacheFromStorage() async {
//    String encodedData = await _imageCacheFile.readAsString();
//    try {
//      _map = json.decode(encodedData);
//      debugPrint("_syncCacheFromStorage()");
//    }catch(FormatException){
//      _map = HashMap<String, String>();
//      debugPrint("format exception caused");
//    }
//    this.isInitialized = true;
//  }
//
//  writeCacheToStorage(){
//    var data = json.encode(_map);
//    _imageCacheFile.writeAsString(data);
//    debugPrint("writeCacheToStorage()");
//  }
//}