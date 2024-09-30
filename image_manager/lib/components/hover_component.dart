import 'package:flutter/material.dart';


class HoverComponent extends StatefulWidget {
  // 接收传入的历史路径列表
  final Widget hoverComponent;
  final Widget content;
  final double width;
  final double componentWidth;

  HoverComponent({
    required this.componentWidth,
    required this.width,
    required this.hoverComponent,
    required this.content
  });

  _HoverComponentState createState() => _HoverComponentState();
}

class _HoverComponentState extends State<HoverComponent>{
  bool hover = false;

  void updateHoverState(bool isHovering) {
    setState(() {
      hover = isHovering;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // 鼠标相关逻辑
      cursor: SystemMouseCursors.click,
      onEnter: (_) => updateHoverState(true),
      onExit: (_) => updateHoverState(false),
      child: AbsorbPointer(
        absorbing: false,
        child:  Row(
                children: [
                  Container(
                    width: !hover ? widget.width : widget.width - widget.componentWidth,
                    child: widget.content,
                  ),
                  if (hover) 
                    Container(
                      width: widget.componentWidth,
                      child: widget.hoverComponent
                    )
                ],
              ),
      ),
    );
  }

}
