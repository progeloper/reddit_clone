import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/loader.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  void navigateToEditProfileScreen(BuildContext context, String uid) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(userProvider)!;

    return Scaffold(
      body: ref.watch(userDataProvider(uid)).when(
            data: (user) {
              return NestedScrollView(
                headerSliverBuilder: (context, isInnerBoxScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      snap: true,
                      floating: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              user.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding:
                                const EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 45,
                            ),
                          ),
                          currentUser.uid == user.uid
                              ? Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.all(20),
                                  child: OutlinedButton(
                                    onPressed: ()=>navigateToEditProfileScreen(context, uid),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                    ),
                                    child: const Text('Edit Profile'),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.all(20),
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                    ),
                                    child: const Text('Follow'),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'u/${user.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text('${user.karma} karma'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                        ]),
                      ),
                    ),
                  ];
                },
                body: const Text('Posts'),
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
