import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MealSelectionScreen extends StatefulWidget {
  const MealSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  final List<String> _dietPlans = [
    'Keto',
    'Paleo',
    'Carnivore',
    'Vegetarian',
    'Vegan',
    'Mediterranean',
    'Low-Carb',
    'High-Protein'
  ];

  String? _selectedPlan;
  bool _isLoading = false;

  // Fetch meal suggestion from OpenAI
  Future<void> fetchMealSuggestion(String plan) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful AI chef assistant providing healthy meal ideas.'
            },
            {
              'role': 'user',
              'content':
                  'Suggest a healthy, simple meal idea for a $plan diet.'
            },
          ],
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final aiReply = data['choices'][0]['message']['content'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(aiReply),
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // Soft contemporary red tint
      appBar: AppBar(
        title: const Text('Select Your Meal Plan'),
        backgroundColor: const Color(0xFFE63946), // Contemporary red
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a Diet Plan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFE63946), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text(
                    'Select a plan',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                  value: _selectedPlan,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _dietPlans.map((String plan) {
                    return DropdownMenuItem<String>(
                      value: plan,
                      child: Text(
                        plan,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPlan = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _selectedPlan == null || _isLoading
                    ? null
                    : () {
                        fetchMealSuggestion(_selectedPlan!);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63946),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Get Suggestion',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
