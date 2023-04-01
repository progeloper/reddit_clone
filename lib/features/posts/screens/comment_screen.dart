import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/comment_card.dart';
import 'package:reddit_clione/core/common/error_text.dart';
import 'package:reddit_clione/core/common/loader.dart';
import 'package:reddit_clione/core/common/post_card.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clione/features/posts/controller/post_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../models/user_model.dart';
import '../../home/delegates/search_community_delegate.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  late TextEditingController commentController;

  void goBack(BuildContext context) {
    Routemaster.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void postComment(UserModel user) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context,
        text: commentController.text,
        user: user,
        postId: widget.postId);
    commentController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);

    return Scaffold(
      endDrawer: const ProfileDrawer(),
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => goBack(context),
            icon: const Icon(Icons.arrow_back),
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
                backgroundImage: NetworkImage(user!.profilePic),
              ),
            );
          }),
        ],
      ),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                  PostCard(post: post),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Add a comment',
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => postComment(user!),
                        child: Text('Post'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ref.watch(fetchCommentsProvider(widget.postId)).when(
                          data: (comments) {
                            return ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical:8.0),
                                  child: CommentCard(
                                    comment: comment,
                                  ),
                                );
                              },
                            );
                          },
                          error: (error, stackTrace) {
                            return const ErrorText(error: 'An error occurred');
                          },
                          loading: () => const Loader(),
                        ),
                  )
                ],
              );
            },
            error: (error, stackTrace) {
              return const ErrorText(error: 'An error occurred');
            },
            loading: () => const Loader(),
          ),
    );
  }
}
