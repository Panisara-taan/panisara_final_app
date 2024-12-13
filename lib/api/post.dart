// import 'dart:async';
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart';
// import 'package:panisara_final_app/login.dart';

// class AllPosts {
//   ///////จะได้ data ทั้ง post ใน json ////////
//   final List<panisara_users> posts;
//   AllPosts(this.posts);

//   factory AllPosts.fromSnapshot(QuerySnapshot qs) {
//     List<panisara_users> posts;

//     posts = qs.docs.map((DocumentSnapshot ds) {
//       panisara_users post = panisara_users.fromSnapshot(ds.data() as Map<String, dynamic>);
//       post.dbId = ds.id;
//       return post;
//     }).toList(); ////// map จะได้ data มา/////////
//     return AllPosts(posts);
//   }

//   factory AllPosts.fromJson(List<dynamic> json) {
//     List<panisara_users> posts;
//     posts = json
//         .map((item) => panisara_users.fromJson(item))
//         .toList(); ////// map จะได้ data มา/////////
//     return AllPosts(posts);
//   }
// }

// //////////////Service/////////////////////////////
// abstract class PostService {
//   Future<List<panisara_users>> getPosts();
//   Future<void> updatePosts(panisara_users post); /////future void ไม่ต้อง return ค่า////
//   Future<panisara_users> addPost(panisara_users post);
// }

// class PostFirebaseService implements PostService {
//   @override
//   Future<panisara_users> addPost(panisara_users post) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<panisara_users>> getPosts() async {
//     QuerySnapshot qs =
//         await FirebaseFirestore.instance.collection('posts').get();
//     AllPosts all = AllPosts.fromSnapshot(qs);
//     return all.posts;
//   }

//   @override
//   Future<void> updatePosts(panisara_users post) async {
//     try {
//       final postsRef =
//           await FirebaseFirestore.instance.collection("posts").doc(post.dbId);
//       await postsRef.update({
//         "email": post.email,
//         "timestamp": FieldValue.serverTimestamp(),
//       });
//       print("DocumentSnapshot successfully updated!");
//     } catch (e) {
//       print("Error updating document $e");
//     }
//   }
// }

// class PostHttpService implements PostService {
//   Client client = Client();

//   // for add Post
//   @override
//   Future<panisara_users> addPost(panisara_users post) async {
//     final response = await client.post(
//       Uri.parse('http://192.168.1.109:3000/posts'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'email': post.email,
        
//       }),
//     );

//     if (response.statusCode == 201) {
//       return panisara_users.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to add post');
//     }
//   }

//   @override
//   Future<List<panisara_users>> getPosts() async {
//     final response = await client.get(
//       Uri.parse(
//           'http://192.168.1.109:3000/posts'), ////เห็นตัวนี้ใส่ await ได้เลย
//     );
//     if (response.statusCode == 200) {
//       var all = AllPosts.fromJson(json.decode(response.body));
//       return all.posts;
//     }
//     throw Exception('Fail to load posts');
//   }

//   @override
//   Future<void> updatePosts(panisara_users post)  {
//     return client.put(Uri.parse('http://192.168.1.109:3000/posts/${post.email}'),
//         body: jsonEncode(<String, dynamic>{
//           'eail': post.email,
       
//         }));
//   }
// }

// ///////controller//////////
// class PostController {
//   List<panisara_users> posts = List.empty();
//   final PostService service;

//   StreamController<bool> onSyncController = StreamController();
//   Stream<bool> get onSync => onSyncController.stream;

//   PostController(this.service);

//   Future<List<panisara_users>> fetchPosts() async {
//     onSyncController.add(true);
//     posts = await service.getPosts();
//     onSyncController.add(false);
//     return posts;
//   }

//   Future<void> updatePosts(panisara_users post) async {
//     onSyncController.add(true);
//     await service.updatePosts(post);
//     onSyncController.add(false);
//   }

//   Future<void> addPost(panisara_users post) async {
//     onSyncController.add(true);
//     await service.addPost(post);
//      onSyncController.add(false);
//   }
// }