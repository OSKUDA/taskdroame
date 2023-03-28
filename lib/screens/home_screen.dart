// Implement home screen with a list of stories and add story button

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taskdroame/screens/add_story_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stories')
                  // .where('sharedWith',
                  //     arrayContains: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    DateTime storyTimestamp = data['timestamp'].toDate();
                    if (DateTime.now()
                        .isBefore(storyTimestamp.add(Duration(minutes: 10)))) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data['photoUrl']),
                        ),
                        title: Text(
                          '${data['username']}\'s story',
                        ),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(storyTimestamp),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }).toList(),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddStoryScreen()),
              );
            },
            child: Text('Add Story'),
          ),
        ],
      ),
    );
  }
}
