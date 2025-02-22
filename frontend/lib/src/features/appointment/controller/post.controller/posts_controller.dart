import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:denta_koas/navigation_menu.dart';
import 'package:denta_koas/src/commons/widgets/state_screeen/state_screen.dart';
import 'package:denta_koas/src/cores/data/repositories/authentication.repository/authentication_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/post.repository/post_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/schedules.repository/shcedule_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/timeslot.repository/timeslot_repository.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/general_information_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/schedule_controller.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/timeslot_controller.dart';
import 'package:denta_koas/src/features/appointment/data/model/likes_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/post_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/schedules_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/tes.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class PostController extends GetxController {
  static PostController get instance => Get.find();

  final calendarController = CalendarController();
  final timeController = TimeController();
  final inputController = InputController();

  RxList<Post> posts = <Post>[].obs;
  RxList<Post> postUser = <Post>[].obs;
  RxList<Post> postWithSpecificTreatment = <Post>[].obs;
  RxList<Post> lastChangePost = <Post>[].obs;
  RxList<Post> newestPosts = <Post>[].obs;
  RxList<Post> openPosts = <Post>[].obs;
  RxList<Post> featuredPosts = <Post>[].obs;

  final isLoading = false.obs;
  final today = DateTime.now();

  final postRepository = Get.put(PostRepository());

  var generalInfo = {}.obs;
  var scheduleInfo = [].obs;

  var koasName = ''.obs;
  var selectedDate = ''.obs;
  var selectedTime = ''.obs;

  final selectedStatus = 'Open'.obs;

  // General information
  final title = TextEditingController();
  final description = TextEditingController();
  final requiredParticipant = TextEditingController();
  final treatmentType = TextEditingController();
  final patientRequirment = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }
  
  Future<void> initializePost() async {
    try {
      isLoading.value = true;
      await fetchPosts();

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
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

      // Last changed posts (3 post terlama berdasarkan createdAt)
      lastChangePost.assignAll(
        (List.of(postWithStatusOpen)
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
            .sublist(0,
                postWithStatusOpen.length < 3 ? postWithStatusOpen.length : 3),
      );

      postUser.assignAll(
        posts
            .where(
              (post) =>
                  post.status != StatusPost.Closed.name &&
                  UserController.instance.user.value.id == post.user.id,
            )
            .toList(),
      );

      // postUser(fetchedPosts);

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void createPost() async {
    try {
      // Log action start
      Logger().i('Starting createPost process...');
    
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);
      Logger().i('Opened loading dialog');

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      Logger().i('Network status: $isConected');
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        Logger().w('No internet connection');
        return;
      }

      final inputController = Get.put(InputController());
      final values = inputController.getAllValues();
      Logger().i('Input values: $values');

      final title = GeneralInformationController.instance.title.text.trim();
      final description =
          GeneralInformationController.instance.description.text.trim();
      final selectedTreatmentId =
          GeneralInformationController.instance.selectedTreatmentId;
      final requiredParticipant = GeneralInformationController.instance
          .convertToInt(GeneralInformationController
              .instance.requiredParticipant.text
              .trim());
      final images = GeneralInformationController.instance.selectedImages;
      final imageNames = GeneralInformationController.instance.fileNames;
      

      Logger().i('Title: $title, Description: $description, '
          'SelectedTreatmentId: $selectedTreatmentId, RequiredParticipant: $requiredParticipant');

      // Upload images to cloud storage
      final imageUrls = GeneralInformationController.instance.uploadedUrls;
      for (var index = 0; index < images.length; index++) {
        final imageUrl = await PostRepository.instance.uploadToCloudinary(
          images[index],
          imageNames[index],
          index,
        );
        Logger().f('Uploaded image URL: $imageUrl');
        imageUrls.add(imageUrl!);
      }

      // Initialize the model for general information post
      final newPost = PostModel(
        userId: UserController.instance.user.value.id,
        koasId: UserController.instance.user.value.koasProfile!.id!,
        title: title,
        desc: description,
        images: imageUrls,
        requiredParticipant: requiredParticipant,
        patientRequirement: values,
        treatmentId: selectedTreatmentId,
      );
      Logger().i('Initialized new PostModel: ${newPost.toJson()}');

      // Create post
      final post = await PostRepository.instance.createPost(newPost);
      Logger().i('Created post response: ${post.toJson()}');

      // Get current postId from the server
      final postId = post.id;
      final postRequiredParticipant = post.requiredParticipant;

      if (postId == null) {
        TFullScreenLoader.stopLoading();
        Logger().e('Failed to fetch post id from the server');
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to fetch post id from the server',
        );
        return;
      }

      Logger().i(
          'Post ID: $postId, Required Participant: $postRequiredParticipant');

      final dateStartValue = SchedulePostController.instance.dateStartValue;
      final dateEndValue = SchedulePostController.instance.dateEndValue;

      // Create the post schedule
      final schedulePost = SchedulesModel(
        postId: postId,
        dateStart: dateStartValue,
        dateEnd: dateEndValue,
      );
      Logger().i('SchedulePost: ${schedulePost.toJson()}');

        final scheduleRepository = Get.put(SchedulesRepository());
        final newPostSchedule =
            await scheduleRepository.createSchedule(schedulePost);
        Logger().i('New Post Schedule: ${newPostSchedule.toJson()}');

        final currentScheduleId = newPostSchedule.id;

        if (currentScheduleId == null) {
          TFullScreenLoader.stopLoading();
          Logger().e('Failed to create post schedule');
          TLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to create post schedule',
          );
          return;
        }

      // Init timeslots controller to get all timeslots
      final timeslotController = Get.put(PostTimeslotController());
      final newTimeslots =
          timeslotController.getAllTimeSlotsForApi(newPostSchedule.id!);
      Logger().i('Generated timeslots: $newTimeslots');

      // Create batch timeslots
      final timeslotRepository = Get.put(TimeslotRepository());
      await timeslotRepository.createBatchTimeslots(
          newPostSchedule.id!, newTimeslots);
      Logger().i('Batch timeslots created successfully');

      final postStatus = PostModel(
        id: postId,
        status: StatusPost.values.firstWhere(
            (e) => e.toString() == 'StatusPost.${selectedStatus.value}'),
      );
      Logger().i('Updating post status to: ${postStatus.toJson()}');

      await postRepository.updatePost(postId, postStatus);

      // Close loading
      TFullScreenLoader.stopLoading();
      Logger().i('Post creation process completed successfully');

      // Success message
      TLoaders.successSnackBar(
        title: 'Congratulations!',
        message: 'Post has been created',
      );

      // Refresh post list
      await fetchPosts();

      // Navigate to next screen but remove routes until CreateGeneralInformation
      Get.to(
          () => StateScreen(
                key: UniqueKey(),
                image: TImages.successCreatePost,
                title: 'Your post has been created successfully!',
                subtitle:
                    'Congratulations! Your post is now live and ready for participants.',
                showButton: true,
                primaryButtonTitle: 'Go to Dashboard',
          onPressed: () => Get.offAll(() => const NavigationMenu()),
              ),
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      Logger().e(
        'Error creating post: $e',
      );
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void deletePost(String postId) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action....', TImages.loadingHealth);

      // Check connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        Logger().e('No internet connection');
        TFullScreenLoader.stopLoading();
        return;
      }

      // debug
      Logger().i('Deleting post with ID: $postId');

      final deletedPost = await PostRepository.instance.deletePost(postId);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Success message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Post has been deleted',
      );

      // Refresh post list
      await fetchPosts();

      // Navigate to next screen
      Get.to(() => const NavigationMenu());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void confirmDeletePost(String postId) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account?',
      confirm: ElevatedButton(
        onPressed: () {
          Navigator.of(Get.overlayContext!).pop();
          deletePost(postId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }


  // Fungsi untuk menyimpan data General Information
  void setGeneralInfo(Map<String, dynamic> generalInformation) {
    generalInfo.value = generalInformation;
  }

  // Fungsi untuk menyimpan data Schedule
  void setSchedule(List<Map<String, dynamic>> schedules) {
    scheduleInfo.value = schedules;
  }

  void updatePreviewAppointment(String name, String date, String time) {
    koasName.value = name;
    selectedDate.value = date;
    selectedTime.value = time;
  }

  setStatusColor(StatusPost status) async {
    Color statusColor;
    switch (status) {
      case StatusPost.Pending:
        statusColor = TColors.warning;
        break;
      case StatusPost.Open:
        statusColor = TColors.success;
        break;
      case StatusPost.Closed:
        statusColor = TColors.error;
        break;
    }
  }

  void createLike(String postId) async {
    try {
      final user = LikesModel(
        userId: AuthenticationRepository.instance.authUser!.uid,
      );
      final like = await postRepository.likePost(user, postId);

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Post has been liked',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  
}

class CalendarController extends GetxController {
  static CalendarController get instance => Get.find<CalendarController>();

  var selectedIndex = 0.obs;
  var selectedDate = DateTime.now().obs;

  var selectedDateRange = <DateTime?>[].obs;

  final calendarRangeConfig = CalendarDatePicker2Config(
    calendarType: CalendarDatePicker2Type.range,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    selectedDayHighlightColor: TColors.primary,
    weekdayLabelTextStyle: const TextStyle(color: TColors.grey),
    controlsTextStyle: const TextStyle(color: TColors.primary),
  );

  void initializeSelectedIndex(DateTime startDate, DateTime today) {
    // Hitung index berdasarkan hari ini, atau tetap 0 jika hari ini sebelum startDate
    selectedIndex.value =
        today.isBefore(startDate) ? 0 : today.difference(startDate).inDays;
  }

  void updateSelectedDay(int index) {
    selectedIndex.value = index;
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }
}

class TimeController extends GetxController {
  static TimeController get instance => Get.find<TimeController>();

  var tooltipShown = false;

  var requiredParticipants = 0.obs;

  // Observables
  var sessionDuration = const Duration(hours: 1).obs;
  var timeSlots = <String, List<String>>{
    'Pagi': [],
    'Siang': [],
    'Malam': [],
  }.obs;

  var maxParticipants = <String, Map<String, int>>{
    'Pagi': {},
    'Siang': {},
    'Malam': {},
  }.obs;

  void setRequiredParticipants(int requiredParticipant) {
    requiredParticipants.value = requiredParticipant;
  }

// Tambahkan timeslot baru
  void addTimeSlot(String section, TimeOfDay startTime) {
    final DateTime now = DateTime.now();
    final DateTime startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final DateTime endDateTime = startDateTime.add(sessionDuration.value);

    final String timeSlot =
        "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - "
        "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";

    // Menambahkan timeslot baru
    timeSlots[section]?.add(timeSlot);
    maxParticipants[section] ??= {};

    // Cek apakah semua section kosong atau tidak
    bool allSectionsEmpty =
        maxParticipants.values.every((slots) => slots.isEmpty);
    maxParticipants[section]![timeSlot] = 1;

    // Mengurangi peserta dari slot sebelumnya dengan maxParticipants tertinggi di semua section
    for (var sec in timeSlots.keys) {
      if (timeSlots[sec]?.isNotEmpty ?? false) {
        // Menemukan timeslot dengan maxParticipants tertinggi
        final sortedSlots = maxParticipants[sec]!.entries.toList()
          ..sort((a, b) => b.value
              .compareTo(a.value)); // Mengurutkan berdasarkan maxParticipants
        final previousSlot =
            sortedSlots.isNotEmpty ? sortedSlots.first.key : null;

        if (previousSlot != null && previousSlot != timeSlot) {
          decrementMaxParticipantsForSlot(sec,
              previousSlot); // Mengurangi peserta dari timeslot dengan maxParticipants tertinggi
        }
      }
    }

    timeSlots.refresh(); // Update UI
    update(); // Update UI
  }

// Ubah durasi sesi
  void updateSessionDuration(int hours) {
    sessionDuration.value = Duration(hours: hours);
    _updateAllTimeSlots(); // Perbarui semua slot waktu
  }

// Perbarui semua slot waktu berdasarkan durasi terbaru
  void _updateAllTimeSlots() {
    final updatedSlots = <String, List<String>>{};

    timeSlots.forEach((section, slots) {
      final updatedSectionSlots = <String>[];

      for (var slot in slots) {
        final startTime = _parseTime(slot.split(' - ')[0]);
        final startDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          startTime.hour,
          startTime.minute,
        );
        final endDateTime = startDateTime.add(sessionDuration.value);

        final updatedSlot =
            "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} - "
            "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
        updatedSectionSlots.add(updatedSlot);
      }

      updatedSlots[section] = updatedSectionSlots;
    });

    timeSlots.value = updatedSlots;
    timeSlots.refresh(); // Update UI
    update(); // Update UI
  }

  // Update jumlah peserta maksimal untuk sesi tertentu
  // void setMaxParticipants(String section, int max) {
  //   if(timeSlots[section] != null) {
  //   maxParticipants[section] = max;
  //   maxParticipants.refresh(); // Update UI
  //   update(); // Update UI
  //   }
  // }

// Helper untuk parsing waktu dari string
  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

// Hapus timeslot
  void removeTimeSlot(String section, String slot) {
    timeSlots[section]?.remove(slot);
    maxParticipants[section]?.remove(slot);
    timeSlots.refresh(); // Update UI
    maxParticipants.refresh(); // Update UI
    update(); // Update UI
  }

// Get total jumlah peserta maksimal dari semua section
  int get totalMaxParticipants {
    int total = 0;
    maxParticipants.forEach((section, slots) {
      slots.forEach((slot, max) {
        total += max;
      });
    });
    return total;
  }

// Get total jumlah timeslot yang tersedia dari semua section
  int get totalAvailableTimeSlots {
    int total = 0;
    maxParticipants.forEach((section, slots) {
      total += slots.length;
    });
    return total;
  }

// Increment jumlah peserta maksimal untuk slot waktu tertentu
  void incrementMaxParticipantsForSlot(String section, String slot) {
    if (timeSlots[section] != null) {
      maxParticipants[section] ??= {};
      maxParticipants[section]![slot] =
          (maxParticipants[section]![slot] ?? 1) + 1;
      maxParticipants.refresh(); // Update UI
      update(); // Update UI
    }
  }

// Decrement jumlah peserta maksimal untuk slot waktu tertentu
  void decrementMaxParticipantsForSlot(String section, String slot) {
    if (timeSlots[section] != null) {
      maxParticipants[section] ??= {};
      final currentMax = maxParticipants[section]![slot] ?? 1;
      if (currentMax > 1) {
        maxParticipants[section]![slot] = currentMax - 1;
        maxParticipants.refresh(); // Update UI
        update(); // Update UI
      }
    }
  }

// Get jumlah peserta maksimal untuk slot waktu tertentu
  int maxParticipantsForSlot(String section, String slot) {
    return maxParticipants[section]?[slot] ?? 1; // Default value is 1
  }

  Map<String, int> calculateSectionLengths() {
    final sectionLengths = <String, int>{};

    // Hitung jumlah slot per section
    timeSlots.forEach((section, slots) {
      sectionLengths[section] = slots.length;
    });

    return sectionLengths;
  }

  int calculateTotalSlots() {
    int totalSlots = 0;

    // Hitung total semua slot
    timeSlots.forEach((_, slots) {
      totalSlots += slots.length;
    });

    return totalSlots;
  }

  final selectedTimeStamp = (-1).obs;

  void updateSelectedTimeStamp(int index) {
    selectedTimeStamp.value = index;
  }
}

class InputController extends GetxController {
  static InputController get instance => Get.find<InputController>();

  // List of TextEditingController to manage dynamic inputs
  RxList<TextEditingController> patientRequirements =
      <TextEditingController>[].obs;

  /// Initialize the inputs with a default count or data from previous
  void initializeInputs(int count, {List<String>? initialData}) {
    // Clear existing controllers first to prevent adding duplicates
    patientRequirements.clear();

    if (initialData != null && initialData.isNotEmpty) {
      // If initialData is provided, initialize with that
      for (var data in initialData) {
        patientRequirements.add(TextEditingController(text: data));
      }
    } else {
      // Otherwise, initialize with a default count
      for (int i = 0; i < count; i++) {
        patientRequirements.add(TextEditingController());
      }
    }
  }

  /// Add a new input for requirement patient
  void addInputRequirment() {
    patientRequirements.add(TextEditingController());
  }

  /// Remove the input requirement at the specified index
  void removeInputRequirement(int index) {
    if (index >= 0 && index < patientRequirements.length) {
      patientRequirements[index].dispose(); // Hapus controller dari memori
      patientRequirements.removeAt(index);
    }
  }

  /// Get all values from the patientRequirements
  List<String> getAllValues() {
    return patientRequirements.map((controller) => controller.text).toList();
  }

  /// Update the general information with new data
  void updateGeneralInformation({required String postId}) {
    // Here, you would retrieve the existing data based on postId (from a repository or API)
    // Assuming you have a method to fetch this data (you can replace it with your actual logic)

    List<String> fetchedData = fetchDataFromPostId(
        postId); // This should return a List<String> from your API or data source

    // Initialize the inputs with the fetched data
    initializeInputs(fetchedData.length, initialData: fetchedData);
  }

  /// Simulate fetching data based on postId (replace with your actual logic)
  List<String> fetchDataFromPostId(String postId) {
    // Example of fetching data; replace with your actual fetching logic
    return ["John Doe", "1234 Main St", "555-1234"];
  }

  @override
  void onClose() {
    // Dispose all controllers to free memory
    for (var controller in patientRequirements) {
      controller.dispose();
    }
    super.onClose();
  }
}


