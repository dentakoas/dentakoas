import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:denta_koas/src/cores/data/repositories/treatments.repository/treatment_repository.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/schedule/create_schedule.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/dio.client/dio_client.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class GeneralInformationController extends GetxController {
static GeneralInformationController get instance => Get.find();

  final title = TextEditingController();
  final description = TextEditingController();
  final requiredParticipant = TextEditingController();
  RxList<TextEditingController> patientRequirements =
      <TextEditingController>[].obs;
  final selectedTreatment = ''.obs;

  RxMap<String, String> treatmentsMap = <String, String>{}.obs;
  String selectedTreatmentId = '';
  late List<String> patientRequirementsValues;

  final GlobalKey<FormState> generalInformationFormKey = GlobalKey<FormState>();

  var cloudinary = Cloudinary.signedConfig(
    apiKey: '338626958888276',
    apiSecret: '8SxMxVmbz4tinfex31MJtaj7x6A',
    cloudName: 'dxw9ywgfq',
  );

  // Image Upload related variables
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> fileNames = <String>[].obs;
  final RxList<String> uploadedUrls = <String>[].obs;
  final ImagePicker picker = ImagePicker();
  final RxBool isUploading = false.obs;

  // Azure Configuration
  static const String azureEndpoint =
      'https://dental-vision-api.cognitiveservices.azure.com/vision/v3.2/read/analyze';
  static const String subscriptionKey =
      '9apMlkrmZWuIqWU4lqf2XCYUJ7f0FGCwdh7ig9JizitYnsIcNB38JQQJ99BBACqBBLyXJ3w3AAAFACOGrpbU';

  final analyzingIndex = (-1).obs;

  // Daftar kata kunci yang berkaitan dengan dental
  final List<String> dentalKeywords = [
    // Dental
    'teeth', 'tooth', 'dental', 'dentist', 'gigi', 'mulut', 'orthodontic',
    'braces', 'cavity', 'filling', 'crown', 'root canal', 'dental clinic',
    'oral', 'odontogram', 'periodontal', 'caries', 'karies', 'scaling',
    'bleaching', 'veneer', 'bridge', 'plak', 'plaque', 'gusi', 'gingiva',
    'behel', 'kawat gigi', 'tambalan', 'pencabutan', 'dental chair',
    'dental x-ray',
    'panoramic x-ray', 'dental radiograph', 'dental tools', 'dental mirror',
    'dental probe', 'dental scaler', 'dental floss', 'toothbrush', 'toothpaste',
    'wisdom tooth', 'tooth extraction', 'fluoride treatment', 'gingivitis',
    'periodontitis', 'occlusion', 'dental retainer', 'dental implant',
    'jawbone',
    'denture', 'oral health', 'pediatric dentistry', 'dental bonding',
    'prosthodontics', 'orthodontics', 'dental lab', 'dental hygienist',
    'pulp', 'enamel', 'dentin', 'root apex', 'molar', 'premolar', 'canine',
    'incisor',
    'dental impression', 'dental tray', 'dental bite', 'bitewing',
    'dental bridge',
    'interdental brush', 'mouthguard', 'intraoral camera', 'digital dentistry',
    'shade guide', 'smile makeover', 'esthetic dentistry', 'dental bonding',
    'oral cancer screening', 'tooth whitening', 'dental sealant',

    // Medical (General)
    'medical', 'doctor', 'nurse', 'clinic', 'hospital', 'healthcare',
    'medication',
    'stethoscope', 'syringe', 'injection', 'blood test', 'x-ray', 'ultrasound',
    'MRI', 'CT scan', 'medical imaging', 'operating room', 'surgery', 'surgeon',
    'patient', 'diagnosis', 'treatment', 'therapy', 'medicine', 'first aid',
    'emergency', 'ambulance', 'ECG', 'defibrillator', 'oxygen mask',
    'ventilator',
    'IV drip', 'thermometer', 'glucose meter', 'bandage', 'medical record',
    'heartbeat', 'blood pressure', 'health check', 'physiotherapy',
    'vaccination',
    'health screening', 'pharmacy', 'prescription', 'surgical instruments',

    // Health & Wellness
    'healthy lifestyle', 'nutrition', 'diet', 'fitness', 'yoga', 'exercise',
    'mental health', 'wellness', 'therapy session', 'counseling',
    'healthy food',
    'vitamins', 'supplements', 'hydration', 'weight loss', 'stress relief',
    'physical therapy', 'rehabilitation', 'home care', 'nursing home', 'spa',
    'sleep', 'wellbeing', 'mindfulness', 'preventive care', 'public health',

    // Anatomy & Physiology
    'heart', 'lungs', 'brain', 'kidney', 'liver', 'stomach', 'intestine',
    'skeletal system', 'muscle', 'nervous system', 'blood vessels', 'skin',
    'bones', 'joints', 'spine', 'pelvis', 'femur', 'ribcage', 'thorax',
    'maxilla', 'mandible', 'sinus', 'tonsils', 'pharynx', 'larynx', 'esophagus',

    // Hospital & Medical Environment
    'hospital bed', 'nursing station', 'reception', 'waiting room',
    'surgical room',
    'laboratory', 'diagnostic center', 'medical team', 'healthcare worker',
    'sanitizer', 'face mask', 'protective gloves', 'PPE', 'biohazard',
    'sterilization',

    // Medical Specializations
    'cardiology', 'neurology', 'orthopedics', 'pediatrics', 'dermatology',
    'gynecology', 'urology', 'oncology', 'gastroenterology', 'radiology',
    'psychiatry', 'immunology', 'genetics', 'endocrinology', 'anesthesiology',
    'ophthalmology', 'otolaryngology', 'hematology', 'pathology',

    // Laboratory & Research
    'microscope', 'test tube', 'beaker', 'petri dish', 'centrifuge', 'lab coat',
    'researcher', 'scientist', 'biomedical research', 'clinical trial', 'DNA',
    'genetic testing', 'molecular biology', 'pathogen', 'vaccine research',
    'antibody', 'antigen', 'blood sample', 'urine test', 'biopsy',

    // Emergency & Critical Care
    'ICU', 'emergency room', 'paramedic', 'life support', 'trauma care',
    'emergency response', 'triage', 'helicopter ambulance', 'resuscitation',
    'emergency kit', 'first responder', 'cardiac arrest', 'stroke',

    // Imaging & Diagnostics
    'radiograph', 'mammogram', 'ultrasound gel', 'imaging technician',
    'diagnostic lab', 'contrast dye', 'echocardiogram', 'bone scan',

    // Public Health & Safety
    'quarantine', 'isolation', 'infection control', 'pandemic',
    'vaccination campaign',
    'immunization', 'outbreak', 'health awareness', 'mask wearing',
    'hand washing',
    'epidemiology', 'herd immunity', 'contact tracing', 'health survey',

    // Healthcare Technology
    'telemedicine', 'wearable health device', 'health app', 'medical AI',
    'electronic health record', 'robotic surgery', 'health sensor',
    '3D printing in healthcare',
    'virtual consultation', 'mobile health', 'digital health monitoring',

    // Rehabilitation & Assistive Devices
    'hearing aid', 'wheelchair', 'crutches', 'prosthetic limb', 'walker',
    'orthotic',
    'speech therapy', 'occupational therapy', 'rehab center',
    'assistive technology',

    // Mental & Psychological Health
    'psychologist', 'psychiatrist', 'therapy', 'counseling',
    'mental health awareness',
    'depression', 'anxiety', 'stress management', 'mindfulness therapy',
    'mental wellness'
  ];

  @override
  void onInit() {
    super.onInit();
    initializeInputs(1);
    getTreatments();
  }

  Future<bool> validateDentalImage(File imageFile, int index) async {
    try {
      analyzingIndex.value = index; // Set analyzing state
      // Read image file as bytes
      final bytes = await imageFile.readAsBytes();

      // Initial request to analyze image
      final initialResponse = await DioClient().post(
        azureEndpoint,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Ocp-Apim-Subscription-Key': subscriptionKey,
            'Content-Type': 'application/octet-stream',
            'Content-Length': bytes.length,
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (initialResponse.statusCode != 202) {
        throw DioException(
          requestOptions: initialResponse.requestOptions,
          response: initialResponse,
          message: 'Failed to analyze image: ${initialResponse.data}',
        );
      }

      // Get the operation-location URL from headers
      final operationLocation =
          initialResponse.headers.value('operation-location');
      if (operationLocation == null) {
        throw Exception('Operation location header not found in response');
      }

      // Poll the result URL until analysis is complete
      bool isAnalysisComplete = false;
      Map<String, dynamic>? result;

      while (!isAnalysisComplete) {
        await Future.delayed(const Duration(seconds: 1));

        final resultResponse = await DioClient().get(
          operationLocation,
          options: Options(
            headers: {
              'Ocp-Apim-Subscription-Key': subscriptionKey,
            },
          ),
        );

        if (resultResponse.statusCode != 200) {
          throw DioException(
            requestOptions: resultResponse.requestOptions,
            response: resultResponse,
            message: 'Failed to get analysis results: ${resultResponse.data}',
          );
        }

        final status = resultResponse.data['status'];
        if (status == 'succeeded') {
          isAnalysisComplete = true;
          result = resultResponse.data;
        } else if (status == 'failed') {
          throw Exception('Image analysis failed');
        }
      }

      if (result == null) {
        throw Exception('No analysis results received');
      }

      // Extract tags and analyze content
      List<String> allTags = [];

      // Add tags from the analysis result
      if (result['analyzeResult'] != null &&
          result['analyzeResult']['tags'] is List) {
        allTags.addAll((result['analyzeResult']['tags'] as List)
            .map((tag) => tag['name'].toString().toLowerCase()));
      }

      // Add any text detected in the image
      if (result['analyzeResult'] != null &&
          result['analyzeResult']['readResults'] is List) {
        final readResults = result['analyzeResult']['readResults'] as List;
        for (var page in readResults) {
          if (page['lines'] is List) {
            allTags.addAll((page['lines'] as List)
                .map((line) => line['text'].toString().toLowerCase()));
          }
        }
      }

      // Debug print detected tags
      Logger().i('Detected tags and text: $allTags');

      // Check if any dental keywords are present
      bool isDentalRelated = allTags.any((tag) =>
          dentalKeywords.any((keyword) => tag.contains(keyword.toLowerCase())));

      if (!isDentalRelated) {
        TLoaders.warningSnackBar(
          title: 'Warning',
          message: 'Please upload an image that is related to dental health',
        );
        analyzingIndex.value = -1;
        return false;
      }

      analyzingIndex.value = -1;
      return true;
    } on DioException catch (e) {
      Logger().e('Dio Error: ${e.message}');
      Logger().e('Response: ${e.response?.data}');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'There was an error validating the image. Please try again'
            ' or upload a different image',
      );
      analyzingIndex.value = -1;
      return false;
    } catch (e) {
      Logger().e('Error: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'There was an error validating the image. Please try again'
            ' or upload a different image',
      );
      analyzingIndex.value = -1;
      return false;
    }
  }


  // Image picking and upload methods
Future<void> pickImage() async {
    try {
      // Check if already uploading or analyzing
      if (isUploading.value || analyzingIndex.value != -1) {
        return;
      }

      // Check maximum image limit
      if (selectedImages.length >= 4) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Maximum 4 images can be uploaded',
        );
        return;
      }

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      const maxSize = 10 * 1024 * 1024; // 10 MB

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize <= maxSize) {
          const uuid = Uuid();
          final randomFileName = '${uuid.v4()}.${image.path.split('.').last}';

          // Add to list first so we have an index for the loading state
          selectedImages.add(file);
          fileNames.add(randomFileName);
          final currentIndex = selectedImages.length - 1;

          // Validate image content
          bool isValid = await validateDentalImage(file, currentIndex);

          if (!isValid) {
            // Remove the image if validation fails
            selectedImages.removeAt(currentIndex);
            fileNames.removeAt(currentIndex);
            return;
          }

          // Optional: Upload to Cloudinary
          // await uploadToCloudinary(file, currentIndex);
        
        } else {
          TLoaders.errorSnackBar(
            title: 'Error',
            message: 'Maximum file size is ${maxSize ~/ (1024 * 1024)} MB',
          );
        }
      }
    } catch (e) {
      Logger().e('Error picking image: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to pick image',
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      fileNames.removeAt(index);
      if (index < uploadedUrls.length) {
        uploadedUrls.removeAt(index);
      }
    }
  }

  void previewImage(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.file(image, fit: BoxFit.contain),
      ),
    );
  }

void createGeneralInformation() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Processing your action...', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate form
      if (!generalInformationFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Check if first requirement is filled
      if (!validateRequirements()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate images
      if (selectedImages.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'Warning',
          message: 'Please upload at least one image',
        );
        TFullScreenLoader.stopLoading();
        return;
      }

      // Get non-empty requirement values
      final requirements = patientRequirements
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Your existing post creation logic here...

      // Close loading
      TFullScreenLoader.stopLoading();

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

  Future<void> getTreatments() async {
    try {
      final treatments =
          await TreatmentRepository.instance.getAllTreatmentTypes();
      if (treatments.isNotEmpty) {
        treatmentsMap.assignAll({
          for (var treatment in treatments) treatment.id!: treatment.alias!
        });
        Logger().i('Treatments Map: $treatmentsMap');
      } else {
        Logger().w('No treatments available.');
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'An error occurred while fetching treatments',
      );
    }
  }

  void setSelectedTreatment(String alias) {
    final selectedEntry = treatmentsMap.entries.firstWhere(
        (entry) => entry.value == alias,
        orElse: () => const MapEntry('', ''));
    selectedTreatmentId = selectedEntry.key; // Simpan ID untuk POST
    selectedTreatment.value = alias; // Simpan alias untuk tampilan
    // Logger().i('Selected Treatment ID: ${selectedEntry.key}');
    // Logger().i('Selected Treatment: $alias');
  }

  List<DropdownMenuItem<String>> buildDropdownItems(Map<String, String> items) {
    return items.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(entry.value),
      );
    }).toList();
  }

  int? convertToInt(String value) {
    try {
      return int.parse(value.trim());
    } catch (e) {
      // Jika gagal konversi, return null atau nilai default
      Logger().e(e.toString());
      return null; // Atau gunakan nilai default seperti 0
    }
  }

  /// Initialize the inputs with a default count
  void initializeInputs(int count) {
    patientRequirements.clear();
    for (int i = 0; i < count; i++) {
      patientRequirements.add(TextEditingController());
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

  // bool validateRequirements() {
  //   for (int i = 0; i < patientRequirements.length; i++) {
  //     if (patientRequirements[i].text.trim().isEmpty) {
  //       TLoaders.warningSnackBar(
  //         title: 'Warning',
  //         message: 'Requirement ${i + 1} cannot be empty',
  //       );
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  bool validateRequirements() {
    // Check if there's at least one requirement
    if (patientRequirements.isEmpty) {
      TLoaders.warningSnackBar(
        title: 'Warning',
        message: 'Please add at least one requirement',
      );
      return false;
    }

    // // Only validate the first requirement
    // if (patientRequirements[0].text.trim().isEmpty) {
    //   TLoaders.warningSnackBar(
    //     title: 'Warning',
    //     message: 'First requirement cannot be empty',
    //   );
    //   return false;
    // }

    return true;
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
