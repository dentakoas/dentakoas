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
    // Initialize filteredPosts with all posts immediately
    filteredPosts.assignAll(postController.posts);
    // Set up listener for posts changes
    ever(postController.posts, (_) {
      if (query.value.isEmpty) {
        filteredPosts.assignAll(postController.posts);
      } else {
        _updateFilteredPosts(showAll: false);
      }
    });
  }

  void setSort(String sort) {
    print('Setting sort to: $sort');
    selectedSort.value = sort;
    query.value = '';
    suggestions.clear();
    _updateFilteredPosts(showAll: true);
  }

  void updateSearch(String newQuery) {
    print('Updating search with query: $newQuery');
    isSearching.value = true;
    query.value = newQuery;
    if (newQuery.isEmpty) {
      suggestions.clear();
      filteredPosts.assignAll(
          postController.posts); // Show all posts when query is empty
    } else {
      updateSuggestions(newQuery);
      _updateFilteredPosts(showAll: false);
    }
  }

  void onSearchFocusLost() {
    isSearching.value = false;
  }

  void _updateFilteredPosts({bool showAll = false}) {
    List<Post> posts = List.from(postController.posts);
    final normalizedQuery = query.value.toLowerCase().trim();

    // Apply filtering only if not showing all and query is not empty
    if (!showAll && normalizedQuery.isNotEmpty) {
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

    // Always apply sorting
    _applySorting(posts);
    
    filteredPosts.assignAll(posts);
  }


  void updateSuggestions(String searchQuery) {
    final normalizedQuery = searchQuery.toLowerCase().trim();
    List<String> newSuggestions = [];

    if (normalizedQuery.isEmpty) {
      // Show all data based on selectedSort
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
      // Filter suggestions based on query
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

  List<Post> getSortedPosts() {
    return filteredPosts.toList();
  }

  
  void _applySorting(List<Post> posts) {
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
  }
}
