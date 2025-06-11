import 'package:denta_koas/src/cores/data/repositories/post.repository/post_repository.dart';
import 'package:denta_koas/src/features/appointment/data/model/post_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/tes.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:get/get.dart';

class ExplorePostController extends GetxController {
  static ExplorePostController get instance => Get.find();

  final postRepository = Get.put(PostRepository());
  final isLoading = false.obs;
  final today = DateTime.now();

  RxList<Post> lastChangePost = <Post>[].obs;
  RxList<Post> newestPosts = <Post>[].obs;
  RxList<Post> posts = <Post>[].obs;
  RxList<Post> openPosts = <Post>[].obs;
  RxList<Post> featuredPosts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      final fetchedPosts = await postRepository.getPosts();

      // Filter status post "Open" dan hanya yang memiliki schedule yang masih berlaku
      final postWithStatusOpen = fetchedPosts
          .where((post) =>
              post.status == StatusPost.Open.name &&
              post.schedule.any((schedule) => schedule.dateEnd.isAfter(today)))
          .toList();
  
      // Assign ke berbagai list
      posts.assignAll(postWithStatusOpen);
      openPosts.assignAll(postWithStatusOpen);

      // Featured posts berdasarkan jumlah like terbanyak
      featuredPosts.assignAll(
        (List.of(postWithStatusOpen)
              ..sort((a, b) => b.likes.length.compareTo(a.likes.length)))
            .sublist(0,
                postWithStatusOpen.length < 3 ? postWithStatusOpen.length : 3),
      );


      // Newest posts (3 post terbaru berdasarkan createdAt)
      newestPosts.assignAll(
        (List.of(postWithStatusOpen)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            .sublist(0,
                postWithStatusOpen.length < 3 ? postWithStatusOpen.length : 3),
      );

      // Last changed posts (3 post terlama berdasarkan schedule yang paling cepat selesai)
      lastChangePost.assignAll(
        (List.of(postWithStatusOpen)
              ..sort((a, b) {
                // Ambil dateEnd paling awal dari setiap post
                final aSoonestEnd = a.schedule.isNotEmpty
                    ? a.schedule
                        .map((s) => s.dateEnd)
                        .reduce((v, e) => v.isBefore(e) ? v : e)
                    : DateTime(2100);
                final bSoonestEnd = b.schedule.isNotEmpty
                    ? b.schedule
                        .map((s) => s.dateEnd)
                        .reduce((v, e) => v.isBefore(e) ? v : e)
                    : DateTime(2100);
                return aSoonestEnd.compareTo(bSoonestEnd);
              }))
            .sublist(0,
                postWithStatusOpen.length < 3 ? postWithStatusOpen.length : 3),
      );

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
