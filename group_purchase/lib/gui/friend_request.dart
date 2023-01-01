import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequest extends StatelessWidget {
  const FriendRequest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              child: const Text(
                'Zaproszenia do znajomych',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            totalFriendContainer(),
            viewFriendRequest(),
            gridView(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
        title: FlutterLogo(size: 25),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
          color: Colors.grey,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
            color: Colors.grey,
          )
        ]);
  }

  Widget totalFriendContainer() {
    return Container(
        margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.grey.shade300)
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liczba znajomych',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '206',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xff4530B3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'Zobacz szczegóły',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff4530B3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget viewFriendRequest() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Zaproszenia do znajomych',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Zobacz wszystkie',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff4530B3),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget gridView() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 0.9,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 8),
      primary: false,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      shrinkWrap: true,
      children: [
        gridViewItem(
            name: 'John Brian',
            description: 'Cusco, Peru',
            status: 'Online',
            image: '')
      ],
    );
  }

  Widget gridViewItem(
      {required String name,
      required String description,
      required String status,
      required String image}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 4,
      shadowColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.only(top: 13),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xff4530B3),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: status == 'Offline'
                            ? Colors.amber
                            : Color(0xff31C911),
                        border: Border.all(
                            color: Colors.white,
                            style: BorderStyle.solid,
                            width: 3)),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 2),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 2),
              child: Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Color(0xff4530B3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Center(
                child: Text(
                  'Odpowiedz',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
