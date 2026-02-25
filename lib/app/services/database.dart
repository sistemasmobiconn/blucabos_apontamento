import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('ProductionOrderEntity')
class ProductionOrders extends Table {
  IntColumn get codEmpresa => integer()();
  IntColumn get numOrdem => integer()();
  TextColumn get codProduto => text()();
  TextColumn get nomeProduto => text()();
  TextColumn get codUnidMedida => text()();
  IntColumn get qtdPlanejada => integer()();
  IntColumn get qtdProduzida => integer()();
  TextColumn get codCentTrab => text()();
  TextColumn get codMaquina => text()();
  TextColumn get denRecurso => text()();
  DateTimeColumn get inicio => dateTime()();
  BoolColumn get informaQtdFios => boolean()();

  @override
  Set<Column> get primaryKey => {codEmpresa, numOrdem, codMaquina};
}

@DriftDatabase(tables: [ProductionOrders])
class AppDatabase extends _$AppDatabase {

  factory AppDatabase() {
    return _instance;
  }
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._internal();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(
              productionOrders,
              productionOrders.informaQtdFios,
            );
          }
          if (from < 3) {
            await m.drop(productionOrders);
            await m.create(productionOrders);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_database.db');
  }
}
