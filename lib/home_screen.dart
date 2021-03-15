import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:karaca_odev/video_items.dart';
import 'package:video_player/video_player.dart';

import 'baslik_widget.dart';
import 'loading_screen.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var category = 'kahveler';
  List<String> videolar = new List<String>();
  List<String> videoURLS = new List<String>();
  var dir;
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<dynamic> getData() async {
    dir = await getApplicationDocumentsDirectory();
    final QuerySnapshot categories =
        await FirebaseFirestore.instance.collection('kahveler').get();
    DocumentSnapshot document;
    final List documents = categories.docs;

    await Future.forEach(documents, (data) async {
      document = await FirebaseFirestore.instance
          .collection("kahveler")
          .doc(data.id)
          .get();
      videolar = List.from(document["videolar"]);
      videoURLS.addAll(videolar);
    });
    downloadFile(videoURLS.toSet().toList());
  }

  Future<void> downloadFile(List videolar) async {
    Dio dio = Dio();
    //print(videolar);
    videolar.asMap().forEach((i, imgUrl) async {
      try {
        print("video " + i.toString());

        // print("path ${dir.path}");
        await dio.download(imgUrl, "${dir.path}/video$i.mp4",
            onReceiveProgress: (rec, total) {
          print("Kaydediliyor: $rec , Toplam: $total");
        });
      } catch (e) {
        print("hata :" + e);
      }
    });
    print("Yüklenme Tamam");
  }

  readVideo(i) {
    final path = dir.path;
    print("buraya girdi");
    File file = new File('$path/video$i.mp4');
    return file;
  }

  @override
  void dispose() {
    // TODO: burada localdeki videoları silme kodu gelecek
    dir.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(category).snapshots(),
      builder: (context, snapshot) {
        return !snapshot.hasData
            //Yükleniyor Animasyon Ekranı
            ? LoadingScreen(size: _size)
            : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Baslik(),
                      //kahve çeşitleri
                      Expanded(
                        child: Container(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot items =
                                  snapshot.data.docs[index];
                              return Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: GestureDetector(
                                      child: CircleAvatar(
                                        foregroundImage: NetworkImage(
                                          items['fotoUrl'],
                                        ),
                                        radius: 60.0,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      //videolar
                      Expanded(
                        flex: 2,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemCount: videoURLS.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                child: VideoItems(
                                    videoPlayerController:
                                        VideoPlayerController.file(
                                            readVideo(index))),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }
}
