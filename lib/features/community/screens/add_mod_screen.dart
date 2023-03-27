import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clione/core/common/error_text.dart';
import 'package:reddit_clione/core/common/loader.dart';
import 'package:reddit_clione/features/auth/controller/auth_controller.dart';
import 'package:reddit_clione/features/community/controller/community_controller.dart';
import 'package:reddit_clione/models/community_model.dart';

class AddModScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AddModScreenState();
}

class _AddModScreenState extends ConsumerState<AddModScreen> {
  Set<String> uids = {};
  int ctr = -1;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void save(){
    ref.read(communityControllerProvider.notifier).addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Moderators'),
        actions: [
          IconButton(
            onPressed: ()=>save(),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ref.watch(namedCommunityProvider(widget.name)).when(
            data: (community) {
              return ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final memberId = community.members[index];
                  return ref.watch(userDataProvider(memberId)).when(
                        data: (user) {
                          if (community.mods.contains(memberId) && ctr < index) {
                            uids.add(memberId);
                          }
                          ctr++;
                          return CheckboxListTile(
                            value: uids.contains(memberId),
                            onChanged: (value) {
                              if (value!) {
                                addUid(memberId);
                              } else {
                                removeUid(memberId);
                              }
                            },
                            title: Text(user.name),
                          );
                        },
                        error: (error, stackTrace) =>
                            const ErrorText(error: 'An error occurred'),
                        loading: () => const Loader(),
                      );
                },
              );
            },
            error: (error, stackTrace) =>
                const ErrorText(error: 'An error occurred'),
            loading: () => const Loader(),
          ),
    );
  }
}
