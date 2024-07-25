import 'package:classly/data/repositories/UserRepository.dart';
import '../../domain/models/Course.dart';
import '../../domain/models/CustomUser.dart';
import '../../domain/enum/UserRole.dart';

class UserService {
  final UserRepository userRepository = UserRepository();

  Future<CustomUser?> getUser(String uid) async {
    try {
      return await userRepository.getUser(uid);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    try {
      await userRepository.updateUserProfileImage(uid, imageUrl);
    } catch (e) {
      print('Error updating user profile image: $e');
      throw e;
    }
  }

  Future<List<Course>> getEnrolledCourses(String uid) async {
    try {
      return await userRepository.getEnrolledCourses(uid);
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      return [];
    }
  }


  Future<void> enrollInCourses(String userId, List<Course> courses) async {
    try {
      List<Map<String, String>> courseIds = courses
          .map((course) => {'courseId': course.courseId})
          .toList();

      await userRepository.updateCourses(userId, courseIds, []);
      print('User $userId enrolled in courses: $courseIds');
    } catch (error) {
      print('Error enrolling in courses: $error');
      throw Exception('Error enrolling in courses: $error');
    }
  }

  Future<void> disenrollFromCourses(String userId, List<Course> courses) async {
    try {
      List<Map<String, String>> courseIds = courses
          .map((course) => {'courseId': course.courseId})
          .toList();

      await userRepository.updateCourses(userId, [], courseIds);
      print('User $userId enrolled in courses: $courseIds');
    } catch (error) {
      print('Error enrolling in courses: $error');
      throw Exception('Error enrolling in courses: $error');
    }
  }

  Future<List<CustomUser>> getAllUsers() async {
    try {
      return await userRepository.getAllUsers();
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      UserRole roleEnum;
      switch (newRole.toUpperCase()) {
        case 'PROFESSOR':
          roleEnum = UserRole.PROFESSOR;
          break;
        case 'STUDENT':
        default:
          roleEnum = UserRole.STUDENT;
          break;
      }

      await userRepository.updateUserRole(uid, roleEnum);
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role');
    }
  }

  Future<void> addUserToFirestore(
      String uid, String email, String firstName, String lastName) async {
    try {
      await userRepository.addUserToFirestore(
          uid, email, firstName, lastName);
    } catch (e) {
      print('Error adding user to Firestore: $e');
      throw Exception('Failed to add user');
    }
  }

  Future<void> enrollInCourse(String userId, Course course) async {
    await userRepository.enrollInCourse(userId, course);
  }

  Future<void> disenrollFromCourse(String userId, Course course) async {
    await userRepository.disenrollFromCourse(userId, course);
  }
}
