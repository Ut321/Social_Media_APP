import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/constants/color.dart';
import 'package:social_media_app/services/post_controller.dart';

class PostUploadBottomSheet extends StatelessWidget {
  final TextEditingController captionController = TextEditingController();

  PostUploadBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Consumer<PostUploader>(
                builder: (context, postUploader, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
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
                      TextField(
                        cursorColor: Colors.black,
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkblueColor,
                        ),
                        onPressed: () {
                          String caption = captionController.text;

                          if (postUploader.pickedImage == null) {
                            // Show error message if no image is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please pick an image.'),
                              ),
                            );
                          } else if (caption.isEmpty) {
                            // Show error message if caption is empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please Enter a caption.'),
                              ),
                            );
                          } else {
                            // Validation successful, proceed with uploading the post
                            postUploader.uploadImageAndCaption(
                                caption: caption);
                            postUploader.clearPickedImage();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Upload Post'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
