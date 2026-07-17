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
                    Text(
                      'Manage users',
                      style: ThemeTextStyles.titleMedium(context),
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
                  hintText: 'Search',
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
                        return const Center(
                          child: Text(
                            'Users not found',
                            style: TextStyle(color: Colors.grey),
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
                        return const Expanded(
                          child: Center(
                            child: Text(
                              'No matching users found',
                              style: TextStyle(color: Colors.grey),
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

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Иконка или аватарка юзера
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey[700],
                                          child: const Icon(Icons.person, color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Инфа о юзере (Имя / Email / Роль — подставь свои поля)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.id,
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),

                                            Text(
                                              user.email,
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              user.number == '' ? 'No number' : user.number,
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              user.name == '' ? 'No name' : user.name!,
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              user.city == '' ? 'No city' : user.city!,
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              user.district == '' ? 'No district' : user.district!,
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              'moderated : ${user.isModerated.toString()}',
                                              style: ThemeTextStyles.bodySmall(
                                                context,
                                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Шеврон вправо, если нужно проваливаться в детали юзера
                                      // const Icon(
                                      //   Icons.chevron_right,
                                      //   color: Colors.grey,
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                                  'User not moderated',
                                                  style: ThemeTextStyles.bodyMedium(context),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text(
                                            'Pay',
                                            style: ThemeTextStyles.chipLabel(
                                              context,
                                            ).copyWith(color: Colors.black),
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

                    // 3. Состояние ошибки
                    if (state is ManageUsersError) {
                      return Center(
                        child: Text(
                          'Ошибка: ${state.failure}',
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
