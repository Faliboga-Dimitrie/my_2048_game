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

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastPlayedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE'];
}
