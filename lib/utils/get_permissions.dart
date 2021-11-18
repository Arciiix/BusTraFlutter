import 'package:bustra/utils/exceptions.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> getPermissions() async {
  print("DEBUG_PERMISSIONS:");
  PermissionStatus locationStatus = await Permission.location.status;
  print("Location: $locationStatus");
  if (!locationStatus.isGranted) {
    await Permission.location.request();
    await getPermissions();
  }
  if (locationStatus.isPermanentlyDenied) {
    //User has denied the basic permission - throw an error
    throw PermissionException(
        "Nie zezwolono na dostęp do lokalizacji - wejdź w ustawienia i przywróć wartości domyślne/zezwól na dostęp");
  }
  PermissionStatus backgroundLocationStatus =
      await Permission.locationAlways.status;
  print("Background_location: $backgroundLocationStatus");
  if (!backgroundLocationStatus.isGranted) {
    await Permission.locationAlways.request();
    await getPermissions();
  }
  if (backgroundLocationStatus.isPermanentlyDenied) {
    //User has denied the basic permission - throw an error
    throw PermissionException(
        "Nie zezwolono na dostęp do lokalizacji w tle - wejdź w ustawienia i przywróć wartości domyślne/zezwól na dostęp");
  }
}
