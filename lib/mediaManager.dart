import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:exif/exif.dart';

import 'dart:io';
import 'dart:collection';


const List<String> EXTENSIONS = ["jpg", "jpeg", "png", "heic",];

enum MediaType{ IMAGE, VIDEO, OTHER }

class MediaModel{

  final File file;
  MediaType _type;
  Directory parent;
  String fileSize;
  DateTime timeStamp;
  Map _exifData;
  bool _isExifInitialized;

  MediaModel({
    @required this.file,

  }){
    this._type = MediaType.IMAGE;
    this.parent = this.file.parent;
    this._isExifInitialized = false;
    this.timeStamp = this.file.lastModifiedSync();
//    this.file.readAsBytes().then((var bytes){
//      readExifFromBytes(bytes).then((var exifMap){
//        this._exifData = exifMap;
//        this._isExifInitialized = true;
//      });
//    });

  }

  get year => this.file.lastModifiedSync().year;

  get month => this.file.lastModifiedSync().month;

  MediaModel getClone(){
    return new MediaModel(file: this.file);
  }

}

class AlbumModel{

  String name;
  List<MediaModel> mediaModels;

  AlbumModel({
    this.name,
    this.mediaModels,
  });
}

class MediaManager{

  Directory _root;
  List<String> _excludedPaths;
  bool _allowHidden;
  List<String> _EXCLUDED_PATHS = ["/storage/emulated/0/Android",];
  bool _isInitialized = false;
  bool _isMediaModelsInitialized = false;

  List<MediaModel> mediaModels = [];

  static MediaManager instance;

  MediaManager._internal(){
    getExternalStorageDirectory().then((Directory root) {
      this._root = root;
      this._allowHidden = false;
      this._excludedPaths = _EXCLUDED_PATHS;
      this._isInitialized = true;
    });
  }

  static Future<MediaManager> getInstance() async {
    if(instance == null){
      instance = MediaManager._internal();
    }
    while(instance == null || instance._isInitialized == false) {
      await Future.delayed(Duration(milliseconds: 20));
    }
    return instance;
  }

  /*
   * working correctly
   * Should be called first for initializing MediaModelTree
   */
  void initMediaModelTree() async {
    mediaModels = [];
    bool isStoragePermission = await _checkStoragePermissions();
    if(!isStoragePermission){
      throw Exception("Storage Permission missing");
    }

    var allFilesOrDirs;
    try {
      allFilesOrDirs = _root.listSync(recursive: true, followLinks: false);
    }catch(FileSystemException){
      debugPrint(FileSystemException.toString());
    }

    for(var dir in allFilesOrDirs){
      if(!_isMediaFile(dir)) continue;

      if(_excludedPaths == null){
        /*dont allow folders starting with '.' if allowHidden == false */
        if(_allowHidden ||
            (!_allowHidden && !dir.absolute.path.contains(RegExp(r"\.[\w]+")))
        ){
          mediaModels.add(MediaModel(file: File(p.normalize(dir.absolute.path))));
        }
      }
      else{
        for(String excludedPath in _excludedPaths) {
          if (p.isWithin(excludedPath, p.normalize(dir.path))) continue;
          /*dont allow folders starting with '.' if allowHidden == false */
          if(_allowHidden ||
              (!_allowHidden && !dir.absolute.path.contains(RegExp(r"\/\.[\w]+")))
          ){
            mediaModels.add(MediaModel(file: File(p.normalize(dir.absolute.path))));
          }
        }
      }
    }
    _isMediaModelsInitialized = true;
  }

  List<AlbumModel> fetchAlbumView() {
    if(!_isMediaModelsInitialized){
      throw Exception("MediaModels is Not initialized");
    }
    HashMap<String, int> map = HashMap<String, int>();
    List<AlbumModel> albumModels = [];
    int index = 0;
    for(MediaModel mediaModel in mediaModels){
      String key = mediaModel.parent.path;
      if(!map.containsKey(key)){
        List<MediaModel> newList = [];
        newList.add(mediaModel);
        albumModels.add(AlbumModel(name: p.basename(mediaModel.parent.path), mediaModels: newList));
        map[key] = index++;
      }
      else{
        albumModels[map[key]].mediaModels.add(mediaModel);
      }
    }
    return albumModels;
  }

  List<AlbumModel> fetchYearView(){
    if(!_isMediaModelsInitialized){
      throw Exception("MediaModels is Not initialized");
    }

    List<AlbumModel> albumModels = [];
    List<MediaModel> copy = getCopy();
    copy.sort((a,b){
      return a.timeStamp.millisecondsSinceEpoch
          .compareTo(b.timeStamp.millisecondsSinceEpoch);
    });
    HashMap<String, int> map = HashMap<String, int>();
    int index = 0;
    for(MediaModel m in copy){
      String key = m.year.toString();
      if(!map.containsKey(key)){
        List<MediaModel> newList = [];
        newList.add(m);
        albumModels.add(AlbumModel(name:key,mediaModels: newList));
        map[key] = index++;
      }
      else{
        albumModels[map[key]].mediaModels.add(m);
      }
    }
    return albumModels;
  }

  List<AlbumModel> fetchMonthView(){
    if(!_isMediaModelsInitialized){
      throw Exception("MediaModels is Not initialized");
    }
    List<AlbumModel> albumModels = [];
    List<MediaModel> copy = getCopy();
    copy.sort((a,b){
      return a.timeStamp.millisecondsSinceEpoch
          .compareTo(b.timeStamp.millisecondsSinceEpoch);
    });
    HashMap<String, int> map = HashMap<String, int>();
    int index = 0;
    for(MediaModel m in copy){
      String key = m.month.toString() +" "+ m.year.toString();
      if(p.basenameWithoutExtension(m.file.path).contains("Hulk_Face")){
        debugPrint("Hulk");
        readExifFromBytes(File(m.file.path).readAsBytesSync()).then((var tags){
          tags.forEach((k, v) {
            debugPrint(k +" => "+ v.toString());
          });
        });
      }
      if(!map.containsKey(key)){
        List<MediaModel> newList = [];
        newList.add(m);
        albumModels.add(AlbumModel(name:key,mediaModels: newList));
        map[key] = index++;
      }
      else{
        albumModels[map[key]].mediaModels.add(m);
      }
    }
    return albumModels;
  }

  /* working correctly */
  bool _isMediaFile(var fileOrDir){
    String file = p.normalize(fileOrDir.path);
    for(var extension in EXTENSIONS){
      if (p.extension(file).replaceFirst(".", "").toLowerCase() == extension.replaceFirst('.', '').toLowerCase())
        return true;
    }
    return false;
  }

  bool _isMediaDir(Directory dir){
    List childFiles = dir.listSync(recursive: false, followLinks: false);
    for(var childFileOrDir in childFiles){

      if(childFileOrDir is Directory) continue;

      String file = p.normalize(childFileOrDir.path);
      for (var extension in EXTENSIONS) {
        if ( p.extension(file).replaceFirst(".", "") != extension.replaceFirst('.', '')) continue;
        if (_allowHidden || (!_allowHidden && !file.startsWith('.'))){
          return true;
        }
      }
    }
    return false;
  }


  Future<List<Directory>> getAllMediaDirs({
    bool followLinks : false,
  }) async {

    List<Directory> mediaDirs = [];

    bool isStoragePermission = await _checkStoragePermissions();
    if(!isStoragePermission){
      throw Exception("Storage Permission missing");
    }

    var allFilesOrDirs;
    try {
      allFilesOrDirs = _root.listSync(recursive: true, followLinks: followLinks);
    }catch(FileSystemException){
      debugPrint(FileSystemException.toString());
    }

    for(var dir in allFilesOrDirs){
      if(!(dir is Directory)) continue;
      if(!_isMediaDir(dir)) continue;

      if(_excludedPaths == null){
        /*dont allow folders starting with '.' if allowHidden == false */
        if(_allowHidden ||
            (!_allowHidden && !dir.absolute.path.contains(RegExp(r"\.[\w]+")))
        ){
          mediaDirs.add(Directory(p.normalize(dir.absolute.path)));
        }
      }
      else{
        for(String excludedPath in _excludedPaths) {
          if (p.isWithin(excludedPath, p.normalize(dir.path))) continue;
          /*dont allow folders starting with '.' if allowHidden == false */
          if(_allowHidden ||
              (!_allowHidden && !dir.absolute.path.contains(RegExp(r"\.[\w]+")))
          ){
            mediaDirs.add(Directory(p.normalize(dir.absolute.path)));
          }
        }
      }
    }
    return mediaDirs;
  }

  List<MediaModel> getCopy(){
    List<MediaModel> newList = [];
    for(MediaModel m in mediaModels){
      newList.add(m.getClone());
    }
    return newList;
  }

  Future<bool> _checkStoragePermissions() async {

    PermissionStatus storagePermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    switch(storagePermission){
      case PermissionStatus.granted:
        return true;
      default:
        Map<PermissionGroup, PermissionStatus> map = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
        if(map[PermissionGroup.storage] == PermissionStatus.granted)
          return true;
    }
    return false;
  }

}