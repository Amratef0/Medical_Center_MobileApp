/// بعض الـ endpoints في الباك اند بترجع array عادي زي: [ {...}, {...} ]
/// وبعضها بيرجع object فيه pagination زي: { data: [...], total, page, limit }
/// الدالة دي بتتعامل مع الحالتين وترجع الـ list بس، عشان الريبوزيتوريز
/// متتكررش نفس الكود ده في كل مكان.
List<dynamic> extractListData(dynamic responseData) {
  if (responseData is List) {
    return responseData;
  }
  if (responseData is Map && responseData['data'] is List) {
    return responseData['data'] as List<dynamic>;
  }
  return [];
}
