import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/history/history_bloc.dart';
import 'package:qde_realme/features/home/history/history_event.dart';
import 'package:qde_realme/features/home/history/history_state.dart';
import 'package:qde_realme/features/home/history/history_type.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
    context.read<HistoryBloc>().add(
      HistoryGetFirstEvent(userId: userId),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<HistoryBloc>().add(
        HistoryGetNextEvent(userId: userId),
      );
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
                    'History',
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryStateLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is HistoryStateError) {
                      return Center(
                        child: Text(state.failure.message),
                      );
                    }

                    if (state is HistoryStateSuccess) {
                      if (state.items.isEmpty) {
                        return const Center(
                          child: Text('History empty'),
                        );
                      }

                      final items = state.items;

                      return ListView.separated(
                        controller: _scrollController,
                        itemCount: items.length,
                        separatorBuilder: (sepContext, index) {
                          return const SizedBox(height: 20);
                        },
                        itemBuilder: (listContext, index) {
                          final item = items[index];
                          final type = HistoryType.fromString(item.type);

                          final color = switch (type) {
                            HistoryType.imeiPending => const Color(0xFFEAD920),
                            HistoryType.imeiAccepted => const Color(0xFF27ED5F),
                            HistoryType.imeiDeclined => const Color(0xFFFF472F),
                            HistoryType.imeiPaid => const Color(0xFFBFBDBD),
                            HistoryType.userAccepted => const Color(0xFF27ED5F),
                            HistoryType.userDeclined => const Color(0xFFFF472F),
                            HistoryType.userPending => const Color(0xFFEAD920),
                            HistoryType.other => const Color(0xFFBFBDBD),
                          };
                          final message = switch (type) {
                            HistoryType.imeiPending => 'Sale with imei ${item.message} on moderate',
                            HistoryType.imeiAccepted => 'Sale with imei ${item.message} approved',
                            HistoryType.imeiDeclined => 'Sale with imei ${item.message} rejected',
                            HistoryType.imeiPaid => 'Sale with imei ${item.message} paid',
                            HistoryType.userAccepted => 'User ${item.message} accepted',
                            HistoryType.userDeclined => 'User ${item.message} rejected',
                            HistoryType.userPending => 'User ${item.message} on moderate',
                            HistoryType.other => 'Other',
                          };

                          return Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF2A243A),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatDate(item.date),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
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

String formatDate(DateTime? dateTime) {
  if (dateTime != null) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  } else {
    return 'no date';
  }
}
