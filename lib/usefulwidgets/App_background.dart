import 'package:flutter/material.dart';
import 'package:todolist/utils/extensions.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.header,
    this.body,
    this.headerHeight,
  });
  final Widget? header;
  final Widget? body;
  final double? headerHeight;

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;
    final colors = context.colorScheme;

    return Column(
      children: [
        Container(
          height: headerHeight,
          width: deviceSize.width,
          color: colors.primary,
          child: Center(child: header),
        ),
        Expanded(
          child: Container(
            width: deviceSize.width,
            color: colors.background,
            child: body,
          ),
        ),
      ],
    );
  }
}
class DisplayWhiteText extends StatelessWidget {
  const DisplayWhiteText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight,
  });
  final String text;
  final double? size;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.headlineSmall?.copyWith(
        color: context.colorScheme.surface,
        fontSize: size,
        fontWeight: fontWeight ?? FontWeight.bold,
      ),
    );
  }
}