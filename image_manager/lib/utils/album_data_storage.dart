
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:image_manager/provider/image_provider.dart';
import 'package:image_manager/utils/util.dart';
// 持久化用
class AlbumDataStorage {
  // 私有构造函数
  AlbumDataStorage._internal();
  
  late String _directory;
  AlbumDataStorageModel _data = AlbumDataStorageModel(albumListByJson: []);
  // 单例对象
  static final AlbumDataStorage _instance = AlbumDataStorage._internal();

  // 获取单例实例的方法
  factory AlbumDataStorage() {
    return _instance;
  }

  final String _fileName = '_image_manager_data.json';

  // 获取文件路径
  File _getLocalFile([String? directory]) {
    if (directory != null) {
      _directory = directory;
    }
    return File('${directory ?? _directory}/$_fileName');
  }

  // 读取 JSON 文件并解析为 DataStorageModel
  Future<AlbumDataStorageModel> readJsonStorage(String directory) async {
    try {
      final file = _getLocalFile(directory);
      if (await file.exists()) {
        final contents = await file.readAsString();
        
        final json = jsonDecode(contents);
        print('解析json....$json  albumListByJson ${json['albumListByJson']}');
        _data = AlbumDataStorageModel.fromJson(json);
        print('解析完成');
        return _data;
      } else {
        // 如果不存在就创建持久化文件
        writeJsonStorage();
      }
    } catch (e) {
      print('Error reading json file: $e');
    }
    // 返回默认的 DataStorageModel，如果文件不存在或读取失败
    return AlbumDataStorageModel(albumListByJson: []);
  }

  // 保存 DataStorageModel 为 JSON 文件
  Future<void> writeJsonStorage() async {
    try {
      final file = _getLocalFile();
      final json = jsonEncode(_data.toJson());
      await file.writeAsString(json);
    } catch (e) {
      print('Error writing json file: $e');
    }
  }

  void updateAlbumList(List<AlbumItem> albumData) {
    _data = AlbumDataStorageModel(
      albumListByJson: albumData
        .map((item) => item.toAlbumItemByJson()
          // AlbumItemByJson(
          //   name: item.name, 
          //   startDate: item.startDate, 
          //   endDate: item.endDate,
          //   coverIndex: item.coverIndex,
          //   createTime: item.createTime
          // )
        )
        .toList(),
    );
    writeJsonStorage();
  }
}

class AlbumItemByJson {
  String name;
  PickDateObject startDate;
  PickDateObject endDate;
  int coverIndex;
  int createTime;
  List<String> starFileNames;

  AlbumItemByJson({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.coverIndex = 0,
    required this.createTime,
    this.starFileNames = const []
  });

  factory AlbumItemByJson.fromJson(Map<String, dynamic> json) {
    print('AlbumItemByJson fromJson $json');
    // print('starFileName ${json['starFileNames']}');
    return AlbumItemByJson(name: json['name'], 
      startDate: PickDateObject.fromJson(json['startDate']), 
      endDate: PickDateObject.fromJson(json['endDate']),
      coverIndex: json['coverIndex'] ?? 0,
      createTime: json['createTime'] ?? DateTime.now().millisecondsSinceEpoch,
      starFileNames: YubiUtil.handleListByJson(json['starFileNames']).cast<String>()
    );
  }   
  Map<String, dynamic> toJson() {
    print('AlbumItemByJson toJson');  
    return {
      'name': name,
      'startDate': startDate.toJson(),
      'endDate': endDate.toJson(),
      'coverIndex': coverIndex,
      'createTime': createTime,
      'starFileNames': starFileNames
    };
  }

  AlbumItem toAlbumItem(List<File> images) => 
    AlbumItem(
      name: name,
      startDate: startDate,
      endDate: endDate,
      coverIndex: coverIndex,
      images: images, 
      createTime: createTime,
      starFileNames: starFileNames.toSet()
    ); 
}

class AlbumDataStorageModel {

  List<AlbumItemByJson> albumListByJson;

  AlbumDataStorageModel({
    required this.albumListByJson
  });

  // 从 JSON 构造 DataStorageModel 对象
  factory AlbumDataStorageModel.fromJson(Map<String, dynamic> json) {
    // 这里要额外处理空数组的情况，留个坑
    try {
      print('AlbumDataStorageModel $json albumListByJson  runtimeType  ${List<AlbumItemByJson>.from(json['albumListByJson'])}');
    } catch(e) {
      print('??? $e');
    }
    var albumListByJsonFromJson = json['albumListByJson'];
    List<AlbumItemByJson> albumListByJson = [];
    print('albumListByJsonFromJson type ${albumListByJsonFromJson.runtimeType}');

    // 检查 albumListByJsonFromJson 是 List 类型，并转换为 List<String>
    if (albumListByJsonFromJson is List) {
      albumListByJson = albumListByJsonFromJson.map((
        item) => AlbumItemByJson.fromJson(item)
        // AlbumItemByJson(
        //   name: item['name'],
        //   startDate: PickDateObject.fromJson(item['startDate']), 
        //   endDate: PickDateObject.fromJson( item['endDate']))
        ).toList();
    } else if (albumListByJsonFromJson is String && (albumListByJsonFromJson.isEmpty || albumListByJsonFromJson == '[]')) {
      // 处理空字符串的情况
      albumListByJson = [];
    } else {
      throw Exception("Unexpected type for albumListByJsonFromJson: ${albumListByJsonFromJson.runtimeType} value: $albumListByJsonFromJson");
    }

    print('albumListByJson: ${albumListByJson.map((item) => item.toJson())}');

    return AlbumDataStorageModel(
      albumListByJson: albumListByJson
    );
  }

  // 转换 DataStorageModel 对象为 JSON
  Map<String, dynamic> toJson() {
    return {
      'albumListByJson': albumListByJson
    };
  }
}