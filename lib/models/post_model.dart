import 'package:flutter/foundation.dart';

class PostModel{
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String username;
  final String uid;
  final String type;
  final createdAt;
  final List<String> awards;

//<editor-fold desc="Data Methods">

  const PostModel({
    required this.id,
    required this.title,
    this.link,
    this.description,
    required this.communityName,
    required this.communityProfilePic,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.username,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.awards,
  });



  PostModel copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityProfilePic,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? username,
    String? uid,
    String? type,
    dynamic? createdAt,
    List<String>? awards,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'link': this.link,
      'description': this.description,
      'communityName': this.communityName,
      'communityProfilePic': this.communityProfilePic,
      'upvotes': this.upvotes,
      'downvotes': this.downvotes,
      'commentCount': this.commentCount,
      'username': this.username,
      'uid': this.uid,
      'type': this.type,
      'createdAt': this.createdAt,
      'awards': this.awards,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      description: map['description'],
      communityName: map['communityName'] ?? '',
      communityProfilePic: map['communityProfilePic'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: map['createdAt'],
      awards: List<String>.from(map['awards']),
    );
  }
//</editor-fold>
}