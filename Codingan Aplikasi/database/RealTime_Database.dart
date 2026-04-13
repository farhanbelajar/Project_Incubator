import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL:
    "https://iotproject-6bdf3-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  static DatabaseReference ecg_monitoringRef = _db.ref("ecg_monitoring");
  static DatabaseReference detakRef = _db.ref("detak_jantung");
}
