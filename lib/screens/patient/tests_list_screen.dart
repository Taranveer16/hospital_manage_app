// lib/screens/patient/tests_list_screen.dart
/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_screen.dart';

final supabase = Supabase.instance.client;

class TestsListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String patientId;

  const TestsListScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.patientId,
  }) : super(key: key);

  @override
  State<TestsListScreen> createState() => _TestsListScreenState();
}

class _TestsListScreenState extends State<TestsListScreen> {
  List<dynamic> tests = [];
  List<String> selectedTestIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      final data = await supabase
          .from('tests')
          .select()
          .eq('category_id', widget.categoryId)
          .order('name');

      setState(() {
        tests = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tests: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tests')),
      );
    }
  }

  void _toggleTest(String testId) {
    setState(() {
      if (selectedTestIds.contains(testId)) {
        selectedTestIds.remove(testId);
      } else {
        selectedTestIds.add(testId);
      }
    });
  }

  void _proceedToCart() {
    if (selectedTestIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one test')),
      );
      return;
    }

    // Get full test objects for selected tests
    final selectedTests = tests
        .where((test) => selectedTestIds.contains(test['id']))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          selectedTests: selectedTests,
          patientId: widget.patientId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blue,
        actions: [
          if (selectedTestIds.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: _proceedToCart,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${selectedTestIds.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tests available in this category',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select tests and proceed to booking',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                final isSelected = selectedTestIds.contains(test['id']);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _toggleTest(test['id']),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Checkbox
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          SizedBox(width: 16),
                          // Test info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  test['name'] ?? 'Unknown Test',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (test['description'] != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    test['description'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${test['avg_duration_minutes'] ?? 0} mins',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.monetization_on,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '\$${test['price'] ?? 0}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: selectedTestIds.isNotEmpty
          ? Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _proceedToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Proceed with ${selectedTestIds.length} test(s)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      )
          : null,
    );
  }
}*/

// lib/screens/patient/tests_list_screen.dart
/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_screen.dart';

final supabase = Supabase.instance.client;

class TestsListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String patientId;

  const TestsListScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.patientId,
  }) : super(key: key);

  @override
  State<TestsListScreen> createState() => _TestsListScreenState();
}

class _TestsListScreenState extends State<TestsListScreen> {
  List<dynamic> tests = [];
  List<String> selectedTestIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      final data = await supabase
          .from('tests')
          .select()
          .eq('category_id', widget.categoryId)
          .order('name');

      setState(() {
        tests = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tests: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tests')),
      );
    }
  }

  void _toggleTest(String testId) {
    setState(() {
      if (selectedTestIds.contains(testId)) {
        selectedTestIds.remove(testId);
      } else {
        selectedTestIds.add(testId);
      }
    });
  }

  void _proceedToCart() {
    if (selectedTestIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one test')),
      );
      return;
    }

    // Get full test objects for selected tests
    final selectedTests = tests
        .where((test) => selectedTestIds.contains(test['id']))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          selectedTests: selectedTests,
          patientId: widget.patientId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blue,
        actions: [
          if (selectedTestIds.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: _proceedToCart,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${selectedTestIds.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tests available in this category',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select tests and proceed to booking',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                final isSelected = selectedTestIds.contains(test['id']);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _toggleTest(test['id']),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Checkbox
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          SizedBox(width: 16),
                          // Test info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  test['name'] ?? 'Unknown Test',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (test['description'] != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    test['description'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${test['avg_duration_minutes'] ?? 0} mins',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.monetization_on,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '₹${test['price'] ?? 0}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: selectedTestIds.isNotEmpty
          ? Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _proceedToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Proceed with ${selectedTestIds.length} test(s)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      )
          : null,
    );
  }
}*/

// lib/screens/patient/tests_list_screen.dart
// UPDATED WITH GLOBAL CART - Can continue browsing other categories
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/screens//services/cart_service.dart';

final supabase = Supabase.instance.client;

class TestsListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String patientId;

  const TestsListScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.patientId,
  }) : super(key: key);

  @override
  State<TestsListScreen> createState() => _TestsListScreenState();
}

class _TestsListScreenState extends State<TestsListScreen> {
  List<dynamic> tests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      final data = await supabase
          .from('tests')
          .select()
          .eq('category_id', widget.categoryId)
          .order('name');

      setState(() {
        tests = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading tests: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tests')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tests available in this category',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select tests and continue browsing other categories',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<CartService>(
              builder: (context, cartService, child) {
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    final isSelected = cartService.isTestSelected(test['id']);

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => cartService.toggleTest(test),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Checkbox
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: isSelected
                                    ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                    : null,
                              ),
                              SizedBox(width: 16),
                              // Test info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test['name'] ?? 'Unknown Test',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (test['description'] != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        test['description'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${test['avg_duration_minutes'] ?? 0} mins',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(
                                          Icons.monetization_on,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '₹${test['price'] ?? 0}',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}