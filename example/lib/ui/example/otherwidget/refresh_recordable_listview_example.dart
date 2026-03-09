/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-01 22:44
 */

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/other/refresh_recordable_listview.dart';
import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

enum _ReorderableListType {
  /// A list tile that contains a [CircleAvatar].
  horizontalAvatar,

  /// A list tile that contains a [CircleAvatar].
  verticalAvatar,

  /// A list tile that contains three lines of text and a checkbox.
  threeLine,
}

class ReorderableListDemo extends StatefulWidget {
  const ReorderableListDemo({super.key});

  static const String routeName = '/material/reorderable-list';

  @override
  _ListDemoState createState() => _ListDemoState();
}

class _ListItem {
  _ListItem(this.value, this.checkState);

  final String value;

  bool checkState;
}

class _ListDemoState extends State<ReorderableListDemo> {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _bottomSheet;
  final RefreshController _refreshController = RefreshController();
  _ReorderableListType _itemType = _ReorderableListType.threeLine;
  bool _reverse = false;
  bool _reverseSort = false;
  final List<_ListItem> _items = <String>[
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
  ].map<_ListItem>((String item) => _ListItem(item, false)).toList();

  void changeItemType(_ReorderableListType type) {
    if (mounted) {
      setState(() {
        _itemType = type;
      });
    }
    // Close the bottom sheet to give the user a clear view of the list.
    _bottomSheet?.close();
  }

  void changeReverse(bool newValue) {
    if (mounted) {
      setState(() {
        _reverse = newValue;
      });
    }
    // Close the bottom sheet to give the user a clear view of the list.
    _bottomSheet?.close();
  }

  void _showConfigurationSheet() {
    if (mounted) {
      setState(() {
        _bottomSheet = scaffoldKey.currentState
            ?.showBottomSheet((BuildContext bottomSheetContext) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black26)),
            ),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              children: <Widget>[
                CheckboxListTile(
                  dense: true,
                  title: const Text('Reverse'),
                  value: _reverse,
                  onChanged: (val) => changeReverse(val ?? false),
                ),
                RadioListTile<_ReorderableListType>(
                  dense: true,
                  title: const Text('Horizontal Avatars'),
                  value: _ReorderableListType.horizontalAvatar,
                  groupValue: _itemType,
                  onChanged: (val) => val != null ? changeItemType(val) : null,
                ),
                RadioListTile<_ReorderableListType>(
                  dense: true,
                  title: const Text('Vertical Avatars'),
                  value: _ReorderableListType.verticalAvatar,
                  groupValue: _itemType,
                  onChanged: (val) => val != null ? changeItemType(val) : null,
                ),
                RadioListTile<_ReorderableListType>(
                  dense: true,
                  title: const Text('Three-line'),
                  value: _ReorderableListType.threeLine,
                  groupValue: _itemType,
                  onChanged: (val) => val != null ? changeItemType(val) : null,
                ),
              ],
            ),
          );
        });

        // Garbage collect the bottom sheet when it closes.
        _bottomSheet?.closed.whenComplete(() {
          if (mounted) {
            setState(() {
              _bottomSheet = null;
            });
          }
        });
      });
    }
  }

  Widget buildListTile(_ListItem item) {
    const Widget secondary = Text(
      'Even more additional list item information appears on line three.',
    );
    Widget listTile;
    switch (_itemType) {
      case _ReorderableListType.threeLine:
        listTile = CheckboxListTile(
          key: Key(item.value),
          isThreeLine: true,
          value: item.checkState,
          onChanged: (bool? newValue) {
            if (mounted) {
              setState(() {
                item.checkState = newValue ?? false;
              });
            }
          },
          title: Text('This item represents ${item.value}.'),
          subtitle: secondary,
          secondary: const Icon(Icons.drag_handle),
        );
        break;
      case _ReorderableListType.horizontalAvatar:
      case _ReorderableListType.verticalAvatar:
        listTile = SizedBox(
          key: Key(item.value),
          height: 100.0,
          width: 100.0,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(item.value),
          ),
        );
        break;
    }

    return listTile;
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (mounted) {
      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final _ListItem item = _items.removeAt(oldIndex);
        _items.insert(newIndex, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Reorderable list'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: 'Sort',
            onPressed: () {
              if (mounted) {
                setState(() {
                  _reverseSort = !_reverseSort;
                  _items.sort((_ListItem a, _ListItem b) => _reverseSort
                      ? b.value.compareTo(a.value)
                      : a.value.compareTo(b.value));
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.more_horiz
                  : Icons.more_vert,
            ),
            tooltip: 'Show menu',
            onPressed: null,
          ),
        ],
      ),
      body: Scrollbar(
        child: RefreshReorderableListView(
          header: _itemType != _ReorderableListType.threeLine
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Header of the list',
                      style: Theme.of(context).textTheme.displayLarge))
              : const SizedBox.shrink(),
          onReorder: _onReorder,
          reverse: _reverse,
          scrollDirection: _itemType == _ReorderableListType.horizontalAvatar
              ? Axis.horizontal
              : Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          refreshController: _refreshController,
          children: _items.map<Widget>(buildListTile).toList(),
        ),
      ),
    );
  }
}
