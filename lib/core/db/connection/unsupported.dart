import 'package:drift/drift.dart';

/// どのプラットフォームにも当てはまらなかった場合の実装。
///
/// 条件付き import はどれにも一致しないときの既定値を要求するので
/// 用意しているだけで、実際に呼ばれることはない想定。
Future<QueryExecutor> openConnection() {
  throw UnsupportedError('このプラットフォームでは DB を開けません');
}
