import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsState {
  final bool safeMode;
  final bool darkMode;
  final bool videoAutoplay;
  final bool mobileDataSaver;
  final String? username;
  final String? apiKey;
  final List<String> blacklist;
  final List<String> searchHistory;

  SettingsState({
    this.safeMode = true,
    this.darkMode = true,
    this.videoAutoplay = false,
    this.mobileDataSaver = false,
    this.username,
    this.apiKey,
    this.blacklist = const [],
    this.searchHistory = const [],
  });

  SettingsState copyWith({
    bool? safeMode,
    bool? darkMode,
    bool? videoAutoplay,
    bool? mobileDataSaver,
    String? username,
    String? apiKey,
    List<String>? blacklist,
    List<String>? searchHistory,
  }) {
    return SettingsState(
      safeMode: safeMode ?? this.safeMode,
      darkMode: darkMode ?? this.darkMode,
      videoAutoplay: videoAutoplay ?? this.videoAutoplay,
      mobileDataSaver: mobileDataSaver ?? this.mobileDataSaver,
      username: username,
      apiKey: apiKey,
      blacklist: blacklist ?? this.blacklist,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }

  bool get isLoggedIn => username != null && apiKey != null;
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final safeMode = await _storage.read(key: 'safe_mode');
    final darkMode = await _storage.read(key: 'dark_mode');
    final videoAutoplay = await _storage.read(key: 'video_autoplay');
    final mobileDataSaver = await _storage.read(key: 'mobile_data_saver');
    final username = await _storage.read(key: 'username');
    final apiKey = await _storage.read(key: 'api_key');
    final blacklistStr = await _storage.read(key: 'blacklist');
    final searchHistoryStr = await _storage.read(key: 'search_history');

    state = state.copyWith(
      safeMode: safeMode != 'false',
      darkMode: darkMode != 'false',
      videoAutoplay: videoAutoplay == 'true',
      mobileDataSaver: mobileDataSaver == 'true',
      username: username,
      apiKey: apiKey,
      blacklist: blacklistStr?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      searchHistory: searchHistoryStr?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
    );
  }

  Future<void> setSafeMode(bool value) async {
    await _storage.write(key: 'safe_mode', value: value.toString());
    state = state.copyWith(safeMode: value);
  }

  Future<void> setDarkMode(bool value) async {
    await _storage.write(key: 'dark_mode', value: value.toString());
    state = state.copyWith(darkMode: value);
  }

  Future<void> setVideoAutoplay(bool value) async {
    await _storage.write(key: 'video_autoplay', value: value.toString());
    state = state.copyWith(videoAutoplay: value);
  }

  Future<void> setMobileDataSaver(bool value) async {
    await _storage.write(key: 'mobile_data_saver', value: value.toString());
    state = state.copyWith(mobileDataSaver: value);
  }

  Future<void> setCredentials(String? username, String? apiKey) async {
    if (username != null && apiKey != null) {
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'api_key', value: apiKey);
    } else {
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'api_key');
    }
    state = state.copyWith(username: username, apiKey: apiKey);
  }

  Future<void> addToBlacklist(String rule) async {
    if (!state.blacklist.contains(rule)) {
      final newList = [...state.blacklist, rule];
      await _storage.write(key: 'blacklist', value: newList.join(','));
      state = state.copyWith(blacklist: newList);
    }
  }

  Future<void> removeFromBlacklist(String rule) async {
    final newList = state.blacklist.where((r) => r != rule).toList();
    await _storage.write(key: 'blacklist', value: newList.join(','));
    state = state.copyWith(blacklist: newList);
  }

  Future<void> addToSearchHistory(String query) async {
    final newList = [query, ...state.searchHistory.where((q) => q != query)].take(50).toList();
    await _storage.write(key: 'search_history', value: newList.join(','));
    state = state.copyWith(searchHistory: newList);
  }

  Future<void> clearSearchHistory() async {
    await _storage.delete(key: 'search_history');
    state = state.copyWith(searchHistory: []);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});