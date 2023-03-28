import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStoryScreen extends StatefulWidget {
  @override
  _AddStoryScreenState createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  List<String> _sharedWith = [];

  void _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _shareStory(BuildContext context) async {
    // if (_sharedWith.isEmpty) {
    //   setState(() {
    //     _errorText = 'Please select at least one user to share your story.';
    //   });
    //   return;
    // }

    if (_image == null) {
      setState(() {
        _errorText = 'Please select an image to share your story.';
      });
      return;
    }

    String username = FirebaseAuth.instance.currentUser!.displayName ?? '';
    String photoUrl = FirebaseAuth.instance.currentUser!.photoURL ?? '';
    String uid = FirebaseAuth.instance.currentUser!.uid;

    Reference storageReference =
        FirebaseStorage.instance.ref().child('stories/$uid/${DateTime.now()}.jpg');
    UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() => null);
    String photoUrlFromStorage = await storageReference.getDownloadURL();

    FirebaseFirestore.instance.collection('stories').add({
      'username': username,
      'photoUrl': photoUrlFromStorage,
      // 'sharedWith': _sharedWith,
      'timestamp': DateTime.now(),
      'expiresAt': DateTime.now().add(Duration(minutes: 10)),
    }).then((documentReference) {
      Navigator.pop(context);
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Story'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _image == null
                    ? Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text('No image selected.'),
                        ),
                      )
                    : Container(
                        height: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Select Photo'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Shared with',
                  ),
                  // onChanged: (value) {
                  //   setState(() {
                  //     _errorText = null;
                  //   });
                  // },
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please select at least one user to share your story.';
                  //   }
                  //                       return null;
                  // },
                  // onTap: () async {
                  //   final result = await Navigator.pushNamed(context, '/select-users');
                  //   if (result != null) {
                  //     setState(() {
                  //       _sharedWith = result as List<String>;
                  //     });
                  //   }
                  // },
                  readOnly: true,
                  
                ),
                SizedBox(height: 16.0),
                if (_errorText != null)
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _shareStory(context);
                    }
                  },
                  child: Text('Share Story'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

