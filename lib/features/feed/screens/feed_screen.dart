import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/error_text.dart';
import 'package:reddit_clione/core/common/loader.dart';
import 'package:reddit_clione/core/common/post_card.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/community/controller/community_controller.dart';
import 'package:reddit_clione/features/posts/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final isGuest = !user!.isAuthenticated;


    if(isGuest){
      return ref.watch(fetchGuestFeedProvider).when(
          data: (posts) {
            return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: PostCard(post: post),
                  );
                });
          },
          error: (error, stackTrace) {
            return const ErrorText(error: 'An error occurred');
          },
          loading: () => const Loader());
    }

    return ref.watch(userCommunitiesProvider).when(
        data: (communities) {
          return ref.watch(fetchUserFeedProvider(communities)).when(
              data: (posts) {
                return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PostCard(post: post),
                      );
                    });
              },
              error: (error, stackTrace) {
                return const ErrorText(error: 'An error occurred');
              },
              loading: () => const Loader());
        },
        error: (error, stackTrace) {
          return ErrorText(error: error.toString());
        },
        loading: () => const Loader());
  }
}
