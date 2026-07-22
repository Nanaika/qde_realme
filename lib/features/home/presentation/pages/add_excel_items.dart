import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/home/add_items/add_items_bloc.dart';
import 'package:qde_realme/features/home/presentation/pages/add_single_item_page.dart';

import '../../add_items/add_items_event.dart';
import '../../add_items/add_items_state.dart';

class AddExcelItems extends StatefulWidget {
  const AddExcelItems({super.key});

  @override
  State<AddExcelItems> createState() => _AddExcelItemsState();
}

class _AddExcelItemsState extends State<AddExcelItems> {
  String excelFilePath = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddItemsBloc, AddItemsState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (BuildContext context, state) {
        if (state is AddItemsLoading) {
          LoadingDialog.show(context);
        } else {
          if (ModalRoute.of(context)?.isCurrent == false) {}
        }
        if (state is AddItemsSuccess) {
          LoadingDialog.hide(context);
          if (state.message == '') {
            setState(() {
              excelFilePath = '';
            });
          }
        }
        if (state is AddItemsError) {
          LoadingDialog.hide(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.failure.message,
                style: ThemeTextStyles.bodyMedium(context),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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
                      'import_excel_file'.tr(),
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
                        'please_pick_excel_file'.tr(),
                        style: ThemeTextStyles.titleMedium(context),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ExcelTile(
                        title: 'file_name'.tr(),
                        fileName: p.basename(excelFilePath),
                        onOpen: () async {
                          final bloc = context.read<AddItemsBloc>();

                          final filePath = await pickExcelFile() ?? '';

                          if (filePath.isEmpty) return;

                          if (!mounted) return;

                          excelFilePath = filePath;
                          bloc.add(ParseEvent(excelFilePath));
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: MainButton(
                          text: 'save'.tr(),
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            context.read<AddItemsBloc>().add(SaveExcelEvent());
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
            color: const Color(0xFF2A243A),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ThemeTextStyles.titleSmall(context).copyWith(color: Colors.white),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(10),
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
                        const Icon(
                          CupertinoIcons.device_phone_portrait,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            fileName,
                            style: ThemeTextStyles.inputLabel(context).copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<AddItemsBloc, AddItemsState>(
                      builder: (BuildContext context, state) {
                        if (state is AddItemsSuccess) {
                          if (state.message == AppConstants.parseComplete) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: CompleteTile(),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
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
                      'open'.tr(),
                      style: ThemeTextStyles.headlineMedium(
                        context,
                      ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
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

class CompleteTile extends StatelessWidget {
  const CompleteTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'completed'.tr(),
          style: ThemeTextStyles.bodySmall(
            context,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        const SizedBox(
          width: 4,
        ),
        const Icon(
          CupertinoIcons.checkmark_alt_circle_fill,
          color: Colors.green,
          size: 12,
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
