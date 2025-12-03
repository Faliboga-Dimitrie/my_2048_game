import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 1, max: 50)();

  @override
  List<String> get customConstraints => ['UNIQUE(username)'];
}

class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().named('user_id')();

  TextColumn get boardState => text()();
  IntColumn get score => integer().withDefault(const Constant(0))();
  IntColumn get moveCount => integer().withDefault(const Constant(0))();

  // NEW: store board size (e.g. 4, 5, 6…)
  IntColumn get boardSize => integer().withDefault(const Constant(4))();

  // NEW: store merge mode as enum index (0 = classic, 1 = cascade)
  IntColumn get mergeMode =>
      integer().withDefault(const Constant(0))(); // 0 = classic

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastPlayedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE'];
}
