import 'package:flutter/material.dart';

class SiteStatsNumberWidget extends StatelessWidget {
  final String caption;
  final int num;
  final Color zeroColor;
  final Color valueColor;
  final GestureTapCallback onTap;

  SiteStatsNumberWidget(
      {required this.caption,
      required this.num,
      required this.valueColor,
      required this.onTap,
      this.zeroColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(caption, style: Theme.of(context).textTheme.labelMedium),
            SizedBox(height: 1),
            Container(
                decoration: BoxDecoration(
                  color: num > 0 ? valueColor : zeroColor,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.black),
                ),
                child: Container(
                    width: 50,
                    height: 20,
                    color: Colors.transparent,
                    child: Center(
                        child: Text(num.toString(),
                            style: TextStyle(
                                color: Colors.black, fontSize: 12))))),
          ],
        ));
  }
}
