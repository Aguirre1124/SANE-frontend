import 'package:flutter/material.dart';

const double kMaxContentWidth = 900;
const double kBreakpointMd = 600;

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kBreakpointMd;
