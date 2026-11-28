import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/design_tokens.dart';
import '../models/astrologer.dart';
import '../services/astrologer_service.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import 'screens.dart';

/// Astrologer workspace, Phase 10.
///
/// The workspace for Hans Ojha, the astrologer the app is
/// built for. His profile comes from his real record in the
/// `astrologers` collection, document id `hans-ojha`, never
/// from a hardcoded string in this widget. Chat opens his
/// assigned chat room; Call dials the phone saved on his
/// record. Anything he has not provided yet, photo, bio,
/// languages, experience, rate, is shown as "not provided
/// yet", never filled with invented content. There is no AI
/// astrology here: the workspace is a room to reach the
/// human astrologer.
class AstrologerWorkspaceScreen extends StatelessWidget {
  const AstrologerWorkspaceScreen({
    super.key,
    required this.firestore,
    required this.currentUserId,
    this.astrologerService,
    this.chatService,
  });

  final FirestoreService firestore;

  /// Signed in user id, or null when signed out. Chat and
  /// call need a signed in user for the chat room.
  final String? currentUserId;

  final AstrologerService? astrologerService;
  final ChatService? chatService;

  AstrologerService get _astrologers =>
      astrologerService ?? AstrologerService(firestore: firestore);

  ChatService get _chat =>
      chatService ?? ChatService(firestore: firestore);

  Future<void> _openChat(BuildContext context, Astrologer astrologer) async {
    final String? uid = currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to chat.')),
      );
      return;
    }
    final String chatId = AstrologerService.chatIdForUser(uid);
    await _astrologers.assignChatToHansOjha(chatId: chatId, uid: uid);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          chatId: chatId,
          title: astrologer.name,
          currentUserId: uid,
          senderRole: 'user',
          participantIds: <String>[uid, astrologer.id],
          astrologerName: astrologer.name,
          firestore: firestore,
          chatService: _chat,
        ),
      ),
    );
  }

  Future<void> _call(BuildContext context, Astrologer astrologer) async {
    final Uri? uri = AstrologerService.callUri(astrologer);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No phone number yet for ${astrologer.name}.',
          ),
        ),
      );
      return;
    }
    final bool opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the dialer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Astrologer')),
      body: StreamBuilder<Astrologer?>(
        stream: _astrologers.watchHansOjha(),
        builder: (BuildContext context, AsyncSnapshot<Astrologer?> snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Text(
                  'The astrologer could not be loaded.',
                  style: AppTextStyles.themed(context, AppTextStyles.body),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Null here is a real value, not loading: the record
          // does not exist yet. hasData is false for a null
          // value, so the loading check above uses the
          // connection state instead.
          final Astrologer? astrologer = snap.data;
          if (astrologer == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Text(
                  'Hans Ojha has not been added yet. The owner adds '
                  'his record from Manage Astrologers in the admin app.',
                  style: AppTextStyles.themed(context, AppTextStyles.body),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: astrologer.hasPhoto
                        ? NetworkImage(astrologer.photoUrl!)
                        : null,
                    child: astrologer.hasPhoto
                        ? null
                        : const Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          astrologer.name,
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.title,
                          ),
                        ),
                        Text(
                          'Astrologer',
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.bodySmall,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (!astrologer.hasPhoto)
                          Text(
                            'Photo not provided yet',
                            style: AppTextStyles.themed(
                              context,
                              AppTextStyles.bodySmall,
                            ),
                          ),
                        Text(
                          'Status: ${astrologer.status}',
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(
                label: 'Bio',
                value: astrologer.bio,
                emptyText: 'Bio not provided yet',
              ),
              _DetailRow(
                label: 'Languages',
                value: astrologer.languages,
                emptyText: 'Languages not provided yet',
              ),
              _DetailRow(
                label: 'Qualifications',
                value: astrologer.qualifications,
                emptyText: 'Qualifications not provided yet',
              ),
              _DetailRow(
                label: 'Experience',
                value: astrologer.experience,
                emptyText: 'Experience not provided yet',
              ),
              _DetailRow(
                label: 'Phone',
                value: astrologer.phone,
                emptyText: 'Phone number not provided yet',
              ),
              _DetailRow(
                label: 'Rate',
                value: astrologer.rate,
                emptyText: 'Rate to be decided',
              ),
              if (astrologer.hasSpecialities) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Specialities',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.subtitle,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...astrologer.specialities!.map(
                  (String item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      item,
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.body,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: astrologer.chatAvailable
                          ? () => _openChat(context, astrologer)
                          : null,
                      icon: const Icon(Icons.chat),
                      label: Text('Chat with ${astrologer.name}'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: astrologer.callAvailable
                          ? () => _call(context, astrologer)
                          : null,
                      icon: const Icon(Icons.call),
                      label: Text('Call ${astrologer.name}'),
                    ),
                  ),
                ],
              ),
              if (!astrologer.chatAvailable || !astrologer.callAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Chat and call open here once the owner turns them on for this astrologer.',
                    style: AppTextStyles.themed(
                      context,
                      AppTextStyles.bodySmall,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Still needed from ${astrologer.name}',
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.subtitle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (astrologer.missingDetails.isEmpty)
                Text(
                  'All details provided.',
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.body,
                  ),
                )
              else
                ...astrologer.missingDetails.map(
                  (String label) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      '$label: not provided yet',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.body,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.emptyText,
  });

  final String label;
  final String? value;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        '$label: ${value ?? emptyText}',
        style: AppTextStyles.themed(context, AppTextStyles.body),
      ),
    );
  }
}
