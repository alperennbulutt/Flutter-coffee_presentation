import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'baslik_widget.dart';
import 'loading_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("turkkahvesi").snapshots(),
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
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: CircleAvatar(
                                    foregroundImage: NetworkImage(
                                      items['name'],
                                    ),
                                    radius: 60.0,
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
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot items = snapshot.data.docs[index];
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                child: Image.network(items['name']),
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
