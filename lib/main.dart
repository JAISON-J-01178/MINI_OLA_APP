import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MiniOlaApp());
}

/* ================= APP ROOT ================= */

class MiniOlaApp extends StatelessWidget {
  const MiniOlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mini OLA",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.yellow[600],
      ),
      home: const LoginPage(),
    );
  }
}

/* ================= LOGIN PAGE ================= */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;

  void login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            name: nameController.text,
            email: emailController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.yellow[600],
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(Icons.local_taxi,
                    size: 90, color: Colors.black),

                const SizedBox(height: 10),

                const Text(
                  "Mini OLA 🚕",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Enter your name" : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Gmail",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      !v!.endsWith("@gmail.com")
                          ? "Use @gmail.com"
                          : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) =>
                      v!.length < 8 ? "Min 8 characters" : null,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.yellow,
                    minimumSize:
                        const Size(double.infinity, 50),
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= DASHBOARD ================= */

class DashboardPage extends StatefulWidget {
  final String name;
  final String email;

  const DashboardPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  int selectedIndex = 0;
  Map<String, String>? lastRide;

  @override
  Widget build(BuildContext context) {

    final pages = [
      HomePage(onVehicleSelected: (_) => setState(() => selectedIndex = 1)),
      BookingPage(
        onBooked: (ride) {
          setState(() {
            lastRide = ride;
            selectedIndex = 2;
          });
        },
      ),
      MyRidesPage(
        ride: lastRide,
        onBookAgain: () => setState(() => selectedIndex = 1),
      ),
      ProfilePage(name: widget.name, email: widget.email),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini OLA 🚕"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow,
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) =>
            setState(() => selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.directions_car), label: "Book"),
          NavigationDestination(icon: Icon(Icons.history), label: "Rides"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/* ================= HOME PAGE ================= */

class HomePage extends StatelessWidget {
  final Function(String) onVehicleSelected;

  const HomePage({super.key, required this.onVehicleSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 20),

        const Text("Select Vehicle",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

        vehicle("Car", Icons.directions_car),
        vehicle("Bike", Icons.motorcycle),
        vehicle("Auto", Icons.electric_rickshaw),
      ],
    );
  }

  Widget vehicle(String title, IconData icon) {
    return GestureDetector(
      onTap: () => onVehicleSelected(title),
      child: Card(
        margin: const EdgeInsets.all(15),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}

/* ================= BOOKING PAGE ================= */

class BookingPage extends StatefulWidget {
  final Function(Map<String, String>) onBooked;

  const BookingPage({super.key, required this.onBooked});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  final pickupController = TextEditingController();
  final dropController = TextEditingController();

  String arrivalTime = "";
  String dropTime = "";
  String distance = "";
  String fare = "";
  bool showETA = false;

  void calculateTimes() {
    final now = DateTime.now();
    final rand = Random();

    arrivalTime =
        TimeOfDay.fromDateTime(now.add(const Duration(minutes: 5)))
            .format(context);

    dropTime =
        TimeOfDay.fromDateTime(now.add(const Duration(minutes: 20)))
            .format(context);

    double km = rand.nextDouble() * 10 + 1;
    distance = "${km.toStringAsFixed(1)} km";
    fare = "₹ ${(km * 18).toStringAsFixed(0)}";

    setState(() => showETA = true);
  }

  void bookRide() {
    widget.onBooked({
      "pickup": pickupController.text,
      "drop": dropController.text,
      "arrival": arrivalTime,
      "dropTime": dropTime,
      "distance": distance,
      "fare": fare,
    });
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          TextField(
            controller: pickupController,
            decoration: const InputDecoration(
              labelText: "Pickup location",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: dropController,
            decoration: const InputDecoration(
              labelText: "Destination",
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => calculateTimes(),
          ),

          const SizedBox(height: 20),

          if (showETA) ...[
            Text("Vehicle arrives at: $arrivalTime"),
            Text("Estimated drop time: $dropTime"),
            Text("Distance: $distance"),
            Text("Fare: $fare",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
          ],

          ElevatedButton(
            onPressed: bookRide,
            child: const Text("Book Ride"),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Live location started 🚕")),
              );
            },
            icon: const Icon(Icons.location_on),
            label: const Text("Live Locate"),
          ),
        ],
      ),
    );
  }
}

/* ================= MY RIDES ================= */

class MyRidesPage extends StatefulWidget {
  final Map<String, String>? ride;
  final VoidCallback onBookAgain;

  const MyRidesPage({
    super.key,
    required this.ride,
    required this.onBookAgain,
  });

  @override
  State<MyRidesPage> createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {

  int rating = 0;

  @override
  Widget build(BuildContext context) {

    if (widget.ride == null) {
      return const Center(child: Text("No rides yet"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [

              Text("Pickup: ${widget.ride!["pickup"]}"),
              Text("Drop: ${widget.ride!["drop"]}"),
              Text("Distance: ${widget.ride!["distance"]}"),
              Text("Fare Paid: ${widget.ride!["fare"]}"),

              const SizedBox(height: 20),

              const Text("Rate your ride"),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() => rating = i + 1);
                    },
                  );
                }),
              ),

              ElevatedButton(
                onPressed: widget.onBookAgain,
                child: const Text("Book Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= PROFILE PAGE ================= */

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.black,
            child: const Icon(Icons.person,
                size: 50, color: Colors.yellow),
          ),

          const SizedBox(height: 10),

          Text(widget.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),

          Text(widget.email),

          const SizedBox(height: 5),

          const Text("+91 98765 43210"),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text("Edit Profile"),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.star),
              title: const Text("Total Rides"),
              trailing: const Text("12"),
            ),
          ),

          Card(
            child: Column(
              children: [

                SwitchListTile(
                  title: const Text("Notifications"),
                  value: notifications,
                  onChanged: (v) =>
                      setState(() => notifications = v),
                ),

                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: darkMode,
                  onChanged: (v) =>
                      setState(() => darkMode = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.yellow,
              minimumSize:
                  const Size(double.infinity, 50),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}