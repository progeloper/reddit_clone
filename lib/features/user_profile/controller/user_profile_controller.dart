import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/models/user_model.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../repository/user_profile_repository.dart';

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>((ref) {
  final repository = ref.read(userProfileRepositoryProvider);
  final storageRepository = ref.read(firebaseStorageRepoProvider);
  return UserProfileController(repository, storageRepository);
});


class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _repository;
  final FirebaseStorageRepository _storageRepository;
  UserProfileController(UserProfileRepository repository,
      FirebaseStorageRepository storageRepository)
      : _repository = repository,
        _storageRepository = storageRepository,
        super(false);

  void editProfile(File? avatarFile, File? bannerFile, String name,
      UserModel user, BuildContext context) async {
    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
          'users/avatar', user.uid, avatarFile);
      res.fold((l) => showSnackBar(context, l.message), (url) {
        user = user.copyWith(profilePic: url);
      });
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          'users/banner', user.uid, bannerFile);
      res.fold((l) => showSnackBar(context, l.message), (url) {
        user = user.copyWith(banner: url);
      });
    }
    if (name.isNotEmpty) {
      user = user.copyWith(name: name);
    }
    final result = await _repository.editUser(user);
    result.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Changes will take effect next time you log in'));
  }
}
