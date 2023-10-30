import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/constants/color.dart';
import 'package:social_media_app/model/post_model.dart';
import 'package:social_media_app/services/post_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textController = TextEditingController();

  List<String> imagePaths = [];
  List<String> imageUrls = [];
  TextEditingController captionController = TextEditingController();
  TextEditingController editedCaptionController = TextEditingController();
  bool isEditing = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomSheet(BuildContext context) {
    //bottomsheet code
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer<PostUploader>(
          builder: (context, postUploader, child) {
            return SingleChildScrollView(
              child: Container(
                height: 800,
                padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (postUploader.pickedImage != null)
                      Image.file(
                        postUploader.pickedImage!,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkblueColor,
                        ),
                        onPressed: () {
                          postUploader.pickImage();
                        },
                        child: const Text('Pick Image'),
                      ),
                    const SizedBox(height: 40),
                    SingleChildScrollView(
                      child: TextField(
                        controller: captionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelStyle:
                              TextStyle(color: darkblueColor, fontSize: 18),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: darkblueColor),
                          ),
                          labelText: "Write your caption...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkblueColor,
                      ),
                      onPressed: () {
                        String caption = captionController.text;

                        if (postUploader.pickedImage == null) {
                          // Show error message if no image is selected
                          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                              .showSnackBar(
                            const SnackBar(
                              content: Text('Please pick an image.'),
                            ),
                          );
                        } else if (caption.isEmpty) {
                          // Show error message if caption is empty
                          ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                              .showSnackBar(
                            const SnackBar(
                              content: Text('Please Enter a caption.'),
                            ),
                          );
                        } else {
                          // Validation successful, proceed with uploading the post
                          postUploader.uploadImageAndCaption(caption: caption);
                          postUploader.clearPickedImage();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Upload Post'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkblueColor,
        title: const Text('Social Media '),
      ),
      drawer: Drawer(
        width: 200,
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [darkblueColor, Colors.indigo],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [-10, 50],
                ),
              ),
              padding: EdgeInsets.only(top: 60, left: 26),
              child: Text(
                'Drawer ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      //Dynamic screen
      body: Consumer<PostUploader>(
        builder: (context, postUploader, child) {
          return ListView.builder(
            itemCount: postUploader.posts.length,
            itemBuilder: (context, index) {
              Post post = postUploader.posts[index];
              editedCaptionController.text = post.caption;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: captionController,
                            style: const TextStyle(fontSize: 20),
                            enabled: isEditing,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                              if (!isEditing) {
                                post.caption = editedCaptionController.text;
                              }
                            });
                          },
                          child: Text(
                            isEditing ? 'Save' : 'Edit',
                            style: const TextStyle(color: darkblueColor),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: darkblueColor,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    // Like, Comment, Share options
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '${post.likes} Likes',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            color: post.likedBy.contains(
                                    FirebaseAuth.instance.currentUser?.uid)
                                ? Colors.blue
                                : Colors.grey,
                            onPressed: () {
                              setState(() {
                                String? currentUserId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (currentUserId != null && !isEditing) {
                                  post.toggleLike(currentUserId);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              // Handle share action
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // float ADD buttom 
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context);
        },
        backgroundColor: darkblueColor,
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 30,
              child: Text(
                ' Post',
                style: TextStyle(fontSize: 9),
              ),
            ),
            Positioned(
              left: 15,
              top: 7,
              child: Icon(
                Icons.add,
                size: 23,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
