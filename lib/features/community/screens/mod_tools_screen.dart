import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({Key? key, required this.name}) : super(key: key);

  void navigateToEditCommunityScreen(BuildContext context){
    Routemaster.of(context).push('/edit-community/$name');
  }

  void navigateToAddModScreen(BuildContext context){
    Routemaster.of(context).push('/add-mods/$name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mod Tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add moderators'),
            onTap: ()=>navigateToAddModScreen(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit community'),
            onTap: (){
              navigateToEditCommunityScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
