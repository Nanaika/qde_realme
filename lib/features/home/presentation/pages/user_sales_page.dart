import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/home/presentation/pages/settings_page.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../user_sales/user_sale_bloc.dart';
import '../../user_sales/user_sales_event.dart';
import '../../user_sales/user_sales_state.dart';
import 'add_single_item_page.dart';
import 'history_page.dart';

class UserSalesPage extends StatefulWidget {
  const UserSalesPage({super.key, required this.user});

  final UserModel user;

  @override
  State<UserSalesPage> createState() => _UserSalesPageState();
}

class _UserSalesPageState extends State<UserSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
          child: Column(
            children: <Widget>[
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
                  Expanded(
                    child: Text(
                      'user_sales'.tr(),
                      style: ThemeTextStyles.titleMedium(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              BlocBuilder<UserSalesBloc, UserSalesState>(
                builder: (context, state) {
                  if (state is UserSalesLoading) {
                    return const Expanded(child: Center(child: CircularProgressIndicator()));
                  }

                  if (state is UserSalesError) {
                    return Expanded(child: Center(child: Text(state.failure)));
                  }

                  if (state is UserSalesSuccess) {
                    if (state.data.isEmpty) {
                      return Expanded(child: Center(child: Text('no_sales'.tr())));
                    }

                    return Expanded(
                      child: ListView.separated(
                        separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                        itemCount: state.data.length,
                        itemBuilder: (context, index) {
                          final sale = state.data[index];
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2A243A),
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.clock,
                                      size: 22,
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Expanded(
                                      child: Text(
                                        formatDate(sale.dateAdded),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'device_info'.tr(),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'imei1'.tr(args: [sale.imei]),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'imei2'.tr(args: [sale.imei2]),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'article'.tr(args: [sale.article]),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'sku_name'.tr(args: [sale.skuName]),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'bonus'.tr(args: [sale.bonus.toString()]),

                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'user_info'.tr(),
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.person_alt_circle,
                                      size: 22,
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Expanded(
                                      child: Text(
                                        sale.ownerName,
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.phone,
                                      size: 22,
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Expanded(
                                      child: Text(
                                        sale.ownerNumber,
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.envelope,
                                      size: 22,
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Expanded(
                                      child: Text(
                                        sale.ownerEmail,
                                        style: ThemeTextStyles.headlineSmall(
                                          context,
                                        ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.user.isModerated) {
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (ctx) => AdaptiveDialog(
                                              title: 'payment_title'.tr(),
                                              content: 'are_you_sure_you_want_to_pay'.tr(),
                                              cancelText: 'cancel'.tr(),
                                              confirmText: 'pay'.tr(),
                                              confirmColor: Colors.yellow,
                                              onConfirm: () {
                                                context.read<UserSalesBloc>().add(
                                                  PaySaleEvent(widget.user.id, sale.id),
                                                );
                                              },
                                            ),
                                          );
                                        } else {
                                          ErrorDialog.show(context, 'user_not_moderated'.tr());
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        width: MediaQuery.widthOf(context) / 2,
                                        decoration: BoxDecoration(
                                          color: Colors.yellow,
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'pay'.tr(),
                                            style: ThemeTextStyles.chipLabel(
                                              context,
                                            ).copyWith(color: Colors.black, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
  }
}
