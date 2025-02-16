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
  int _currentIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Center(child: Text('Lets Do this!')),

      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(
                    icon: Icons.task,
                    label: 'Task 1',
                    isSelected: _currentIndex == 0,
                    onTap: () => _selectTab(0),
                  ),
                  _buildTab(
                    icon: Icons.task,
                    label: 'Task 2',
                    isSelected: _currentIndex == 1,
                    onTap: () => _selectTab(1),
                  ),
                  _buildTab(
                    icon: Icons.task,
                    label: 'Task 5',
                    isSelected: _currentIndex == 2,
                    onTap: () => _selectTab(2),
                  ),
                  _buildTab(
                    icon: Icons.task,
                    label: 'Task 6',
                    isSelected: _currentIndex == 3,
                    onTap: () => _selectTab(3),
                  )
                ],
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children:  [
                    VoiceAssistantApp(),
                    MorphingShapesScreen(),
                    ProgressCheckBoxes(),
                    AnimatedNavBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 80 : 0,
            height: 2,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}