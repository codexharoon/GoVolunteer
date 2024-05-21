import 'package:flutter/material.dart';
import 'package:go_volunteer/screens/profile.dart';
import 'package:go_volunteer/screens/publish_ride.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final CollectionReference rides =
  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;
    final PageController _pageController = PageController();
    // Dummy data for local testing
    final List<Map<String, dynamic>> dummyData = [
      {
        'name': 'SITTAT ULLAH SHAH',
        'date': 'April 3, 2022',
        'time': '18:00',
        'start': 'Abbasseen House queen road, Estonia...',
        'end': '234 kings roads, new city Estonia 345...',
        'vehicle': 'Mercedes',
        'seats': 2,
        'rating': 4.5,
      },
      {
        'name': 'SITTAT ULLAH SHAH',
        'date': 'April 3, 2022',
        'time': '18:00',
        'start': 'Abbasseen House queen road, Estonia...',
        'end': '234 kings roads, new city Estonia 345...',
        'vehicle': 'Mercedes',
        'seats': 2,
        'rating': 4.5,
      },
      {
        'name': 'SITTAT ULLAH SHAH',
        'date': 'April 3, 2022',
        'time': '18:00',
        'start': 'Abbasseen House queen road, Estonia...',
        'end': '234 kings roads, new city Estonia 345...',
        'vehicle': 'Mercedes',
        'seats': 2,
        'rating': 4.5,
      },
      {
        'name': 'SITTAT ULLAH SHAH',
        'date': 'April 3, 2022',
        'time': '18:00',
        'start': 'Abbasseen House queen road, Estonia...',
        'end': '234 kings roads, new city Estonia 345...',
        'vehicle': 'Mercedes',
        'seats': 2,
        'rating': 4.5,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Volunteer'),
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        children: [
          ListView.builder(
            itemCount: dummyData.length,
            itemBuilder: (context, index) {
              var ride = dummyData[index];
              return RideCard(
                name: ride['name'],
                date: ride['date'],
                time: ride['time'],
                start: ride['start'],
                end: ride['end'],
                vehicle: ride['vehicle'],
                seats: ride['seats'],
                rating: ride['rating'],
              );
            },
          ),
          ProfileScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PublishRidePage()));
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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

  RideCard({
    required this.name,
    required this.date,
    required this.time,
    required this.start,
    required this.end,
    required this.vehicle,
    required this.seats,
    required this.rating,
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
              onTap: () {},
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
                  'Request',
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
