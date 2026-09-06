import 'dart:async';

import 'package:bakiru/core/model/trash_item.dart';
import 'package:bakiru/features/mail/repository/mail_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Gmail 連携の本物の実装。
///
/// 要求するスコープは gmail.readonly と gmail.modify の2つだけ。
/// メールを完全削除する権限は持たない。
class GmailMailRepository implements MailRepository {
  /// 一覧の取得とゴミ箱移動に必要なスコープ。
  static const List<String> _scopes = [
    GmailApi.gmailReadonlyScope,
    GmailApi.gmailModifyScope,
  ];

  /// ごみ箱に入れてから完全消去するまでの期間。
  ///
  /// Gmail 側も30日でゴミ箱から自動削除するので、それに合わせている。
  static const Duration _keepDuration = Duration(days: 30);

  static const Uuid _uuid = Uuid();

  final StreamController<bool> _signedInController =
      StreamController<bool>.broadcast();

  bool _initialized = false;
  GoogleSignInAccount? _user;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;

  /// SDK の初期化とサインイン状態の監視を1回だけ行う。
  ///
  /// initialize() はアプリ起動時に一度呼べばよいものだが、main.dart は
  /// 担当Bの持ち物なのでここで遅延させている。呼ばれた回数に関わらず
  /// 実際の初期化は最初の1回だけ走る。
  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    // クライアント ID は web/index.html の meta タグから読まれるので、
    // ここでは渡さない。Android は SHA-1 で紐づくのでこれも不要。
    await GoogleSignIn.instance.initialize();

    _subscription = GoogleSignIn.instance.authenticationEvents.listen((event) {
      _user = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };
      _signedInController.add(_user != null);
    });
  }

  @override
  Future<void> signIn() async {
    await _ensureInitialized();

    // 前回の資格情報が残っていれば、これで黙ってサインインが完了する。
    // 残っていなければ何も起きない。Web でサインインを始めるには
    // Google が用意したボタンを押してもらう必要がある。
    await GoogleSignIn.instance.attemptLightweightAuthentication();
  }

  @override
  Stream<bool> watchSignedIn() async* {
    await _ensureInitialized();

    // 今の状態を先に1回流してから、以降の変化を流す。
    // こうしないと画面を開いた直後に何も表示できない。
    yield _user != null;
    yield* _signedInController.stream;
  }

  @override
  Future<List<TrashItem>> fetchRecent({int limit = 20}) async {
    final client = await _authorizedClient();
    try {
      final api = GmailApi(client);

      // list が返すのは ID だけなので、件名や送信者は1件ずつ取りに行く。
      final listed = await api.users.messages.list('me', maxResults: limit);
      final messages = listed.messages ?? const <Message>[];

      final items = <TrashItem>[];
      for (final message in messages) {
        final id = message.id;
        if (id == null) {
          continue;
        }
        // format: metadata にすると本文を受け取らずヘッダだけ取れる。
        // 本文を取ると「消したはずのものがアプリ内に残る」ことになるため。
        final detail = await api.users.messages.get(
          'me',
          id,
          format: 'metadata',
          metadataHeaders: ['From', 'Subject', 'Date'],
        );
        items.add(_toTrashItem(id, detail));
      }
      return items;
    } finally {
      client.close();
    }
  }

  @override
  Future<void> moveToTrash(String messageId) async {
    final client = await _authorizedClient();
    try {
      // trash は「ゴミ箱に移す」だけ。delete（完全削除）は呼ばない。
      await GmailApi(client).users.messages.trash('me', messageId);
    } finally {
      client.close();
    }
  }

  /// 使い終わったら購読を止める。
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _signedInController.close();
  }

  /// アクセストークンを載せた HTTP クライアントを作る。
  ///
  /// googleapis は「認証済みの http クライアント」を受け取る作りなので、
  /// google_sign_in から受け取ったトークンをヘッダに載せて渡す。
  Future<http.Client> _authorizedClient() async {
    await _ensureInitialized();

    final user = _user;
    if (user == null) {
      throw StateError('Gmail にサインインしていません。');
    }

    // 認可はサインインとは別物。サインイン済みでも、Gmail を読む許可は
    // 改めてもらう必要がある。すでに許可済みなら画面は出ない。
    final authorization = await user.authorizationClient.authorizeScopes(
      _scopes,
    );
    return _BearerClient(http.Client(), authorization.accessToken);
  }

  /// Gmail のメール1件を [TrashItem] に変換する。
  ///
  /// 本文は含めない。残すのは一覧に出すための最低限だけ。
  TrashItem _toTrashItem(String messageId, Message message) {
    final subject = _headerValue(message, 'Subject');
    final now = DateTime.now();

    return TrashItem(
      id: _uuid.v4(),
      type: TrashItemType.mail,
      title: subject.isEmpty ? '(件名なし)' : subject,
      addedAt: now,
      purgeAt: now.add(_keepDuration),
      payload: {
        'messageId': messageId,
        'from': _headerValue(message, 'From'),
        'subject': subject,
        'date': _headerValue(message, 'Date'),
      },
    );
  }

  /// メールのヘッダから [name] の値を取り出す。無ければ空文字。
  String _headerValue(Message message, String name) {
    final headers = message.payload?.headers ?? const <MessagePartHeader>[];
    for (final header in headers) {
      if (header.name?.toLowerCase() == name.toLowerCase()) {
        return header.value ?? '';
      }
    }
    return '';
  }
}

/// すべてのリクエストにアクセストークンを付ける HTTP クライアント。
class _BearerClient extends http.BaseClient {
  _BearerClient(this._inner, this._accessToken);

  final http.Client _inner;
  final String _accessToken;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
