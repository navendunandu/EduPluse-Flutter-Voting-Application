import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupulse/my_profile.dart';
import 'package:flutter/material.dart';

class Election extends StatefulWidget {
  const Election({super.key});

  @override
  State<Election> createState() => _ElectionState();
}

class _ElectionState extends State<Election> {
  List<Map<String, dynamic>> electionList = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      // Reference to the collection
      CollectionReference electionCollection =
          FirebaseFirestore.instance.collection('tbl_election');

      // Get documents from the collection
      QuerySnapshot<Object?> querySnapshot = await electionCollection.get();

      // Explicitly cast the type to QuerySnapshot<Map<String, dynamic>>
      QuerySnapshot<Map<String, dynamic>> typedQuerySnapshot =
          querySnapshot as QuerySnapshot<Map<String, dynamic>>;

      // Iterate through the documents and add them to the list
      typedQuerySnapshot.docs.forEach((QueryDocumentSnapshot<Object?> doc) {
        electionList.add(doc.data()! as Map<String, dynamic>);
      });

      // Print the list for testing (you can remove this in the final version)
      print(electionList);

      // setState to rebuild the UI with the fetched data
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDUPULSE'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyProfile(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: electionList.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> electionData = electionList[index];
            return Container(
              padding: const EdgeInsets.all(20.0),
              width: 500,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${electionData['election_for_date']}'),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('${electionData['election_details']}'),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                      'Last Date: ${electionData['election_nomination_ldate']}'),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text('View Candidates')),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('View Results'))
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
