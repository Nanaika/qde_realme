import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/home/add_item/add_item_state.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';

import '../../add_item/add_item_bloc.dart';
import '../../add_item/add_item_event.dart';

class AddSingleItemPage extends StatefulWidget {
  const AddSingleItemPage({super.key});

  @override
  State<AddSingleItemPage> createState() => _AddSingleItemPageState();
}

class _AddSingleItemPageState extends State<AddSingleItemPage> {
  late final TextEditingController articleController;
  late final TextEditingController imei1Controller;
  late final TextEditingController imei2Controller;
  late final TextEditingController skuNameController;

  @override
  void initState() {
    super.initState();
    articleController = TextEditingController();
    imei1Controller = TextEditingController();
    imei2Controller = TextEditingController();
    skuNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddItemBloc, AddItemState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (BuildContext context, state) {
        if (state is AddItemLoading) {
          LoadingDialog.show(context);
        } else {
          if (ModalRoute.of(context)?.isCurrent == false) {
            LoadingDialog.hide(context);
          }
        }
        if (state is AddItemSuccess) {
          _clearControllers();
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
            child: Stack(
              children: [
                Column(
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
                          'Add item',
                          style: ThemeTextStyles.titleMedium(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Column(
                          children: [
                            Tile(
                              title: 'ARTICLE',
                              hintText: '123456789...',
                              controller: articleController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Tile(
                              title: 'IMEI 1',
                              hintText: '123456789...',
                              controller: imei1Controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Tile(
                              title: 'IMEI 2',
                              hintText: '123456789...',
                              controller: imei2Controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Tile(
                              title: 'SKU NAME',
                              hintText: 'realme 51 ...',
                              controller: skuNameController,
                              maxLines: null,
                            ),
                            const Opacity(
                              opacity: 0,

                              child: IgnorePointer(
                                child: MainButton(
                                  text: '',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MainButton(
                      text: 'Save',
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (articleController.text.isEmpty ||
                            imei1Controller.text.isEmpty ||
                            imei2Controller.text.isEmpty ||
                            skuNameController.text.isEmpty) {
                          ErrorDialog.show(context, 'Please fill all fields');
                          return;
                        }
                        final item = ItemModel(
                          id: '',
                          imei1: imei1Controller.text,
                          imei2: imei2Controller.text,
                          article: articleController.text,
                          skuName: skuNameController.text,
                        );
                        context.read<AddItemBloc>().add(AddEvent(item));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearControllers() {
    articleController.clear();
    imei1Controller.clear();
    imei2Controller.clear();
    skuNameController.clear();
  }
}

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    this.title = '',
    this.hintText = '',
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String title;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

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
              CustomTextField(
                hintText: hintText,
                controller: controller,
                inputFormatters: inputFormatters,
                keyboardType: keyboardType,
                maxLines: maxLines,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText = '',
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      controller: controller,
      style: ThemeTextStyles.headlineMedium(
        context,
      ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
      // Цвет вводимого текста
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(
          0x1A888888,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Убирает обводку даже при нажатии
        ),
      ),
    );
  }
}

class ErrorDialog {
  static void show(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: true, // Можно закрыть тапом по экрану
      barrierColor: Colors.black.withOpacity(0.4), // Темный полупрозрачный фон
      builder: (BuildContext context) {
        return BackdropFilter(
          // Мягкое размытие заднего фона
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0), // Красивые круглые углы
            ),
            backgroundColor: Colors.white,
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Диалог подстраивается под высоту контента
                children: [
                  // Красивая иконка ошибки с мягким красным фоном вокруг нее
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50]!, // Мягкий красный фон
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red[600],
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Заголовок
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Текст ошибки
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.4, // Межстрочный интервал для читаемости
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadingDialog {
  // Показать диалог
  static void show(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Крутилка
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 24),

                    // Текст
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
