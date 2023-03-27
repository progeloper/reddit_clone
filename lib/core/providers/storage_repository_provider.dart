import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clione/core/failure.dart';
import 'package:reddit_clione/core/type_defs.dart';

import 'firebase_providers.dart';

final firebaseStorageRepoProvider = Provider((ref) {
  final firebaseStorage = ref.read(firebaseStorageProvider);
  return FirebaseStorageRepository(storage: firebaseStorage);
});

class FirebaseStorageRepository{
  final FirebaseStorage _storage;
  FirebaseStorageRepository({required FirebaseStorage storage}) : _storage = storage;

  FutureEither<String> storeFile(String path, String id, File? file)async{
    try{
      final ref = _storage.ref().child(path).child(id);
      TaskSnapshot uploadTask = await ref.putFile(file!);
      final snapshot = uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    }catch (e){
      return left(Failure(e.toString()));
    }
  }
}