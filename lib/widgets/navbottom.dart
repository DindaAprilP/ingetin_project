import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ingetin_project/screens/beranda.dart';
import 'package:ingetin_project/screens/menu.dart';
import 'package:ingetin_project/screens/profile.dart';

class bottomNavigationBar extends StatefulWidget {
  const bottomNavigationBar({super.key});

  @override
  State<bottomNavigationBar> createState() => _bottomNavigationBarState();
}

class _bottomNavigationBarState extends State<bottomNavigationBar> {
  var _bottomNavIndex = 0;

  final List <Widget> _pages = [
    Beranda(),
    Menu(),
    Profile(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.edit,
    Icons.person,
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages [_bottomNavIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.none,
        backgroundColor: Colors.black,
        activeColor: Colors.white,
        inactiveColor: Colors.white,
        onTap: (index){
          setState((){
            _bottomNavIndex = index;
          }
          );
        }
      ),
    );
  }
}