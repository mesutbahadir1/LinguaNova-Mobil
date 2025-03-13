import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _singleton = LocalStorageService._internal();

  factory LocalStorageService() {
    return _singleton;
  }

  LocalStorageService._internal();

  bool _viewedOnboard = false;
  bool _isGuest = true;
  String _apiToken = '';

  bool isViewedOnboard() => _viewedOnboard;

  bool isGuest() => _isGuest;

  String apiToken() => _apiToken;

  Future<bool> checkViewOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    final isViewed = prefs.getBool('isViewedOnboard') ?? false;

    if (isViewed == true) {
      _viewedOnboard = true;
    }

    return isViewed;
  }

  Future<bool?> doneViewOnboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool('isViewedOnboard', true);
  }

  Future<bool> checkIsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? true;

    if (isGuest != true) {
      _isGuest = false;
    }

    return isGuest;
  }


  Future<bool?> signedAsUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _isGuest = false;

    return prefs.setBool('isGuest', false);
  }

  Future<bool?> setApiToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _apiToken = token;

    return prefs.setString('apiToken', token);
  }

  Future<bool?> removeApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('apiToken');

    _apiToken = '';

    return true;
  }

  Future<bool> checkApiToken() async {
    final prefs = await SharedPreferences.getInstance();
    final apiToken = prefs.getString('apiToken');
    print(apiToken);

    if (apiToken == null || apiToken == '') {
      return false;
    }

    _apiToken = apiToken;
    _isGuest = false;

    return true;
  }

  Future<bool?> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _isGuest = true;
    _apiToken = '';

    prefs.remove('isViewedOnboard');
    prefs.remove('isGuest');
    prefs.remove('apiToken');

    return true;
  }
}
