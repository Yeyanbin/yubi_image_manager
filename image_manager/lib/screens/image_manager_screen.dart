import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_manager/components/history_list_card.dart';
import 'package:image_manager/components/progress_dialog.dart';
import 'package:image_manager/provider/setting_provider.dart';
import 'package:image_manager/views/setting_view.dart';
import 'package:image_manager/utils/album_data_storage.dart';
import 'package:image_manager/utils/util.dart';
import 'package:image_manager/views/image_grid_view.dart';
import 'package:image_manager/screens/image_preview_screen.dart';
import 'package:image_manager/views/phote_album_view.dart';
import 'package:path/path.dart';

import '../provider/image_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
- StatefulWidget:
  - 是 Flutter 中最常用的有状态 Widget，允许在其内部维护和管理局部状态。
  - 使用 State 类来定义其状态逻辑和 UI 的重建。
  - 适合需要管理局部状态的组件，但本身不具备与任何外部状态管理库（如 Riverpod、Provider 等）的直接集成能力。

- ConsumerStatefulWidget:
  - 是 Riverpod 提供的一个扩展 StatefulWidget 的 Widget，它集成了 Riverpod 的状态管理能力。
  - 使用 ConsumerState 来定义其状态逻辑，ConsumerState 内部拥有对 WidgetRef 的直接访问，使得访问和操作 Riverpod 的 Providers 非常便捷。
  - 适合需要既管理局部状态，又需要与 Riverpod 集成的场景。
*/

class ImageManagerScreen extends ConsumerStatefulWidget /* StatefulWidget */ {
  const ImageManagerScreen({super.key});

  @override
  _ImageManagerScreenState createState() => _ImageManagerScreenState();
}

class _ImageManagerScreenState extends ConsumerState {
  // List<File> _images = [];
  // List<String> _selectedFolderPaths = [];
final ProgressController _progressController = ProgressController();

  @override
  void initState() {
    super.initState();
    // ref.read(settingDataProvider.notifier).fetchDataAsync();
  }

  Future<void> _pickFolder(context) async {
    // 打开文件夹选择对话框
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    var selectedFolderPaths = ref.watch(selectedFolderPathsProvider);
    final historyList = ref.watch(settingDataProvider).settingData.historyList;

    if (selectedDirectory != null &&
        !selectedFolderPaths.contains(selectedDirectory)) {

      print('historyList: $historyList, selectedDirectory: $selectedDirectory');

      if (!historyList.contains(selectedDirectory)) {
        print('新文件夹 $selectedDirectory, 记录一下');
        ref.read(settingDataProvider.notifier).updateSettingData(
          historyList: [...historyList, selectedDirectory],
        );
      }

      YubiUtil.requestPhotoLibraryPermission(
        () {
          print('请求权限成功？');
          _loadImagesFromFolder(selectedDirectory, context);
        },
        () {
          // 拒绝
        }
      );
    }
  }
  
  void _loadImagesFromFolder(String folderPath, context) {
    ref
      .read(selectedFolderPathsProvider.notifier)
      .state = folderPath;

    final picturesFolder = Directory(folderPath);

    if (picturesFolder.existsSync()) {
      // 创建一个空的图片文件列表
      List<File> imageFiles = [];

      // 递归获取所有图片文件
      _getImagesRecursively(picturesFolder, imageFiles);

      // 按文件名排序
      // imageFiles.sort((fileA, fileB) =>
      //     basename(fileA.path).compareTo(basename(fileB.path)));

      // 按拍摄时间排序
      imageFiles.sort((fileA, fileB) => fileA.statSync().modified.compareTo(fileB.statSync().modified));

      // 生成缓存文件
      showDialog(
        context: context,
        builder: (context) {
          return ProgressDialog(
            updateProgreeController: _progressController,
            initCallBack: () async {
              final thumbImageFiles = await YubiUtil.getThumbImages(
                _progressController,
                imageFiles,
                folderPath
              );

              // 正确触发状态更新：直接设置新列表
              ref.read(imageProvider.notifier).state = [
                ...imageFiles
              ];
              final thumbImageMap = Map<String, File>();
              thumbImageFiles.forEach((item) {
                thumbImageMap[basename(item.path)] = item;
              });

              ref.read(imageThumbProvider.notifier).state = thumbImageFiles;
              ref.read(imageThumbMapProvider.notifier).state = thumbImageMap;
            },
            closeBtnText: '关闭',
          );
        },
      );

      AlbumDataStorage().readJsonStorage(folderPath).then((resp) {
        print('resp: $resp');
        // 加载持久化文件成功

        final albumData = resp.albumListByJson.map((item) {
          // 转化一下
          List<File> filteredFiles = getFilesWithinTimeRange(
            imageFiles, 
            item.startDate.toDateTime(), 
            item.endDate.toDateTime()
          );
          
          return item.toAlbumItem(filteredFiles);
        }).toList();

        ref.read(albumListProvider.notifier).state = albumData;
      });

      print('图片数量: ${imageFiles.length}');
    } else {
      print("文件夹不存在: $folderPath");
    }
  }

// 递归获取文件夹中的所有图片文件
  void _getImagesRecursively(Directory directory, List<File> imageFiles) {
    // 遍历文件夹中的所有文件和子文件夹
    for (var entity in directory.listSync(recursive: false)) {
      try {
        // 检查文件类型，如果是文件并且是图片，则加入列表
        if (entity is File && _isImageFile(entity.path)) {
          // 如果是图片文件，添加到列表
          imageFiles.add(entity);
        } else if (entity is Directory && basename(entity.path) != '_thumbData') {
          // 如果是子文件夹，递归调用
          _getImagesRecursively(entity, imageFiles);
        }
      } catch (e) {
        // 捕获和处理 PathAccessException 异常
        if (e is FileSystemException) {
          print('无法访问文件或文件夹: ${entity.path}, 错误: ${e.message}');
        }
      }
    }
  }

// 判断是否为图片文件
  bool _isImageFile(String path) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  void _clearFolders() {
    // setState(() {
    //   _selectedFolderPaths.clear();
    // });
    ref.read(selectedFolderPathsProvider.notifier).state = '';
    ref.read(imageProvider.notifier).state = [];
  }

  void _openImagePreview(int initialIndex, context) {
    final images = ref.watch(imageProvider);
    ref.read(currentIndexProvider.notifier).state = initialIndex;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageProvider);
    final selectedFolderPaths = ref.watch(selectedFolderPathsProvider);
    final isLoading = ref.watch(settingDataProvider);
    final historyList = ref.watch(settingDataProvider).settingData.historyList;


    print('image Manager buiding... images number is ${images.length}');
    print('historyList $historyList');
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Image Viewer'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.folder_open),
      //       onPressed: _pickFolder,
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.clear),
      //       onPressed: _clearFolders,
      //     ),
      //   ],
      // ),
      body: images.isEmpty
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: historyList.isNotEmpty ? 32: 8,),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: IconButton(
                    icon: Icon(Icons.folder_open),
                    iconSize: 100,
                    onPressed: () => _pickFolder(context),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(selectedFolderPaths.isEmpty
                        ? '你还没有选择文件夹，请点击选择文件夹'
                        : '文件夹里没有图片')),
                if (historyList.isNotEmpty) 
                  Center(
                    child: Container(
                      width: 400,
                      child: HistoryListCard(
                        historyPathList: historyList,
                        onOpen: (String pathName) {
                          print('historyList onOpen $pathName');
                          YubiUtil.requestPhotoLibraryPermission(
                            () {
                              print('请求权限成功？');
                              _loadImagesFromFolder(pathName, context);
                            },
                            () {
                              // 拒绝
                            }
                          );
                        },
                        onClear: () {
                          ref.read(settingDataProvider.notifier).updateSettingData(
                            historyList: []
                          );
                        }
                      )
                    ),
                  )
              ],
            ))
          : _bulidImageManagerBody(),
      // 这个部分应该放在设置里，这里是图方便先放这里了
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(4),
      //   child: Row(
      //   children: [
      //     IconButton(
      //       icon: const Icon(Icons.delete_forever),
      //       onPressed: _clearFolders,
      //       tooltip: '清除选中的文件夹',
      //     ),
      //   ],
      // )
      // )
    );
  }

  Widget _bulidImageManagerBody() {
    final imageThumbs = ref.watch(imageThumbProvider);
    final images = ref.watch(imageProvider);
    final gridImageNumOption = ref.watch(settingDataProvider).settingData.gridImageNumOption;
    
    print('_bulidImageManagerBody count: $gridImageNumOption');
    return DefaultTabController(
      length: 3, // 选项卡的数量
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.image), text: '所有照片'),
            Tab(icon: Icon(Icons.directions_transit), text: '相册'),
            Tab(icon: Icon(Icons.settings), text: '设置')
          ],
        ),
        body: TabBarView(
          children: [
            ImageGridView(
                images: images,
                thumbImages: imageThumbs,
                openImagePreview: _openImagePreview,
                clearFolders: _clearFolders, 
                gridAxisCount: gridImageNumOption.count
              ),
            PhoteAlbumView(),
            SettingsPage(),
          ],
        ),
      ),
    );
  }
}
