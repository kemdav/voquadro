import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class ProfileEditSheet extends StatefulWidget {
  const ProfileEditSheet({
    super.key,
    required this.initialBio,
    required this.onPickAvatar,
    required this.onPickBanner,
    required this.onSaveBio,
  });

  final String initialBio;
  final VoidCallback onPickAvatar;
  final VoidCallback onPickBanner;
  final ValueChanged<String> onSaveBio;

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _voqButton(
                icon: Icons.photo_camera,
                label: 'Change Avatar',
                onPressed: widget.onPickAvatar,
              ),
              _voqButton(
                icon: Icons.wallpaper,
                label: 'Change Banner',
                onPressed: widget.onPickBanner,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Bio', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _bioController,
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: '7962A5'.toColor()),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: '7962A5'.toColor()),
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Write your bio here...',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _voqPrimaryButton(
              onPressed: () {
                widget.onSaveBio(_bioController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voqButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: '7962A5'.toColor(),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _voqPrimaryButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: '49416D'.toColor(),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: child,
    );
  }
}
