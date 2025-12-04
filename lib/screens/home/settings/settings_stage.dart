import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/screens/home/settings/change_password_stage.dart';
import 'package:voquadro/widgets/Modals/delete_account_confirmation.dart';
import 'package:voquadro/widgets/Modals/terms_of_service_modal.dart';
import 'package:voquadro/widgets/Modals/privacy_policy_modal.dart';

class SettingsStage extends StatefulWidget {
  const SettingsStage({super.key});

  @override
  State<SettingsStage> createState() => _SettingsStageState();
}

class _SettingsStageState extends State<SettingsStage> {
  @override
  Widget build(BuildContext context) {
    final soundService = context.watch<SoundService>();
    final Color purpleDark = '49416D'.toColor();
    final Color purpleMid = '7962A5'.toColor();
    const Color cardBg = Color(0xFFF0E6F6);
    const Color pageBg = Color(0xFFF7F3FB);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row with back and title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          IconButton.filled(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back),
                            iconSize: 40,
                            style: IconButton.styleFrom(
                              backgroundColor: purpleMid,
                              foregroundColor: Colors.white,
                              fixedSize: const Size(60, 60),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                color: purpleDark,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // General
                    _SectionHeader(
                      title: 'General',
                      icon: Icons.settings,
                      color: purpleDark,
                    ),
                    _SettingsCard(
                      background: cardBg,
                      children: [
                        _SwitchRow(
                          label: 'Dolph SFX',
                          value: !soundService.isDolphSfxMuted,
                          onChanged: (v) => soundService.toggleDolphSfxMute(),
                          activeColor: purpleMid,
                        ),
                        const _TileDivider(),
                        _VolumeSliderRow(
                          label: 'Music Volume',
                          value: soundService.musicVolume,
                          onChanged: (v) => soundService.setMusicVolume(v),
                          activeColor: purpleMid,
                        ),
                      ],
                    ),

                    // Account & Profile
                    const _TileDivider(),
                    _SectionHeader(
                      title: 'Account & Profile',
                      icon: Icons.person,
                      color: purpleDark,
                    ),
                    _SettingsCard(
                      background: cardBg,
                      children: [
                        SettingsTile(
                          title: 'Edit Profile',
                          textColor: purpleDark,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PublicSpeakingProfileStage(),
                              ),
                            );
                          },
                        ),

                        const _TileDivider(),
                        SettingsTile(
                          title: 'Linked Accounts',
                          textColor: purpleDark,
                          onTap: () {},
                        ),
                        const _TileDivider(),
                        SettingsTile(
                          title: 'Delete Account',
                          textColor: Colors.red,
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  const DeleteConfirmationDialog(),
                            );
                          },
                        ),
                      ],
                    ),

                    // Privacy & Security section
                    _SectionHeader(
                      title: 'Privacy & Security',
                      icon: Icons.lock,
                      color: purpleDark,
                    ),
                    _SettingsCard(
                      background: cardBg,
                      children: [
                        SettingsTile(
                          title: 'Privacy Policy',
                          textColor: purpleDark,
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () {
                            // [CHANGED] Show new PrivacyPolicyModal
                            showDialog(
                              context: context,
                              builder: (context) => const PrivacyPolicyModal(),
                            );
                          },
                        ),
                        const _TileDivider(),
                        SettingsTile(
                          title: 'Terms of Service',
                          textColor: purpleDark,
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () {
                            // [CHANGED] Show new TermsOfServiceModal
                            showDialog(
                              context: context,
                              builder: (context) => const TermsOfServiceModal(),
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Your recordings are deleted after analysis to protect your privacy',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.onTap,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
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
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.background});

  final List<Widget> children;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1);
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _VolumeSliderRow extends StatelessWidget {
  const _VolumeSliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Row(
            children: [
              Icon(
                value == 0 ? Icons.volume_off : Icons.volume_down,
                color: Colors.grey,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                  activeColor: activeColor,
                  inactiveColor: activeColor.withValues(alpha: 0.2),
                ),
              ),
              Icon(Icons.volume_up, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
