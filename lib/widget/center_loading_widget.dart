import 'package:flutter/material.dart';

class CenterLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Card(
            child: Container(
              width: 80,
              height: 80,
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}
