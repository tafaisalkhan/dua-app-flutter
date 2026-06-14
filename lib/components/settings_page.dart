import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F7A5A),
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose between light and dark mode',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: SettingsService.themeMode,
                builder: (context, mode, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: _ThemeOption(
                          icon: Icons.light_mode_rounded,
                          label: 'Light',
                          isSelected: mode == ThemeMode.light,
                          onTap: () => SettingsService.themeMode.value = ThemeMode.light,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ThemeOption(
                          icon: Icons.dark_mode_rounded,
                          label: 'Dark',
                          isSelected: mode == ThemeMode.dark,
                          onTap: () => SettingsService.themeMode.value = ThemeMode.dark,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Translation Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the language for dua translations',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: SettingsService.selectedLanguage,
                builder: (context, selected, _) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: SettingsService.availableLanguages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lang = SettingsService.availableLanguages[index];
                      final isSelected = lang == selected;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF1F7A5A)
                                : const Color(0xFFE8DED0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            SettingsService.languageNames[lang] ?? lang,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1F7A5A)
                                  : const Color(0xFF2C3E50),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF1F7A5A),
                                )
                              : const Icon(
                                  Icons.circle_outlined,
                                  color: Color(0xFFCCCCCC),
                                ),
                          onTap: () {
                            SettingsService.selectedLanguage.value = lang;
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F7A5A) : const Color(0xFFE8DED0),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? const Color(0xFFE7F4EE) : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1F7A5A) : const Color(0xFF888888),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1F7A5A) : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
