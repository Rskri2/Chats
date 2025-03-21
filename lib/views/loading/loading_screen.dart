import 'dart:async';

import 'package:chatapp/views/loading/loading_screen_controller.dart';
import 'package:flutter/material.dart';

class LoadingScreen {
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  factory LoadingScreen() => _shared;

  LoadingScreenController? controller;
  void show({required BuildContext context, required String text}) {
    if (controller?.update(text) ?? false) {
      return;
    }
    controller = showOverlay(context: context, text: text);
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final texts = StreamController<String>();
    texts.add(text);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final state = Overlay.of(context);
    final overlay = OverlayEntry(
      builder: (BuildContext context) {
        return Material(
          color: Colors.white.withAlpha(250),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width*0.8,
                maxHeight: size.height*0.8,
                minHeight: size.height*0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      StreamBuilder(
                        stream: texts.stream,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          }
                          return Text('');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    state.insert(overlay);
    return LoadingScreenController(
      close: () {
        texts.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        texts.add(text);
        return true;
      },
    );
  }
}
