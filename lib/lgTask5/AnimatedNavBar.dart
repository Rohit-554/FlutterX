import 'dart:math';

import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AnimatedNavBar extends StatefulWidget {
  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) =>
        Tween<double>(begin: 0.0, end: 1.0).animate(controller))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _controllers[index].forward().then((_) => _controllers[index].reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, AnimatedIcons.home_menu, 'Home'),
                _buildNavItem(1, AnimatedIcons.play_pause, 'Reels'),
                _buildNavItem(2, AnimatedIcons.view_list, 'Feed'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, AnimatedIconData iconData, String label) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedIcon(
            icon: iconData,
            progress: _animations[index],
            size: 30,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AnimatedNavBar(),
  ));
}
