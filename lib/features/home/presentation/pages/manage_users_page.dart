import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_bloc.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_event.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_state.dart';

import '../../../auth/data/models/user_model.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  @override
  void initState() {
    super.initState();
    // Триггерим загрузку пользователей при входе на экран
    context.read<ManageUsersBloc>().add(ManageUsersGetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление пользователями'),
      ),
      body: BlocBuilder<ManageUsersBloc, ManageUsersState>(
        builder: (context, state) {
          if (state is ManageUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Успешное состояние со списком юзеров
          if (state is ManageUsersSuccess) {
            final List<UserModel> users = state.users;

            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'Пользователи не найдены',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 16),
              itemBuilder: (ctx, index) {
                final user = users[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Иконка или аватарка юзера
                          CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 16),

                          // Инфа о юзере (Имя / Email / Роль — подставь свои поля)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.id ?? 'Без имени',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  user.number ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  user.isModerated.toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Шеврон вправо, если нужно проваливаться в детали юзера
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<ManageUsersBloc>().add(
                                  ManageUsersPayEvent(userId: user.id),
                                );
                              },
                              child: Text('pay'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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
    );
  }
}
