import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'mediaManager.dart';
import 'CacheMe.dart';

enum GalleryViewMode {
  YEARS, MONTHS, DAYS, ALBUMS
}

class GalleryView extends StatefulWidget {

  GalleryViewMode _mode;

  GalleryView({ GalleryViewMode mode ,}) {
    this._mode = mode;
  }

  set galleryViewMode(GalleryViewMode mode) => this._mode = mode;

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {

  List<AlbumModel> albumViewModels = [];
  List<AlbumModel> yearViewModels = [];
  List<AlbumModel> monthViewModels = [];
  MediaManager mediaManager;

  @override
  void initState() {
    super.initState();
    _loadImageFiles();
  }

  @override
  void didUpdateWidget(GalleryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget._mode = oldWidget._mode;
  }


  @override
  Widget build(BuildContext context) {
    if(mediaManager == null)
      return Center(
        child: CircularProgressIndicator(),
      );

    switch(widget._mode){
      case GalleryViewMode.ALBUMS:
        albumViewModels = mediaManager.fetchAlbumView();
        return _buildAlbumView();
        break;
      case GalleryViewMode.YEARS:
        yearViewModels = mediaManager.fetchYearView();
        return _buildYearView();
        break;
      case GalleryViewMode.MONTHS:
        monthViewModels = mediaManager.fetchMonthView();
        return _buildMonthView();
        break;
      case GalleryViewMode.DAYS:
        return _buildDayView();
        break;
    }
    return Container();
  }

  Widget _buildAlbumViewData(String name){
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
          ),
          padding: EdgeInsets.all(5),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0
              ),
            ),
          ),
      ),
    );
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

  void _loadImageFiles() async {
    bool isStoragePermission = await _checkStoragePermissions();
    if(!isStoragePermission){
      return null;
    }
    mediaManager = await MediaManager.getInstance();
    await mediaManager.initMediaModelTree();
    setState(() {});
  }

  Widget _buildAlbumView(){
    return GridView.count(
        crossAxisCount: 3,
        children: List<Widget>.generate(albumViewModels.length, (index) {
          return GridTile(
            child: Card(
              child: Stack(
                children: <Widget>[
                  CacheMe2.getInstance().ImageView(
                    albumViewModels[index].mediaModels[0].file.path,
                  ),
                  _buildAlbumViewData(albumViewModels[index].name),
                ],
              ),
            ),
          );
    }),
    );
  }

  Widget _buildYearView(){
    return GridView.count(
        crossAxisCount: 3,
        children: List<Widget>.generate(yearViewModels.length, (index) {
      return GridTile(
        child: Card(
          child: Center(child: Text(yearViewModels[index].name)),
        ),
      );
    }),
    );
  }

  Widget _buildMonthView(){
    return GridView.count(
        crossAxisCount: 3,
        children: List<Widget>.generate(monthViewModels.length, (index) {
      return GridTile(
        child: Card(
          child: Center(child: Text(monthViewModels[index].name)),
        ),
      );
    }),
    );
  }

  Widget _buildDayView(){
    return Center(
      child: Text("Day"),
    );
  }

}
