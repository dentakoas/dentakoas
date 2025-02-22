import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/features/appointment/data/model/likes_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/post_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/tes.dart';
import 'package:denta_koas/src/utils/constants/api_urls.dart';
import 'package:denta_koas/src/utils/dio.client/dio_client.dart';
import 'package:denta_koas/src/utils/exceptions/exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/firebase_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/format_exceptions.dart';
import 'package:denta_koas/src/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  Future<List<Post>> getPosts() async {
    try {
      final response = await DioClient().get(Endpoints.posts);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final List<dynamic> postData = response.data['posts'] ?? [];
        return Post.postsFromJson(postData);
      }

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error fetching post: $e']);
      throw 'Something went wrong. Please try again later.';
    }
    throw 'Failed to fetch posts data.';
  }

  Future<List<Post>> getPostByUser2() async {
    try {
      final response = await DioClient().get(
        Endpoints.postWithSpecificUser(
          AuthenticationRepository.instance.authUser!.uid,
        ),
      );

      if (response.statusCode == 200) {
        // Ambil array posts dari data
        final data = response.data as Map<String, dynamic>?;
        final posts = data?['posts'] as List<dynamic>? ?? [];
        return posts
            .map((json) => Post.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw 'Unexpected status code: ${response.statusCode}';
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      // Log error untuk debugging
      // TLoaders.errorSnackBar(title: 'Failed to fetch post');
      Logger().e(['Error fetching post: $e']);
      throw e.toString();
    }
}

  Future<PostModel> getPostByPostId(String postId) async {
    try {
      final response =
          await DioClient().get(
        Endpoints.post(postId),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data);
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error fetching post: $e']);
      throw 'Something went wrong. Please try again later.';
    }
    throw 'Failed to fetch post data.';
  }

  Future<List<String>> getPostTitles() async {
    final response = await DioClient().get(Endpoints.posts);

    if (response.statusCode == 200) {
      final data = response.data;

      if (data['data'] == null || data['data']['post'] == null) {
        throw Exception('Post data not found');
      }

      // Ambil hanya key 'title' dari setiap objek
      return (data['data']['post'] as List)
          .map((postJson) =>
              (postJson as Map<String, dynamic>)['title'] as String)
          .toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  Future<List<PostModel>> getPostCurrentUser() async {
    try {
      final response = await DioClient().get(
        Endpoints.postWithSpecificUser(
          AuthenticationRepository.instance.authUser!.uid,
        ),
      );

      if (response.statusCode == 200) {
        return PostModel.postsFromJson(response.data);
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error fetching post: $e']);
      throw e.toString();
    }
    throw 'Failed to fetch post data.';
  }

  Future<PostModel> createPost(PostModel post) async {
    try {
      final response =
          await DioClient().post(Endpoints.posts, data: post.toJson());

      if (response.statusCode == 201) {
        return PostModel.fromJson(response.data);
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error creating post: $e']);
      throw e.toString();
    }
    throw 'Failed to create post.';
  }

  Future<void> updatePost(String postId, PostModel post) async {
    try {
      final response = await DioClient().patch(
        Endpoints.post(post.id!),
        data: post.toJson(),
      );

      if (response.statusCode == 200) {
        return;
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error updating post: $e']);
      throw e.toString();
    }
    throw 'Failed to update post.';
  }

  Future<void> deletePost(String postId) async {
    try {
      final response = await DioClient().delete(Endpoints.post(postId));

      return;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error deleting post: $e']);
      throw e.toString();
    }
    throw 'Failed to delete post.';
  }

  // Get current postId from the server
  Future<String> getPostId(PostModel post) async {
    try {
      final response = await DioClient().get(Endpoints.posts);

      if (response.statusCode == 200) {
        final data = response.data['data']['post']; // Perbaikan akses
        if (data is Map<String, dynamic>) {
          return data['id'];
        }
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
    throw 'Failed to fetch post data.';
  }

  Future<LikesModel> likePost(LikesModel post, String postId) async {
    try {
      final response = await DioClient().post(
        Endpoints.likePost(postId),
        data: post.toJson(),
      );

      if (response.statusCode == 200) {
        return LikesModel.fromJson(response.data);
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on TExceptions catch (e) {
      throw TExceptions(e.message);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      Logger().e(['Error liking post: $e']);
      throw e.toString();
    }
    throw 'Failed to like post.';
  }

  Future<String?> uploadToCloudinary(
      File imageFile, fileNames, int index) async {
    try {
      var cloudinary = Cloudinary.signedConfig(
        apiKey: '338626958888276',
        apiSecret: '8SxMxVmbz4tinfex31MJtaj7x6A',
        cloudName: 'dxw9ywgfq',
      );

      final response = await cloudinary.upload(
        file: imageFile.path,
        folder: 'post/images', // Cloudinary folder,
        fileBytes: await imageFile.readAsBytes(),
        resourceType: CloudinaryResourceType.image,
        fileName: fileNames[index],
        progressCallback: (count, total) {
          final progress = ((count / total) * 100).toStringAsFixed(2);
          Logger().i('Upload progress: $progress%');
        },
      );

      if (!response.isSuccessful) {
        throw Exception('Failed to upload image');
      }

      return response.secureUrl;
    } catch (e) {
      Logger().e('Error uploading image: $e');
    }
    return null;
  }
  
}

