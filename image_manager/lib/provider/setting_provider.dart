

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_manager/utils/emuns.dart';
import 'package:image_manager/utils/setting_data_storage.dart';

// 模拟一个异步获取数据的函数
Future<SettingDataModel> fetchSettingData() async {
  // return await 
  return await SettingDataStorage().getSettingDataByCache();
}

// 创建一个 FutureProvider 来包装异步函数
// final settingDataProvider = FutureProvider<SettingDataModel>((ref) async {
//   print('获取配置');
//   await Future.delayed(Duration(seconds: 10));
//   print('获取配置 done');
//   return fetchSettingData();
// });

class SettingDataState {
  
  bool isLoading;
  SettingDataModel settingData;

  SettingDataState({
    this.isLoading = false,
    required this.settingData
  });
}

// // StateNotifier 用来管理同步和异步状态
class SettingDataStateNotifier extends StateNotifier<SettingDataState> {
  SettingDataStateNotifier() : super(
    SettingDataState(settingData: SettingDataModel(historyList: []))
  ) {
    fetchDataAsync();
  }

  // 同步更新数据，不触发异步操作
  void updateDataSync(SettingDataModel newData) {
    state = SettingDataState(isLoading: false, settingData: newData);
  }

  void updateAlbumOutputOption(AlbumOutputOptionsMap value) {
    final newSettingData = state.settingData;
    newSettingData.albumOutputOption = value;
    state = SettingDataState(settingData: newSettingData);
  }

  void updateAlbumMinTimeOption(AlbumMinTimeOptionsMap value) {
    final newSettingData = state.settingData;
    newSettingData.albumMinTimeOption = value;
    state = SettingDataState(settingData: newSettingData);
  }

  void updateAlbumSortOption(AlbumSortOptionsMap value) {
    final newSettingData = state.settingData;
    newSettingData.albumSortOption = value;
    state = SettingDataState(settingData: newSettingData);
  }

  void updateGridImageNumOption(GridImageNumOptionsMap value) {
    final newSettingData = state.settingData;
    newSettingData.gridImageNumOption = value;
    state = SettingDataState(settingData: newSettingData);
  }

  // 通用方法，用于更新 SettingDataModel 中的某个字段
  void updateSettingData({
    AlbumOutputOptionsMap? albumOutputOption,
    AlbumMinTimeOptionsMap? albumMinTimeOption,
    AlbumSortOptionsMap? albumSortOption,
    GridImageNumOptionsMap? gridImageNumOption,
    List<String>? historyList
  }) {
    state = SettingDataState(
      settingData: state.settingData.copyWith(
        albumOutputOption: albumOutputOption,
        albumMinTimeOption: albumMinTimeOption,
        albumSortOption: albumSortOption,
        gridImageNumOption: gridImageNumOption,
        historyList: historyList
      ),
      isLoading: false,
    );
    SettingDataStorage().saveSettingDataByCache(state.settingData);
  }

  // 异步获取数据并更新状态
  Future<void> fetchDataAsync() async {
    state = SettingDataState(settingData: state.settingData, isLoading: true); // 进入 loading 状态
    final data = await fetchSettingData(); // 模拟异步获取数据
    print('setting data $data');
    state = SettingDataState(settingData: data, isLoading: false); // 请求完成，更新数据
  }
}

// 使用 StateNotifierProvider 来提供状态管理
final settingDataProvider = StateNotifierProvider<SettingDataStateNotifier, SettingDataState>(
  (ref) => SettingDataStateNotifier(),
);