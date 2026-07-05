import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/add_item/add_item_bloc.dart';
import 'package:qde_realme/features/home/add_item/add_item_event.dart';
import 'package:qde_realme/features/home/add_item/add_item_state.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';
import 'package:qde_realme/features/home/add_items/add_items_bloc.dart';
import 'package:qde_realme/features/home/add_items/add_items_event.dart';

import '../../add_items/add_items_state.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late final TextEditingController controller;
  String excelFilePath = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AddItemsBloc, AddItemsState>(
        builder: (BuildContext context, state) {
          if (state is AddItemsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AddItemsSuccess || state is AddItemsInitial) {
            return BlocConsumer<AddItemBloc, AddItemState>(
              builder: (BuildContext context, state) {
                if (state is AddItemLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AddItemSuccess || state is AddItemInitial) {
                  return SafeArea(
                    child: Column(
                      children: [
                        Text('ADDITEM PAGE'),
                        TextField(controller: controller),
                        ElevatedButton(
                          onPressed: () {
                            final item = ItemModel(id: '', imei: controller.text);
                            context.read<AddItemBloc>().add(AddEvent(item));
                          },
                          child: Text('add'),
                        ),

                        SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: () async {
                            excelFilePath = await pickExcelFile() ?? '';
                            setState(() {});
                          },
                          child: Text('excel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            context.read<AddItemsBloc>().add(ParseEvent(excelFilePath));
                          },
                          child: Text('Parse = ${excelFilePath}'),
                        ),
                        ElevatedButton(onPressed: () {
                          context.read<AddItemsBloc>().add(SaveExcelEvent());
                        }, child: Text('SAVE')),
                      ],
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
              listener: (BuildContext context, state) {
                if (state is AddItemError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
                }
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
        listener: (BuildContext context, state) {
          if (state is AddItemsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
          }
        },
      ),
    );
  }
}

Future<String?> pickExcelFile() async {
  final FilePickerResult? result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);

  if (result != null && result.files.single.path != null) {
    return result.files.single.path!;
  }

  return null;
}
