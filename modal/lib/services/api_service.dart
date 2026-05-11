import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class ApiService {
  static const String _baseUrl =
      'https://script.google.com/macros/s/AKfycbz5u1X7sNCXw6hlK196Mde0jz89YvLYIiHOi_WochI8QMuTK1cDH-znhEffZuyi8HGL/exec';

  /// Generates a unique device ID (HWID) using device_info_plus.
  Future<String> getHwid() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique ID on Android
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_id';
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macosInfo = await deviceInfo.macOsInfo;
        return macosInfo.systemGUID ?? 'unknown_macos_id';
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.machineId ?? 'unknown_linux_id';
      }
    } catch (e) {
      return 'fallback_id_${DateTime.now().millisecondsSinceEpoch}';
    }
    return 'unknown_platform_id';
  }

  /// Registers a new user.
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'register',
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 302) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user: ${response.statusCode}');
    }
  }

  /// Logs in a user.
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final String hwid = await getHwid();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'login',
        'email': email,
        'password': password,
        'hwid': hwid,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 302) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login user: ${response.statusCode}');
    }
  }
}
