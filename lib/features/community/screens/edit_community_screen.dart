import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/error_text.dart';
import 'package:reddit_clione/core/common/loader.dart';
import 'package:reddit_clione/core/utils.dart';
import 'package:reddit_clione/features/community/controller/community_controller.dart';
import 'package:reddit_clione/models/community_model.dart';

import '../../../core/constants/constants.dart';
import '../../../theme/palette.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? avatarFile;

  void selectBannerImage() async {
    final result = await pickImage();
    if (result != null) {
      setState(() {
        bannerFile = File(result.files.first.path!);
      });
    }
  }

  void saveEdits(CommunityModel community) {
    final communityController = ref.read(communityControllerProvider.notifier);
    return communityController.editCommunity(
        bannerFile, avatarFile, community, context);
  }

  void selectAvatarImage() async {
    final result = await pickImage();
    if (result != null) {
      setState(() {
        avatarFile = File(result.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    ThemeData theme = ref.watch(themeNotifierProvider);

    return ref.watch(namedCommunityProvider(widget.name)).when(
          data: (community) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text('Edit Community'),
                actions: [
                  TextButton(
                    onPressed: () {
                      saveEdits(community);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: selectBannerImage,
                                  child: DottedBorder(
                                    dashPattern: const [10, 4],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    strokeCap: StrokeCap.round,
                                    color: theme.textTheme
                                        .bodyText2!.color!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: (bannerFile != null)
                                          ? Image.file(bannerFile!)
                                          : (community.banner.isEmpty ||
                                                  community.banner ==
                                                      Constants.bannerDefault)
                                              ? const Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                )
                                              : Image.network(community.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectAvatarImage,
                                    child: avatarFile != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                FileImage(avatarFile!),
                                            radius: 32,
                                          )
                                        : CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(community.avatar),
                                            radius: 32,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
