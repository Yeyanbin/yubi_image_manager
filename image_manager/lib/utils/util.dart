import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_manager/components/progress_dialog.dart';
import 'package:image_manager/provider/image_provider.dart';
import 'package:image_manager/utils/emuns.dart';
import 'package:path/path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

// 
List<File> getFilesWithinTimeRange(List<File> files, DateTime startTime, DateTime endTime) {
  // 使用二分查找找到开始索引和结束索引
  int startIndex = _binarySearch(files, startTime, findStart: true);
  int endIndex = _binarySearch(files, endTime, findStart: false);

  // 截取符合时间范围的文件
  return files.sublist(startIndex, endIndex);
}

int _binarySearch(List<File> files, DateTime targetTime, {required bool findStart}) {
  int left = 0;
  int right = files.length;

  while (left < right) {
    int mid = left + (right - left) ~/ 2; // ~/ 整除
    DateTime fileTime = files[mid].statSync().modified;

    if (fileTime.isBefore(targetTime) || (findStart && fileTime.isAtSameMomentAs(targetTime))) {
      left = mid + 1;
    } else {
      right = mid;
    }
  }
  
  return findStart ? left : right;
}

String dateRangeStr(PickDateObject startDate, PickDateObject endDate) {
  return '${startDate.year}/${startDate.month}/${startDate.day}到${endDate.year}/${endDate.month}/${endDate.day}';
}

class YubiUtil {
  // 私有构造函数，防止被实例化
  YubiUtil._();
  static String OUTPUT_THUMB_DIRPATH = '_thumbData';

  static Set<String> handleStarFiles(List<String> fileNames) {
    return Set<String>.from(fileNames);
  }

  static List<dynamic> handleListByJson(dynamic jsonStr) {
    print('jsonStr ${jsonStr.runtimeType}');
    if (jsonStr is List) {
      if (jsonStr.isEmpty) {
        return [];
      } else {
        return jsonStr;
      }
    } else if (jsonStr is String && (jsonStr.isEmpty || jsonStr == '[]')) {
      // 处理空字符串的情况
      return [];
    } else {
      throw Exception("Unexpected type for albumListByJsonFromJson: ${jsonStr.runtimeType} value: $jsonStr");
    }
  }

  static void showTopMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 10, // 距离顶部的位置
        left: MediaQuery.of(context).size.width * 0.35, // 居中
        width: MediaQuery.of(context).size.width * 0.3, // 设置宽度
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 使容器根据内容高度自动调
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )]
            ),
          ),
          )
        )
      ),
    );

    // 插入 OverlayEntry
    overlay.insert(overlayEntry);

    // 2秒后移除 OverlayEntry
    Future.delayed(Duration(seconds: 2)).then((_) => overlayEntry.remove());
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static void showProgressDialog(context, initCallBack, ProgressController progressController) {
    showDialog(
      context: context,
      builder: (context) {
        return ProgressDialog(
          updateProgreeController: progressController,
          initCallBack: initCallBack,
        );
      },
    );
  }

  static void outputAlbum(void Function(double, String) updateProgress, List<AlbumItem> albumList, AlbumOutputOptionsMap albumOutputOption, String outputPath) async {
    // 首先要判断是否只用筛选已收藏
    // 然后筛选需要导出的相册
    // 然后分别创建导出文件夹，导出文件

    print('开始导出');
    // 避免影响原数据
    final _albumList = [...albumList];

    if (albumOutputOption == AlbumOutputOptionsMap.onlyStar) {
      // 去掉收藏为空的
      _albumList.removeWhere((albumItem) => albumItem.starFileNames.isEmpty);
    }
    var len = _albumList.length;
    // _albumList.forEach((albumItem) {
    //   updateProgress(index / len, albumItem.name);
    // });
    // print('开始拷贝');
    for (var index = 0; index < len; index++) {
      final albumItem = _albumList[index];
      print('开始拷贝 $index ${albumItem.name}');
      updateProgress(index / len, '正在拷贝：${albumItem.name}');

      final dirPath = '$outputPath/${albumItem.startDate.year}/${albumItem.startDate.month}_${albumItem.startDate.day}_${albumItem.name}';
      // 创建文件夹
      await createFolder(dirPath);
      
      final starNameSet = albumItem.starFileNames;
      // 输出一个个文件
      for (var imageFile in albumItem.images) {
        if (
          albumOutputOption == AlbumOutputOptionsMap.all // 全部
        || starNameSet.contains(basename(imageFile.path)) // 已经收藏
        ) {
          print('正在拷贝文件 ${basename(imageFile.path)} 到 $dirPath');
          try {
            await imageFile.copy('$dirPath/${basename(imageFile.path)}');
          } catch (e) {
            print('Error writing json file: $e');
          }
        }
      }
    }
    updateProgress(1, '导出完成！');
  }


  static Future<List<File>> getThumbImages(ProgressController progressController, List<File> imageFiles, String folderPath, [List<File>? inputThumbImages]) async {
    final subsIndex = folderPath.length;
    final List<File> thumbImages = inputThumbImages ?? [];
    final len = imageFiles.length;
    var count = 0;
    final updateProgress = progressController.triggerUpdateProgressEvent;
    print('getThumbImages 图片数量${imageFiles.length} folderPath: $folderPath');

    

    for (var i = thumbImages.length; i < len; i++) {
      if (progressController.getProgressCloseState!()) {
        return thumbImages;
      }
      
      final dirPath = '$folderPath/$OUTPUT_THUMB_DIRPATH';

      final imageFile = imageFiles[i];

      final outputFilePath = '$dirPath/${imageFile.path.substring(subsIndex)}';
      final thumbFile = File(outputFilePath);
      // final Directory dir = Directory(outputFilePath);
      print('getThumbImages file path ${outputFilePath} ${imageFile.path}');

      if (await thumbFile.exists()) {
        // 文件已存在。
        thumbImages.add(thumbFile);
        updateProgress(i / len, '正在处理缓存文件 $i / $len');
      } else {
        await createFolder(thumbFile.parent.path);

        final result = await FlutterImageCompress.compressAndGetFile(
          imageFile.path,
          thumbFile.path,
          quality: 95,  // 设置图片质量
          minWidth: 300,  // 设置缩略图宽度
          minHeight: 300,  // 设置缩略图高度
        );
        if (result != null) {
          thumbImages.add(File(result.path));
          updateProgress(i / len, '正在处理缓存文件 $i / $len');
        }
      }
    }
    // print('');
    updateProgress(1, '成功获取缓存文件 $len 个');
    return thumbImages;
  }


  // 请求权限
  static Future<void> requestPhotoLibraryPermission(void Function() successCallback,void Function() rejectCallback) async {
    // final status = await Permission.photos.request();
    // if (status.isGranted) {
    //   // 权限被授予，执行相关操作
    //   successCallback();
    // } else if (status.isDenied) {
    //   // 权限被拒绝，提示用户
    //   rejectCallback();
    // } else if (status.isPermanentlyDenied) {
    //   // 权限被永久拒绝，建议用户去设置中手动授权
    //   openAppSettings();
    // }
    successCallback();
  }



  static Future<void> clearThumbImages(String folderPath) async {
    final dirPath = '$folderPath/$OUTPUT_THUMB_DIRPATH';
    // OUTPUT_THUMB_DIRPATH
    final directory = Directory(dirPath);
      try {
        if (await directory.exists()) {
          // 删除文件夹及其内容
          await directory.delete(recursive: true);
          print('文件夹删除成功');
        } else {
          print('文件夹不存在');
        }
      } catch (e) {
        print('删除文件夹时出错: $e');
      }
  }

  static Future<void> createFolder(String path) async {
    final Directory dir = Directory(path);

    // 检查目录是否存在
    if (await dir.exists()) {
      print('文件夹已存在: $path');
    } else {
      try {
        // 创建目录，递归创建父目录
        await dir.create(recursive: true);
        print('文件夹创建成功: $path');
      } catch (e) {
        print('创建文件夹失败: $e');
      }
    }
  }
}