import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_bloc.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_event.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_state.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import 'add_single_item_page.dart';

class AddSalePage extends StatefulWidget {
  const AddSalePage({super.key});

  @override
  State<AddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSaleBloc, AddSaleState>(
      builder: (BuildContext context, state) {
        if (state is AddSaleLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
              child: Column(
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
                        'Add sale',
                        style: ThemeTextStyles.titleMedium(context),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ImeiTile(
                    title: 'IMEI',
                    hintText: '1234 5678 9012 3456',
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onScan: () async {
                      final bloc = context.read<AddSaleBloc>();
                      final scannedImei = await context.push<String?>(
                        '/imei_scanner_page',
                      ); // Твой путь к сканеру в GoRouter

                      if (scannedImei != null && scannedImei.isNotEmpty) {
                        setState(() {
                          controller.text = scannedImei;
                        });
                        bloc.add(GetPhoneByImeiEvent(imei: scannedImei));
                      }
                    },
                    onSuffixTap: () {
                      final bloc = context.read<AddSaleBloc>();
                      bloc.add(GetPhoneByImeiEvent(imei: controller.text));
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BlocBuilder<AddSaleBloc, AddSaleState>(
                    builder: (BuildContext context, state) {
                      if (state is GetPhoneByImeiSuccess) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Device information:',
                              style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                            ),
                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              'Articul: ${state.item.article}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              'imei1: ${state.item.imei1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              'imei2: ${state.item.imei2}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              'Sku name: ${state.item.skuName}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              'Bonus = ${state.bonus}\$',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      } else if (state is AddSaleError) {
                        return Text(
                          state.failure.message,
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const Spacer(),
                  BlocBuilder<AddSaleBloc, AddSaleState>(
                    builder: (BuildContext context, state) {
                      if (state is GetPhoneByImeiSuccess) {
                        return MainButton(
                          text: 'Send',
                          onTap: () {
                            final ownerId = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                            final sale = SaleModel(imei: controller.text, ownerId: ownerId, id: '', bonus: state.bonus);
                            context.read<AddSaleBloc>().add(AddEvent(sale));
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, state) {
        if (state is AddSaleSuccess) {
          context.pop();
        } else if (state is AddSaleError) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       state.failure.message,
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     backgroundColor: Colors.red,
          //   ),
          // );
        }
      },
    );
  }
}

class ImeiTile extends StatelessWidget {
  const ImeiTile({
    super.key,
    this.title = '',
    this.hintText = '',
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.onScan,
    this.fileName = '',
    this.onSuffixTap,
  });

  final String title;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final void Function()? onScan;
  final String fileName;
  final void Function()? onSuffixTap;

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
              CustomTextField(
                hintText: '1234 5678 9123 4567',
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textStyle: ThemeTextStyles.headlineMedium(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                suffixIcon: IconButton(onPressed: onSuffixTap, icon: const Icon(CupertinoIcons.search)),
              ),

              const SizedBox(
                height: 20,
              ),
              Center(
                child: GestureDetector(
                  onTap: onScan,
                  child: Container(
                    color: Colors.transparent,
                    child: Text(
                      'Scan',
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
