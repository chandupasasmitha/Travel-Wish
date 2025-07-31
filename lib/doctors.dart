import 'package:flutter/material.dart';
import 'services/api.dart';

class DoctorsPage extends StatefulWidget {
  @override
  _DoctorsPageState createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String selectedSpecialty = 'all';

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getDoctors();
      setState(() {
        doctors = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading doctors: $e")),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredDoctors() {
    if (selectedSpecialty == 'all') return doctors;
    return doctors.where((doc) {
      final spec = doc['specialty']?.toString().toLowerCase() ?? '';
      return spec.contains(selectedSpecialty.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredDoctors();

    return Scaffold(
      appBar: AppBar(
        title: Text("Doctors Directory"),
        backgroundColor: const Color.fromARGB(255, 0, 8, 121),
      ),
      body: Column(
        children: [
          _buildSpecialtyFilter(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchDoctors,
                    child: filtered.isEmpty
                        ? Center(child: Text("No doctors found"))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final doctor = filtered[index];
                              return DoctorCard(data: doctor);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    List<String> specialties = [
      'all',
      'Radiology',
      'Anesthesiology',
      'Cardiology',
      'Surgery'
    ];

    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final spec = specialties[index];
          final isSelected = selectedSpecialty == spec;
          return GestureDetector(
            onTap: () => setState(() => selectedSpecialty = spec),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color.fromARGB(255, 0, 5, 59) : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  spec,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const DoctorCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = data['fullName'] ?? 'Unknown';
    final specialty = data['specialty'] ?? 'Unknown';
    final phone = data['phone'] ?? '';
    final email = data['email'] ?? '';
    final experience = data['experienceYears']?.toString() ?? 'N/A';
    final address = data['address'] ?? '';
    final license = data['licenseNumber'] ?? '';
    final school = data['medicalSchool'] ?? '';
    final year = data['graduationYear']?.toString() ?? '';
    final certifications = data['certifications'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: const Color.fromARGB(255, 6, 0, 69))),
            SizedBox(height: 4),
            Text(specialty,
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            SizedBox(height: 6),
            if (phone.isNotEmpty)
              Text("Phone: $phone",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            if (email.isNotEmpty)
              Text("Email: $email",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 6),
            Text("Experience: $experience years",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text("License: $license",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text("School: $school ($year)",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            if (certifications.isNotEmpty)
              Text("Certifications: $certifications",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 4),
            Text("Address: $address",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
