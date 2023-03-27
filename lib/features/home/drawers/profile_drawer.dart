import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({
    Key? key,
  }) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.65,
      elevation: 12,
      child: SafeArea(
        child: user == null
            ? Container()
            : Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.profilePic),
                    radius: 70,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'u/${user.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    thickness: 0.5,
                  ),
                  ListTile(
                    title: const Text('My Profile'),
                    leading: const Icon(
                      Icons.person,
                    ),
                    onTap: () => navigateToUserProfile(context, user.uid),
                  ),
                  ListTile(
                    title: const Text('Log Out'),
                    leading: Icon(
                      Icons.logout,
                      color: Palette.redColor,
                    ),
                    onTap: () => signOut(ref),
                  ),
                  Switch.adaptive(
                    value: ref.watch(themeNotifierProvider.notifier).mode ==
                        ThemeMode.dark,
                    onChanged: (val) => toggleTheme(ref),
                  ),
                ],
              ),
      ),
    );
  }
}
