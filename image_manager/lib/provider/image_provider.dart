import 'dart:io';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_manager/utils/album_data_storage.dart';

final imageProvider = StateProvider<List<File>>((ref) => []);
final imageThumbProvider = StateProvider<List<File>>((ref) => []);
final imageThumbMapProvider = StateProvider<Map<String, File>>((ref) => {});

final currentIndexProvider = StateProvider<int>((ref) => 0);
final selectedFolderPathsProvider = StateProvider<String>((ref) => '');

final albumListProvider = StateProvider<List<AlbumItem>>((ref) => []);
final currentAlbumIndexProvider = StateProvider<int>((ref) => 0);
final currentAlbumImageIndexProvider = StateProvider<int>((ref) => 0);

final settingProvider = StateProvider((ref) => {});

// class SettingObject {
//   String outputPath;

//   SettingObject({});
// }

class PickDateObject {
  int year, month, day;

  PickDateObject({
    required this.year,
    required this.month,  
    required this.day
  });

  factory PickDateObject.fromJson(Map<String, dynamic> json) {
    return PickDateObject(
      year: json['year'],
      month: json['month'],
      day: json['day']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day  
    };
  }
  
  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  int compareTo(PickDateObject startDate) {
    if (year > startDate.year) {
      return 1;
    }
    if (year < startDate.year) {
      return -1;
    }
    if (month > startDate.month) {
      return 1;
    }
    if (month < startDate.month) {
      return -1;
    }
    if (day > startDate.day) {
      return 1;
    }
    if (day < startDate.day) {
      return -1;
    }
    return 0;
  }
}

class AlbumItem {
  String name;
  PickDateObject startDate;
  PickDateObject endDate;
  List<File> images;
  int coverIndex;
  int createTime;
  Set<String> starFileNames;

  AlbumItem({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.images,
    this.coverIndex = 0,
    required this.createTime,
    required this.starFileNames
  });

  AlbumItemByJson toAlbumItemByJson() {
    return AlbumItemByJson(
      name: name, 
      startDate: startDate, 
      endDate: endDate, 
      coverIndex: coverIndex, 
      createTime: createTime,
      starFileNames: starFileNames.toList()
    );
  }
}

