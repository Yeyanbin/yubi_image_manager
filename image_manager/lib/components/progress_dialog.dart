import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_manager/utils/util.dart';

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

class ProgressDialog extends StatefulWidget {
  ProgressController updateProgreeController;
  void Function() initCallBack;
  bool isShowClose;
  String closeBtnText;
  void Function()? closeCallback;

  ProgressDialog(
      {super.key,
      required this.updateProgreeController,
      required this.initCallBack,
      this.isShowClose = true,
      this.closeBtnText = '隐藏弹窗',
      this.closeCallback
    });

  @override
  _ProgressDialogState createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  late bool _value;
  double _progress = 0.0;
  String _progressName = '';
  bool isFinish = false;

  Debouncer debouncer = Debouncer(delay: Duration(milliseconds: 500));
  @override
  void initState() {
    super.initState();
    print('_ProgressDialogState initState');
    // 将组件内部的函数分配给控制器
    widget.updateProgreeController._onEventTriggered = _updateProgress;
    widget.updateProgreeController.getProgressCloseState = getIsFinish;

    // widget.updateProgreeController.bindEvent(_updateProgress); 也可以
    widget.initCallBack();
  }

  void _updateProgress(double newProgress, String progressName) {

    if (_progress > 1.0) {
      debouncer.finish();
      setState(() {
        _progress = newProgress;
        _progressName = progressName;
      });
    } else {
      debouncer.run(() {
        print('_updateProgress $newProgress');
        setState(() {
          _progress = newProgress;
          _progressName = progressName;
          // if (_progress > 1.0) {
          //   _progress = 0.0; // 重置进度条
          // }
        });
      });
    }
  }

  bool getIsFinish() {
    return isFinish;
  }

  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('进度条'),
        content: SizedBox(
          height: 200,
          width: 500,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$_progressName'),
                Text('Progress: ${YubiUtil.formatPercentage(_progress)}'),
                SizedBox(height: 20),
                ProgressManager.buildProgressBar(_progress),
                SizedBox(height: 20),
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
            onPressed: () {
              debouncer.finish();
              Navigator.of(context).pop();
              isFinish = true;
              if (widget.closeCallback != null) {
                widget.closeCallback!();
              }
            },
            child: Text(widget.closeBtnText))
        ]
      );
  }
}

class ProgressManager {
  static Widget buildProgressBar(double progressValue) {
    return LinearProgressIndicator(
      value: progressValue,
      minHeight: 10.0,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }
}

class ProgressController {
  void Function(double, String)? _onEventTriggered;
  bool Function()? getProgressCloseState;
  // bool Function()? getProgressCloseState;

  // 控制器方法，用于触发事件
  void triggerUpdateProgressEvent(double progress, String progressName) {
    if (_onEventTriggered != null) {
      _onEventTriggered!(progress, progressName);
    }
  }

  // 绑定组件的事件
  void bindEvent(void Function(double, String) callback) {
    _onEventTriggered = callback;
  }

  // bool getProgressCloseState() {

  // }
}

class Debouncer {
  final Duration delay;
  Timer? _timer;
  void Function()? _action;

  Debouncer({required this.delay}) {
    callback() {
      if (_action != null) {
        _action!();
      }
      _timer = Timer(delay, callback);
    };

    callback();
  }

  void run(void Function() action) {
    _action = action;
  }

  void finish() {
    if (_action != null) {
      _action!();
    }
    _timer?.cancel();
  }
}