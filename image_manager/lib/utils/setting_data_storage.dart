import 'dart:async';
import 'dart:convert';

import 'package:image_manager/utils/emuns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingDataStorage {
  static final SettingDataStorage _instance = SettingDataStorage._internal();

  // 私有构造函数，用于初始化单例
  SettingDataStorage._internal() {
    print('SettingDataStorage is being initialized.');
    _settingData = SettingDataModel(historyList: []); // 执行初始化逻辑
    _cacheManager = CacheManager();
  }


  // 获取单例实例的方法
  factory SettingDataStorage() {
    return _instance;
  }


  // final String _cacheFileName = '_image_manager_data.json';
  late final CacheManager _cacheManager;
  late final SettingDataModel _settingData;
  final isInit = false;
  final key = 'yubi_image_manager_setting_data';
  Future<SettingDataModel> getSettingDataByCache() async {
    final settingDataCache = await _cacheManager.loadData(key);
    print('yubi_image_manager_setting_data getSettingDataByCache $settingDataCache');
    if (settingDataCache != null) {
      final data = jsonDecode(settingDataCache);
      // 
      return SettingDataModel.fromJson(data);
    } else {
      return SettingDataModel(historyList: []);
    }
  }

  Future<void> saveSettingDataByCache(SettingDataModel settingData) async {
    print('saveSettingDataByCache historyList：${settingData.historyList}');
    _cacheManager.saveData(key, jsonEncode(settingData.toJson()));
  }
}

class SettingDataModel {

  AlbumOutputOptionsMap albumOutputOption;
  AlbumMinTimeOptionsMap albumMinTimeOption;
  AlbumSortOptionsMap albumSortOption;
  GridImageNumOptionsMap gridImageNumOption;
  List<String> historyList;



  SettingDataModel({
    this.albumOutputOption =  AlbumOutputOptionsMap.onlyStar,
    this.albumMinTimeOption = AlbumMinTimeOptionsMap.onlyDate,
    this.albumSortOption = AlbumSortOptionsMap.create,
    this.gridImageNumOption = GridImageNumOptionsMap.four,
    required this.historyList
  });

    // 从 JSON 构造 SettingDataModel 对象
  factory SettingDataModel.fromJson(Map<String, dynamic> json) {
    print('AlbumMinTimeOptionsMap.values ${AlbumMinTimeOptionsMap.values} SettingKeysMap.albumMinTimeOptionKey.name ${SettingKeysMap.albumMinTimeOption.name} ${json[SettingKeysMap.albumMinTimeOption.name]}');
    print('json ${json} ${json.keys}');
    var _historyList = json['historyList'];

    if (_historyList == null){
      _historyList = <String>[];
    }else if (_historyList is List) {
      _historyList = List<String>.from(_historyList);
    } else if (_historyList is String  && (_historyList.isEmpty || _historyList == '[]')) {
      _historyList = <String>[];
    } 

    return SettingDataModel(
      albumMinTimeOption: AlbumMinTimeOptionsMap.values.firstWhere((e) => e.name == json[SettingKeysMap.albumMinTimeOption.name]),
      albumOutputOption: AlbumOutputOptionsMap.values.firstWhere((e) => e.name == json[SettingKeysMap.albumOutputOption.name] as String),
      albumSortOption: AlbumSortOptionsMap.values.firstWhere((e) => e.name == json[SettingKeysMap.albumSortOption.name] as String),
      gridImageNumOption: GridImageNumOptionsMap.values.firstWhere((e) => e.name == json[SettingKeysMap.gridImageNumOption.name] as String),
      historyList: _historyList
    );
  }

  @override
  String toString() {
    // ignore: prefer_interpolation_to_compose_strings
    return 'albumOutputOption: ${albumOutputOption.name}，'
         + 'albumMinTimeOption: ${albumMinTimeOption.name}，'
         + 'albumSortOption: ${albumSortOption.name}，'
         + 'gridImageNumOption: ${gridImageNumOption.name}';
  }

  Map<String, dynamic> toJson() {
    return {
      'albumOutputOption': albumOutputOption.name,
      'albumMinTimeOption': albumMinTimeOption.name,
      'albumSortOption': albumSortOption.name,
      'gridImageNumOption': gridImageNumOption.name,
      'historyList': historyList
    };
  }


  // copyWith 方法，用于更新某个字段时保持其他字段不变
  SettingDataModel copyWith({
    AlbumOutputOptionsMap? albumOutputOption,
    AlbumMinTimeOptionsMap? albumMinTimeOption,
    AlbumSortOptionsMap? albumSortOption,
    GridImageNumOptionsMap? gridImageNumOption,
    List<String>? historyList
  }) {
    print('copyWith done');
    return SettingDataModel(
      albumOutputOption: albumOutputOption ?? this.albumOutputOption,
      albumMinTimeOption: albumMinTimeOption ?? this.albumMinTimeOption,
      albumSortOption: albumSortOption ?? this.albumSortOption,
      gridImageNumOption: gridImageNumOption ?? this.gridImageNumOption,
      historyList: historyList ?? this.historyList
    );
  }
}

class CacheManager {
  // 保存数据
  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 读取数据
  Future<String?> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // 移除数据
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // 清空所有数据
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

