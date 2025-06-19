import 'package:fire_base/auth/login.dart';
import 'package:fire_base/ui/views/account/contact_screen.dart';
import 'package:fire_base/ui/views/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../services/authService.dart';



class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Account",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SvgPicture.asset('assets/icons/avatar.svg', height: 150),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(120, 120, 120, 1),
                borderRadius: BorderRadius.circular(12), // 12 px yuvarlatma
              ),
              child: ListTile(
                title: Text("Profile", style: TextStyle(fontSize: 15,color: Colors.white)),
                trailing: Icon(Icons.keyboard_arrow_right_rounded, size: 20, color: Colors.white,),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(120, 120, 120, 1),
                borderRadius: BorderRadius.circular(12), // 12 px yuvarlatma
              ),
              child: ListTile(
                title: Text("Contact Us", style: TextStyle(fontSize: 15, color: Colors.white)),
                trailing: Icon(Icons.keyboard_arrow_right_rounded, size: 20,color: Colors.white,),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(120, 120, 120, 1),
                borderRadius: BorderRadius.circular(12), // 12 px yuvarlatma
              ),
              child: ListTile(
                title: Text("Logout", style: TextStyle(fontSize: 15,color: Colors.white)),
                trailing: Icon(Icons.logout, size: 20, color: Colors.white,),
                onTap: () async {
                  AuthServices().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.center,
        child: Text(
          "Account",
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
    );
  }
}
