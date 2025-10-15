import 'package:flutter/material.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';

class SettingsStage extends StatefulWidget {
  const SettingsStage({Key? key}) : super(key: key);

  @override
  State<SettingsStage> createState() => _SettingsStageState();
}

class _SettingsStageState extends State<SettingsStage> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General', Icons.settings),
          _buildCard([
            SwitchSettingsTile(
              title: 'Dark Mode',
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
              },
            ),
          ]),

          _buildSectionHeader('Account & Profile', Icons.person),
          _buildCard([
            SettingsTile(
              title: 'Edit Profile',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PublicSpeakingProfileStage(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            SettingsTile(title: 'Change Password', onTap: () {}),
            const Divider(height: 1),
            SettingsTile(title: 'Linked Accounts', onTap: () {}),
            const Divider(height: 1),
            SettingsTile(
              title: 'Delete Account',
              textColor: Colors.red,
              onTap: () {},
            ),
            const Divider(height: 1),
            SettingsTile(
              title: 'Log out',
              textColor: Colors.cyan,
              onTap: () {},
            ),
          ]),

          _buildSectionHeader('Privacy & Security', Icons.lock),
          _buildCard([
            SettingsTile(
              title: 'Privacy Policy',
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1),
            SettingsTile(
              title: 'Terms of Service',
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () {},
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Your recordings are deleted after analysis to protect your privacy',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Widget? trailing;

  const SettingsTile({
    Key? key,
    required this.title,
    required this.onTap,
    this.textColor,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class SwitchSettingsTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchSettingsTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
