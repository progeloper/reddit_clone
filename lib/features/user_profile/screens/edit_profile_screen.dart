import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils.dart';
import '../../../models/community_model.dart';
import '../../../models/user_model.dart';
import '../../../theme/palette.dart';
import '../../community/controller/community_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  ConsumerState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? avatarFile;
  late TextEditingController nameController;

  void save(BuildContext context, WidgetRef ref, UserModel user) {
    ref.read(userProfileControllerProvider.notifier).editProfile(
        avatarFile, bannerFile, nameController.text.trim(), user, context);
    Routemaster.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

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
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ref.watch(themeNotifierProvider);

    return ref.watch(userDataProvider(widget.uid)).when(
          data: (user) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text('Edit Community'),
                actions: [
                  TextButton(
                    onPressed: () => save(context, ref, user),
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: Padding(
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
                              color: theme.textTheme.bodyText2!.color!,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: (bannerFile != null)
                                    ? Image.file(bannerFile!)
                                    : (user.banner.isEmpty ||
                                            user.banner ==
                                                Constants.bannerDefault)
                                        ? const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 40,
                                          )
                                        : Image.network(user.banner),
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
                                      backgroundImage: FileImage(avatarFile!),
                                      radius: 32,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                      radius: 32,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Name',
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
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
