import 'dart:io' show Platform;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../widgets/geocode_suggestions_widget.dart';

class CreateApplicationPage extends StatefulWidget {
  final String? initialCity;

  const CreateApplicationPage({super.key, this.initialCity});

  @override
  State<CreateApplicationPage> createState() => _CreateApplicationPageState();
}

class _CreateApplicationPageState extends State<CreateApplicationPage> {
  final _commentController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize the form via ApplicationBloc. No profile-based city logic here.
    context.read<ApplicationBloc>().add(InitializeFormEvent());
  }

  @override
  void dispose() {
    _commentController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _commentFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update controllers from ApplicationBloc state, fallback to widget.initialCity if needed
    final applicationState = context.watch<ApplicationBloc>().state;

    if (applicationState is ApplicationFormState) {
      if (applicationState.addressQuery != _addressController.text) {
        _addressController.text = applicationState.addressQuery;
      }

      if ((applicationState.selectedCity ?? '').isNotEmpty &&
          applicationState.selectedCity != _cityController.text) {
        _cityController.text = applicationState.selectedCity!;
      } else if ((applicationState.selectedCity ?? '').isEmpty &&
          (widget.initialCity ?? '').isNotEmpty &&
          widget.initialCity != _cityController.text) {
        // Use passed initialCity as a one-time fallback when ApplicationBloc has no city
        _cityController.text = widget.initialCity!;
      }

      if (applicationState.description != _commentController.text) {
        _commentController.text = applicationState.description;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      backgroundColor: const Color(0xFFF1F2F1),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: BlocListener<ApplicationBloc, ApplicationState>(
                  listener: (context, state) {
                    if (state is ApplicationCreated) {
                      _showSuccessMessage();
                      Navigator.pop(context);
                    } else if (state is ApplicationFormState &&
                        state.error != null) {
                      _showErrorMessage(state.error!);
                    } else if (state is GeolocationSuccess) {
                      _addressController.text = state.result.displayName;
                      _showSuccessMessage('Геолокация получена успешно');
                    } else if (state is GeolocationError) {
                      _showErrorMessage(state.message);
                    }
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          _buildGeneralInfoSection(),
                          const SizedBox(height: 40),
                          _buildPhotosSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              height: 31,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/back_arrow.svg',
                width: 24,
                height: 20,
                color: const Color(0xFF353F49),
                semanticsLabel: 'back',
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Создать заявку',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF353F49),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Общие сведения',
          style: TextStyle(
            fontFamily: 'Mabry Pro',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xDE000000),
            height: 1.10,
          ),
        ),
        const SizedBox(height: 12),
        _buildCityField(),
        const SizedBox(height: 14),
        _buildAddressField(),
        const SizedBox(height: 6),
        _buildUseLocationButton(),
        const SizedBox(height: 24),
        _buildCommentField(),
      ],
    );
  }

  Widget _buildCityField() {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        // city is controlled by _cityController and updated from ApplicationBloc state

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F2F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: TextField(
              controller: _cityController,
              readOnly:
                  true, // City is populated automatically by ApplicationBloc
              decoration: const InputDecoration(
                hintText: 'Город',
                hintStyle: TextStyle(
                  fontFamily: 'Mabry Pro',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color(0x52000000),
                  height: 1.30,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
              style: const TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color(0xDE000000),
                height: 1.30,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressField() {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        final formState = state is ApplicationFormState
            ? state
            : const ApplicationFormState();

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: TextField(
                  controller: _addressController,
                  focusNode: _addressFocusNode,
                  onChanged: (value) {
                    context.read<ApplicationBloc>().add(
                      UpdateAddressQueryEvent(addressQuery: value),
                    );

                    if (value.trim().isNotEmpty) {
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        if (_addressController.text == value &&
                            value.trim().isNotEmpty) {
                          final city = _cityController.text.trim();
                          final query = city.isNotEmpty
                              ? '$city, $value'
                              : value;
                          context.read<ApplicationBloc>().add(
                            GeocodeAddressEvent(query: query),
                          );
                        }
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Город, улица, здание',
                    hintStyle: TextStyle(
                      fontFamily: 'Mabry Pro',
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color(0x52000000),
                      height: 1.30,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Mabry Pro',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Color(0xDE000000),
                    height: 1.30,
                  ),
                ),
              ),
            ),
            if (formState.geocodeResults.isNotEmpty)
              GecodeSuggestionsWidget(
                suggestions: formState.geocodeResults,
                onSuggestionSelected: (address) {
                  _addressController.text = address.displayName;
                  context.read<ApplicationBloc>().add(
                    SelectGeocodeResultEvent(address: address),
                  );
                  _addressFocusNode.unfocus();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildUseLocationButton() {
    return GestureDetector(
      onTap: _requestLocationPermissionAndGetLocation,
      child: const Text(
        'Использовать текущую геолокацию',
        style: TextStyle(
          fontFamily: 'SF Compact',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF2782E3),
          height: 1.30,
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _commentController,
          focusNode: _commentFocusNode,
          maxLines: null,
          expands: true,
          onChanged: (value) {
            context.read<ApplicationBloc>().add(
              UpdateDescriptionEvent(description: value),
            );
          },
          decoration: const InputDecoration(
            hintText: 'Комментарий',
            hintStyle: TextStyle(
              fontFamily: 'Mabry Pro',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0x52000000),
              height: 1.30,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(
            fontFamily: 'Mabry Pro',
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Color(0xDE000000),
            height: 1.30,
          ),
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        final formState = state is ApplicationFormState
            ? state
            : const ApplicationFormState();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Фотографии',
              style: TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xDE000000),
                height: 1.10,
              ),
            ),
            const SizedBox(height: 11),
            const Text(
              'Добавьте одну или несколько фотографий, описывающих проблему или другие особенности',
              style: TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0x8A000000),
                height: 1.20,
              ),
            ),
            const SizedBox(height: 14),
            _buildPhotoSelector(),
            if (formState.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildImageGrid(formState.imageUrls),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPhotoSelector() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 90,
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
        ),
        child: Center(
          // use SVG camera icon instead of placeholder glyph
          child: SvgPicture.asset(
            'assets/icons/camera.svg',
            width: 30,
            height: 23,
            color: const Color(0x8A000000),
            semanticsLabel: 'camera',
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: imageUrls.asMap().entries.map((entry) {
        final index = entry.key;
        final imagePath = entry.value;

        return Stack(
          children: [
            Container(
              width: 90,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  context.read<ApplicationBloc>().add(
                    RemoveImageEvent(index: index),
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        final formState = state is ApplicationFormState
            ? state
            : const ApplicationFormState();
        final isLoading = formState.isLoading;
        final isValid = formState.isValid;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 35),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isValid && !isLoading) ? _submitApplication : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Отправить',
                      style: TextStyle(
                        fontFamily: 'Mabry Pro',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Камера'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Галерея'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Файлы'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        context.read<ApplicationBloc>().add(
          AddImageEvent(imagePath: pickedFile.path),
        );
      }
    } else {
      _showPermissionDeniedMessage('Доступ к камере');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        context.read<ApplicationBloc>().add(
          AddImageEvent(imagePath: pickedFile.path),
        );
      }
    } else {
      _showPermissionDeniedMessage('Доступ к галерее');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      context.read<ApplicationBloc>().add(
        AddImageEvent(imagePath: result.files.single.path!),
      );
    }
  }

  Future<void> _requestLocationPermissionAndGetLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorMessage(
          'Службы геолокации отключены. Включите геолокацию в настройках устройства.',
        );
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedMessage('Доступ к геолокации');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedMessage(
          'Доступ к геолокации заблокирован навсегда',
        );
        return;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      context.read<ApplicationBloc>().add(
        GetGeolocationEvent(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      _showSuccessMessage('Геолокация получена успешно');
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        if (Platform.isIOS) {
          _showErrorMessage(
            'Ошибка геолокации на iOS симуляторе. Используйте реальное устройство или введите адрес вручную.',
          );
        } else {
          _showErrorMessage(
            'Ошибка плагина геолокации. Попробуйте перезапустить приложение.',
          );
        }
        _showManualAddressEntry();
      } else if (e.toString().contains('timeout')) {
        _showErrorMessage(
          'Превышено время ожидания геолокации. Попробуйте еще раз.',
        );
      } else {
        // Handle geolocation error
        // print('Geolocation error: $e');
        _showErrorMessage('Не удалось получить геолокацию: $e');
      }
    }
  }

  void _submitApplication() {
    final state = context.read<ApplicationBloc>().state;
    if (state is ApplicationFormState && state.isValid) {
      context.read<ApplicationBloc>().add(
        CreateApplicationEvent(
          description: state.description,
          imageUrls: state.imageUrls,
          addressQuery: state.addressQuery,
          latitude: state.latitude!,
          longitude: state.longitude!,
        ),
      );
    }
  }

  void _showSuccessMessage([String message = 'Заявка успешно создана']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showPermissionDeniedMessage(String permission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permission не предоставлен'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Настройки',
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  void _showManualAddressEntry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ввести адрес вручную'),
          content: const Text(
            'Не удалось получить геолокацию. Вы можете ввести адрес вручную в поле выше.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
