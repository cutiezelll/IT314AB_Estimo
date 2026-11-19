import 'package:postgres/postgres.dart';

import 'db_config.dart';

class DbConnection {
  static Connection? _connection;

  static Future<Connection> getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    _connection = await Connection.open(
      Endpoint(
        host: DbConfig.host,
        port: DbConfig.port,
        database: DbConfig.database,
        username: DbConfig.username,
        password: DbConfig.password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.require,
        connectTimeout: Duration(seconds: 20),
      ),
    );

    return _connection!;
  }

  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
