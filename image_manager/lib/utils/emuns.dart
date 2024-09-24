
enum SettingKeysMap {
  albumOutputOption,
  albumMinTimeOption,
  albumSortOption,
  gridImageNumOption
}

enum AlbumOutputOptionsMap {
  onlyStar,
  all
}

enum AlbumMinTimeOptionsMap {
  onlyDate,
  time,
}

enum AlbumSortOptionsMap {
  create,
  timeSort
}

enum GridImageNumOptionsMap {
  two(2),
  three(3),
  four(4),
  five(5),
  six(6);

  final int count; // 数量
  const GridImageNumOptionsMap(this.count);

  // 重载toString
  @override
  String toString() {
    return count.toString();
  }
}