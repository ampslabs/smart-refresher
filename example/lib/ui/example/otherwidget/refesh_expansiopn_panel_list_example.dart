/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-01 20:48
 */

import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class RefreshExpansionPanelList extends StatefulWidget {
  const RefreshExpansionPanelList({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RefreshExpansionPanelListState();
  }
}

class RefreshExpansionPanelListState extends State<RefreshExpansionPanelList> {
  final List<Item> _data = generateItems(10);
  final RefreshController _controller = RefreshController();
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      enablePullUp: true,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[_buildPanel()],
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        if (mounted) {
          setState(() {
            _data[index].isExpanded = !isExpanded;
          });
        }
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
              title: Text(item.headerValue),
              subtitle: Text('To delete this panel, tap the trash can icon'),
              trailing: Icon(Icons.delete),
              onTap: () {
                if (mounted) {
                  setState(() {
                    _data.removeWhere((currentItem) => item == currentItem);
                  });
                }
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

// stores ExpansionPanel state information
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}
