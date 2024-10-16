import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_manager/components/progress_dialog.dart';
import 'package:image_manager/provider/image_provider.dart';
import 'package:image_manager/provider/setting_provider.dart';
import 'package:image_manager/utils/emuns.dart';
import 'package:image_manager/utils/util.dart';
import 'package:path/path.dart';

// 测试一下UI
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends ConsumerStatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

final TextStyle descTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey[600],
);

final TextStyle titleTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // 控制选中的磁盘共享选项
  AlbumOutputOptionsMap _outputOption = AlbumOutputOptionsMap.onlyStar;
  AlbumMinTimeOptionsMap _timeOption = AlbumMinTimeOptionsMap.onlyDate;
  AlbumSortOptionsMap _albumSortOption = AlbumSortOptionsMap.create;
  final _usedSpace = 11; // 当前占用空间，单位GB
  String? _selectedDirectory;
  GridImageNumOptionsMap _gridImageNumOptison = GridImageNumOptionsMap.four;
  final ProgressController _progressController = ProgressController();

  Future<void> _pickFolder() async {
    // 打开文件夹选择对话框
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    setState(() {
      _selectedDirectory = selectedDirectory;
    });
  }

  EdgeInsets _dynamicInsideMargin(BoxConstraints constraints) {
    late double leftAndRightDistance;
    // late double topAndBottomDistance;

    // 响应式
    final containerWidth = constraints.maxWidth;
    if (containerWidth > 1600) {
      leftAndRightDistance = 300;
    } else if (containerWidth > 1400) {
      leftAndRightDistance = 240;
    } else if (containerWidth > 1200) {
      leftAndRightDistance = 160;
      // topAndBottomDistance = 16;
    } else if (containerWidth > 1000) {
      leftAndRightDistance = 110;
    } else if (containerWidth > 800) {
      leftAndRightDistance = 36;
    } else {
      leftAndRightDistance = 16;
    }

    return EdgeInsets.fromLTRB(
        leftAndRightDistance, 16, leftAndRightDistance, 16);
  }

  // void _showProgressDialog(context, initCallBack) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return ProgressDialog(
  //         updateProgreeController: _progressController,
  //         initCallBack: initCallBack
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final settingDataState = ref.watch(settingDataProvider);
    final settingData = settingDataState.settingData;
    final isLoading = settingDataState.isLoading;
    final historyList = ref.watch(settingDataProvider).settingData.historyList;

    print('setting data: ${settingData.toString()}; isLoading $isLoading');
    print('setting $historyList');

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
              padding: _dynamicInsideMargin(constraints),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '相册顺序',
                    style: titleTextStyle,
                  ),
                  // SizedBox(height: 8),
                  RadioListTile(
                    title: Text('相册建立顺序'),
                    value: AlbumSortOptionsMap.create,
                    groupValue: settingData.albumSortOption,
                    onChanged: (value) {
                      // setState(() {
                      //   _albumSortOption = value!;
                      // });
                      ref.read(settingDataProvider.notifier).updateSettingData(albumSortOption: value);
                    },
                    subtitle: Text(
                      '按相册建立顺序排序。',
                      style: descTextStyle,
                    ),
                  ),
                  RadioListTile(
                    title: Text('时间顺序'),
                    value: AlbumSortOptionsMap.timeSort,
                    groupValue: settingData.albumSortOption,
                    onChanged: (value) {
                      // setState(() {
                      //   _albumSortOption = value!;
                      // });
                      ref.read(settingDataProvider.notifier).updateAlbumSortOption(value!);
                    },
                    subtitle: Text(
                      '按照相册中的开始时间来排序。',
                      style: descTextStyle,
                    ),
                  ),
                  // SizedBox(height: 16),
                  // Text(
                  //   '选择时间的最小单位',
                  //   style: titleTextStyle,
                  // ),
                  // SizedBox(height: 8),
                  // RadioListTile(
                  //   title: Text('仅具体到天'),
                  //   value: AlbumMinTimeOptionsMap.onlyDate,
                  //   groupValue: settingData.albumMinTimeOption,
                  //   onChanged: (value) {
                  //     ref.read(settingDataProvider.notifier).updateSettingData(albumMinTimeOption: value);
                  //   },
                  //   subtitle: Text(
                  //     '适合几天以上的行程进行分类成一个相册。大多数情况够用。',
                  //     style: descTextStyle,
                  //   ),
                  // ),
                  // RadioListTile(
                  //   title: Text('小时'),
                  //   value: AlbumMinTimeOptionsMap.time,
                  //   groupValue: settingData.albumMinTimeOption,
                  //   onChanged: (value) {
                  //     ref.read(settingDataProvider.notifier).updateSettingData(albumMinTimeOption: value);
                  //   },
                  //   subtitle: Text(
                  //     '适合将一个行程中不同景点的照片进行细致化管理，包含几点到几点。',
                  //     style: descTextStyle,
                  //   ),
                  // ),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    '导出相册',
                    style: titleTextStyle,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedDirectory == null
                                ? '请选择导出文件夹'
                                : '选择的文件夹为：',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (_selectedDirectory != null)
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        (constraints.maxWidth - 300) * 1.33 -
                                            270),
                                child: Text(
                                  _selectedDirectory!,
                                  style: descTextStyle,
                                ))
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => {_pickFolder()},
                            child: Text(_selectedDirectory == null
                                ? '选择文件夹'
                                : '重新选择文件夹'),
                          ),
                          if (_selectedDirectory != null)
                            const SizedBox(
                              width: 16,
                            ),
                          if (_selectedDirectory != null)
                            ElevatedButton(
                              onPressed: () {
                                YubiUtil.showProgressDialog(context, () {
                                  YubiUtil.outputAlbum(
                                    _progressController.triggerUpdateProgressEvent,
                                    ref.read(albumListProvider),
                                    settingData.albumOutputOption,
                                    _selectedDirectory!
                                  );
                                }, _progressController);

                              },
                              child: Text('导出'),
                            ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '可以在这里很方便的导出相册中已经选好的照片，',
                    style: descTextStyle,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '选择导出方式',
                    style: titleTextStyle,
                  ),
                  SizedBox(height: 8),
                  RadioListTile(
                    title: Text('仅已收藏照片'),
                    value: AlbumOutputOptionsMap.onlyStar,
                    groupValue: settingData.albumOutputOption,
                    onChanged: (value) {
                      // setState(() {
                      //   _outputOption = value!;
                      // });
                      ref.read(settingDataProvider.notifier).updateSettingData(albumOutputOption: value);
                    },
                    subtitle: Text(
                      '若相册中没有收藏的照片，则略过该相册。',
                      style: descTextStyle,
                    ),
                  ),
                  RadioListTile(
                    title: Text('导出所有照片'),
                    value: AlbumOutputOptionsMap.all,
                    groupValue: settingData.albumOutputOption,
                    onChanged: (value) {
                      ref.read(settingDataProvider.notifier).updateSettingData(albumOutputOption: value);
                    },
                    subtitle: Text(
                      '按照已有相册导出所有照片，需注意硬盘空间是否充足。',
                      style: descTextStyle,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 16),
                  buildThumbDataOption(context),
                  SizedBox(height: 16),
                  Divider(),
                  // Text(
                  //   '清除配置',
                  //   style: titleTextStyle,
                  // ),
                  // SizedBox(height: 12),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       '当前已创建 $_usedSpace 个相册',
                  //       style: TextStyle(fontSize: 16),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () {},
                  //       child: Text('一键清除所有相册'),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 16),
                  // Text(
                  //   '这里的清除会清除被选中的文件夹里的配置文件“_image_manager_data.json”，也仅此而已，并不会删除照片。',
                  //   style: descTextStyle,
                  // ),
                  // SizedBox(height: 16),
                  // Divider(),
                  SizedBox(height: 16),
                  Text(
                    '图库设置',
                    style: titleTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '每行的网格数量为：',
                        style: TextStyle(fontSize: 16),
                      ),
                      // 不知道为什么这里有样式问题
                      // DropdownButton<int>(
                      //   value: _selectedOption, // 当前选中的值
                      //   items:
                      //       <int>[3, 4, 5, 6].map<DropdownMenuItem<int>>((int value) {
                      //     return DropdownMenuItem<int>(
                      //       value: value,
                      //       child: Text('$value 个'),
                      //     );
                      //   }).toList(),
                      //   onChanged: (int? newValue) {
                      //     setState(() {
                      //       _selectedOption = newValue!;
                      //     });
                      //   },
                      // ),
                      Row(
                        children: GridImageNumOptionsMap.values
                            .map((num) => Row(
                                  children: [
                                    Radio<GridImageNumOptionsMap>(
                                      value: num,
                                      groupValue: settingData.gridImageNumOption,
                                      onChanged: (GridImageNumOptionsMap? value) {
                                        // setState(() {
                                        //   _gridImageNumOptison = value!;
                                        // });
                                        ref.read(settingDataProvider.notifier).updateSettingData(gridImageNumOption: value);
                                      },
                                    ),
                                    Text('$num 个  ')
                                  ],
                                ))
                            .toList(),
                      )
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '会改变“所有照片”和“相册”中，每一行的网格预览数量。',
                    style: descTextStyle,
                  ),
                ],
              )

              // settingDataAsync.when<Widget>(
              //     data: (settingData) {
              //       print('setting data: ${settingData.toString()}');
              //       return
              //     },
              //     error: (err, stack) => Text('bug $err'),
              //     loading: () => const Center(
              //         child: Column(
              //             mainAxisSize: MainAxisSize.max,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [CircularProgressIndicator()]
              //         )
              //       )
              //   ),
              ),
        ));
  }

  Widget buildThumbDataOption(BuildContext context) {
    final images = ref.watch(imageProvider);
    final imageThumbs = ref.watch(imageThumbProvider);
    final settingDataState = ref.watch(settingDataProvider);
    final settingData = settingDataState.settingData;
    final ProgressController _progressController = ProgressController();
    final selectedFolderPaths = ref.watch(selectedFolderPathsProvider);

    showThumbProgressDialog() {
      // 生成缓存文件
      showDialog(
        context: context,
        builder: (context) {
          return ProgressDialog(
            updateProgreeController: _progressController,
            initCallBack: () async {
              await Future.delayed(const Duration(milliseconds: 200));
              final thumbImageFiles = await YubiUtil.getThumbImages(
                _progressController,
                images,
                selectedFolderPaths,
                imageThumbs,
              );

              final thumbImageMap = <String, File>{};
              thumbImageFiles.forEach((item) {
                thumbImageMap[basename(item.path)] = item;
              });

              ref.read(imageThumbProvider.notifier).state = [...thumbImageFiles];
              ref.read(imageThumbMapProvider.notifier).state = thumbImageMap;
            },
            closeBtnText: '关闭',
          );
        },
      );
    }

    clearThumbDialog() {
      showDialog(context: context, 
        builder: (context) {
          return AlertDialog(
            title: Text('清除缓存'),
            content: const SizedBox(
              height: 200,
              width: 500,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('是否确认清除所有照片缓存。')
                    // ElevatedButton(
                    //   onPressed: _updateProgress,
                    //   child: const Text('Increase Progress'),
                    // ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await YubiUtil.clearThumbImages(selectedFolderPaths);
                  ref.read(imageThumbProvider.notifier).state = [];
                  ref.read(imageThumbMapProvider.notifier).state = {};
                  Navigator.of(context).pop();
                },
                child: Text('确定清除')),
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text('取消'))
            ]
          );
        }
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(
          '缓存数据',
          style: titleTextStyle,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '已缓存照片：${imageThumbs.length}张。总照片数量：${images.length}张。',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: showThumbProgressDialog,
                  child: const Text('继续生成缓存文件'),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: clearThumbDialog,
                  child: const Text('清除缓存'),
                ),
              ],
            )
          ],
        ),
        Text(
          '生成缓存照片可以极大的提升网格照片的预览速度。',
          style: descTextStyle,
        )
      ],
    );
  }
}
