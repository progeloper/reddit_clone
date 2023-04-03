import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/constants/constants.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clione/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_clione/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clione/theme/palette.dart';

import '../../../models/user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ref.watch(themeNotifierProvider);
    final UserModel user = ref.read(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Home'),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              displayDrawer(context);
            },
            icon: const Icon(Icons.menu),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                displayEndDrawer(context);
              },
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
            );
          }),
        ],
      ),
      body: Constants.tabScreens[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest? null : const ProfileDrawer(),
      bottomNavigationBar: isGuest? null : CupertinoTabBar(
        backgroundColor: theme.backgroundColor,
        activeColor: theme.iconTheme.color,
        onTap: onPageChanged,
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), tooltip: 'Home feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add), tooltip: 'Add a post'),
        ],
      ),
    );
  }
}
