import 'package:flutter/material.dart';

class BottomTabItem {
  String _title;
  VoidCallback _onTap;

  BottomTabItem({ @required String title, @required onTap,}){
    this._title = title;
    this._onTap = onTap;
  }

}

class BottomTabBar extends StatefulWidget {

  List<BottomTabItem> _tabItems;
  int _selectedIndex;

  BottomTabBar({
    @required List<BottomTabItem> tabItems,
    int initialSelectedIndex = 0,
  }){
    this._tabItems = tabItems;
    this._selectedIndex = initialSelectedIndex;
  }


  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {

  int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget._selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        height: 40.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildTabButtons(),
              ),
            ),
          ),
      ),
    );
  }

  List<Widget> _buildTabButtons(){
    List<TabButton> _tabButtons = [];
    int index = 0;
    for(var item in widget._tabItems){
      _tabButtons.add(
          TabButton(
            name: item._title,
            index: index,
            color: getTabColor(index),
            onTabPressed: (index){
              //debugPrint("tapped "+ index);
              item._onTap();
              onTabIndexChanged(index);
            },
          )
      );
      index++;
    }
    return _tabButtons;
  }

  onTabIndexChanged(int index){
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Color getTabColor(int index){
    if(index == _selectedTabIndex) return Colors.blue;
    return Colors.lightBlue;
  }

}

class TabButton extends StatelessWidget {

  @required final int index;
  @required final String name;
  @required final Function onTabPressed;
  @required final Color color;

  TabButton({
    this.name,
    this.index,
    this.onTabPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
          name,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          )
      ),
      color: color,
      onPressed: (){
        onTabPressed(index);
      },
    );
  }
}

