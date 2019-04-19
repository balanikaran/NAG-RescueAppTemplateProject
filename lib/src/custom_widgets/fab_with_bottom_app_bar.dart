import 'package:flutter/material.dart';

class FabWithBottomAppBarItem {
  FabWithBottomAppBarItem({this.iconData, this.text});
  IconData iconData;
  String text;
}

class FabWithBottomAppBar extends StatefulWidget {
  FabWithBottomAppBar({
    this.items,
    this.centerItemText,
    this.height,
    this.iconSize,
    this.backgroundColor,
    this.color,
    this.notchedShape,
    this.onTabSelected,
    this.selectedColor,
  }) {
    assert(this.items.length == 2 || this.items.length <= 4);
  }

  final List<FabWithBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  @override
  _FabWithBottomAppBarState createState() => _FabWithBottomAppBarState();
}

class _FabWithBottomAppBarState extends State<FabWithBottomAppBar> {
  int _selectedIndex = 0;
  _updateIndex(int selectedIndex) {
    widget.onTabSelected(selectedIndex);
    setState(() {
      _selectedIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
          item: widget.items[index], index: index, onPressed: _updateIndex);
    });

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildTabItem(
      {FabWithBottomAppBarItem item, int index, ValueChanged<int> onPressed}) {
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  item.iconData,
                  color: color,
                  size: widget.iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
