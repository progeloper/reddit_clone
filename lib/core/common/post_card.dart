import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/posts/controller/post_controller.dart';
import 'package:reddit_clione/models/post_model.dart';
import 'package:reddit_clione/theme/palette.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  const PostCard({
    required this.post,
    Key? key,
  }) : super(key: key);

  void deletePost(WidgetRef ref, BuildContext context) {
    final user = ref.read(userProvider);
    ref
        .read(postControllerProvider.notifier)
        .deletePost(context, post, user!.uid);
  }

  void upvote(WidgetRef ref, BuildContext context){
    final user = ref.read(userProvider);
    ref.read(postControllerProvider.notifier).upvotePost(context, user!.uid, post);
  }

  void downvote(WidgetRef ref, BuildContext context){
    final user = ref.read(userProvider);
    ref.read(postControllerProvider.notifier).downvotePost(context, user!.uid, post);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final theme = ref.watch(themeNotifierProvider);

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.drawerTheme.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(post.communityProfilePic),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('r/${post.communityName}'),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                text: 'u/${post.username}',
                                children: [
                                  TextSpan(
                                      //TODO add timeago package
                                      text: ' • 1h')
                                ],
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(),
                        ),
                        IconButton(
                          onPressed: ()=>deletePost(ref, context),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (isTypeImage)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.network(
                                post.description!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (isTypeText)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            post.description!,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    if (isTypeLink)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          AnyLinkPreview(
                            link: post.link!,
                            displayDirection: UIDirection.uiDirectionHorizontal,
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: ()=>upvote(ref, context),
                          icon: Icon(
                            Icons.arrow_upward,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(post.upvotes.length.toString()),
                        IconButton(
                          onPressed: ()=>downvote(ref, context),
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.grey[600],
                          ),
                        ),
                        Flexible(flex: 2, child: Container()),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline),
                        ),
                        Text(post.commentCount.toString()),
                        Flexible(flex: 2, child: Container()),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                        ),
                        Flexible(flex: 1, child: Container())
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
