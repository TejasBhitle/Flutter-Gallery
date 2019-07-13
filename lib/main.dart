import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'BottomTabBar.dart';
import 'galleryView.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    GalleryView galleryView = GalleryView(
      mode: GalleryViewMode.ALBUMS,
    );
    BottomTabBar bottomTabBar = BottomTabBar(
      initialSelectedIndex: 3,
      tabItems: [
        BottomTabItem(
          title: "Years",
          onTap: (){
            setState(() {
              galleryView.galleryViewMode = GalleryViewMode.YEARS;
            });
          }),
        BottomTabItem(
          title: "Months",
          onTap: (){
            setState(() {
              galleryView.galleryViewMode = GalleryViewMode.MONTHS;
            });
          }),
        BottomTabItem(
          title: "Days",
          onTap: (){
            setState(() {
              galleryView.galleryViewMode = GalleryViewMode.DAYS;
            });
          }),
        BottomTabItem(
          title: "Albums",
          onTap: (){
            setState(() {
              galleryView.galleryViewMode = GalleryViewMode.ALBUMS;
            });
          }),
      ],
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          galleryView,
          bottomTabBar,
          _buildAppBar(context),
        ],
      ),
    );

  }
}

Widget _buildAppBar(BuildContext context){
  return PreferredSize(
    preferredSize: Size.fromHeight(60.0),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 25.0, 12.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
              color: Colors.lightBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 4.0,
                )
              ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  showModalBottomSheet<Null>(
                    context: context,
                    builder: (BuildContext context) => _buildBottomDrawer(),
                  );
                },
              ),
              Text(
                'Gallery',
                style: TextStyle(fontSize: 20.0,color: Colors.white,fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {

                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildBottomDrawer(){
  return Drawer(
    child: Column(
      children: const <Widget>[
        //Add menu item to edit
        const ListTile(
          leading: const Icon(Icons.mode_edit),
          title: const Text('Menu Item 1'),
        ),
        const ListTile(
          //Add menu item to add a new item
          leading: const Icon(Icons.add),
          title: const Text('Menu Item 2'),
        ),
      ],
    ),
  );
}

