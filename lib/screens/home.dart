import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:go_volunteer/screens/profile.dart';
import 'package:go_volunteer/screens/publish_ride.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  dynamic user;
  HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference rides =
      FirebaseFirestore.instance.collection('rides');

  void _launchPhoneDialer(dynamic phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Go Volunteer'),
      //   automaticallyImplyLeading: false,
      // ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        children: [
          FutureBuilder<QuerySnapshot>(
            future: rides.get(),
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
                  return RideCard(
                    name: ride['name'],
                    date: ride['date'],
                    time: ride['time'],
                    start: ride['start'],
                    end: ride['end'],
                    vehicle: ride['vehicle'],
                    seats: ride['seats'],
                    rating: ride['rating'],
                    phoneNumber: ride['phone'],
                    launchPhoneDialer: _launchPhoneDialer,
                  );
                },
              );
            },
          ),
          ProfilePage(
            user: widget.user,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PublishRidePage(
                        user: widget.user,
                      )));
        },
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final String start;
  final String end;
  final String vehicle;
  final int seats;
  final double rating;
  final String phoneNumber;
  final void Function(String) launchPhoneDialer;

  RideCard({
    required this.name,
    required this.date,
    required this.time,
    required this.start,
    required this.end,
    required this.vehicle,
    required this.seats,
    required this.rating,
    required this.phoneNumber,
    required this.launchPhoneDialer,
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
              onTap: () async {
                await FlutterPhoneDirectCaller.callNumber(phoneNumber);
              },
              child: Container(
                // margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF04BF68),
                ),
                width: double.infinity,
                child: const Center(
                    child: Text(
                  '☏ Call Volunteer',
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
