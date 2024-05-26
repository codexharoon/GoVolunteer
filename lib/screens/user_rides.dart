import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRides extends StatefulWidget {
  dynamic user;
  UserRides({super.key, required this.user});

  @override
  State<UserRides> createState() => _UserRidesState();
}

class _UserRidesState extends State<UserRides> {
  final CollectionReference rides =
      FirebaseFirestore.instance.collection('rides');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: rides.where('user', isEqualTo: widget.user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No rides found.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          }
          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var ride = data.docs[index];
              return UserRideCard(
                name: ride['name'],
                date: ride['date'],
                time: ride['time'],
                start: ride['start'],
                end: ride['end'],
                vehicle: ride['vehicle'],
                seats: ride['seats'],
                rating: ride['rating'],
                onDelete: () async {
                  await ride.reference.delete();
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserRideCard extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final String start;
  final String end;
  final String vehicle;
  final int seats;
  final double rating;
  final VoidCallback onDelete;

  UserRideCard({
    required this.name,
    required this.date,
    required this.time,
    required this.start,
    required this.end,
    required this.vehicle,
    required this.seats,
    required this.rating,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    Text('($rating)'),
                  ],
                )
              ],
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                '------- $date | $time -------',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_pin, color: Colors.green),
                    const SizedBox(width: 5),
                    Expanded(child: Text(start)),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Icon(Icons.location_pin, color: Colors.red),
                    const SizedBox(width: 5),
                    Expanded(child: Text(end)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle',
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                    Text(
                      '$vehicle',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Total seats',
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                    Text('$seats',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.red,
                ),
                width: double.infinity,
                child: const Center(
                    child: Text(
                  'Delete Ride',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
