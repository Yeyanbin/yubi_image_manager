

import 'package:flutter/material.dart';

class StarButton extends StatefulWidget {

  bool value;
  double size;
  String text;
  String hoverText;
  Function onTap;

  StarButton({
    this.value = false,
    this.size = 16,
    required this.text,
    required this.hoverText,
    required this.onTap
  });

  _StarButtonState createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }
  
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _value = widget.value;
  // }
  

  Widget build(BuildContext context) {

    return  IntrinsicWidth(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8), // 按钮的内边距
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // 设置圆角半径
                          )),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            widget.value ? Icons.star : Icons.star_border,
                            size: widget.size,
                          ),
                          SizedBox(width: 8),
                          Text(!widget.value ? widget.text: widget.hoverText),
                          SizedBox(width: 8),
                        ],
                      ),
                      onPressed: () {
                        // setState(() {
                        //   _value = !_value;
                        // });
                        widget.onTap();
                      },
                    ),
                  );

  }
}