import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/authorized_network_image.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'package:shweeshaungdaily/views/view_router.dart';

// IMPORTANT: ApiService is assumed to be defined elsewhere in your project.
// This code will not run without your actual ApiService implementation.
// class ApiService {
//   static Future<List<Map<String, dynamic>>> searchNames(String query) async {
//     // Your actual API call logic goes here.
//     // This mock was for demonstration and has been removed as per your request.
//     return [];
//   }
// }

class Person {
  final String name;
  final String profileImageUrl;
  final String email;

  Person({required this.name, required this.profileImageUrl,required this.email});
}

class FacebookSearchPage extends StatefulWidget {
  const FacebookSearchPage({super.key});

  @override
  State<FacebookSearchPage> createState() => _FacebookSearchPageState();
}

class _FacebookSearchPageState extends State<FacebookSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Person> _filteredPeople = []; // This will hold people filtered by search
  bool _isLoading = false; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    // No initial load, as fetching happens on keystroke
    _searchController.addListener(
      _fetchAndFilterPeople,
    ); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_fetchAndFilterPeople);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchAndFilterPeople() async {
    String query =
        _searchController.text; // Get the current text from the controller

    // Only fetch if the query is not empty
    if (query.isEmpty) {
      setState(() {
        _filteredPeople = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Call your API service
      // The 'query' variable directly holds the value from the text field.
      final response = await ApiService.searchNames(query);

      setState(() {
        _filteredPeople =
            response.map((item) {
              final String email = item['email']?.toString() ?? 'no email';
              // Safely access 'name' and 'profile' and provide default values if they are null
              final String name = item['name']?.toString() ?? 'Unknown Name';
              const baseUrl =
                  'https://shweeshaung.mooo.com/'; // Replace with your actual base URL

              final profilePath = item['profile'] ?? '';
              final profile =
                  profilePath.isNotEmpty ? '$baseUrl$profilePath' : '';
              return Person(name: name, profileImageUrl: profile, email: email);
            }).toList();
        _isLoading = false; // Hide loading indicator
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar or an error message
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false; // Hide loading indicator even on error
        _filteredPeople = []; // Clear results on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700], // Facebook blue
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search people...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            style: TextStyle(color: Colors.grey[800]),
            cursorColor: Colors.blue[700],
          ),
        ),
        // Adding a back button for navigation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : _filteredPeople.isEmpty
              ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Start typing to search for people.'
                      : 'No results for "${_searchController.text}"',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                itemCount: _filteredPeople.length,
                itemBuilder: (context, index) {
                  final person = _filteredPeople[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewRouter(email: person.email,)),
    );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                                  child:
                                      (person.profileImageUrl != null &&
                                              person.profileImageUrl.isNotEmpty)
                                          ? ClipOval(
                                            child: AuthorizedNetworkImage(
                                              imageUrl: person.profileImageUrl,
                                              height: double.infinity,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Icon(Icons.person, color: kPrimaryColor,),
                                ),
                          const SizedBox(width: 16),
                          Text(
                            person.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
