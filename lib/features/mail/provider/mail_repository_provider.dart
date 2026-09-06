import 'package:bakiru/features/mail/repository/gmail_mail_repository.dart';
import 'package:bakiru/features/mail/repository/mail_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gmail 連携の実装を画面へ渡す Provider。
final mailRepositoryProvider = Provider<MailRepository>((ref) {
  final repository = GmailMailRepository();

  // 画面が閉じられたあともサインイン状態の監視が残らないようにする。
  ref.onDispose(repository.dispose);

  return repository;
});

/// Gmail にサインインしているかどうかを流す Provider。
///
/// Web ではサインインが「ボタンを押した結果あとから起きること」なので、
/// 一度きりの結果ではなく変化を受け取れる形にしている。
final gmailSignedInProvider = StreamProvider<bool>((ref) {
  return ref.watch(mailRepositoryProvider).watchSignedIn();
});
