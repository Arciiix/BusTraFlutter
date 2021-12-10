import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bustra/utils/generate_unique_id.dart';

void createNotification(title, content) {
  print("CREATE_NOTIFICATION");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: generateUniqueId(),
        channelKey: 'bustra_notifications',
        title: 'Testowe powiadomienie',
        body: 'Lorem ipsum dolor sit amet',
      ),
      actionButtons: [
        NotificationActionButton(
            key: "STOP_TRACKING", label: "Przerwij trackowanie")
      ]);
}
