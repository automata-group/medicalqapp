import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;
  NotificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dioClient.get('/notifications');
    final List data = response.data['data'] ?? [];
    return data.map((n) => NotificationModel.fromJson(n)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await dioClient.get('/notifications/unread-count');
    return response.data['count'] ?? 0;
  }

  @override
  Future<void> markAsRead(int id) async {
    await dioClient.put('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await dioClient.put('/notifications/read-all');
  }

  @override
  Future<void> deleteNotification(int id) async {
    await dioClient.delete('/notifications/$id');
  }
}
