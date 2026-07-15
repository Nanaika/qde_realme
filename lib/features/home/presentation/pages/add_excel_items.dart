import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/home/add_items/add_items_bloc.dart';

import '../../add_items/add_items_event.dart';
import '../../add_items/add_items_state.dart';

class AddExcelItems extends StatefulWidget {
  const AddExcelItems({super.key});

  @override
  State<AddExcelItems> createState() => _AddExcelItemsState();
}

class _AddExcelItemsState extends State<AddExcelItems> {
  String excelFilePath = 'file name';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddItemsBloc, AddItemsState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (BuildContext context, state) {
        if (state is AddItemsLoading) {
        } else {
          if (ModalRoute.of(context)?.isCurrent == false) {}
        }
        if (state is AddItemsSuccess) {}
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(LocaleKeys.home_title.tr()),
        //   actions: const [LanguageToggle(), ThemeToggle()],
        // ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: const Icon(CupertinoIcons.arrow_left),
                      ),
                    ),
                    SizedBox(
                      width: ThemeDimensions.paddingM,
                    ),
                    Text(
                      'Import excel file',
                      style: ThemeTextStyles.titleMedium(context),
                    ),
                  ],
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please pick excel file',
                        style: ThemeTextStyles.titleMedium(context),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ExcelTile(
                        title: 'File name',
                        fileName: excelFilePath,
                        onOpen: () async {
                          // 1. Забираем Блок сразу, пока контекст жив и стабилен
                          final bloc = context.read<AddItemsBloc>();

                          // 2. Ждем файл
                          final filePath = await pickExcelFile() ?? '';

                          // 3. Если путь пустой — ничего не делаем
                          if (filePath.isEmpty) return;

                          // 4. Проверяем, что виджет все еще на экране (монтирован)
                          if (!mounted) return;

                          // 5. Передаем путь и обновляем стейт
                          excelFilePath = filePath;
                          bloc.add(ParseEvent(excelFilePath));
                          setState(() {});
                        },
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: MainButton(
                          text: 'Save',
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExcelTile extends StatelessWidget {
  const ExcelTile({
    super.key,
    this.title = '',
    this.hintText = '',
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.onOpen,
    this.fileName = '',
  });

  final String title;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final void Function()? onOpen;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ThemeTextStyles.titleSmall(context).copyWith(color: Colors.black),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(
                    0x1A888888,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.device_phone_portrait,
                          color: Colors.black,
                          size: 15,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            fileName,
                            style: ThemeTextStyles.inputLabel(context).copyWith(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: GestureDetector(
                  onTap: onOpen,
                  child: Container(
                    color: Colors.transparent,
                    child: Text(
                      'Open',
                      style: ThemeTextStyles.headlineMedium(
                        context,
                      ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
