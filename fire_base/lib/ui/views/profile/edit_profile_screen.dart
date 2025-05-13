import 'dart:convert';
import 'dart:io';

import 'package:fire_base/app/constants/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants/light_mode_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int? userId;
  Map<String, String> userInfo = {
    'fullName': '',
    'level': '',
    'email': '',
  };

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('userId');
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchUserInfo(id);
    }
  }

  Future<void> _fetchUserInfo(int id) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    try {
      final response = await http.get(Uri.parse('${HTTPS_URL}/api/User/user/$userId')); // local IP adresi değişebilir

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userInfo = {
            'fullName': data['fullName'],
            'level': data['level'].toString(),
            'email': data['email'],
          };
        });
      } else {
        print('Kullanıcı bulunamadı.');
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PROFILE & PRIVACY",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19,color: Colors.white),
            ),
            SizedBox(
              height: 25,
            ),
            buildInfoColumn(context, 'YOUR NAME', userInfo['fullName']!),
            SizedBox(
              height: 15,
            ),
            buildInfoColumn(context, 'YOUR LEVEL', userInfo['level']!),
            SizedBox(
              height: 25,
            ),
            buildInfoColumn(context, 'YOUR EMAIL ADDRESS', userInfo['email']!),
          ],
        ),
      ),
    );
  }

  Column buildInfoColumn(BuildContext context, String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.06,
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD3D3D3),
                width: 0.7,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor
                  : LightModeColors.COURSE_CONTAINER_BACKGROUNG),
          padding: const EdgeInsets.all(12.0),
          child: Text(info, style: TextStyle(fontSize: 17)),
        )
      ],
    );
  }
}
