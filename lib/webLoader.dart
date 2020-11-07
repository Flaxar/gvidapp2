import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// webLoader is a widget that is used for async and network functions
// it downloads the data, shows them and handles errors
abstract class WebLoader<T> extends StatefulWidget {
  WebLoader({Key key}) : super(key: key);

  // async function to download NEW data from web (do not use function load!)
  Future<T> download();

  // async function to load SAVED data (can use function download)
  Future<T> load();

  // widget builder, construct result based on downloaded data
  Widget success(T data);

  // widget displayed while waiting for download
  Widget waiting();

  // widget displayed after error (wrong password, no internet, etc)
  Widget failure();

  // simple function that will save any text to specified file
  void saveToFile(String filename, String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = await File("${directory.path}/$filename").create(recursive: true);
    await file.writeAsString(text);
  }

  // simple function that will load any text from specified file
  // returns empty string if nothing was loaded or the file was just created
  Future<String> loadFromFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = await File("${directory.path}/$filename").create(recursive: true);
    return await file.readAsString();
  }

  @override
  _WebLoaderState<T> createState() => _WebLoaderState();
}

class _WebLoaderState<S> extends State<WebLoader<S>> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  S data;

  Widget createFutureBuilder() {
    return FutureBuilder<S>(
      future: this.widget.load(),
      builder: (BuildContext context, AsyncSnapshot<S> snapshot) {
        if (snapshot.hasData) {
          data = snapshot.data;
          return this.widget.success(data);
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

  void _onRefresh() async{
    try {
      S someData = await this.widget.download();
      setState(() {
        data = someData;
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      print(e);
      _refreshController.refreshFailed();
    }
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: ClassicHeader(),
        footer: CustomFooter(
          builder: (BuildContext context,LoadStatus mode){
            Widget body;
            if(mode == LoadStatus.idle){
              body = Text("pull up load");
            }
            else if(mode == LoadStatus.loading){
              body = CupertinoActivityIndicator();
            }
            else if(mode == LoadStatus.failed){
              body = Text("Load Failed! Click retry!");
            }
            else if(mode == LoadStatus.canLoading){
              body = Text("release to load more");
            }
            else{
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: createFutureBuilder(),
      ),
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
