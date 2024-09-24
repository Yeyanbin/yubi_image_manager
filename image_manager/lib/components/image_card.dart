import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_manager/views/album_form_dialog_view.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('图片卡片示例'),
//         ),
//         body: Center(
//           child: ImageCard(
//             imageUrl: 'https://via.placeholder.com/300', // 替换为你实际的图片 URL
//             title: '图片标题',
//             description: '这是图片的描述内容。',
//             onTap: () {
//               // 点击事件处理逻辑
//               print('卡片被点击');
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

class ImageCard extends StatefulWidget {
  final File imageFile;
  final String title;
  final String description;
  final VoidCallback onTap; // 点击事件的回调函数
  final Function showModifyFormDialog;

  ImageCard({
    required this.imageFile,
    required this.title,
    required this.description,
    required this.onTap,
    required this.showModifyFormDialog
  });
  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool _isHovering = false;

  void _updateHoverState(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // 绑定点击事件
      child: MouseRegion(
          // 鼠标相关逻辑
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _updateHoverState(true),
          onExit: (_) => _updateHoverState(false),
          child: Card(
            elevation: _isHovering ? 8.0 : 4.0, // 设置卡片的阴影
            color: _isHovering ? Colors.grey[200] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // 设置卡片的圆角
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2, // 使用2份比例
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)), // 图片顶部圆角
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover, // 填充整个区域
                      height: 150, // 图片高度
                      width: double.infinity, // 宽度占满
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // 剩余的比例
                  child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8), // 标题和描述之间的间距
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          if(_isHovering)
                            IconButton(onPressed: () => widget.showModifyFormDialog(), iconSize: 24, icon: const Icon(Icons.mode))
                        ],
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
