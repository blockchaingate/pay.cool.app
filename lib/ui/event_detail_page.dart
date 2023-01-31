import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'states.dart';

class EventDetail extends StatefulWidget {
  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  String _selectedNode;
  List<Node> _nodes;
  TreeViewController _treeViewController;
  bool docsOpen = true;
  bool deepExpanded = true;
  final Map<ExpanderPosition, Widget> expansionPositionOptions = const {
    ExpanderPosition.start: Text('Start'),
    ExpanderPosition.end: Text('End'),
  };
  final Map<ExpanderType, Widget> expansionTypeOptions = const {
    ExpanderType.caret: Icon(
      Icons.arrow_drop_down,
      size: 28,
    ),
    ExpanderType.arrow: Icon(Icons.arrow_downward),
    ExpanderType.chevron: Icon(Icons.expand_more),
    ExpanderType.plusMinus: Icon(Icons.add),
  };
  final Map<ExpanderModifier, Widget> expansionModifierOptions = const {
    ExpanderModifier.none: ModContainer(ExpanderModifier.none),
    ExpanderModifier.circleFilled: ModContainer(ExpanderModifier.circleFilled),
    ExpanderModifier.circleOutlined:
        ModContainer(ExpanderModifier.circleOutlined),
    ExpanderModifier.squareFilled: ModContainer(ExpanderModifier.squareFilled),
    ExpanderModifier.squareOutlined:
        ModContainer(ExpanderModifier.squareOutlined),
  };
  final ExpanderPosition _expanderPosition = ExpanderPosition.start;
  final ExpanderType _expanderType = ExpanderType.caret;
  final ExpanderModifier _expanderModifier = ExpanderModifier.none;
  final bool _allowParentSelect = false;
  final bool _supportParentDoubleTap = false;

  @override
  void initState() {
    _nodes = [];
    _treeViewController = TreeViewController(
      selectedKey: _selectedNode,
      children: _nodes,
    );
    _treeViewController = _treeViewController.loadJSON(json: US_STATES_JSON);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TreeViewTheme _treeViewTheme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
          type: _expanderType,
          modifier: _expanderModifier,
          position: _expanderPosition,
          size: 20,
          color: Colors.blue),
      labelStyle: const TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w800,
        color: Colors.blue.shade700,
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: Theme.of(context).colorScheme,
    );
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xff333333)),
          backgroundColor: const Color(0xfff0f3f6),
          elevation: 0,
          title: const Text("活动收益",
              style: TextStyle(color: Color(0xff333333), fontSize: 18))),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xfff0f3f6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: const Text("我的资料",
                    style: TextStyle(color: Color(0xff776666), fontSize: 18))),
            const SizedBox(
              height: 20,
            ),
            Material(
                borderRadius: BorderRadius.circular(10),
                elevation: 5,
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            SizedBox(
                                width: 40,
                                child: FaIcon(FontAwesomeIcons.coins,
                                    color: Colors.blue)),
                            Text("我的投资额：\$2000",
                                style: TextStyle(
                                    color: Color(0xff333333), fontSize: 18)),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: const [
                            SizedBox(
                                width: 40,
                                child: FaIcon(FontAwesomeIcons.userAlt,
                                    color: Color(0xFF88dd77))),
                            Text("我的下线人数：356",
                                style: TextStyle(
                                    color: Color(0xff333333), fontSize: 18)),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: const [
                            SizedBox(
                                width: 40,
                                child: FaIcon(FontAwesomeIcons.moneyBill,
                                    color: Colors.green)),
                            Text("我的投资收益：\$6,000,498.99",
                                style: TextStyle(
                                    color: Color(0xff333333), fontSize: 18)),
                          ],
                        ),
                      ],
                    ))),
            const SizedBox(
              height: 30,
            ),
            Container(
                child: const Text("我的下线",
                    style: TextStyle(color: Color(0xff776666), fontSize: 18))),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 5,
                  child: SizedBox(
                    // padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: TreeView(
                              controller: _treeViewController,
                              allowParentSelect: _allowParentSelect,
                              supportParentDoubleTap: _supportParentDoubleTap,
                              onExpansionChanged: (key, expanded) =>
                                  _expandNode(key, expanded),
                              onNodeTap: (key) {
                                debugPrint('Selected: $key');
                                setState(() {
                                  _selectedNode = key;
                                  _treeViewController = _treeViewController
                                      .copyWith(selectedKey: key);
                                });
                              },
                              theme: _treeViewTheme,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            debugPrint('Close Keyboard');
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 20),
                            alignment: Alignment.center,
                            child: Text(
                                _treeViewController.getNode(_selectedNode) ==
                                        null
                                    ? ''
                                    : _treeViewController
                                        .getNode(_selectedNode)
                                        .label),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _expandNode(String key, bool expanded) {
    String msg = '${expanded ? "Expanded" : "Collapsed"}: $key';
    debugPrint(msg.toString());
    Node node = _treeViewController.getNode(key);
    if (node != null) {
      List<Node> updated;
      if (key == 'docs') {
        updated = _treeViewController.updateNode(
          key,
          node.copyWith(
              expanded: expanded,
              icon: IconData(
                expanded ? Icons.folder_open.codePoint : Icons.folder.codePoint,
                //  color: expanded ? "blue600" : "grey700",
              )),
        );
      } else {
        updated = _treeViewController.updateNode(
            key,
            node.copyWith(
              expanded: expanded,
            ));
        // ,
        // node.copyWith(
        //     expanded: expanded,
        //     icon: NodeIcon(
        //         codePoint: Icons.person.codePoint, color: "blue600")));
      }
      setState(() {
        if (key == 'docs') docsOpen = expanded;
        _treeViewController = _treeViewController.copyWith(children: updated);
      });
    }
  }
}

class ModContainer extends StatelessWidget {
  final ExpanderModifier modifier;

  const ModContainer(this.modifier, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _borderWidth = 0;
    BoxShape _shapeBorder = BoxShape.rectangle;
    Color _backColor = Colors.transparent;
    Color _backAltColor = Colors.grey.shade700;
    switch (modifier) {
      case ExpanderModifier.none:
        break;
      case ExpanderModifier.circleFilled:
        _shapeBorder = BoxShape.circle;
        _backColor = _backAltColor;
        break;
      case ExpanderModifier.circleOutlined:
        _borderWidth = 1;
        _shapeBorder = BoxShape.circle;
        break;
      case ExpanderModifier.squareFilled:
        _backColor = _backAltColor;
        break;
      case ExpanderModifier.squareOutlined:
        _borderWidth = 1;
        break;
    }
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: _shapeBorder,
            border: _borderWidth == 0
                ? null
                : Border.all(
                    width: _borderWidth,
                    color: _backAltColor,
                  ),
            color: _backColor,
          ),
          width: 15,
          height: 15,
        ),
        const Icon(
          Icons.verified_user,
          size: 14,
        )
      ],
    );
  }
}
