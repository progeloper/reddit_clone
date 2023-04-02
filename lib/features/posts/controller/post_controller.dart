import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/providers/storage_repository_provider.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/posts/repository/post_repository.dart';
import 'package:reddit_clione/models/comment_model.dart';
import 'package:reddit_clione/models/community_model.dart';
import 'package:reddit_clione/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils.dart';
import '../../../models/user_model.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final repository = ref.read(postRepositoryProvider);
  final storageRepository = ref.read(firebaseStorageRepoProvider);
  return PostController(
      repository: repository, ref: ref, storageRepository: storageRepository);
});

final fetchUserFeedProvider =
    StreamProvider.family((ref, List<CommunityModel> communities) {
  final controller = ref.read(postControllerProvider.notifier);
  return controller.fetchUserFeed(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String id) {
  final controller = ref.read(postControllerProvider.notifier);
  return controller.getPostFromId(id);
});

final fetchCommentsProvider = StreamProvider.family((ref, String postId){
  final controller = ref.read(postControllerProvider.notifier);
  return controller.fetchPostComments(postId);
});


class PostController extends StateNotifier<bool> {
  final PostRepository _repository;
  final Ref _ref;
  final FirebaseStorageRepository _storageRepository;
  PostController(
      {required PostRepository repository,
      required Ref ref,
      required FirebaseStorageRepository storageRepository})
      : _repository = repository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost(
      {required BuildContext context,
      required String title,
      required String description,
      required CommunityModel community,
      required UserModel user}) async {
    state = true;
    String id = const Uuid().v1();
    final user = _ref.read(userProvider);
    final post = PostModel(
        id: id,
        title: title,
        communityName: community.name,
        communityProfilePic: community.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        description: description);
    final res = await _repository.addPost(post);
    res.fold((l) => showSnackBar(context, l.toString()), (r) {
      showSnackBar(context, 'Post shared successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required String link,
      required CommunityModel community,
      required UserModel user}) async {
    state = true;
    final id = const Uuid().v1();
    final user = _ref.read(userProvider);
    final post = PostModel(
        id: id,
        title: title,
        communityName: community.name,
        communityProfilePic: community.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);
    final res = await _repository.addPost(post);
    res.fold((l) => showSnackBar(context, l.toString()), (r) {
      showSnackBar(context, 'Post shared successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost(
      {required BuildContext context,
      required String title,
      required File? image,
      required CommunityModel community,
      required UserModel user}) async {
    state = true;
    final id = const Uuid().v1();
    final upload = await _storageRepository.storeFile(
        'posts/${community.name}', id, image);
    upload.fold(
        (l) => showSnackBar(context, 'An error occurred uploading your image'),
        (r) async {
      final post = PostModel(
        id: id,
        title: title,
        communityName: community.name,
        communityProfilePic: community.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        description: r,
      );
      final res = await _repository.addPost(post);
      res.fold((l) => showSnackBar(context, 'An error occurred'), (r) {
        showSnackBar(context, 'Post shared successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  void deletePost(BuildContext context, PostModel post, String uid) async {
    if (uid == post.uid) {
      final res = await _repository.deletePost(post);
      res.fold((l) => showSnackBar(context, 'An error occurred'),
          (r) => showSnackBar(context, 'Post deleted successfully'));
    }
  }

  Stream<List<PostModel>> fetchUserFeed(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _repository.fetchUserFeed(communities);
    }
    return Stream.value([]);
  }

  Stream<List<CommentModel>> fetchPostComments(String postId){
    return _repository.fetchPostComments(postId);
  }

  void upvotePost(
      BuildContext context, String upvoterId, PostModel post) async {
    final res = await _repository.upvotePost(upvoterId, post);
    res.fold((l) => showSnackBar(context, 'An error occurred'), (r) => null);
  }

  void downvotePost(
      BuildContext context, String downvoterId, PostModel post) async {
    final res = await _repository.downvotePost(downvoterId, post);
    res.fold((l) => showSnackBar(context, 'An error occurred'), (r) => null);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required UserModel user,
      required String postId}) async {
    String id = const Uuid().v1();
    final CommentModel comment = CommentModel(
      comment: text,
      id: id,
      createdAt: DateTime.now(),
      uid: user.uid,
      avatar: user.profilePic,
      upvotes: [],
      downvotes: [],
      username: user.name,
      postId: postId,
    );
    final res = await _repository.addComment(postId, comment);
    res.fold((l) => showSnackBar(context, 'An error occurred'), (r) => null);
  }

  void upvoteComment(
      BuildContext context, String upvoterId, CommentModel comment) async {
    final res = await _repository.upvoteComment(upvoterId, comment);
    res.fold((l) => showSnackBar(context, 'An error occurred'), (r) => null);
  }

  void downvoteComment(
      BuildContext context, String upvoterId, CommentModel comment ) async {
    final res = await _repository.downvoteComment(upvoterId, comment);
    res.fold((l) => showSnackBar(context, 'An error occurred'), (r) => null);
  }

  Stream<PostModel> getPostFromId(String id) {
    return _repository.getPostById(id);
  }
}
