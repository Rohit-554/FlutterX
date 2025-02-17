import 'package:flutter/material.dart';

import 'AnimatedNavBar.dart';
import 'AnimatingShapes.dart';
import 'GlowingVoiceUI.dart';
import 'MorphableSides.dart';
import 'ProgressBar.dart';


class AnimatedTabEffect extends StatelessWidget {
  const AnimatedTabEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tab Indicator Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TabIndicatorExample(),
    );
  }
}

class TabIndicatorExample extends StatefulWidget {
  const TabIndicatorExample({Key? key}) : super(key: key);

  @override
  State<TabIndicatorExample> createState() => _TabIndicatorExampleState();
}

class _TabIndicatorExampleState extends State<TabIndicatorExample> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _labels = ["Task 1", "Task 2", "Task 5", "Task 6"];
  final List<IconData> _icons = [Icons.task, Icons.task, Icons.task, Icons.task];

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Let\'s Do This!')),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                VoiceAssistantApp(),
                MorphingShapesScreen(),
                ProgressCheckBoxes(),
                AnimatedNavBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_labels.length, (index) {
            return GestureDetector(
              onTap: () => _selectTab(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[index],
                    color: _currentIndex == index ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[index],
                    style: TextStyle(
                      color: _currentIndex == index ? Colors.blue : Colors.grey,
                      fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 2, color: Colors.grey[300]),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _currentIndex * (MediaQuery.of(context).size.width / _labels.length),
              width: MediaQuery.of(context).size.width / _labels.length,
              height: 2,
              child: Container(color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }
}
