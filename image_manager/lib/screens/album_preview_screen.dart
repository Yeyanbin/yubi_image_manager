
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_manager/provider/setting_provider.dart';
import 'package:image_manager/views/image_grid_view.dart';
import 'package:image_manager/screens/image_preview_screen.dart';
import 'package:image_manager/views/phote_album_view.dart';
import 'package:path/path.dart';

import '../provider/image_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AlbumPreviewScreen extends ConsumerStatefulWidget {
  AlbumPreviewScreen({
    super.key,
  });

  @override
  _AlbumPreviewScreenState createState() => _AlbumPreviewScreenState();
}

class _AlbumPreviewScreenState extends ConsumerState<AlbumPreviewScreen> {
  _AlbumPreviewScreenState();

  // List<File> _images = [];
  // List<String> _selectedFolderPaths = [];

  void _openImagePreview(int initialIndex, context) {
    ref.read(currentAlbumImageIndexProvider.notifier).state = initialIndex;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(isAlbum: true,),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    final albumItem = ref.watch(albumListProvider)[ref.watch(currentAlbumIndexProvider)];
    final images = albumItem.images;
    final gridImageNumOption = ref.watch(settingDataProvider).settingData.gridImageNumOption;

    return 
      Scaffold(
      appBar: AppBar(
        title: Text(albumItem.name),
      ),
      body:
        GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridImageNumOption.count,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openImagePreview(index, context),
              child: Stack(
            alignment: Alignment.topRight, // 将图标对齐到右上角
            children: [
              Image.file(images[index], 
              height: double.maxFinite,
              width: double.maxFinite,
              fit: BoxFit.cover),
              if (albumItem.starFileNames.contains(basename(images[index].path)))
                const Positioned(
                  top: 8, // 设置图标的边距
                  right: 8,
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.yellow, // 设置图标颜色
                    size: 24, // 设置图标大小
                  ),
                ),
            ],
          ),
            );
          },
        )
      );
  }
}