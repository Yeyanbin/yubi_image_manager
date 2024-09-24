import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_manager/components/date_picker.dart';
import 'package:image_manager/provider/image_provider.dart';
import 'package:image_manager/provider/setting_provider.dart';
import 'package:image_manager/utils/album_data_storage.dart';
import 'package:image_manager/utils/emuns.dart';
import 'package:image_manager/utils/util.dart';

class AlbumFormDialogView extends ConsumerStatefulWidget {
  bool isModify;

  AlbumFormDialogView({
    super.key,
    this.isModify = false,
  });

  @override
  _AlbumFormDialogViewState createState() => _AlbumFormDialogViewState();
}

class _AlbumFormDialogViewState extends ConsumerState<AlbumFormDialogView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  // final _nameController = TextEditingController();
  // String? _initName;
  DateTime? _initStartDate;
  DateTime? _initEndDate;

  Widget build(BuildContext context) {
    late TextEditingController nameController;
    if (widget.isModify) {
      final albumList = ref.read(albumListProvider);
      final albumIndex = ref.read(currentAlbumIndexProvider);
      final modifyAlbumData = albumList[albumIndex];

      nameController =  TextEditingController(text: modifyAlbumData.name);
      _selectedStartDate = _initStartDate = modifyAlbumData.startDate.toDateTime();
      _selectedEndDate = _initEndDate = modifyAlbumData.endDate.toDateTime();
    } else {
      nameController = TextEditingController();
    }
    final settingDataState = ref.read(settingDataProvider);

    return AlertDialog(
      title: const Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text('新增行程'),
      ),
      content: Container(
        width: 360,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                // initialValue: _initName,
                controller: nameController,
                decoration: const InputDecoration(labelText: '行程名称'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入行程名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CustomDatePickerFormField(
                labelText: '选择开始日期',
                initialValue: _initStartDate,
                onDateChanged: (date) {
                  _selectedStartDate = date;
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择开始日期';
                  }
                  return null;
                },
                context: context,
                isShowTimePick: settingDataState.settingData.albumMinTimeOption == AlbumMinTimeOptionsMap.time,
              ),
              const SizedBox(height: 8),
              CustomDatePickerFormField(
                labelText: '选择结束日期',
                initialValue: _initEndDate,
                onDateChanged: (date) {
                  _selectedEndDate = date;
                },
                validator: (value) {
                  if (value == null) {
                    return '请选择结束日期';
                  }
                  return null;
                },
                context: context,
                isShowTimePick: settingDataState.settingData.albumMinTimeOption == AlbumMinTimeOptionsMap.time,
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: widget.isModify ? MainAxisAlignment.spaceBetween: MainAxisAlignment.end,
                children: [
                  if (widget.isModify)
                    IntrinsicWidth(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(245, 108, 108, 1),
                          padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8), // 按钮的内边距
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 设置圆角半径
                        )),
                        child: const Row(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              color: Colors.white,
                              Icons.delete_forever,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text('删除相册', style: TextStyle(color: Colors.white,)),
                            SizedBox(width: 8),
                          ],
                        ),
                        onPressed: () {
                          final currentAlbumIndex = ref.read(currentAlbumIndexProvider);
                          final albumList = ref.read(albumListProvider);
                          albumList.removeAt(currentAlbumIndex);
                          ref.read(albumListProvider.notifier).state = [...albumList];
                          AlbumDataStorage().updateAlbumList(albumList);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  IntrinsicWidth(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8), // 按钮的内边距
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // 设置圆角半径
                          )),
                      child: const Row(
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.clear,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('重置表单'),
                          SizedBox(width: 8),
                        ],
                      ),
                      onPressed: () => {_formKey.currentState?.reset()},
                    ),
                  ),
      
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _formKey.currentState?.reset();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            print('点击提交');
            // 提交表单逻辑
            if (_formKey.currentState?.validate() ?? false) {
              // 表单验证成功
              final name = nameController.text;
              final startDate = _selectedStartDate!;
              final endDate = _selectedEndDate!;

              // 需要处理一下日期相关的校验，开始日期是否小于结束日期，该日期区间内是否有图片
              print('新增行程名称: $name');
              print('选择的开始日期: ${startDate?.toLocal()}');
              print('选择的结束日期: ${endDate?.toLocal()}');

              final images = ref.read(imageProvider);
              final fixedEndDate = DateTime.fromMicrosecondsSinceEpoch(endDate.microsecondsSinceEpoch).add(const Duration(days: 1));
              List<File> filteredFiles =
                  getFilesWithinTimeRange(images, startDate, fixedEndDate);
              late List<AlbumItem> albumData;

              if (widget.isModify) {
                final currentAlbumIndex = ref.read(currentAlbumIndexProvider);
                final albumList = ref.read(albumListProvider);
                // albumList[currentAlbumIndex] = AlbumItem(
                //     name: name,
                //     startDate: PickDateObject(
                //         year: startDate.year,
                //         month: startDate.month,
                //         day: startDate.day),
                //     endDate: PickDateObject(
                //         year: endDate.year,
                //         month: endDate.month,
                //         day: endDate.day),
                //     images: filteredFiles);
                albumList[currentAlbumIndex].name = name;
                albumList[currentAlbumIndex].startDate = PickDateObject(
                  year: startDate.year,
                  month: startDate.month,
                  day: startDate.day);
                albumList[currentAlbumIndex].endDate =  PickDateObject(
                  year: endDate.year,
                  month: endDate.month,
                  day: endDate.day);
                albumList[currentAlbumIndex].images = filteredFiles;
                albumData = albumList;
              } else {
                albumData = [
                  ...ref.read(albumListProvider),
                  AlbumItem(
                      name: name,
                      startDate: PickDateObject(
                          year: startDate.year,
                          month: startDate.month,
                          day: startDate.day),
                      endDate: PickDateObject(
                          year: endDate.year,
                          month: endDate.month,
                          day: endDate.day),
                      images: filteredFiles,
                      createTime: DateTime.now().millisecondsSinceEpoch,
                      starFileNames: {}
                    )
                ];
              }
              AlbumDataStorage().updateAlbumList(albumData);
              ref.read(albumListProvider.notifier).state = [...albumData];
              // 打印结果
              // for (var file in filteredFiles) {
              //   print('文件: ${file.path}, 修改时间: ${file.statSync().modified}');
              // }
              print('筛选后的文件：$name, 图片数量：${filteredFiles.length}');

              Navigator.of(context).pop();
              _formKey.currentState?.reset();
            }
          },
          child: const Text('提交'),
        ),
        const SizedBox(
          width: 12,
        )
      ],
    );
  }
}
