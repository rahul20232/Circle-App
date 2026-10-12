import '../../demo/demo_mode.dart';

/// Single source of truth for the backend address.
///
/// Demo builds (--dart-define=DEMO=true) point at a `.invalid` host, which can
/// never resolve — so even if a request slipped past the demo mock it would
/// fail immediately instead of reaching the production server.
class BackendConfig {
  BackendConfig._();

  static const String host = kDemoMode ? 'demo.invalid' : 'circle-app-production-09eb.up.railway.app';

  static const String apiUrl = 'https://$host/api';
  static const String wsUrl = 'wss://$host/api';
  static const String healthUrl = 'https://$host/health';
}
