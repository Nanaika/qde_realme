import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_bloc.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_event.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_state.dart';
import 'package:qde_realme/features/home/presentation/pages/add_single_item_page.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../../../core/utils/uz_cities.dart';
import '../../../auth/data/models/user_model.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late final TextEditingController searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    context.read<ManageUsersBloc>().add(ManageUsersGetEvent());
    searchController = TextEditingController();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageUsersBloc, ManageUsersState>(
      listenWhen: (previous, current) {
        if (current is ManageUsersLoading && current.message == AppConstants.onPayLoading) {
          return true;
        }

        if (previous is ManageUsersLoading && previous.message == AppConstants.onPayLoading) {
          return true;
        }

        return false;
      },
      listener:
          (
            BuildContext context,
            state,
          ) {
            if (state is ManageUsersLoading && state.message == AppConstants.onPayLoading) {
              LoadingDialog.show(context);
            }

            if (state is ManageUsersSuccess || state is ManageUsersError) {
              LoadingDialog.hide(context);
            }
            if (state is ManageUsersError) {
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
                        'manage_users'.tr(),
                        style: ThemeTextStyles.titleMedium(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  textStyle: ThemeTextStyles.headlineMedium(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.grey),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
                  hintText: 'search'.tr(),
                  controller: searchController,
                ),
                const SizedBox(
                  height: 20,
                ),
                BlocBuilder<ManageUsersBloc, ManageUsersState>(
                  builder: (context, state) {
                    if (state is ManageUsersLoading && state.message == '') {
                      return const Expanded(child: Center(child: CircularProgressIndicator()));
                    }

                    // 2. Успешное состояние со списком юзеров
                    if (state is ManageUsersSuccess) {
                      final List<UserModel> users = state.users;

                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            'users_not_found'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      // 2. Фильтруем его по всем текстовым полям (приводим к lowerCase для точности)
                      final List<UserModel> filteredUsers = users.where((user) {
                        final query = _searchQuery;
                        if (query.isEmpty) return true; // Если поиск пустой — показываем всех

                        return user.id.toLowerCase().contains(query) ||
                            user.email.toLowerCase().contains(query) ||
                            (user.name ?? '').toLowerCase().contains(query) ||
                            user.number.toLowerCase().contains(query) ||
                            (user.city ?? '').toLowerCase().contains(query) ||
                            (user.district ?? '').toLowerCase().contains(query);
                      }).toList();

                      // 3. Если после фильтрации ничего не нашли
                      if (filteredUsers.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              'no_matching_users_found'.tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: ListView.separated(
                          itemCount: filteredUsers.length,
                          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                          itemBuilder: (ctx, index) {
                            final user = filteredUsers[index];
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A243A),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Icon(CupertinoIcons.person_alt_circle),
                                      ),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          user.name ?? 'no_name'.tr(),
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.phone),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          user.number,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.location_solid),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.envelope),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          user.email,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
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
                                          if (user.isModerated) {
                                            context.read<ManageUsersBloc>().add(
                                              ManageUsersPayEvent(userId: user.id),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'user_not_moderated'.tr(),
                                                  style: ThemeTextStyles.bodyMedium(context),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
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

                    if (state is ManageUsersError) {
                      return Center(
                        child: Text(
                          '${'error'.tr()}: ${state.failure}',
                          style: const TextStyle(color: Colors.red),
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
      ),
    );
  }
}
