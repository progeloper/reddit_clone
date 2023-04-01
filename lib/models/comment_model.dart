class CommentModel{
  final String comment;
  final String id;
  final String username;
  final dynamic createdAt;
  final String uid;
  final String postId;
  final String avatar;
  final List<String> upvotes;
  final List<String> downvotes;

//<editor-fold desc="Data Methods">

  const CommentModel({
    required this.comment,
    required this.id,
    required this.username,
    required this.createdAt,
    required this.uid,
    required this.postId,
    required this.avatar,
    required this.upvotes,
    required this.downvotes,
  });

  CommentModel copyWith({
    String? comment,
    String? id,
    String? username,
    dynamic? createdAt,
    String? uid,
    String? postId,
    String? avatar,
    List<String>? upvotes,
    List<String>? downvotes,
  }) {
    return CommentModel(
      comment: comment ?? this.comment,
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      avatar: avatar ?? this.avatar,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'comment': this.comment,
      'id': this.id,
      'username': this.username,
      'createdAt': this.createdAt,
      'uid': this.uid,
      'postId': this.postId,
      'avatar': this.avatar,
      'upvotes': this.upvotes,
      'downvotes': this.downvotes,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      comment: map['comment'] as String,
      id: map['id'] as String,
      username: map['username'] as String,
      createdAt: map['createdAt'] as dynamic,
      uid: map['uid'] as String,
      postId: map['postId'] as String,
      avatar: map['avatar'] as String,
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
    );
  }

//</editor-fold>
}