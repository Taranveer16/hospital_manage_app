// lib/services/navigation_service.dart
/*import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class NavigationService {
  // Get navigation path between two locations
  Future<Map<String, dynamic>?> getNavigationPath({
    required String fromLocation,
    required String toLocation,
  }) async {
    try {
      final data = await supabase
          .from('navigation_paths')
          .select()
          .eq('from_location', fromLocation)
          .eq('to_location', toLocation)
          .maybeSingle();

      return data;
    } catch (e) {
      print('Error fetching navigation path: $e');
      return null;
    }
  }

  // Get test sequence for an appointment
  Future<List<Map<String, dynamic>>> getTestSequence(String appointmentId) async {
    try {
      final testsData = await supabase
          .from('appointment_tests')
          .select('*, tests(*)')
          .eq('appointment_id', appointmentId)
          .order('test_order');

      return List<Map<String, dynamic>>.from(testsData);
    } catch (e) {
      print('Error fetching test sequence: $e');
      return [];
    }
  }

  // Update test status
  Future<bool> updateTestStatus({
    required String appointmentTestId,
    required String status,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      if (status == 'reached') {
        updates['reached_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await supabase
          .from('appointment_tests')
          .update(updates)
          .eq('id', appointmentTestId);

      return true;
    } catch (e) {
      print('Error updating test status: $e');
      return false;
    }
  }

  // Get current location based on last completed test
  String getCurrentLocation(List<Map<String, dynamic>> tests) {
    // Find the last reached/completed test
    for (int i = tests.length - 1; i >= 0; i--) {
      final status = tests[i]['status'] as String?;
      if (status == 'reached' || status == 'completed') {
        final test = tests[i]['tests'] as Map<String, dynamic>?;
        return test?['room_number'] ?? 'Main Entrance';
      }
    }
    return 'Main Entrance';
  }

  // Get next pending test
  Map<String, dynamic>? getNextTest(List<Map<String, dynamic>> tests) {
    for (var test in tests) {
      final status = test['status'] as String?;
      if (status == 'pending') {
        return test;
      }
    }
    return null;
  }

  // Check if all tests are completed
  bool areAllTestsCompleted(List<Map<String, dynamic>> tests) {
    return tests.every((test) => test['status'] == 'completed');
  }

  // Get progress (completed/total)
  Map<String, int> getProgress(List<Map<String, dynamic>> tests) {
    final completed = tests.where((t) => t['status'] == 'completed').length;
    return {
      'completed': completed,
      'total': tests.length,
    };
  }

  // Generate fallback directions when path not in database
  List<Map<String, String>> generateFallbackDirections({
    required String fromRoom,
    required String toRoom,
    required String fromFloor,
    required String toFloor,
  }) {
    if (fromFloor == toFloor) {
      // Same floor
      return [
        {'step': '1', 'instruction': 'Exit $fromRoom'},
        {'step': '2', 'instruction': 'Follow corridor signs'},
        {'step': '3', 'instruction': 'Look for $toRoom'},
      ];
    } else {
      // Different floors
      return [
        {'step': '1', 'instruction': 'Exit $fromRoom'},
        {'step': '2', 'instruction': 'Walk to elevator'},
        {'step': '3', 'instruction': 'Take elevator to $toFloor'},
        {'step': '4', 'instruction': 'Exit elevator'},
        {'step': '5', 'instruction': 'Follow signs to $toRoom'},
      ];
    }
  }
}*/



// lib/services/navigation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PathSegment {
  final String floor;
  final String pathId;
  final String fromLocation;
  final String toLocation;

  PathSegment({
    required this.floor,
    required this.pathId,
    required this.fromLocation,
    required this.toLocation,
  });
}

class NavigationService {
  // Get test sequence optimized by queue length
  Future<List<Map<String, dynamic>>> getOptimalTestSequence(String appointmentId) async {
    try {
      // Call the database function for optimal ordering
      final result = await supabase.rpc('get_optimal_test_order',
          params: {'p_appointment_id': appointmentId}
      );

      if (result != null && result is List) {
        return List<Map<String, dynamic>>.from(result);
      }

      // Fallback: get tests in original order
      return await getTestSequence(appointmentId);
    } catch (e) {
      print('Error getting optimal test sequence: $e');
      // Fallback to original sequence
      return await getTestSequence(appointmentId);
    }
  }

  // Get test sequence (original order)
  Future<List<Map<String, dynamic>>> getTestSequence(String appointmentId) async {
    try {
      final testsData = await supabase
          .from('appointment_tests')
          .select('*, tests(*), test_rooms!appointment_tests_assigned_room_id_fkey(*)')
          .eq('appointment_id', appointmentId)
          .order('test_order');

      return List<Map<String, dynamic>>.from(testsData);
    } catch (e) {
      print('Error fetching test sequence: $e');
      return [];
    }
  }

  // Get room queue information
  Future<Map<String, dynamic>?> getRoomQueueInfo(String roomNumber) async {
    try {
      final result = await supabase.rpc('get_room_queue_info',
          params: {'p_room_number': roomNumber}
      );

      if (result != null && result is List && result.isNotEmpty) {
        return result[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching room queue info: $e');
      return null;
    }
  }

  // Get all current queues
  Future<List<Map<String, dynamic>>> getAllQueueStatus() async {
    try {
      final result = await supabase
          .from('current_queue_status')
          .select();

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching queue status: $e');
      return [];
    }
  }

  // Get navigation path between two locations (with multi-floor support)
  Future<List<PathSegment>> getNavigationPathSegments({
    required String fromLocation,
    required String toLocation,
    required String fromFloor,
    required String toFloor,
  }) async {
    List<PathSegment> segments = [];

    try {
      // Same floor navigation
      if (fromFloor == toFloor) {
        final pathId = _getPathId(fromLocation, toLocation, fromFloor);
        if (pathId.isNotEmpty) {
          segments.add(PathSegment(
            floor: fromFloor,
            pathId: pathId,
            fromLocation: fromLocation,
            toLocation: toLocation,
          ));
        }
      }
      // Multi-floor navigation
      else {
        // Segment 1: Current location to elevator on current floor
        final pathToElevator = _getPathId(fromLocation, 'Elevator', fromFloor);
        if (pathToElevator.isNotEmpty) {
          segments.add(PathSegment(
            floor: fromFloor,
            pathId: pathToElevator,
            fromLocation: fromLocation,
            toLocation: 'Elevator',
          ));
        }

        // Segment 2: Elevator to destination on target floor
        final pathFromElevator = _getPathId('Elevator', toLocation, toFloor);
        if (pathFromElevator.isNotEmpty) {
          segments.add(PathSegment(
            floor: toFloor,
            pathId: pathFromElevator,
            fromLocation: 'Elevator',
            toLocation: toLocation,
          ));
        }
      }

      return segments;
    } catch (e) {
      print('Error getting path segments: $e');
      return segments;
    }
  }

  // Helper: Get SVG path ID based on locations
  String _getPathId(String from, String to, String floor) {
    // Normalize location names
    final fromNorm = from.toLowerCase().replaceAll(' ', '_');
    final toNorm = to.toLowerCase().replaceAll(' ', '_');

    // Generate path ID
    if (floor == 'Ground Floor') {
      if (from == 'Main Entrance' && to == 'Lab A') return 'path_entrance_to_lab_a';
      if (from == 'Main Entrance' && to == 'Lab B') return 'path_entrance_to_lab_b';
      if (from == 'Lab A' && to == 'Elevator') return 'path_lab_a_to_elevator';
      if (from == 'Lab B' && to == 'Elevator') return 'path_lab_b_to_elevator';
    } else if (floor == '1st Floor') {
      if (from == 'Elevator' && to.startsWith('Room')) {
        return 'path_elevator_to_${toNorm}';
      }
    } else if (floor == '2nd Floor') {
      if (from == 'Elevator' && to.startsWith('Room')) {
        return 'path_elevator_to_${toNorm}';
      }
    }

    return '';
  }

  // Update test status with queue tracking
  Future<bool> updateTestStatus({
    required String appointmentTestId,
    required String status,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'reached') {
        updates['reached_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await supabase
          .from('appointment_tests')
          .update(updates)
          .eq('id', appointmentTestId);

      print('✅ Test status updated to: $status');
      return true;
    } catch (e) {
      print('❌ Error updating test status: $e');
      return false;
    }
  }

  // Get current location based on last completed test
  String getCurrentLocation(List<Map<String, dynamic>> tests) {
    // Find the last reached/completed test
    for (int i = tests.length - 1; i >= 0; i--) {
      final status = tests[i]['status'] as String?;
      if (status == 'reached' || status == 'completed') {
        final testRooms = tests[i]['test_rooms'] as Map<String, dynamic>?;
        return testRooms?['room_number'] ?? 'Main Entrance';
      }
    }
    return 'Main Entrance';
  }

  // Get next pending test
  Map<String, dynamic>? getNextTest(List<Map<String, dynamic>> tests) {
    for (var test in tests) {
      final status = test['status'] as String?;
      if (status == 'pending') {
        return test;
      }
    }
    return null;
  }

  // Check if all tests are completed
  bool areAllTestsCompleted(List<Map<String, dynamic>> tests) {
    return tests.every((test) => test['status'] == 'completed');
  }

  // Get progress (completed/total)
  Map<String, int> getProgress(List<Map<String, dynamic>> tests) {
    final completed = tests.where((t) => t['status'] == 'completed').length;
    return {
      'completed': completed,
      'total': tests.length,
    };
  }

  // Group tests by room (for batch completion)
  Map<String, List<Map<String, dynamic>>> groupTestsByRoom(
      List<Map<String, dynamic>> tests
      ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var test in tests) {
      final testRooms = test['test_rooms'] as Map<String, dynamic>?;
      final roomNumber = testRooms?['room_number'] ?? 'Unknown';

      if (!grouped.containsKey(roomNumber)) {
        grouped[roomNumber] = [];
      }
      grouped[roomNumber]!.add(test);
    }

    return grouped;
  }

  // Get all pending tests for current room
  List<Map<String, dynamic>> getPendingTestsForRoom(
      List<Map<String, dynamic>> tests,
      String roomNumber,
      ) {
    return tests.where((test) {
      final testRooms = test['test_rooms'] as Map<String, dynamic>?;
      final testRoom = testRooms?['room_number'] ?? '';
      final status = test['status'] as String?;
      return testRoom == roomNumber && status == 'pending';
    }).toList();
  }

  // Complete all tests in current room
  Future<bool> completeAllTestsInRoom(
      List<Map<String, dynamic>> testsInRoom,
      ) async {
    try {
      for (var test in testsInRoom) {
        await updateTestStatus(
          appointmentTestId: test['id'],
          status: 'completed',
        );
      }
      return true;
    } catch (e) {
      print('Error completing tests in room: $e');
      return false;
    }
  }

  // Generate fallback directions when path not in database
  List<Map<String, String>> generateFallbackDirections({
    required String fromRoom,
    required String toRoom,
    required String fromFloor,
    required String toFloor,
  }) {
    if (fromFloor == toFloor) {
      // Same floor
      return [
        {'step': '1', 'instruction': 'Exit $fromRoom'},
        {'step': '2', 'instruction': 'Follow corridor signs'},
        {'step': '3', 'instruction': 'Look for $toRoom'},
      ];
    } else {
      // Different floors
      return [
        {'step': '1', 'instruction': 'Exit $fromRoom'},
        {'step': '2', 'instruction': 'Walk to elevator'},
        {'step': '3', 'instruction': 'Take elevator to $toFloor'},
        {'step': '4', 'instruction': 'Exit elevator'},
        {'step': '5', 'instruction': 'Follow signs to $toRoom'},
      ];
    }
  }
}