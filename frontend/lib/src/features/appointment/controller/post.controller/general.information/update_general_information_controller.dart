import 'package:denta_koas/src/cores/data/repositories/post.repository/post_repository.dart';
import 'package:denta_koas/src/features/appointment/controller/post.controller/general_information_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/schedule/create_schedule.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class UpdateGeneralInformationController extends GetxController {
  static UpdateGeneralInformationController get instance => Get.find();

  final title = TextEditingController();
  final description = TextEditingController();
  final requiredParticipant = TextEditingController();
  final selectedTreatment = ''.obs;
  RxList<TextEditingController> patientRequirements =
      <TextEditingController>[].obs;

  RxMap<String, String> treatmentsMap = <String, String>{}.obs; // {id: alias}

  List<DropdownMenuItem<String>> items =
      []; // Update this to store DropdownMenuItem<String>

  String selectedTreatmentId = ''; // Untuk menyimpan ID yang dipilih

  late List<String> patientRequirementsValues;

  final GlobalKey<FormState> updateGeneralInformationFormKey =
      GlobalKey<FormState>();

  final generalInformationController = Get.put(GeneralInformationController());

  // @override
  // void onInit() {
  //   super.onInit();
  //   final postId = Get.arguments;
  //   initializedGeneralInformation(postId);
  //   generalInformationController.getTreatments();
  // }

  void initializedGeneralInformation(String postId) async {
    final generalInformation =
        await PostRepository.instance.getPostByPostId(postId);
    try {
      title.text = generalInformation.title!;
      description.text = generalInformation.desc!;
      requiredParticipant.text =
          generalInformation.requiredParticipant!.toString();
      selectedTreatment.value = generalInformation.treatment!.alias!;
      selectedTreatmentId = generalInformation.treatment!.id!;
      patientRequirements.clear();
      generalInformation.patientRequirement!.forEach((element) {
        patientRequirements.add(TextEditingController(text: element));
      });
    } catch (e) {
      Logger().e(e);
      TLoaders.errorSnackBar(
        title: 'Error',
        message: "Something went wrong, please try again",
      );
    }
  }

  void updateGeneralInformation() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Proceccing your action....', TImages.superToothLoading);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate the form
      if (!updateGeneralInformationFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // final inputController = Get.put(InputController());
      // final values = inputController.getAllValues();

      // // Initialize the model for the post
      // final newPost = PostModel(
      //   userId: UserController.instance.user.value.id,
      //   koasId: UserController.instance.user.value.koasProfile!.id!,
      //   title: title.text.trim(),
      //   desc: description.text.trim(),
      //   requiredParticipant: convertToInt(requiredParticipant.text.trim()),
      //   patientRequirement: values,
      //   treatmentId: selectedTreatmentId,
      // );

      // Logger().i(newPost);

      // // Send the data to the server
      // final post = await PostRepository.instance.createPost(newPost);

      // // Get current postId from the server
      // final postId = post.id;
      // final postRequiredParticipant = post.requiredParticipant;

      // if (postId == null) {
      //   TLoaders.errorSnackBar(
      //     title: 'Error',
      //     message: 'Failed to fetch post id from the server',
      //   );
      //   return;
      // }

      // Close loading
      TFullScreenLoader.stopLoading();

      // Success message
      // TLoaders.successSnackBar(
      //   title: 'Success',
      //   message: 'Post has been created',
      // );

      // Navigate to next screen
      Get.to(() => const CreateSchedulePost());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void setSelectedTreatment(String alias) {
    final selectedEntry = treatmentsMap.entries.firstWhere(
        (entry) => entry.value == alias,
        orElse: () => const MapEntry('', ''));
    selectedTreatmentId = selectedEntry.key; // Simpan ID untuk POST
    selectedTreatment.value = alias; // Simpan alias untuk tampilan
  }
}
