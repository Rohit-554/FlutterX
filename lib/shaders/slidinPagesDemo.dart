import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Pages Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SlidingPagesDemo(),
    );
  }
}

class SlidingPagesDemo extends StatefulWidget {
  @override
  _SlidingPagesDemoState createState() => _SlidingPagesDemoState();
}

class _SlidingPagesDemoState extends State<SlidingPagesDemo> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sliding Pages Animation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Page 1',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'Page 2',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _goToPage(0),
                  child: Text('Go to Page 1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == 0 ? Colors.blue : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _goToPage(1),
                  child: Text('Go to Page 2'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == 1 ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}