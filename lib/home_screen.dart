import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:karaca_odev/Models/videoModel.dart';
import 'package:karaca_odev/video_items.dart';
import 'package:video_player/video_player.dart';
import 'baslik_widget.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> videoURLS = new List<String>();
  List<VideoModel> videoModelList = new List<VideoModel>();
  int category = -1;
  List documents = new List();
  List categoryPhotos = new List();
  List categoryNames = new List();
  List<File> videoList = new List<File>();
  DocumentSnapshot document;
  bool loaded = false;
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
    documents = categories.docs;
    int docIndex = 0;
    await Future.forEach(documents, (data) async {
      document = await FirebaseFirestore.instance
          .collection("kahveler")
          .doc(data.id)
          .get();
      categoryNames.add(document['name']);
      categoryPhotos.add(document['fotoUrl']);

      document["videolar"].forEach((videoUrl) => {
            videoModelList
                .add(new VideoModel(category: docIndex, url: videoUrl))
          });

      docIndex++;
    });
    downloadFile(videoModelList);
    readVideo();
  }

  Future<void> downloadFile(List videolar) async {
    Dio dio = Dio();
    //print(videolar);
    videolar.asMap().forEach((i, video) async {
      try {
        print("video " + i.toString());
        // print("path ${dir.path}");
        await dio.download(video.url, "${dir.path}/video${i.toString()}.mp4",
            onReceiveProgress: (rec, total) {
          print("Kaydediliyor: $rec , Toplam: $total");
        });
      } catch (e) {
        print("hata :" + e);
      }
    });
    print("Yüklenme Tamam");
  }

  readVideo() {
    File file;
    videoList.clear();
    print("buraya girdi");
    videoModelList.asMap().forEach((i, videoModel) {
      videoModel.videoPath = "video${i.toString()}";
      file = new File('${dir.path}/${videoModel.videoPath}.mp4');
      //BURASI -1 OLACAKTI
      if (category == -1) {
        setState(() {
          videoList.add(file);
        });
      }
      if (category == 0) {
        setState(() {
          videoList.add(file);
        });
      } else if (category != -1 && videoModel.category == category) {
        setState(() {
          videoList.add(file);
        });
      }
    });
    setState(() {
      loaded = true;
    });
  }

  @override
  void dispose() {
    //  burada localdeki videoları silme kodu gelecek

    dir.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Image.asset(
          "assets/background.jpg",
          height: _size.height,
          width: _size.width,
          fit: BoxFit.cover,
        ),
        loaded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Baslik(),
                  //kahve çeşitleri
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryNames.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          category = index;
                                          loaded = false;
                                          readVideo();
                                        });
                                      },
                                      child: CircleAvatar(
                                        foregroundImage: NetworkImage(
                                          categoryPhotos[index],
                                        ),
                                        radius: _size.height * 0.07,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        categoryNames[index],
                                        style: TextStyle(
                                          fontSize: _size.height * 0.025,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemCount: videoList.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: VideoItems(
                                videoPlayerController:
                                    VideoPlayerController.file(
                                        videoList[index])),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
