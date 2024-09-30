import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_manager/components/star_button.dart';
import 'package:image_manager/provider/image_provider.dart';
import 'package:image_manager/utils/album_data_storage.dart';
import 'package:image_manager/utils/util.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter/services.dart'; // 用于键盘事件处理
import 'package:exif/exif.dart'; // 用于提取Exif元数据

class ImagePreviewScreen extends ConsumerStatefulWidget {
  bool isAlbum;
  ImagePreviewScreen({this.isAlbum = false});

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  late PageController _pageController;
  // int _currentIndex = 0;
  Map<String, IfdTag>? _imageExifData = null;
  late List<File> images;
  // Map<int, Map<String, IfdTag>> _imageExifData = {};
  late int currentIndex;
  Set<String> isStarSet = {};

  @override
  void initState() {
    super.initState();
    // _currentIndex = widget.initialIndex;
    // 这里不能用 ref.watch，如果需要监听 Provider 的变化，也可以使用 ref.listen
    /* 查阅了一下
    避免在 initState 中使用 ref.watch：
    因为 ref.watch 是用于在 build 方法中监听 Provider 变化，并自动触发 UI 重建的。
    在 initState 中不建议使用 ref.watch，因为它不适合在非构建上下文中使用。
    */

    if (widget.isAlbum) {
      currentIndex = ref.read(currentAlbumImageIndexProvider);
      images = ref
          .read(albumListProvider)[ref.read(currentAlbumIndexProvider)]
          .images;
    } else {
      currentIndex = ref.read(currentIndexProvider);
      images = ref.read(imageProvider);
    }
    _updateExifData(currentIndex);

    _pageController = PageController(initialPage: currentIndex);
    // _loadExifData();
  }

  void _onKey(RawKeyEvent event) {
    // late List<File> images;

    // if (widget.isAlbum) {
    //   currentIndex = ref.read(currentAlbumImageIndexProvider);
    //   images = ref.read(albumListProvider)[ref.read(currentAlbumIndexProvider)].images;
    // } else {
    //   currentIndex = ref.read(currentIndexProvider);
    //   images = ref.watch(imageProvider);
    // }

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (currentIndex < images.length - 1) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentIndex > 0) {
          _pageController.previousPage(
              duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final currentIndex = ref.watch(currentIndexProvider);
    // final images = ref.watch(imageProvider);
    if (widget.isAlbum) {
      currentIndex = ref.read(currentAlbumImageIndexProvider);
      images = ref
          .read(albumListProvider)[ref.read(currentAlbumIndexProvider)]
          .images;
      isStarSet = ref.read(albumListProvider)[ref.read(currentAlbumIndexProvider)].starFileNames;
    } else {
      currentIndex = ref.read(currentIndexProvider);
      images = ref.watch(imageProvider);
    }

    final imageName = basename(images[currentIndex].path);

    print('update image ${images[currentIndex]} $isStarSet');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
                '$imageName  ${currentIndex + 1} / ${images.length}'),
            const SizedBox(
              width: 12,
            ),
            if (widget.isAlbum)
              StarButton(
                value: isStarSet.contains(imageName),
                text: '收藏',
                hoverText: '已收藏',
                onTap: () {
                  // Mark一下
                  print('收藏 ${basename(images[currentIndex].path)}');
                  
                  if (!isStarSet.contains(imageName)) {
                    isStarSet.add(imageName);
                  } else {
                    isStarSet.remove(imageName);
                  }
                  AlbumDataStorage().updateAlbumList(ref.read(albumListProvider));
                  setState(() {
                    // 触发一下收藏按钮样式更新
                    isStarSet = isStarSet;
                  });
                
                  YubiUtil.showTopMessage(context, '操作成功');
                  print('目前已收藏：${isStarSet.toList()}');
                },
              ),
            // SizedBox(width: 12,),
          ]),
          if (widget.isAlbum)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8), // 按钮的内边距
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 设置圆角半径
                  )),
              child: const Text('将该照片设为封面'),
              onPressed: () {
                // currentIndex
                print('更改封面 $currentIndex');
                final currentAlbumIndex = ref.read(currentAlbumIndexProvider);
                final albumList = ref.read(albumListProvider);
                albumList[currentAlbumIndex].coverIndex = currentIndex;
                // albumData = albumList;
                AlbumDataStorage().updateAlbumList(albumList);
                ref.read(albumListProvider.notifier).state = [...albumList];
                YubiUtil.showTopMessage(context, '成功将照片${imageName}设为封面。');
              },
            ),
        ],
      )),
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKey: _onKey,
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: Stack(
                children: [
                  PhotoViewGallery.builder(
                    itemCount: images.length,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: FileImage(images[index]),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 10,
                      );
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    backgroundDecoration: const BoxDecoration(color: Colors.black),
                    pageController: _pageController,
                    onPageChanged: (index) {
                      _updateExifData(index);
                      if (widget.isAlbum) {
                        ref
                            .read(currentAlbumImageIndexProvider.notifier)
                            .state = index;
                      } else {
                        ref.read(currentIndexProvider.notifier).state = index;
                      }
                    },
                    allowImplicitScrolling: true, // 允许隐式滚动以预加载邻近页面
                  ),
                  if (currentIndex > 0) // 左切换按钮
                    Positioned(
                      left: 20,
                      top: MediaQuery.of(context).size.height / 2 - 30,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 40),
                        onPressed: _goToPreviousImage,
                      ),
                    ),
                  if (currentIndex < images.length - 1) // 右切换按钮
                    Positioned(
                      right: 20,
                      top: MediaQuery.of(context).size.height / 2 - 30,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 40),
                        onPressed: _goToNextImage,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(16.0),
                child: (_imageExifData != null &&
                        _imageExifData is Map<String, IfdTag>)
                    ? _buildExifInfo(_imageExifData!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousImage() {
    // final currentIndex = ref.watch(currentIndexProvider);
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextImage() {
    // final currentIndex = ref.watch(currentIndexProvider);
    // final images = ref.watch(imageProvider);
    if (currentIndex < images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _updateExifData(int _currentIndex) async {
    // final images = ref.read(imageProvider);
    _imageExifData = null;
    final file = images[_currentIndex];
    final exifData = await readExifFromBytes(await file.readAsBytes());

    var data = <String, IfdTag>{};
    if (exifData != null) {
      exifData.forEach((key, value) {
        if (key != null) {
          data![key] = value; // 只添加非 null 的键值对
        }
      });
    }
    setState(() {
      _imageExifData = data;
    });
    // print('_imageExifData $_imageExifData');
  }

  // 侧边栏数据
  Widget _buildExifInfo(Map<String, IfdTag> exifData) {
    final exifList = [
      _buildExifItem('拍摄设备', exifData['Image Model']),
      _buildExifItem('拍摄时间', exifData['Image DateTime']),
      _buildExifItem('图像宽度', exifData['EXIF ExifImageWidth']),
      _buildExifItem('图像长度', exifData['EXIF ExifImageLength']),
      _buildExifItem('测光模式', exifData['EXIF MeteringMode']),
      _buildExifItem('光圈值', exifData['EXIF FNumber']), // 9/2 f/4.5
      _buildExifItem('曝光时间', exifData['EXIF ExposureTime']),
      _buildExifItem('感光度', exifData['EXIF ISOSpeedRatings']),
      _buildExifItem('焦距', exifData['EXIF FocalLength'],
          '${exifData['EXIF FocalLength']?.printable}mm'),
      _buildExifItem('曝光模式', exifData['EXIF ExposureMode']),
      _buildExifItem('白平衡', exifData['MakerNote WhiteBalance']),
      _buildExifItem('曝光偏移', exifData['EXIF ExposureBiasValue']),
      // 镜头型号 （EXIF LensModel）: YN85mm f/1.8Z DF DSM
      _buildExifItem('镜头型号', exifData['EXIF LensModel']),
      _buildExifItem('图像质量', exifData['MakerNote Quality']),
      _buildExifItem('对焦模式', exifData['MakerNote FocusMode']),
      _buildExifItem('色彩空间', exifData['EXIF ColorSpace']),
      // 作者 Image Artist
      // _buildExifItem('作者', exifData['Image Artist']),
    ];
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // 设置网格项的最小宽度
          crossAxisSpacing: 8.0, // 网格项之间的水平间距
          mainAxisSpacing: 8.0, // 网格项之间的垂直间距
          childAspectRatio: 1.5),
      itemCount: exifList.length, // 网格项的数量
      itemBuilder: (context, index) {
        return exifList[index];
      },
    );
  }

  Widget _buildExifItem(String label, IfdTag? tag, [String? str]) {
    return ListTile(
      minTileHeight: 20,
      title: Text(label),
      subtitle: Text((str ?? tag?.printable) ?? '无信息'),
    );
  }
}
