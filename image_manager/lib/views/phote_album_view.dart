import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_manager/album_preview_screen.dart';
import 'package:image_manager/components/image_card.dart';
import 'package:image_manager/provider/image_provider.dart';
import 'package:image_manager/provider/setting_provider.dart';
import 'package:image_manager/utils/emuns.dart';
import 'package:image_manager/utils/util.dart';
import 'package:image_manager/views/album_form_dialog_view.dart';

class PhoteAlbumView extends ConsumerStatefulWidget {
  PhoteAlbumView();

  @override
  _PhoteAlbumViewState createState() => _PhoteAlbumViewState();
}

class _PhoteAlbumViewState extends ConsumerState<PhoteAlbumView> {
  @override
  Widget build(BuildContext context) {
    // final images = ref.watch(imageProvider);
    final ablumList = ref.watch(albumListProvider);
    final settingDataState = ref.watch(settingDataProvider);
    if (settingDataState.settingData.albumSortOption == AlbumSortOptionsMap.timeSort) {
      ablumList.sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });
    }
    print('image album update ablum: ${ablumList.length}');


    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0, // 每个网格项的最大宽度
        crossAxisSpacing: 36.0, // 网格项之间的水平间距
        mainAxisSpacing: 36.0, // 网格项之间的垂直间距
        childAspectRatio: 1, // 网格项的宽高比（宽度/高度）
      ),
      itemCount: ablumList.length + 1,
      itemBuilder: (context, index) {
        return index == 0
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 92,
                  onPressed: () {
                    _showFormDialog(context);
                  },
                ),
              )
            : Container(
                // height: 500,
                child:  !ablumList[index - 1].images.isEmpty ? ImageCard(
                  showModifyFormDialog: () => _showModifyFormDialog(context, index - 1),
                  imageFile: ablumList[index - 1].images[ablumList[index - 1].coverIndex],
                  title: ablumList[index - 1].name,
                  description:
                    '${dateRangeStr(ablumList[index - 1].startDate, ablumList[index - 1].endDate)}\n照片：${ablumList[index - 1].images.length}张    已收藏：${ablumList[index -1].starFileNames.length}张',
                  onTap: () => _openImagePreview(index - 1, context),
              ): Text('BUG')
            );
      },
    );
  }

  void _openImagePreview(int initialIndex, context) {
    ref.read(currentAlbumIndexProvider.notifier).state = initialIndex;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumPreviewScreen(),
      ),
    );
  }

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlbumFormDialogView();
      },
    );
  }
  void _showModifyFormDialog(BuildContext context, int albumIndex) {
    ref.read(currentAlbumIndexProvider.notifier).state = albumIndex;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlbumFormDialogView(isModify: true);
      },
    );
  }
}
