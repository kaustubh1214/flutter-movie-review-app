import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Review App',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const MovieReviewForm(),
    );
  }
}

class MovieReviewForm extends StatefulWidget {
  const MovieReviewForm({super.key});

  @override
  _MovieReviewFormState createState() => _MovieReviewFormState();
}

class _MovieReviewFormState extends State<MovieReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  int _rating = 0;
  String? _selectedGender;

  // Form fields
  final Map<String, dynamic> _formData = {
    'firstName': '',
    'lastName': '',
    'address': '',
    'email': '',
    'phone': '',
    'review': '',
  };

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a rating'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text('Are you sure you want to submit your review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPage(
                      formData: _formData,
                      rating: _rating,
                      gender: _selectedGender,
                      dob: _selectedDate,
                    ),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎬 Thanks for being a fan!'),
              backgroundColor: Colors.amber,
            ),
          );
        },
        child: const Icon(Icons.favorite),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black87, Colors.deepPurple],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Movie Review Form',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField('First Name', 'firstName', Icons.person),
                _buildTextField('Last Name', 'lastName', Icons.person),
                _buildDateField(),
                _buildTextField('Address', 'address', Icons.home),
                _buildTextField('Email', 'email', Icons.email,
                    keyboardType: TextInputType.emailAddress),
                _buildTextField('Phone Number', 'phone', Icons.phone,
                    keyboardType: TextInputType.phone),
                _buildGenderDropdown(),
                _buildReviewField(),
                const SizedBox(height: 20),
                _buildRatingStars(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String field, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $label';
          }
          if (field == 'email' && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          if (field == 'phone' && value.length < 10) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
        onSaved: (value) => _formData[field] = value!,
      ),
    );
  }

  Widget _buildDateField() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _dobController,
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please select date of birth';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Gender',
          prefixIcon: Icon(Icons.person_outline),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: ['Male', 'Female', 'Other']
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
            .toList(),
        validator: (value) =>
            value == null ? 'Please select your gender' : null,
        onChanged: (value) => _selectedGender = value,
      ),
    );
  }

  Widget _buildReviewField() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Your Review',
          prefixIcon: Icon(Icons.edit),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        maxLines: 4,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please write your review';
          }
          return null;
        },
        onSaved: (value) => _formData['review'] = value!,
      ),
    );
  }

  Widget _buildRatingStars() {
    return Column(
      children: [
        const Text(
          'Rate the Movie:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            );
          }),
        ),
      ],
    );
  }
}

class DisplayPage extends StatelessWidget {
  final Map<String, dynamic> formData;
  final int rating;
  final String? gender;
  final DateTime? dob;

  const DisplayPage({
    super.key,
    required this.formData,
    required this.rating,
    required this.gender,
    required this.dob,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Submission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildInfoRow(
                'Name', '${formData['firstName']} ${formData['lastName']}'),
            _buildInfoRow(
                'Date of Birth', DateFormat('yyyy-MM-dd').format(dob!)),
            _buildInfoRow('Address', formData['address']),
            _buildInfoRow('Email', formData['email']),
            _buildInfoRow('Phone', formData['phone']),
            _buildInfoRow('Gender', gender!),
            _buildInfoRow('Review', formData['review']),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Rating: ', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                ...List.generate(
                  rating,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
