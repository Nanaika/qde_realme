import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../moferate_users/moderate_users_bloc.dart';
import '../../moferate_users/moderate_users_event.dart';
import '../../moferate_users/moderate_users_state.dart';

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
                    'Moderate users',
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
                        return const Center(child: Text("Empty"));
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ModerateUsersBloc>().add(ModerateUsersGetFirstEvent());
                        },
                        child: ListView.builder(
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
                            return Container(
                              padding: const EdgeInsets.all(30),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.id,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    user.email,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    user.number,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    'Moderated = ${user.isModerated.toString()}',
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final userId =
                                              (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                                          context.read<ModerateUsersBloc>().add(
                                            ModerateUserEvent(userId: userId, isModerated: true),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('confirm'),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          final userId =
                                              (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                                          context.read<ModerateUsersBloc>().add(
                                            ModerateUserEvent(userId: userId, isModerated: false),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('decline'),
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
