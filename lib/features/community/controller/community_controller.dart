import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clione/core/failure.dart';
import 'package:reddit_clione/core/providers/storage_repository_provider.dart';
import 'package:reddit_clione/core/utils.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/community/repository/community_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/constants.dart';
import '../../../models/community_model.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final repository = ref.read(communityRepositoryProvider);
  final storageRepository = ref.read(firebaseStorageRepoProvider);
  return CommunityController(
      repository: repository, ref: ref, storageRepository: storageRepository);
});

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.read(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final namedCommunityProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.read(communityControllerProvider.notifier);
  return communityController.getCommunityByName(name);
});


final searchCommunityProvider = StreamProvider.family((ref, String query){
  final communityController = ref.read(communityControllerProvider.notifier);
  return communityController.searchCommunity(query);
});


class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final FirebaseStorageRepository _storageRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository repository,
      required FirebaseStorageRepository storageRepository,
      required Ref ref})
      : _communityRepository = repository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void createCommunity(String communityName, BuildContext context) async {
    state = true;
    String id = const Uuid().v1();
    final uid = _ref.read(userProvider)?.uid ?? '';
    CommunityModel community = CommunityModel(
        id: id,
        name: communityName,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, "r/$communityName has been created successfully!");
      Routemaster.of(context).pop();
    });
  }

  Stream<List<CommunityModel>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<CommunityModel> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(File? bannerFile, File? avatarFile,
      CommunityModel community, BuildContext context) async {
    state = true;
    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
          'communities/avatar', community.name, avatarFile);
      res.fold((l) => showSnackBar(context, l.message), (url) {
        community = community.copyWith(avatar: url);
      });
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          'communities/banner', community.name, bannerFile);
      res.fold((l) => showSnackBar(context, l.message), (url) {
        community = community.copyWith(banner: url);
      });
    }
    final result = await _communityRepository.editCommunity(community);
    state = false;
    result.fold((l) => showSnackBar(context, l.message), (r) {
      Routemaster.of(context).push('/');
    });
  }

  void addMods(String communityName, List<String> uids, BuildContext context)async{
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message), (r) => Routemaster.of(context).pop());
  }

  void joinCommunity(CommunityModel community, BuildContext context)async{
    final user = _ref.read(userProvider);
    Either<Failure, void> res;
    if(community.members.contains(user!.uid)){
      res =  await _communityRepository.leaveCommunity(community.name, user.uid);
    } else{
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }
    res.fold((l) => showSnackBar(context, l.message), (r){
      if(community.members.contains(user.uid)){
        showSnackBar(context, 'r/${community.name} left successfully');
      } else{
        showSnackBar(context, 'r/${community.name} joined successfully');
      }
    });
  }

  Stream<List<CommunityModel>> searchCommunity(String query){
    return _communityRepository.searchCommunity(query);
  }
}
