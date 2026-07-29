import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_colors.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/presentation/pages/settings_page.dart';
import 'package:qde_realme/features/home/presentation/pages/slave_home_content_page.dart';

class HomePageSlave extends StatefulWidget {
  const HomePageSlave({super.key});

  @override
  State<HomePageSlave> createState() => _HomePageSlaveState();
}

class _HomePageSlaveState extends State<HomePageSlave> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthAuthenticated) {
          if (state.isUserLoaded) {
            if (!state.currentUser.isModerated && !state.onModeration) {
              context.push('/confirm_account');
            }
          }
        }
      },
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [SlaveHomeContentPage(), SettingsPage()],
        ),
        bottomNavigationBar: StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setLocalState) {
            return BottomAppBar(
              height: 60,
              padding: EdgeInsets.zero,

              color: const Color(0xFF2A243A),
              child: Row(
                mainAxisAlignment: .spaceAround,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setLocalState(() {
                          _currentIndex = 0;
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: Container(
                        height: 60,
                        color: Colors.transparent,
                        child: Icon(
                          CupertinoIcons.house_alt,
                          color: _currentIndex != 0 ? Colors.white : ThemeColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setLocalState(() {
                          _currentIndex = 1;
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Icon(
                          CupertinoIcons.settings,
                          color: _currentIndex != 1 ? Colors.white : ThemeColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // child: Scaffold(
      //   body: SafeArea(
      //     child: Padding(
      //       padding: EdgeInsets.only(
      //         top: ThemeDimensions.paddingM,
      //         left: ThemeDimensions.paddingM,
      //         right: ThemeDimensions.paddingM,
      //       ),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.stretch,
      //         children: [
      //           Row(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               BlocBuilder<AuthBloc, AuthState>(
      //                 builder: (BuildContext context, AuthState state) {
      //                   final String text;
      //                   if (state is AuthAuthenticated) {
      //                     final name = state.currentUser.name != '' || state.currentUser.name != null
      //                         ? state.currentUser.name
      //                         : '';
      //                     if (name != '') {
      //                       text = 'hello_user'.tr(args: [?state.currentUser.name]);
      //                     } else {
      //                       text = 'hello'.tr();
      //                     }
      //                   } else {
      //                     text = 'hello'.tr();
      //                   }
      //                   return Expanded(
      //                     child: Text(
      //                       text,
      //                       maxLines: 2,
      //                       style: ThemeTextStyles.headlineLarge(context),
      //                       overflow: TextOverflow.ellipsis,
      //                     ),
      //                   );
      //                 },
      //               ),
      //               const SizedBox(
      //                 width: 10,
      //               ),
      //               GestureDetector(
      //                 onTap: () {
      //                   context.push('/history');
      //                 },
      //                 child: Container(
      //                   decoration: const BoxDecoration(color: Colors.transparent),
      //                   child: const Icon(CupertinoIcons.clock),
      //                 ),
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 16,
      //           ),
      //           Expanded(
      //             child: BlocConsumer<SlaveDataBloc, SlaveDataState>(
      //               builder: (BuildContext context, state) {
      //                 if (state is SlaveDataLoading) {
      //                   return const Center(child: CircularProgressIndicator());
      //                 } else if (state is SlaveDataSuccess) {
      //                   return RefreshIndicator(
      //                     onRefresh: () async {
      //                       _initData();
      //                     },
      //                     child: SingleChildScrollView(
      //                       physics: const AlwaysScrollableScrollPhysics(),
      //                       child: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Padding(
      //                             padding: const EdgeInsets.only(left: 5.0),
      //                             child: Text(
      //                               overflow: TextOverflow.ellipsis,
      //                               'total'.tr(),
      //                               style: ThemeTextStyles.custom(
      //                                 context: context,
      //                                 fontSize: 20,
      //                                 fontWeight: FontWeight.w700,
      //                                 color: Colors.white,
      //                               ),
      //                             ),
      //                           ),
      //                           const SizedBox(
      //                             height: 17,
      //                           ),
      //                           Container(
      //                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      //                             decoration: BoxDecoration(
      //                               color: const Color(0xFF2A243A),
      //                               borderRadius: BorderRadius.circular(16.0),
      //                             ),
      //                             child: Center(
      //                               child: Text(
      //                                 '${state.data.bonusesSum} USD',
      //                                 style: ThemeTextStyles.custom(
      //                                   context: context,
      //                                   fontSize: 36,
      //                                   fontWeight: FontWeight.w700,
      //                                   color: Colors.white,
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                           const SizedBox(
      //                             height: 34,
      //                           ),
      //
      //                           IntrinsicHeight(
      //                             child: Row(
      //                               crossAxisAlignment: CrossAxisAlignment.stretch,
      //                               children: [
      //                                 Expanded(
      //                                   child: Column(
      //                                     crossAxisAlignment: CrossAxisAlignment.start,
      //                                     children: [
      //                                       Padding(
      //                                         padding: const EdgeInsets.only(left: 5.0),
      //                                         child: Text(
      //                                           overflow: TextOverflow.ellipsis,
      //                                           'accepted'.tr(),
      //                                           style: ThemeTextStyles.custom(
      //                                             context: context,
      //                                             fontSize: 20,
      //                                             fontWeight: FontWeight.w700,
      //                                             color: Colors.white,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       const SizedBox(
      //                                         height: 17,
      //                                       ),
      //                                       Expanded(
      //                                         child: Container(
      //                                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      //                                           decoration: BoxDecoration(
      //                                             color: const Color(0xFF2A243A),
      //                                             borderRadius: BorderRadius.circular(16.0),
      //                                           ),
      //                                           child: Center(
      //                                             child: Text(
      //                                               '${state.data.acceptedSum}',
      //                                               style: ThemeTextStyles.custom(
      //                                                 context: context,
      //                                                 fontSize: 32,
      //                                                 fontWeight: FontWeight.w700,
      //                                                 color: const Color(0xFF27ED5F),
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                                 const SizedBox(
      //                                   width: 20,
      //                                 ),
      //                                 Expanded(
      //                                   child: Column(
      //                                     crossAxisAlignment: CrossAxisAlignment.start,
      //                                     children: [
      //                                       Padding(
      //                                         padding: const EdgeInsets.only(left: 5.0),
      //                                         child: Text(
      //                                           'declined'.tr(),
      //                                           overflow: TextOverflow.ellipsis,
      //                                           style: ThemeTextStyles.custom(
      //                                             context: context,
      //                                             fontSize: 20,
      //                                             fontWeight: FontWeight.w700,
      //                                             color: Colors.white,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       const SizedBox(
      //                                         height: 17,
      //                                       ),
      //                                       Expanded(
      //                                         child: Container(
      //                                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      //                                           decoration: BoxDecoration(
      //                                             color: const Color(0xFF2A243A),
      //                                             borderRadius: BorderRadius.circular(16.0),
      //                                           ),
      //                                           child: Center(
      //                                             child: Text(
      //                                               '${state.data.declinedSum}',
      //                                               style: ThemeTextStyles.custom(
      //                                                 context: context,
      //                                                 fontSize: 32,
      //                                                 fontWeight: FontWeight.w700,
      //                                                 color: const Color(0xFFFF472F),
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                           const SizedBox(
      //                             height: 34,
      //                           ),
      //                           IntrinsicHeight(
      //                             child: Row(
      //                               crossAxisAlignment: CrossAxisAlignment.stretch,
      //                               children: [
      //                                 Expanded(
      //                                   child: Column(
      //                                     crossAxisAlignment: CrossAxisAlignment.start,
      //                                     children: [
      //                                       Padding(
      //                                         padding: const EdgeInsets.only(left: 5.0),
      //                                         child: Text(
      //                                           'waiting'.tr(),
      //                                           overflow: TextOverflow.ellipsis,
      //                                           style: ThemeTextStyles.custom(
      //                                             context: context,
      //                                             fontSize: 20,
      //                                             fontWeight: FontWeight.w700,
      //                                             color: Colors.white,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       const SizedBox(
      //                                         height: 17,
      //                                       ),
      //                                       Expanded(
      //                                         child: Container(
      //                                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      //                                           decoration: BoxDecoration(
      //                                             color: const Color(0xFF2A243A),
      //                                             borderRadius: BorderRadius.circular(16.0),
      //                                           ),
      //                                           child: Center(
      //                                             child: Text(
      //                                               '${state.data.awaitingSum}',
      //                                               style: ThemeTextStyles.custom(
      //                                                 context: context,
      //                                                 fontSize: 32,
      //                                                 fontWeight: FontWeight.w700,
      //                                                 color: const Color(0xFFFFEF40),
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                                 const SizedBox(
      //                                   width: 20,
      //                                 ),
      //                                 Expanded(
      //                                   child: Column(
      //                                     crossAxisAlignment: CrossAxisAlignment.start,
      //                                     children: [
      //                                       Padding(
      //                                         padding: const EdgeInsets.only(left: 5.0),
      //                                         child: Text(
      //                                           'paid'.tr(),
      //                                           overflow: TextOverflow.ellipsis,
      //                                           style: ThemeTextStyles.custom(
      //                                             context: context,
      //                                             fontSize: 20,
      //                                             fontWeight: FontWeight.w700,
      //                                             color: Colors.white,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       const SizedBox(
      //                                         height: 17,
      //                                       ),
      //                                       Expanded(
      //                                         child: Container(
      //                                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      //                                           decoration: BoxDecoration(
      //                                             color: const Color(0xFF2A243A),
      //                                             borderRadius: BorderRadius.circular(16.0),
      //                                           ),
      //                                           child: Center(
      //                                             child: Text(
      //                                               '${state.data.paidSum}',
      //                                               style: ThemeTextStyles.custom(
      //                                                 context: context,
      //                                                 fontSize: 32,
      //                                                 fontWeight: FontWeight.w700,
      //                                                 color: const Color(0xFFBFBDBD),
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //
      //                           ElevatedButton(
      //                             onPressed: () {
      //                               context.push('/homeadmin');
      //                             },
      //                             child: const Text('Change to admin'),
      //                           ),
      //                           const SizedBox(
      //                             height: 60,
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   );
      //                 }
      //                 return const SizedBox.shrink();
      //               },
      //               listener: (BuildContext context, state) {
      //                 if (state is SlaveDataError) {
      //                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
      //                 }
      //               },
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      //   floatingActionButton: FloatingActionButton.extended(
      //     backgroundColor: ThemeColors.primaryDark,
      //
      //     onPressed: () {
      //       context.push('/add_sale');
      //     },
      //     label: Text('add_sale'.tr()),
      //   ),
      //   bottomNavigationBar: BottomAppBar(
      //     height: 60,
      //
      //     color: Color(0xFF2A243A),
      //     child: Row(
      //       mainAxisAlignment: .spaceAround,
      //       children: [Icon(CupertinoIcons.house_alt), Icon(CupertinoIcons.settings)],
      //     ),
      //   ),
      // ),
    );
  }
}
