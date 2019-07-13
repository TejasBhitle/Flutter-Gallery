import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class CacheMe2{

  static const _CREATE_TABLE_QUERY = "CREATE TABLE ImageCache (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT NOT NULL UNIQUE, value BLOB);";

  _getSelectQuery(String key) => "SELECT value from ImageCache WHERE key = '$key';";

  _getInsertQuery(String key, String value) => "INSERT INTO ImageCache (key, value) VALUES ('$key','$value');";


  //private constructor
  CacheMe2._internal() {
    //init db
    getDatabasesPath().then(
        (String path) {
          path = join(path,'ImageCache.db');
          debugPrint("dbpath => "+path);
          openDatabase(path, version: 1,
              onCreate: (Database db, int version) async {
                // When creating the db, create the table
                await db.execute(_CREATE_TABLE_QUERY);
                debugPrint("db created");
              }).then((Database db){
                _cacheDb = db;
                _isInitialized = true;
                debugPrint("db initialized");
          });
        }
    );
  }

  static CacheMe2 _instance;
  static bool _isInitialized = false;

  static CacheMe2 getInstance(){
    if(_instance == null){
      _instance = CacheMe2._internal();
    }
    return _instance;
  }


  static Database _cacheDb;


  waitTillCacheDbInit() async{
    int min = 0, max = 500;
    do{
      if(_isInitialized) return;
      await Future.delayed(Duration(milliseconds: min + Random().nextInt(max - min)));
    }while(true);
  }

  Future<List<int>> compressFile(String path) async {
    File file = File(path);
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 400,
      minHeight: 400,
      quality: 50,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }


  //TODO: Handle SQL Injection
  Future<Uint8List> loadImage(String url) async{

    await waitTillCacheDbInit();
    List<Map> res = await _cacheDb.rawQuery(_getSelectQuery(url));
    if(res.length == 0){
      //cache miss
      debugPrint("cache miss");

      List<int> imageList = await compressFile(url);

      String s = imageList.toString();
      try{
        _cacheDb.rawQuery(_getInsertQuery(url, s));
      }
      catch(DatabaseException, e){
        debugPrint("Exception occured "+ e.toString());
      }
      return Uint8List.fromList(imageList);
    }
    else{
      debugPrint("cache hit");
      String cachedValue = res[0]['value'];
      List<int> imagelist = parseListFromString(cachedValue);
      return Uint8List.fromList(imagelist);
    }

  }

  List<int> parseListFromString(String s){
    List<int> list= [];
    int num = 0; bool isZero = true;
    for(int i=0;i<s.length; i++){
      int ch = s.codeUnitAt(i).toInt();
      if(ch >= 48 && ch <= 57){
        isZero = false;
        num = num*10 + (ch - 48);
      }
      else{
        if(!isZero){
          list.add(num);
          num = 0;
          isZero = true;
        }
      }
    }
    return list;
  }


  Widget ImageView(String url){

    return Container(
      child: FutureBuilder(
        future: loadImage(url),
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
            return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)
              ),
            );
          }
        },
      ),
    );


  }





}