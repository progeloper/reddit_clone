import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/error_text.dart';
import 'package:reddit_clione/core/common/loader.dart';
import 'package:reddit_clione/features/community/controller/community_controller.dart';
import 'package:reddit_clione/features/posts/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
        data: (communities) {
          return ref.watch(fetchUserFeedProvider(communities)).when(
              data: (posts) {
                print('hello');
                return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return ListTile(
                        title: Text(post.title),
                      );
                    });
              },
              error: (error, stackTrace) {
                print("${error.toString()} ${stackTrace.toString()}");
                return ErrorText(error: 'An error occurred');
              },
              loading: () => const Loader());
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
