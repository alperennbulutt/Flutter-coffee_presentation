import 'package:flutter/material.dart';

class Baslik extends StatelessWidget {
  const Baslik({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            Text('Hangi kahve türü sizi anlatıyor? Favori kahve makinanı seç.'),
          ],
        ),
      ),
    );
  }
}
