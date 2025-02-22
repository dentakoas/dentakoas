// search_post_controller.dart
import 'package:denta_koas/src/features/appointment/controller/post.controller/posts_controller.dart';
import 'package:denta_koas/src/features/appointment/data/model/tes.dart';
import 'package:get/get.dart';

class SearchPostController extends GetxController {
  static SearchPostController get instance => Get.find();

  final RxString query = ''.obs;
  final RxString selectedSort = 'Name'.obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxList<Post> filteredPosts = <Post>[].obs;
  final PostController postController = Get.put(PostController());

  final RxBool isSearching = false.obs;
  void toggleSearch() => isSearching.toggle();

  @override
  void onInit() {
    super.onInit();
    _updateFilteredPosts(); // Panggil ini untuk inisialisasi dengan sorting
  }

  void setSort(String sort) {
    print('Setting sort to: $sort');
    selectedSort.value = sort;
    query.value = '';
    suggestions.clear();
    _updateFilteredPosts();
  }

  void updateSearch(String newQuery) {
    print('Updating search with query: $newQuery');
    isSearching.value = true; // Set isSearching to true when search starts
    query.value = newQuery;
    if (newQuery.isEmpty) {
      suggestions.clear();
    } else {
      updateSuggestions(newQuery);
    }
    _updateFilteredPosts(); // Selalu panggil ini untuk update sorting
  }

  void onSearchFocusLost() {
    isSearching.value = false; // Set isSearching to false when focus is lost
  }

  void _updateFilteredPosts() {
    final normalizedQuery = query.value.toLowerCase().trim();
    List<Post> posts = List.from(postController.posts);

    if (normalizedQuery.isNotEmpty) {
      posts = posts.where((post) {
        switch (selectedSort.value) {
          case 'Name':
            return post.user.fullName.toLowerCase().contains(normalizedQuery);
          case 'Treatment':
            return post.treatment.alias.toLowerCase().contains(normalizedQuery);
          case 'University':
            return (post.user.koasProfile?.university ?? '')
                .toLowerCase()
                .contains(normalizedQuery);
          case 'Title':
            return post.title.toLowerCase().contains(normalizedQuery);
          default:
            return true;
        }
      }).toList();
    }

    // Sorting sesuai selectedSort
    switch (selectedSort.value) {
      case 'Popularity':
        posts.sort((a, b) => b.likes.length.compareTo(a.likes.length));
        break;
      case 'Newest':
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      default:
        posts.sort((a, b) {
          String valueA = '';
          String valueB = '';
          switch (selectedSort.value) {
            case 'Name':
              valueA = a.user.fullName;
              valueB = b.user.fullName;
              break;
            case 'Treatment':
              valueA = a.treatment.alias;
              valueB = b.treatment.alias;
              break;
            case 'University':
              valueA = a.user.koasProfile?.university ?? '';
              valueB = b.user.koasProfile?.university ?? '';
              break;
            case 'Title':
              valueA = a.title;
              valueB = b.title;
              break;
          }
          return valueA.compareTo(valueB);
        });
    }

    filteredPosts.assignAll(posts);
  }

  void updateSuggestions(String searchQuery) {
    final normalizedQuery = searchQuery.toLowerCase().trim();
    List<String> newSuggestions = [];

    if (normalizedQuery.isEmpty) {
      // Tampilkan semua data berdasarkan selectedSort
      switch (selectedSort.value) {
        case 'Name':
          newSuggestions =
              postController.posts.map((post) => post.user.fullName).toList();
          break;
        case 'Treatment':
          newSuggestions =
              postController.posts.map((post) => post.treatment.alias).toList();
          break;
        case 'University':
          newSuggestions = postController.posts
              .map((post) => post.user.koasProfile?.university ?? '')
              .where((uni) => uni.isNotEmpty)
              .toList();
          break;
        case 'Title':
          newSuggestions =
              postController.posts.map((post) => post.title).toList();
          break;
      }
    } else {
      // Filter data jika query tidak kosong
      switch (selectedSort.value) {
        case 'Name':
          newSuggestions = postController.posts
              .where((post) =>
                  post.user.fullName.toLowerCase().contains(normalizedQuery))
              .map((post) => post.user.fullName)
              .toList();
          break;
        case 'Treatment':
          newSuggestions = postController.posts
              .where((post) =>
                  post.treatment.alias.toLowerCase().contains(normalizedQuery))
              .map((post) => post.treatment.alias)
              .toList();
          break;
        case 'University':
          newSuggestions = postController.posts
              .where((post) => (post.user.koasProfile?.university ?? '')
                  .toLowerCase()
                  .contains(normalizedQuery))
              .map((post) => post.user.koasProfile?.university ?? '')
              .where((uni) => uni.isNotEmpty)
              .toList();
          break;
        case 'Title':
          newSuggestions = postController.posts
              .where(
                  (post) => post.title.toLowerCase().contains(normalizedQuery))
              .map((post) => post.title)
              .toList();
          break;
      }
    }

    suggestions.value = newSuggestions.toSet().toList();
  }

  // Getter untuk mendapatkan filtered posts
  List<Post> getSortedPosts() {
    return filteredPosts.toList();
  }
}
