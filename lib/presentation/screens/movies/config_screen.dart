import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:chipileta_movies_app/domain/datasources/auth_local_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/repositories/auth_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/update_profile_photo_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/update_username_usecase.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

class ConfigScreen extends StatefulWidget {
  static const name = 'config-screen';

  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late final UpdateProfilePhotoUseCase _updatePhotoUseCase;
  late final UpdateUsernameUseCase _updateUsernameUseCase;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String? _photoPath;
  bool _savingPhoto = false;
  bool _savingName = false;

  @override
  void initState() {
    super.initState();
    final datasource = AuthLocalDataSource(DatabaseHelper.instance);
    final repository = AuthRepositoryImpl(datasource);
    _updatePhotoUseCase = UpdateProfilePhotoUseCase(repository);
    _updateUsernameUseCase = UpdateUsernameUseCase(repository);

    final user = SessionService.instance.currentUser;
    _photoPath = user?.photoPath;
    _nameController.text = user?.name ?? '';
    _lastNameController.text = user?.lastName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedImage = await File(picked.path).copy(p.join(dir.path, fileName));

      await _savePhoto(savedImage.path);
    } catch (e) {
      _showMessage('No se pudo cargar la imagen.');
    }
  }

  Future<void> _savePhoto(String path) async {
    final user = SessionService.instance.currentUser;
    if (user?.id == null) {
      _showMessage('No hay sesión activa.');
      return;
    }

    setState(() => _savingPhoto = true);
    try {
      final updated = await _updatePhotoUseCase(
        userId: user!.id!,
        photoPath: path,
      );
      SessionService.instance.setUser(updated);
      setState(() => _photoPath = updated.photoPath);
      _showMessage('Foto actualizada.');
    } catch (e) {
      _showMessage('No se pudo guardar la foto.');
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

  Future<void> _saveName() async {
    final user = SessionService.instance.currentUser;
    if (user?.id == null) {
      _showMessage('No hay sesión activa.');
      return;
    }

    final newName = _nameController.text.trim();
    final newLastName = _lastNameController.text.trim();

    _showMessage('DEBUG nombre="$newName" apellido="$newLastName"');
    if (newName.isEmpty) {
      _showMessage('El nombre no puede estar vacío.');
      return;
    }

    setState(() => _savingName = true);
    try {
      final updated = await _updateUsernameUseCase(
        userId: user!.id!,
        newName: newName,
        newLastName: newLastName,
      );
      SessionService.instance.setUser(updated);
      _showMessage('Nombre actualizado.');
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.homeGradientBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading:
                    const Icon(Icons.photo_library_outlined, color: AppColors.white),
                title: const Text(
                  'Elegir de la galería',
                  style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_outlined, color: AppColors.white),
                title: const Text(
                  'Tomar una foto',
                  style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/profile'),
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Configuración general',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(color: AppColors.white70, height: 1, thickness: 0.7),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _PhotoSection(
                        photoPath: _photoPath,
                        saving: _savingPhoto,
                        onTap: _showPhotoSourceSheet,
                      ),
                      const SizedBox(height: 40),
                      _NameSection(
                        nameController: _nameController,
                        lastNameController: _lastNameController,
                        saving: _savingName,
                        onSave: _saveName,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final String? photoPath;
  final bool saving;
  final VoidCallback onTap;

  const _PhotoSection({
    required this.photoPath,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.white,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.yellow,
            backgroundImage: hasPhoto ? FileImage(File(photoPath!)) : null,
            child: hasPhoto
                ? null
                : const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.gradientTop,
                  ),
          ),
        ),
        GestureDetector(
          onTap: saving ? null : onTap,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.turquoise,
            child: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.edit, size: 20, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _NameSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final bool saving;
  final VoidCallback onSave;

  const _NameSection({
    required this.nameController,
    required this.lastNameController,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ConfigField(
          controller: nameController,
          hint: 'Tu nombre',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        const Text(
          'Apellido',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ConfigField(
          controller: lastNameController,
          hint: 'Tu apellido',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: saving ? null : onSave,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.heroText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.heroText,
                    ),
                  )
                : const Text(
                    'Guardar nombre',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class ConfigField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;

  const ConfigField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 18, right: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                color: AppColors.heroText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isCollapsed: true,
                hintStyle: TextStyle(
                  color: AppColors.heroText.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}