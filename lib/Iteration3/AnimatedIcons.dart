import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'Contstants.dart';


class AnimatedNavBarIcons extends StatefulWidget {
  const AnimatedNavBarIcons({super.key});

  @override
  _AnimatedNavBarIconsState createState() => _AnimatedNavBarIconsState();
}

class _AnimatedNavBarIconsState extends State<AnimatedNavBarIcons> {
  final Color backgroundColor = Colors.black;


  final List<Map<String, String>> riveAnimations = [
    {
      "asset": "assets/icons/shop_icon2.riv",
      "animation1": "Idle",
      "animation2": "Hover_in",
      "title": "Shop"
    },
    {
      "asset": "assets/icons/message_icon.riv",
      "animation1": "Idle",
      "animation2": "Hover_loop",
      "title": "Message"
    },
    {
      "asset": "assets/icons/donnie_the_dino.riv",
      "animation1": "Intro Idle",
      "animation2": "Egg Open",
      "title": "Surprise"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: riveAnimations.length,
              itemBuilder: (context, index) {
                final data = riveAnimations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RiveAnimatedIconTile(
                    asset: data["asset"]!,
                    animation1: data["animation1"]!,
                    animation2: data["animation2"]!,
                    iconName: data["title"]!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RiveAnimatedIconTile extends StatefulWidget {
  final String asset;
  final String animation1;
  final String animation2;
  final String iconName;

  const RiveAnimatedIconTile({
    super.key,
    required this.asset,
    required this.animation1,
    required this.animation2,
    required this.iconName,
  });

  @override
  _RiveAnimatedIconTileState createState() => _RiveAnimatedIconTileState();
}

class _RiveAnimatedIconTileState extends State<RiveAnimatedIconTile> {
  late RiveAnimationController _controller;
  late String currentAnimation;
  bool isForward = true;

  @override
  void initState() {
    super.initState();
    currentAnimation = widget.animation1;
    _controller = SimpleAnimation(currentAnimation);
  }

  void _toggleAnimation() {
    setState(() {
      currentAnimation = isForward ? widget.animation2 : widget.animation1;
      _controller = SimpleAnimation(currentAnimation);
      isForward = !isForward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: RiveAnimation.asset(
              widget.asset,
              key: ValueKey(currentAnimation),
              controllers: [_controller],
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.iconName,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AnimatedNavBarIcons(),
  ));
}