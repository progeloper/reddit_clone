import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/posts/controller/post_controller.dart';
import 'package:reddit_clione/models/comment_model.dart';
import 'package:reddit_clione/theme/palette.dart';


class CommentCard extends ConsumerWidget {
  final CommentModel comment;
  const CommentCard({
    required this.comment,
    Key? key,
  }) : super(key: key);

  void upvote(WidgetRef ref, BuildContext context, String userId){
    ref.read(postControllerProvider.notifier).upvoteComment(context, userId, comment);
  }

  void downvote(WidgetRef ref, BuildContext context, String userId){
    ref.read(postControllerProvider.notifier).downvoteComment(context, userId, comment);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeData theme = ref.watch(themeNotifierProvider);
    final user = ref.read(userProvider);
    final isGuest = !user!.isAuthenticated;
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
                            backgroundImage: NetworkImage(comment.avatar),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'u/${comment.username}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      comment.comment,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: isGuest? (){} : ()=>upvote(ref, context, user.uid),
                          icon: comment.upvotes.contains(user.uid)
                              ? Icon(
                                  Icons.arrow_upward,
                                  color: Colors.orange[900],
                                )
                              : Icon(
                                  Icons.arrow_upward,
                                  color: Colors.grey[600],
                                ),
                        ),
                        Text((comment.upvotes.length - comment.downvotes.length)
                            .toString()),
                        IconButton(
                          onPressed: isGuest? (){} : ()=> downvote(ref, context, user.uid),
                          icon: comment.downvotes.contains(user.uid)
                              ? Icon(
                                  Icons.arrow_downward,
                                  color: Colors.orange[900],
                                )
                              : Icon(
                                  Icons.arrow_downward,
                                  color: Colors.grey[600],
                                ),
                        ),
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
