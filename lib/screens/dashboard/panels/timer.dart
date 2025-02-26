
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime createdAt;

  const CountdownTimer({required this.createdAt, Key? key}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remainingTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    DateTime targetTime = widget.createdAt.add(const Duration(hours: 24));
    _remainingTime = targetTime.difference(DateTime.now());

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        DateTime targetTime = widget.createdAt.add(const Duration(hours: 24));
        _remainingTime = targetTime.difference(DateTime.now());

        if (_remainingTime.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeLeft;

    if (_remainingTime.inSeconds <= 0) {
      timeLeft = "Inactive";
    } else if (_remainingTime.inHours > 0) {
      timeLeft = '${_remainingTime.inHours}h';
    } else {
      timeLeft = '${_remainingTime.inMinutes}m';
    }

    return Text(
      timeLeft,
      style: GoogleFonts.inter(
        color: kPrimaryColor,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
