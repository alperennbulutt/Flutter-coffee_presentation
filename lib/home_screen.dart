import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:karaca_odev/Models/kahveModel.dart';
import 'package:karaca_odev/Models/videoModel.dart';
import 'package:karaca_odev/video_items.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: deprecated_member_use
  List<VideoModel> videoModelList = new List<VideoModel>();
  // ignore: deprecated_member_use
  List<KahveModel> kahveList = new List<KahveModel>();
  // ignore: deprecated_member_use
  List documents = new List();
  // ignore: deprecated_member_use
  List<File> videoList = new List<File>();
  int category = 0;
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
    print("çekilen path yolllar $dir");
    //burada kahve çeşitlerini verileri çektik name
    final QuerySnapshot categories =
        await FirebaseFirestore.instance.collection('kahveler').get();
    documents = categories.docs;
    int docIndex = 0;
    await Future.forEach(documents, (data) async {
      KahveModel kahveModel = new KahveModel();
      document = await FirebaseFirestore.instance
          .collection("kahveler")
          .doc(data.id)
          .get();

      kahveModel.fotoUrl = document['fotoUrl'];
      kahveModel.id = document['id'];
      kahveModel.name = document['name'];

      kahveList.add(kahveModel);

      document["videolar"].forEach((videoUrl) => {
            videoModelList.add(new VideoModel(
              category: docIndex,
              url: videoUrl,
            ))
          });

      docIndex++;
    });
    await downloadFile(videoModelList);
    await readVideo();
  }

  downloadFile(List videolar) {
    Dio dio = Dio();

    videolar.asMap().forEach((i, video) async {
      try {
        print("video " + i.toString());

        //local storage a hangi path e hangi isimde atılacağı
        await dio.download(video.url, "${dir.path}/video${i.toString()}.mp4",
            onReceiveProgress: (rec, total) {
          // print("Kaydediliyor: $rec , Toplam: $total");
        });
      } catch (e) {
        print("hata :" + e);
      }
    });
    print("yüklenme Tamam");
  }

  readVideo() {
    videoList.clear();
    print("buraya girdi");
    videoModelList.asMap().forEach((i, videoModel) {
      //local storage a hangi path e hangi isimde okunacağı
      File file = new File('${dir.path}/video${i.toString()}.mp4');
      videoModel.videoPath = "video${i.toString()}";
      if (videoModel.category == category) {
        videoList.add(file);
      }
    });
    setState(() {
      loaded = true;
    });
  }

//homescreen den çıktıgında burası çalışır ve içerisine istenilen metot eklenir
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Stack(
      children: [
        //arka fon
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
                  //başlık
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 90),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'EVİNİN BARİSTASI OL',
                              style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 25),
                            ),
                          ),
                          Text(
                              'Hangi kahve türü sizi anlatıyor? Favori kahve makinanı seç.'),
                        ],
                      ),
                    ),
                  ),
                  //kahve çeşitleri
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: kahveList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: FittedBox(
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
                                            kahveList[index].fotoUrl,
                                          ),
                                          radius: _size.height * 0.07,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          kahveList[index].name,
                                          style: TextStyle(
                                            fontSize: _size.height * 0.025,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemCount: videoList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: VideoItems(
                              videoPlayerController:
                                  VideoPlayerController.file(videoList[index]),
                            ),
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
