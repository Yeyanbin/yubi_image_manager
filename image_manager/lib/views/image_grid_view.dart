import 'dart:io';
import 'package:flutter/material.dart';

class ImageGridView extends StatelessWidget {
  final Function openImagePreview;
  final List<File> images;
  final Function() clearFolders;
  final int gridAxisCount;
  final List<File> thumbImages;

  const ImageGridView({
    super.key,
    required this.gridAxisCount,
    required this.openImagePreview,
    required this.images,
    required this.thumbImages,
    required this.clearFolders,
  });

  File getImage(int index) {
    if (thumbImages.length > index) {
      return thumbImages[index];
    } else {
      return images[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => openImagePreview(index, context),
              child: Image.file(getImage(index), fit: BoxFit.cover),
            );
          },
        ),
        Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white60, // 设置背景颜色
                shape: BoxShape.circle, // 使背景为圆形
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_forever),
                // color: Colors.white,
                // disabledColor: Colors.white,
                // hoverColor: Colors.white,
                // splashColor: Colors.white,
                onPressed: clearFolders,
                tooltip: '清除选中的文件夹',
              ),
            ))
      ],
    );
  }
}
