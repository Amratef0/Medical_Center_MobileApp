import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/user_model.dart';

/// كل اللي يخص المستخدمين (الموظفين)، نفس /users بتاعة الباك اند.
/// متاحة غالبا للأدمن بس.
class UsersRepository {
  final _dio = ApiClient().dio;

  Future<List<UserModel>> getUsers({int page = 1, int limit = 20, String? search}) async {
    final response = await _dio.get('/users', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = extractListData(response.data);
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _dio.post('/users', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    return UserModel.fromJson(response.data);
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }
}
