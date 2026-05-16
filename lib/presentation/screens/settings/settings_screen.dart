import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Content'),
          SwitchListTile(
            title: const Text('Safe Mode'),
            subtitle: const Text('Only show general and sensitive content'),
            value: settings.safeMode,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setSafeMode(value),
          ),
          const Divider(),
          const _SectionHeader(title: 'Playback'),
          SwitchListTile(
            title: const Text('Video Autoplay'),
            subtitle: const Text('Automatically play videos'),
            value: settings.videoAutoplay,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setVideoAutoplay(value),
          ),
          SwitchListTile(
            title: const Text('Mobile Data Saver'),
            subtitle: const Text('Always use sample images instead of originals'),
            value: settings.mobileDataSaver,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setMobileDataSaver(value),
          ),
          const Divider(),
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.darkMode,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setDarkMode(value),
          ),
          const Divider(),
          const _SectionHeader(title: 'Authentication'),
          if (settings.isLoggedIn)
            ListTile(
              title: const Text('Logged in as'),
              subtitle: Text(settings.username ?? ''),
              trailing: TextButton(
                onPressed: () =>
                    ref.read(settingsProvider.notifier).setCredentials(null, null),
                child: const Text('Logout'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_usernameController.text.isNotEmpty &&
                          _apiKeyController.text.isNotEmpty) {
                        ref.read(settingsProvider.notifier).setCredentials(
                              _usernameController.text,
                              _apiKeyController.text,
                            );
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          const Divider(),
          const _SectionHeader(title: 'Blacklist'),
          ...settings.blacklist.map((rule) => ListTile(
                title: Text(rule),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      ref.read(settingsProvider.notifier).removeFromBlacklist(rule),
                ),
              )),
          ListTile(
            title: const Text('Add blacklist rule'),
            onTap: () => _showAddBlacklistDialog(),
          ),
        ],
      ),
    );
  }

  void _showAddBlacklistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blacklist Rule'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., guro or scat',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(settingsProvider.notifier).addToBlacklist(controller.text);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}