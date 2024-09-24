import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('表单提交示例')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DatePickerFormDemo(),
        ),
      ),
    );
  }
}

class DatePickerFormDemo extends StatefulWidget {
  @override
  _DatePickerFormDemoState createState() => _DatePickerFormDemoState();
}

class _DatePickerFormDemoState extends State<DatePickerFormDemo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool isSort = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '名称'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入名称';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          CustomDatePickerFormField(
            labelText: '选择日期',
            onDateChanged: (date) {
              _selectedDate = date;
            },
            validator: (value) {
              if (value == null) {
                return '请选择日期';
              }
              return null;
            },
            context: context,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // 表单验证成功
                final name = _nameController.text;
                final date = _selectedDate;
                print('名称: $name');
                print('选择的日期: ${date?.toLocal()}');
              }
            },
            child: Text('提交'),
          ),
        ],
      ),
    );
  }
}

class CustomDatePickerFormField extends FormField<DateTime> {
  CustomDatePickerFormField({
    Key? key,
    required String labelText,
    FormFieldValidator<DateTime>? validator,
    required void Function(DateTime?) onDateChanged,
    required BuildContext context,
    DateTime? initialValue,
    bool? isShowTimePick,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState<DateTime> state) {
            final TextEditingController _controller = TextEditingController();
            _controller.text = state.value != null
                ? '${state.value!.toLocal().toString().split(' ')[0]} ${state.value!.hour}:${state.value!.minute.toString().padLeft(2, '0')}'
                : '';

            Future<void> _selectDateTime(BuildContext context) async {
              // 选择日期
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: state.value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              
              if (pickedDate == null) return;


              if (isShowTimePick ?? false) {
                // 选择时间
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(pickedDate),
                );

                if (pickedTime != null) {
                  final DateTime pickedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );

                  state.didChange(pickedDateTime);
                  _controller.text = '${pickedDateTime.toLocal().toString().split(' ')[0]} ${pickedDateTime.hour}:${pickedDateTime.minute.toString().padLeft(2, '0')}';
                  onDateChanged(pickedDateTime);
                }
              } else {
                  final DateTime pickedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    0,
                    0,
                  );
                  state.didChange(pickedDateTime);
                  _controller.text = '${pickedDateTime.toLocal().toString().split(' ')[0]} ${pickedDateTime.hour}:${pickedDateTime.minute.toString().padLeft(2, '0')}';
                  onDateChanged(pickedDateTime);
              }

            }

            return GestureDetector(
              onTap: () => _selectDateTime(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: labelText,
                      errorText: state.errorText,
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
