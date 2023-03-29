import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clione/core/constants/firebase_constants.dart';
import 'package:reddit_clione/core/providers/firebase_providers.dart';
import 'package:reddit_clione/core/type_defs.dart';

import '../../../core/failure.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  final firestore = ref.read(firestoreProvider);
  return PostRepository(firestore);
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository(FirebaseFirestore firestore) : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<PostModel>> fetchUserFeed(List<CommunityModel> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => PostModel.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid upvotePost(String upvoterId, PostModel post) async {
    try {
      if (!post.upvotes.contains(upvoterId)) {
        return right(_posts.doc(post.id).update({
          'upvotes': FieldValue.arrayUnion([upvoterId]),
        }));
      } else {
        return right(_posts.doc(post.id).update({
          'upvotes': FieldValue.arrayRemove([upvoterId]),
        }));
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid downvotePost(String downvoterId, PostModel post) async {
    try {
      if (!post.downvotes.contains(downvoterId)) {
        return right(_posts.doc(post.id).update({
          'downvotes': FieldValue.arrayUnion([downvoterId]),
        }));
      } else {
        return right(_posts.doc(post.id).update({
          'downvotes': FieldValue.arrayRemove([downvoterId]),
        }));
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
