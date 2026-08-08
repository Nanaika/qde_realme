import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_colors.dart';
import 'package:qde_realme/core/utils/uz_cities.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/presentation/pages/settings_page.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../moderate_users/moderate_users_bloc.dart';
import '../../moderate_users/moderate_users_event.dart';
import '../../moderate_users/moderate_users_state.dart';

class ModerateUsersPage extends StatefulWidget {
  const ModerateUsersPage({super.key});

  @override
  State<ModerateUsersPage> createState() => _ModerateUsersPageState();
}

class _ModerateUsersPageState extends State<ModerateUsersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ТУТ ПИНАЕМ БЛОК НА СТАРТЕ (Поменяй на свой эвент, например LoadUsers())
    context.read<ModerateUsersBloc>().add(ModerateUsersGetFirstEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // ТУТ ПОДГРУЖАЕМ СЛЕДУЮЩУЮ ПАЧКУ (Поменяй на свой эвент, например GetNextUsers())
      context.read<ModerateUsersBloc>().add(ModerateUsersGetNextEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'moderate_users'.tr(),
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              Expanded(
                child: BlocBuilder<ModerateUsersBloc, ModerateUsersState>(
                  builder: (context, state) {
                    if (state is ModerateUsersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ModerateUsersError) {
                      final message = state.failure;

                      return Center(child: Text(message.message));
                    }
                    if (state is ModerateUsersSuccess) {
                      if (state.items.isEmpty) {
                        return Center(child: Text('empty'.tr()));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ModerateUsersBloc>().add(ModerateUsersGetFirstEvent());
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: state.items.length + (state.isMoreLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final user = state.items[index];
                            final city = user.city ?? '';
                            final district = user.district ?? '';
                            String location = '';
                            if (district == '') {
                              location = LocationTranslator.translate(context, city);
                            } else {
                              location =
                                  '${LocationTranslator.translate(context, city)}, ${LocationTranslator.translate(context, district)}';
                            }
                            return Container(
                              padding: const EdgeInsets.all(17),
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
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Icon(
                                          CupertinoIcons.person_alt_circle,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          user.name ?? 'no_name'.tr(),
                                          style:
                                              ThemeTextStyles.headlineSmall(
                                                context,
                                              ).copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
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
                                          user.number,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.location_solid,
                                        size: 22,
                                      ),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
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
                                          user.email,
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
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (ctx) => AdaptiveDialog(
                                                title: 'reject_moderation_title'.tr(),
                                                content: 'are_you_sure_you_want_to_reject'.tr(),
                                                cancelText: 'cancel'.tr(),
                                                confirmText: 'reject'.tr(),
                                                confirmColor: ThemeColors.error,
                                                onConfirm: () {
                                                  final userId = user.id;
                                                  print('USER ID===================${userId}');
                                                  context.read<ModerateUsersBloc>().add(
                                                    ModerateUserEvent(userId: userId, isModerated: false),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: ThemeColors.error,
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'reject'.tr(),
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (ctx) => AdaptiveDialog(
                                                title: 'approve_moderation_title'.tr(),
                                                content: 'are_you_sure_you_want_to_approve'.tr(),
                                                cancelText: 'cancel'.tr(),
                                                confirmText: 'approve'.tr(),
                                                confirmColor: ThemeColors.success,
                                                onConfirm: () {
                                                  final userId = user.id;
                                                  context.read<ModerateUsersBloc>().add(
                                                    ModerateUserEvent(userId: userId, isModerated: true),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: ThemeColors.success,
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'approve'.tr(),
                                                style: const TextStyle(fontSize: 16),
                                              ),
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
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 16,
                            );
                          },
                        ),
                      );
                    }

                    // Вместо пустого SizedBox возвращаем крутилку для Initial стейта
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
