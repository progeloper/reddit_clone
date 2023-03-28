import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/error_text.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/community/controller/community_controller.dart';
import 'package:reddit_clione/features/posts/controller/post_controller.dart';
import 'package:reddit_clione/theme/palette.dart';

import '../../../core/common/loader.dart';
import '../../../core/utils.dart';
import '../../../models/community_model.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({Key? key, required this.type}) : super(key: key);

  @override
  ConsumerState createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  File? bannerFile;
  List<CommunityModel> communities = [];
  CommunityModel? selectedCommunity;

  void selectBannerImage() async {
    final result = await pickImage();
    if (result != null) {
      setState(() {
        bannerFile = File(result.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          title: titleController.text,
          image: bannerFile,
          community: selectedCommunity ?? communities[0],
          user: ref.watch(userProvider)!);
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          title: titleController.text,
          link: descriptionController.text,
          community: selectedCommunity ?? communities[0],
          user: ref.read(userProvider)!);
    } else if (widget.type == 'text' &&
        titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: titleController.text,
          description: descriptionController.text,
          community: selectedCommunity ?? communities[0],
          user: ref.read(userProvider)!);
    } else{
      showSnackBar(context, 'Please enter the required fields');
    }
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = (widget.type == 'image');
    final isTypeText = (widget.type == 'text');
    final isTypeLink = (widget.type == 'link');
    final theme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              maxLength: 30,
              controller: titleController,
              decoration: const InputDecoration(
                filled: true,
                hintText: 'Enter title here',
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (isTypeImage)
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
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: (bannerFile != null)
                        ? Image.file(bannerFile!)
                        : const Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                          ),
                  ),
                ),
              ),
            if (isTypeText)
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter description',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            if (isTypeLink)
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter link',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text('Select Community'),
            ),
            ref.watch(userCommunitiesProvider).when(
                  data: (data) {
                    communities = data;
                    return DropdownButton(
                        value: selectedCommunity ?? data[0],
                        items: communities
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCommunity = val;
                          });
                        });
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          ],
        ),
      ),
    );
  }
}
