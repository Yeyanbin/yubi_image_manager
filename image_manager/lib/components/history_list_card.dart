import 'package:flutter/material.dart';
import 'package:image_manager/components/hover_component.dart';

class HistoryListCard extends StatelessWidget {
  // 接收传入的历史路径列表
  final List<String> historyPathList;
  void Function(String pathName) onOpen;
  void Function() onClear;

  HistoryListCard({super.key,
    required this.historyPathList,
    required this.onOpen,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0, // 卡片的阴影
      margin: const EdgeInsets.all(16.0), // 卡片的外边距
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // 圆角
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // 卡片内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.black54),
                const SizedBox(width: 8,),
                const Text(
                  '历史文件夹',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  // color: Colors.red.shade400,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            '是否清除文件夹历史',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const SizedBox(
                            height: 100,
                            width: 300,
                            child: Text('保留收藏和相册配置。仅清理这里的文件夹历史列表。'),
                          ),
                          actions: [
                            TextButton(onPressed: () {
                              onClear();
                              Navigator.of(context).pop();
                            }, child: const Text('清除')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('取消')
                            ),
                          ]
                        );
                      },
                    );
                  },
                )
              ],
            ),
            const Divider(), // 分割线
            // 使用ListView.builder生成动态列表
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: historyPathList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Row(
                      children: [
                        HoverComponent(
                          width: 320,
                          componentWidth: 50,
                          content: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(
                                historyPathList[index],
                                maxLines: 3, // 最多显示3行
                                overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            hoverComponent: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: const Icon(Icons.folder_open), 
                                onPressed: () { 
                                  onOpen(historyPathList[index]);
                                },
                              ),
                            )),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 主函数：演示如何使用HistoryCard组件
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // 模拟历史路径列表
//     List<String> historyPathList = [
//       '/home/user/documents',
//       '/downloads',
//       '/music',
//       '/pictures',
//       '/videos',
//             '/home/user/documents',
//       '/downloads',
//       '/music',
//       '/pictures',
//       '/videos',
//             '/home/user/documents',
//       '/downloads',
//       '/music',
//       '/pictures',
//       '/videos'
//     ];

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('History Card Example'),
//         ),
//         body: Center(
//           // 使用传入的historyPathList创建HistoryCard组件
//           child: HistoryListCard(historyPathList: historyPathList),
//         ),
//       ),
//     );
//   }
// }
