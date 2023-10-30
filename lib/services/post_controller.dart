import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/model/post_model.dart';

class PostUploader with ChangeNotifier {
  File? _pickedImage;
  TextEditingController captionController = TextEditingController();

  File? get pickedImage => _pickedImage;
  List<Post> posts = [];

  saveUser(String name, email, uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email, 'name': name});
  }

  //pick image
  Future<void> pickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _pickedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Method to clear the picked image
  void clearPickedImage() {
    _pickedImage = null;
    notifyListeners();
  }

  // upload Image
  Future<void> uploadImageAndCaption({required String caption}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _pickedImage != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putFile(_pickedImage!);

        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        Post newPost = Post(imageUrl: imageUrl, caption: caption);
        posts.add(newPost);

        notifyListeners();
      } else {
        print('User not authenticated or image not picked');
      }
    } catch (error) {
      print('Error uploading image and creating post: $error');
    }
  }

  // Future<List<Post>> fetchPosts() async {
  //   List<Post> posts = [];
  //   try {
  //     QuerySnapshot postSnapshots =
  //         await FirebaseFirestore.instance.collection('posts').get();

  //   } catch (error) {
  //     // Handle errors while fetching posts
  //     print('Error fetching posts: $error');
  //   }
  //   return posts;
  // }
}
