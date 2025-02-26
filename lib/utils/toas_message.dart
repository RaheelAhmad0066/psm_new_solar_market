import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';

class MessageToast {
  static showToast({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      backgroundColor: kPrimaryColor,
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  static void showToastMessage({
    required BuildContext context,
    required String msg,
  }) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: AnimatedToastWidget(
            message: msg,
            onDismissed: () => overlayEntry?.remove(),
            backgroundColor: kPrimaryColor,
            textColor: Colors.white,
            duration: Duration(seconds: 3),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class AnimatedToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;

  const AnimatedToastWidget({
    Key? key,
    required this.message,
    required this.onDismissed,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
  }) : super(key: key);

  @override
  State<AnimatedToastWidget> createState() => _AnimatedToastWidgetState();
}

class _AnimatedToastWidgetState extends State<AnimatedToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Automatically dismiss after the specified duration
    Future.delayed(widget.duration, () {
      _controller.reverse().then((_) {
        widget.onDismissed();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.r,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Image.asset('assets/images/appLogo.png',width: 26.w,)),

                  SizedBox(
                    width: 16.w,
                  ),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: widget.textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
