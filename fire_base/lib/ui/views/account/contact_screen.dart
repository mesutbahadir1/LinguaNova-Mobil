import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/light_mode_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _launch(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  void showUrl(String url) {
    _launch(url);
  }

  void showTel() {
    _launch("tel:+1 (917) 266-0005");
  }

  void showMail() {
    _launch("mailto:support@linguanova.com");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      appBar:AppBar(
        centerTitle: true,
        title: Text(
          "Contact Us",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email, call, or contact us with our social medias to learn how TalentifyLAB can solve your problem.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    showTel();
                  },
                  child: _buildContactContainer('assets/icons/phone.png', "Call Us", "+1 (917) 266-0005"),
                ),
                GestureDetector(
                  onTap: () {
                    showMail();
                  },
                  child: _buildContactContainer('assets/icons/mail.png', "Email Us", "support@linguanova.com"),
                ),
              ],
            ),
            _buildAddressContainer(context),
            Text(
              "Contact us In Social Media",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            _buildSocialMediaContainer(context, "https://talentifylab.com/en", "LinguaNova Website", "icon"),
            _buildSocialMediaContainer(context, "https://www.instagram.com/talentifylab/", "LinguaNova Instagram", "instagram"),
            _buildSocialMediaContainer(context, "https://twitter.com/TalentifyLAB", "LinguaNova X", "twitter"),
            _buildSocialMediaContainer(context, "https://www.linkedin.com/company/talentifylab/mycompany/", "LinguaNova LinkedIn", "linkedin"),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaContainer(BuildContext context, String url, String title, String iconName) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD3D3D3),
          width: 0.7,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).brightness == Brightness.light
            ? LightModeColors.COURSE_CONTAINER_BACKGROUNG
            : Theme.of(context).primaryColor,
      ),
      child: ListTile(
        leading: Image.asset(
          "assets/icons/$iconName.png",
          height: MediaQuery.sizeOf(context).height * 0.033,
          width: MediaQuery.sizeOf(context).height * 0.033,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 17),
        ),
        trailing: IconButton(
          onPressed: () {
            showUrl(url);
          },
          icon: Icon(
            Icons.send,
            size: 20,
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildAddressContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40),
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.043,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD3D3D3),
          width: 0.7,
        ),
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).brightness == Brightness.light
            ? LightModeColors.COURSE_CONTAINER_BACKGROUNG
            : Theme.of(context).primaryColor,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded),
          SizedBox(
            width: 15,
          ),
          Text("8 The Green STE A, Dover Delaware 19901", style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildContactContainer(String iconUrl, String title, String info) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.2,
      width: MediaQuery.sizeOf(context).width * 0.45,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD3D3D3),
          width: 0.7,
        ),
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.light
            ? LightModeColors.COURSE_CONTAINER_BACKGROUNG
            : Theme.of(context).primaryColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).brightness == Brightness.light
                  ? LightModeColors.COURSE_CONTAINER_BACKGROUNG
                  : Colors.white,
            ),
            child: Image.asset(
              iconUrl,
              height: MediaQuery.sizeOf(context).height * 0.054,
              width: MediaQuery.sizeOf(context).height * 0.054,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          Text(info, style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
