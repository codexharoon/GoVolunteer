import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_volunteer/utilities/fetch_user_data.dart';
import 'package:intl/intl.dart';

class PublishRidePage extends StatefulWidget {
  dynamic user;
  PublishRidePage({super.key, required this.user});

  @override
  _PublishRidePageState createState() => _PublishRidePageState();
}

class _PublishRidePageState extends State<PublishRidePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _seatsController =
      TextEditingController(text: '1');
  final TextEditingController _vehicleController =
      TextEditingController(text: 'Green Nissan Note - AXK 370');

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 0, minute: 0);

  late String phone = '1234567890';
  late String name = widget.user.email;

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        ) ??
        _selectedDate;
    if (picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEE, dd MMM').format(_selectedDate);
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        ) ??
        _selectedTime;
    if (picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime.format(context);
      });
  }

  void _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('rides').add({
        'user': uid,
        'name': name,
        'start': _pickupController.text,
        'end': _destinationController.text,
        'date': _selectedDate.toString().substring(0, 10),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'seats': int.parse(_seatsController.text),
        'vehicle': _vehicleController.text,
        'rating': 4.5,
        'phone': phone,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ride Published Successfully')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      Map<String, dynamic> userData = await fetchUserData();
      setState(() {
        name = userData['name'] ?? widget.user.email;
        phone = userData['phone'] ?? '1234567890';
      });
    });
    return Scaffold(
      appBar: AppBar(
          title: const Text('Publish a Ride'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mySeprator(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pickupController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter pickup address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destination Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter destination address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                mySeprator(),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Departure Date',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                mySeprator(),
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Select Time',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                mySeprator(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _seatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available Seats',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_seat),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter available seats';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                mySeprator(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _vehicleController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                  ),
                ),
                mySeprator(),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _submitData,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF04BF68),
                    ),
                    width: double.infinity,
                    child: const Center(
                        child: Text(
                      'Publish',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget mySeprator() {
  return Container(
    color: const Color(0xFFF3F5FD),
    height: 10,
  );
}
