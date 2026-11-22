import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RotatingCupHeader extends StatefulWidget {
  const RotatingCupHeader({super.key});

  @override
  State<RotatingCupHeader> createState() => _RotatingCupHeaderState();
}

class _RotatingCupHeaderState extends State<RotatingCupHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPausedByUser = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else if (!_initialized) {
      _initialized = true;
      _controller.repeat();
    } else if (!_isPausedByUser && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _toggleRotation() {
    setState(() {
      if (_controller.isAnimating) {
        _isPausedByUser = true;
        _controller.stop();
      } else {
        _isPausedByUser = false;
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnimating = _controller.isAnimating;

    return Semantics(
      button: true,
      label: isAnimating
          ? 'Jeda animasi ikon cangkir berputar'
          : 'Lanjutkan animasi ikon cangkir berputar',
      child: Tooltip(
        message: isAnimating ? 'Jeda rotasi cangkir' : 'Putar cangkir',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _toggleRotation,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _controller,
                    child: const _CupBadge(),
                    builder: (BuildContext context, Widget? child) {
                      return Transform.rotate(
                        angle: _controller.value * 2.0 * math.pi,
                        child: child,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupBadge extends StatelessWidget {
  const _CupBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.primaryText,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.coffee_rounded,
        color: AppColors.accentWarm,
        size: 20,
      ),
    );
  }
}
