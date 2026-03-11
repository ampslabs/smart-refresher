/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-11 5:55 PM
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';
import '../../../other/expanded_viewport.dart';

/*
   Implements a chat list with load-more functionality, similar to the loading effect in QQ.
   The biggest challenge with a chat list is pushing it to the top when it doesn't fill the screen.
   Currently, Flutter doesn't provide a sliver that can occupy remaining space like Expanded; SliverFillRemaining doesn't work here.
   ExpandedViewport is a custom Viewport used to solve the issue of a reverse ListView staying at the top when the screen isn't full.
   The principle is to detect the layout situation in the first pass, and if it's not full, adjust the main axis offset for all slivers after SliverExpanded in the second pass.
 */
class QQChatList extends StatefulWidget {
  const QQChatList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _QQChatListState();
  }
}

const String myUrl =
    "https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4";

class _QQChatListState extends State<QQChatList> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  List<_MessageItem> data = [
    const _MessageItem(
      content: "Hello...................asdasdasdasdasdasdasdasdasda",
      isMe: true,
      author: "Me",
      url: myUrl,
    ),
    const _MessageItem(
      content:
          "eem.....................................................................",
      isMe: false,
      author: "Friend",
      url:
          "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1718395925,3485808025&fm=27&gp=0.jpg",
    ),
    const _MessageItem(
      content: "Have you eaten yet?????????????",
      isMe: false,
      author: "Friend",
      url:
          "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1718395925,3485808025&fm=27&gp=0.jpg",
    )
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: RefreshConfiguration.copyAncestor(
        context: context,
        shouldFooterFollowWhenNotFull: (mode) {
          return true;
        },
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text("Chat Demo"),
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
                size: 20,
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            trailing: const Icon(
              Icons.group,
              color: Colors.grey,
              size: 24,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: false,
                    onLoading: () async {
                      await Future.delayed(const Duration(milliseconds: 1000));
                      data.add(const _MessageItem(
                        content: "Load history data...",
                        isMe: true,
                        author: "Me",
                        url: myUrl,
                      ));
                      data.add(const _MessageItem(
                        content: "...........",
                        isMe: false,
                        author: "Friend",
                        url:
                            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1718395925,3485808025&fm=27&gp=0.jpg",
                      ));
                      data.add(const _MessageItem(
                          content: "Old message content",
                          isMe: false,
                          author: "Friend",
                          url:
                              "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1718395925,3485808025&fm=27&gp=0.jpg"));
                      setState(() {});
                      _refreshController.loadComplete();
                    },
                    footer: CustomFooter(
                      loadStyle: LoadStyle.ShowAlways,
                      builder: (context, mode) {
                        if (mode == LoadStatus.loading) {
                          return const SizedBox(
                            height: 60.0,
                            child: Center(
                              child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    enablePullUp: true,
                    controller: _refreshController,
                    child: Scrollable(
                      controller: _scrollController,
                      axisDirection: AxisDirection.up,
                      viewportBuilder: (context, offset) {
                        return ExpandedViewport(
                          offset: offset as ScrollPosition,
                          center: null,
                          axisDirection: AxisDirection.up,
                          slivers: <Widget>[
                            SliverExpanded(),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (c, i) => data[i],
                                  childCount: data.length),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 56.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          child: CupertinoTextField(
                            controller: _textController,
                            placeholder: "Enter your message",
                            onSubmitted: (s) {
                              data.insert(
                                  0,
                                  _MessageItem(
                                    content: s,
                                    author: "Me",
                                    url: myUrl,
                                    isMe: true,
                                  ));
                              setState(() {});
                              _scrollController.jumpTo(0.0);
                              _textController.clear();
                            },
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent),
                        onPressed: () {
                          _scrollController.jumpTo(0.0);
                          data.insert(
                              0,
                              _MessageItem(
                                content: _textController.text,
                                author: "Me",
                                url: myUrl,
                                isMe: true,
                              ));
                          setState(() {});
                          _textController.clear();
                        },
                        child: const Text("Send"),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String content;
  final String author;
  final bool isMe;
  final String url;

  const _MessageItem(
      {required this.content,
      required this.author,
      required this.isMe,
      required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 20.0,
          ),
          Container(width: 15.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 25.0,
                width: 222.0,
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                child: Text(
                  author,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 100.0,
                  minHeight: 100.0,
                  maxWidth: 222.0,
                ),
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  content,
                  style: const TextStyle(color: Colors.black),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
