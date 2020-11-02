import 'package:flutter/material.dart';

// webLoader is a widget that is used for async and network functions
// it downloads the data, shows them and handles errors
abstract class WebLoader<T> extends StatefulWidget {
  WebLoader({Key key}) : super(key: key);

  // async function to download data
  Future<T> calculation();

  // widget builder, construct result based on downloaded data
  Widget success(T data);

  // widget displayed while waiting for download
  Widget waiting();

  // widget displayed after error (wrong password, no internet, etc)
  Widget failure();

  @override
  _WebLoaderState<T> createState() => _WebLoaderState();
}

class _WebLoaderState<S> extends State<WebLoader<S>> {
  Widget build(BuildContext context) {
    return FutureBuilder<S>(
      future: this.widget.calculation(),
      builder: (BuildContext context, AsyncSnapshot<S> snapshot) {
        if (snapshot.hasData) {
          return this.widget.success(snapshot.data);
        }
        else if (snapshot.hasError) {
          return this.widget.failure();
        }
        else {
          return this.widget.waiting();
        }
      },
    );
  }
}

Widget createLoadingCircle(String text) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: CircularProgressIndicator(),
          width: 60,
          height: 60,
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20
            )
          ),
        )
      ]
    )
  );
}

Widget createIconText(IconData icon, Color color, String text) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 60,
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
              )
          ),
        )
      ]
    )
  );
}

Widget createErrorText(String text) {
  return createIconText(Icons.error_outline, Colors.red, text);
}

Widget createSuccessText(String text) {
  return createIconText(Icons.check_circle_outline, Colors.green, text);
}
