import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioWidget extends StatefulWidget {
  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  static const String assetSource = 'audio/isartor_tts.mp3';

  final player = AudioPlayer();
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  String maxdurationlabel = "00:00";
  bool isplaying = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await player.setSource(AssetSource(assetSource));

      player.onDurationChanged.listen((Duration d) { //get the duration of audio
        setState(() {
          maxduration = d.inMilliseconds;
          String maxMinutes = (Duration(milliseconds: maxduration).inMinutes % 60)
              .toString().padLeft(2, '0');
          String maxSeconds = (Duration(milliseconds: maxduration).inSeconds % 60)
              .toString().padLeft(2, '0');
          maxdurationlabel =  "$maxMinutes:$maxSeconds";
        });
      });

      player.onPlayerStateChanged.listen((PlayerState state) async {
        if(state == PlayerState.completed) {
          setState(() {
            isplaying = false;
          });
          await player.setSource(AssetSource(assetSource));
        }
      });

      player.onPositionChanged.listen((Duration p) {
        currentpos = p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        String minutes = (Duration(milliseconds: currentpos).inMinutes % 60)
            .toString().padLeft(2, '0');
        String seconds = (Duration(milliseconds: currentpos).inSeconds % 60)
            .toString().padLeft(2, '0');
        currentpostlabel = "$minutes:$seconds";

        setState(() {
          //refresh the UI
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Container(
              child: Text("$currentpostlabel/$maxdurationlabel", style: TextStyle(fontSize: 25),),
            ),
            Container(
                child: Slider(
                  value: double.parse(currentpos.toString()),
                  min: 0,
                  max: double.parse(maxduration.toString()),
                  divisions: maxduration,
                  label: currentpostlabel,
                  onChanged: (double value) async {
                    int seekval = value.round();
                    player.seek(Duration(milliseconds: seekval));
                  },
                )
            ),
            Container(
              child: Wrap(
                spacing: 10,
                children: [
                  IconButton(
                      onPressed: () async {
                        if (!isplaying) {
                          await player.resume();
                          setState(() {
                            isplaying = true;
                          });
                        } else {
                          await player.pause();
                          setState(() {
                            isplaying = false;
                          });
                        }
                      },
                      icon: Icon(isplaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 30,
                      color: Colors.red,
                  ),
                  IconButton(
                      onPressed: () async {
                        await player.stop();
                        setState(() {
                          isplaying = false;
                          currentpos = 0;
                          currentpostlabel = "00:00";
                        });
                        await player.setSource(AssetSource(assetSource));
                      },
                      icon: Icon(Icons.stop),
                      iconSize: 30,
                      color: Colors.red, //todo fix color here
                  ),
                ],
              ),
            )
          ],
        )
    );
  }
}
