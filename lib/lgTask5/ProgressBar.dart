import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ProgressCheckBoxes extends StatefulWidget {
  @override
  _ProgressStepperState createState() => _ProgressStepperState();
}

class _ProgressStepperState extends State<ProgressCheckBoxes>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<String> steps = ['Lets', 'Do', 'Something', 'Crazyy'];
  bool inProgress = true;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scaleController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
        inProgress = currentStep == 0 ? true : currentStep < steps.length - 1;
      });
      _scaleController.forward();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        inProgress = currentStep == 0 ? true : currentStep < steps.length - 1;
      });
      _scaleController.forward();
    }
  }

  void resetSteps() {
    setState(() {
      currentStep = 0;
      inProgress = true;
    });
    _scaleController.forward();
  }

  String _getStepText(int index) {
    if (index < currentStep) {
      return 'Completed';
    } else if (index == currentStep) {
      if (index == 0 && inProgress) {
        return 'In Progress';
      } else if (index == currentStep && inProgress) {
        return 'In Progress';
      } else {
        return 'Completed';
      }
    } else {
      return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Row(
                children: List.generate(steps.length, (index) {
                  bool isCompleted = index <= currentStep;
                  bool isCurrent = index == currentStep;

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: index == 0
                                  ? const SizedBox()
                                  : Divider(
                                color: isCompleted
                                    ? Colors.blue
                                    : Colors.grey[300],
                                thickness: 2,
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                  isCurrent ? _scaleAnimation.value : 1.0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? Colors.blue
                                          : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCompleted ? Icons.check : null,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: index == steps.length - 1
                                  ? const SizedBox()
                                  : Divider(
                                color: isCompleted
                                    ? Colors.blue
                                    : Colors.grey[300],
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStepText(index),
                          style: TextStyle(
                            color: isCompleted ? Colors.blue : Colors.grey[300],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            if (currentStep < steps.length - 1)
              Row( 
                 mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: previousStep ,
                        child: Text("Previous Step")
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: nextStep,
                      child: Text('Next Step'),
                    ),
                  ],
               )

            else
              ElevatedButton(
                onPressed: resetSteps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                ),
                child: Text('Reset Progress'),
              ),
          ],
        ),
      ),
    );
  }
}