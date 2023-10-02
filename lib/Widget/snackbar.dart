import 'package:flutter/material.dart';

class snackBar {
  display(BuildContext context, String? message, Color? color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message'),
        duration: Duration(seconds: 1), // Set a longer duration
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,// Action label
          onPressed: () {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Dismiss the Snackbar
          },
        ),
        backgroundColor: color, // Customize the background color
        behavior:
            SnackBarBehavior.floating, // Makes the Snackbar float above content
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Customize the border
        ),
        elevation: 6.0, // Elevation for shadow
      ),
    );
  }
}
