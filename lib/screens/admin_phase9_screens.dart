import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/admin_metrics.dart';

/// Phase 9 admin screens. Every screen reads and writes real
/// Firestore documents through FirestoreService. No screen
/// invents a value: empty collections show honest empty states,
/// prices stay "Price to be decided", and a feature that has no
/// source data says so instead of showing a made up number.
String _s(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is String ? value : '';
}

double _n(Map<String, dynamic> doc, String key) {
  final Object? value = doc[key];
  return value is num ? value.toDouble() : 0;
}

String _stamp(Object? value) {
  if (value is Timestamp) {
    final DateTime at = value.toDate();
    final String hh = at.hour.toString().padLeft(2, '0');
    final String mm = at.minute.toString().padLeft(2, '0');
    return '${at.day} ${_months9[at.month - 1]} ${at.year}, $hh:$mm';
  }
  if (value is String && value.isNotEmpty) return value;
  return '';
}

const List<String> _months9 = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class _Pill9 extends StatelessWidget {
  const _Pill9({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.themed(
          context,
          AppTextStyles.caption.copyWith(color: color),
        ),
      ),
    );
  }
}

Color _statusColor9(String status) {
  return switch (status) {
    'active' || 'Active' || 'Published' || 'published' || 'Approved' ||
    'approved' || 'Paid' || 'paid' || 'Sent' || 'sent' || 'completed' ||
    'assigned' || 'verified' || 'owner' =>
      AppColors.good,
    'waiting' || 'Draft' || 'draft' || 'Pending' || 'pending' ||
    'Scheduled' || 'scheduled' || 'Escalated' || 'escalated' ||
    'disputed' || 'booked' =>
      AppColors.saffron2,
    'Failed' || 'failed' || 'Removed' || 'removed' || 'Rejected' ||
    'rejected' || 'cancelled' || 'suspended' || 'revoked' =>
      AppColors.maroon,
    _ => AppColors.ink3,
  };
}

class _Empty9 extends StatelessWidget {
  const _Empty9({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: <Widget>[
          const Icon(Icons.wb_sunny, size: 48, color: AppColors.saffron),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.themed(context, AppTextStyles.title)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.themed(context, AppTextStyles.body),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget _field9({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
  String? hint,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Future<bool> _confirm9(
  BuildContext context,
  String title,
  String body,
  String action,
) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void _toast9(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<void> _audit(
  FirestoreService firestore,
  String action,
  String target,
  String detail,
) async {
  try {
    await firestore.logAudit(
      actor: 'owner',
      action: action,
      target: target,
      detail: detail,
    );
  } catch (_) {
    // Audit logging never blocks the admin action itself.
  }
}

/// User management. List, search, filter, profile, status,
/// verification, suspension, and account history from the audit
/// log. The owner writes status and verification here; the
/// rules allow an owner write to a user document.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Users',
          style: AppTextStyles.themed(context, AppTextStyles.display),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: (String value) =>
              setState(() => _query = value.toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Search by name or email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'All', label: Text('All')),
              ButtonSegment<String>(value: 'active', label: Text('Active')),
              ButtonSegment<String>(
                  value: 'suspended', label: Text('Suspended')),
              ButtonSegment<String>(
                  value: 'verified', label: Text('Verified')),
              ButtonSegment<String>(
                  value: 'unverified', label: Text('Unverified')),
            ],
            selected: <String>{_filter},
            onSelectionChanged: (Set<String> value) =>
                setState(() => _filter = value.first),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('users'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (snap.hasError) {
              return const Text('Users could not be loaded.');
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_filter == 'active' || _filter == 'suspended') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      _s(d, 'status') == _filter)
                  .toList();
            } else if (_filter == 'verified') {
              docs = docs
                  .where((Map<String, dynamic> d) => d['verified'] == true)
                  .toList();
            } else if (_filter == 'unverified') {
              docs = docs
                  .where((Map<String, dynamic> d) => d['verified'] != true)
                  .toList();
            }
            if (_query.isNotEmpty) {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      (_s(d, 'name') + _s(d, 'email'))
                          .toLowerCase()
                          .contains(_query))
                  .toList();
            }
            if (docs.isEmpty) {
              if (snap.data!.isEmpty) {
                return const _Empty9(
                  title: 'No users yet',
                  body: 'Users appear here once someone creates a profile.',
                );
              }
              return const _Empty9(
                title: 'No user matches this search.',
                body: 'Try a different name, email, or filter.',
              );
            }
            return Card(
              child: Column(
                children: docs.map((Map<String, dynamic> doc) {
                  final String name = _s(doc, 'name');
                  final String email = _s(doc, 'email');
                  final String status =
                      _s(doc, 'status').isEmpty ? 'active' : _s(doc, 'status');
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        name.isEmpty
                            ? '?'
                            : name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(name.isEmpty ? email : name),
                    subtitle: Text(
                      '${email.isEmpty ? 'Email not set' : email}  •  ${_stamp(doc['createdAt'])}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (doc['verified'] == true)
                          const _Pill9(
                            label: 'verified',
                            color: AppColors.good,
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        _Pill9(
                          label: status,
                          color: _statusColor9(status),
                        ),
                      ],
                    ),
                    onTap: () => _showDetail(context, doc),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showDetail(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    final String id = _s(doc, 'id');
    final String status =
        _s(doc, 'status').isEmpty ? 'active' : _s(doc, 'status');
    final bool verified = doc['verified'] == true;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_s(doc, 'name').isEmpty ? _s(doc, 'email') : _s(doc, 'name')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Email: ${_s(doc, 'email')}'),
                Text('Phone: ${_s(doc, 'phoneNumber').isEmpty ? 'Not set' : _s(doc, 'phoneNumber')}'),
                Text('Language: ${_s(doc, 'language').isEmpty ? 'Not set' : _s(doc, 'language')}'),
                Text('Status: $status'),
                Text('Verified: ${verified ? 'Yes' : 'No'}'),
                Text('Joined: ${_stamp(doc['createdAt'])}'),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Account history',
                  style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: widget.firestore.watchDocs('audit_logs'),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snap,
                  ) {
                    if (!snap.hasData) {
                      return const Text('Loading history');
                    }
                    final List<Map<String, dynamic>> entries = snap.data!
                        .where((Map<String, dynamic> d) =>
                            _s(d, 'target') == id)
                        .toList();
                    if (entries.isEmpty) {
                      return const Text('No history yet.');
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.take(10).map((Map<String, dynamic> e) {
                        return Text(
                          '${_s(e, 'action')}  •  ${_stamp(e['createdAt'])}',
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await widget.firestore.saveDoc('users', id,
                    <String, Object?>{'verified': !verified});
                await _audit(widget.firestore, 'user_verification', id,
                    verified ? 'Verification removed.' : 'User verified.');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast9(
                    context,
                    verified ? 'Verification removed.' : 'User verified.',
                  );
                }
              },
              child: Text(verified ? 'Remove verification' : 'Mark verified'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String next =
                    status == 'suspended' ? 'active' : 'suspended';
                final bool ok = await _confirm9(
                  context,
                  next == 'suspended'
                      ? 'Suspend this user?'
                      : 'Reactivate this user?',
                  _s(doc, 'name').isEmpty
                      ? _s(doc, 'email')
                      : _s(doc, 'name'),
                  next == 'suspended' ? 'Suspend' : 'Reactivate',
                );
                if (!ok) return;
                await widget.firestore.saveDoc(
                    'users', id, <String, Object?>{'status': next});
                await _audit(widget.firestore, 'user_$next', id,
                    'User status changed to $next.');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast9(context, 'User $next.');
                }
              },
              child: Text(status == 'suspended' ? 'Reactivate' : 'Suspend'),
            ),
          ],
        );
      },
    );
  }
}

/// Admin team management. Owner, Super Admin, Admin, Staff
/// roles, invitations, access revocation, and the audit trail.
/// An invite only records the invitation: the invitee signs
/// in once in the admin app, then the owner sets the role here.
class AdminTeamScreen extends StatefulWidget {
  const AdminTeamScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<AdminTeamScreen> createState() => _AdminTeamScreenState();
}

class _AdminTeamScreenState extends State<AdminTeamScreen> {
  static const List<String> _roles = <String>[
    'owner',
    'super_admin',
    'admin',
    'staff',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Admin Team',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showInvite(context),
              child: const Text('Invite admin'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('admins'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data!.isEmpty) {
              return const _Empty9(
                title: 'No admin records yet',
                body: 'Admin records appear here once an admin signs in.',
              );
            }
            return Card(
              child: Column(
                children: snap.data!.map((Map<String, dynamic> doc) {
                  final String role = _s(doc, 'role');
                  return ListTile(
                    title: Text(_s(doc, 'email')),
                    subtitle: Text('Joined ${_stamp(doc['createdAt'])}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _Pill9(
                          label: role.isEmpty ? 'admin' : role,
                          color: _statusColor9(role),
                        ),
                        TextButton(
                          onPressed: () => _changeRole(context, doc),
                          child: const Text('Change role'),
                        ),
                        TextButton(
                          onPressed: () => _revoke(context, doc),
                          child: const Text('Revoke access'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Invitations',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('admin_invites'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data!.isEmpty) {
              return const Text('No invitations yet.');
            }
            return Card(
              child: Column(
                children: snap.data!.map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(_s(doc, 'email')),
                    subtitle: Text(
                      'Role ${_s(doc, 'role')}  •  ${_stamp(doc['createdAt'])}',
                    ),
                    trailing: _Pill9(
                      label: _s(doc, 'status').isEmpty
                          ? 'pending'
                          : _s(doc, 'status'),
                      color: _statusColor9(_s(doc, 'status')),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Audit trail',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('audit_logs'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data!.isEmpty) {
              return const Text('No audit entries yet.');
            }
            return Card(
              child: Column(
                children: snap.data!.take(30).map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(
                      '${_s(doc, 'action')}  •  ${_s(doc, 'target')}',
                    ),
                    subtitle: Text(
                      '${_s(doc, 'detail')}  •  ${_stamp(doc['createdAt'])}',
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showInvite(BuildContext context) async {
    final TextEditingController email = TextEditingController();
    String role = 'admin';
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            return AlertDialog(
              title: const Text('Invite admin'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _field9(label: 'Email', controller: email),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration:
                        const InputDecoration(labelText: 'Role'),
                    items: _roles
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) setDialog(() => role = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'The invitee signs in once in the admin app, then the owner sets the role here.',
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String address = email.text.trim();
                    if (address.isEmpty) return;
                    await widget.firestore.saveDoc(
                      'admin_invites',
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      <String, Object?>{
                        'email': address,
                        'role': role,
                        'status': 'pending',
                        'invitedBy': 'owner',
                      },
                      isNew: true,
                    );
                    await _audit(
                      widget.firestore,
                      'admin_invited',
                      address,
                      'Invited as $role.',
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _toast9(context, 'Invitation saved.');
                    }
                  },
                  child: const Text('Save invitation'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changeRole(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    String role = _s(doc, 'role').isEmpty ? 'admin' : _s(doc, 'role');
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            return AlertDialog(
              title: Text('Role for ${_s(doc, 'email')}'),
              content: DropdownButtonFormField<String>(
                initialValue: _roles.contains(role) ? role : 'admin',
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) setDialog(() => role = value);
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await widget.firestore.saveDoc('admins', _s(doc, 'id'),
                        <String, Object?>{'role': role});
                    await _audit(widget.firestore, 'admin_role_changed',
                        _s(doc, 'email'), 'Role changed to $role.');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _toast9(context, 'Role changed to $role.');
                    }
                  },
                  child: const Text('Save role'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _revoke(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    final bool ok = await _confirm9(
      context,
      'Revoke access?',
      _s(doc, 'email'),
      'Revoke access',
    );
    if (!ok) return;
    await widget.firestore.saveDoc(
      'admins',
      _s(doc, 'id'),
      <String, Object?>{'role': 'revoked'},
    );
    await _audit(widget.firestore, 'admin_revoked', _s(doc, 'email'),
        'Admin access revoked.');
    if (context.mounted) {
      _toast9(context, 'Access revoked.');
    }
  }
}

/// Astrology library management. Interpretations, yogas, doshas,
/// remedies, mantras, gemstones, numerology rules, and matching
/// rules, each with a category, a source, and a reference. The
/// owner writes the content; nothing is prefilled.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const List<String> _types = <String>[
    'Interpretation',
    'Yoga',
    'Dosha',
    'Remedy',
    'Mantra',
    'Gemstone',
    'Numerology',
    'Matching Rule',
  ];

  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Astrology Library',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showForm(context, null),
              child: const Text('New entry'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: (String value) =>
              setState(() => _query = value.toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Search by title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: <ButtonSegment<String>>[
              const ButtonSegment<String>(value: 'All', label: Text('All')),
              ..._types.map(
                (String t) =>
                    ButtonSegment<String>(value: t, label: Text(t)),
              ),
            ],
            selected: <String>{_filter},
            onSelectionChanged: (Set<String> value) =>
                setState(() => _filter = value.first),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('library_items'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_filter != 'All') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      _s(d, 'type') == _filter)
                  .toList();
            }
            if (_query.isNotEmpty) {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      (_s(d, 'title') + _s(d, 'category'))
                          .toLowerCase()
                          .contains(_query))
                  .toList();
            }
            if (docs.isEmpty) {
              if (snap.data!.isEmpty) {
                return const _Empty9(
                  title: 'No library entries yet',
                  body: 'Add the first interpretation, yoga, dosha, remedy, mantra, gemstone, numerology rule, or matching rule.',
                );
              }
              return const _Empty9(
                title: 'No entry matches this search.',
                body: 'Try a different title or type.',
              );
            }
            return Card(
              child: Column(
                children: docs.map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(_s(doc, 'title')),
                    subtitle: Text(
                      '${_s(doc, 'type')}  •  ${_s(doc, 'category')}  •  Source ${_s(doc, 'source').isEmpty ? 'Not set' : _s(doc, 'source')}',
                    ),
                    trailing: _Pill9(
                      label: _s(doc, 'status').isEmpty
                          ? 'draft'
                          : _s(doc, 'status'),
                      color: _statusColor9(_s(doc, 'status')),
                    ),
                    onTap: () => _showForm(context, doc),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showForm(
    BuildContext context,
    Map<String, dynamic>? doc,
  ) async {
    final TextEditingController title =
        TextEditingController(text: doc == null ? '' : _s(doc, 'title'));
    final TextEditingController category =
        TextEditingController(text: doc == null ? '' : _s(doc, 'category'));
    final TextEditingController content =
        TextEditingController(text: doc == null ? '' : _s(doc, 'content'));
    final TextEditingController source =
        TextEditingController(text: doc == null ? '' : _s(doc, 'source'));
    final TextEditingController reference = TextEditingController(
        text: doc == null ? '' : _s(doc, 'reference'));
    String type =
        doc == null ? _types.first : _s(doc, 'type');
    if (!_types.contains(type)) type = _types.first;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            return AlertDialog(
              title: Text(doc == null ? 'New entry' : _s(doc, 'title')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _field9(label: 'Title', controller: title),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration:
                          const InputDecoration(labelText: 'Type'),
                      items: _types
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) setDialog(() => type = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _field9(label: 'Category', controller: category),
                    _field9(
                      label: 'Content',
                      controller: content,
                      maxLines: 5,
                    ),
                    _field9(label: 'Source', controller: source),
                    _field9(label: 'Reference', controller: reference),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (doc != null)
                  TextButton(
                    onPressed: () async {
                      final String next =
                          _s(doc, 'status') == 'published'
                              ? 'draft'
                              : 'published';
                      await widget.firestore.saveDoc('library_items',
                          _s(doc, 'id'), <String, Object?>{'status': next});
                      await _audit(widget.firestore, 'library_$next',
                          _s(doc, 'title'), 'Library entry $next.');
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        _toast9(context, 'Entry $next.');
                      }
                    },
                    child: Text(
                      _s(doc, 'status') == 'published'
                          ? 'Unpublish'
                          : 'Publish',
                    ),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.text.trim().isEmpty) return;
                    await widget.firestore.saveDoc(
                      'library_items',
                      doc == null
                          ? DateTime.now()
                              .millisecondsSinceEpoch
                              .toString()
                          : _s(doc, 'id'),
                      <String, Object?>{
                        'title': title.text.trim(),
                        'type': type,
                        'category': category.text.trim(),
                        'content': content.text.trim(),
                        'source': source.text.trim(),
                        'reference': reference.text.trim(),
                        'status': doc == null
                            ? 'draft'
                            : _s(doc, 'status'),
                      },
                      isNew: doc == null,
                    );
                    await _audit(widget.firestore, 'library_saved',
                        title.text.trim(), 'Library entry saved as $type.');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _toast9(context, 'Entry saved as draft.');
                    }
                  },
                  child: const Text('Save entry'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Calculation configuration. Ayanamsha, zodiac system, house
/// system, node mode, panchang config, regional settings, and
/// effective dates, kept as versions. A version becomes active
/// only after AdminMetrics.validateCalcConfig passes. Activating
/// a version supersedes the version that was active before it,
/// so the full version history stays in the collection.
class CalcConfigScreen extends StatefulWidget {
  const CalcConfigScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<CalcConfigScreen> createState() => _CalcConfigScreenState();
}

class _CalcConfigScreenState extends State<CalcConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Calculation Config',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showForm(context, null),
              child: const Text('New version'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Only a validated version can be active. Unvalidated changes are never applied.',
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('calc_configs'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data!.isEmpty) {
              return const _Empty9(
                title: 'No calculation version yet',
                body: 'Create the first version with an ayanamsha, zodiac system, house system, node mode, region, and effective date.',
              );
            }
            return Card(
              child: Column(
                children: snap.data!.map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(
                      'Version ${_s(doc, 'version')}  •  ${_s(doc, 'ayanamsha')}',
                    ),
                    subtitle: Text(
                      '${_s(doc, 'zodiacSystem')}  •  ${_s(doc, 'houseSystem')}  •  ${_s(doc, 'nodeMode')}  •  ${_s(doc, 'region')}  •  Effective ${_s(doc, 'effectiveDate')}',
                    ),
                    trailing: _Pill9(
                      label: _s(doc, 'status').isEmpty
                          ? 'draft'
                          : _s(doc, 'status'),
                      color: _statusColor9(_s(doc, 'status')),
                    ),
                    onTap: () => _showForm(context, doc),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showForm(
    BuildContext context,
    Map<String, dynamic>? doc,
  ) async {
    final TextEditingController version = TextEditingController(
        text: doc == null ? '' : _s(doc, 'version'));
    final TextEditingController region = TextEditingController(
        text: doc == null ? '' : _s(doc, 'region'));
    final TextEditingController panchang = TextEditingController(
        text: doc == null ? '' : _s(doc, 'panchangConfig'));
    String ayanamsha = doc == null
        ? AdminMetrics.ayanamshas.first
        : _s(doc, 'ayanamsha');
    if (!AdminMetrics.ayanamshas.contains(ayanamsha)) {
      ayanamsha = AdminMetrics.ayanamshas.first;
    }
    String zodiac = doc == null
        ? AdminMetrics.zodiacSystems.first
        : _s(doc, 'zodiacSystem');
    if (!AdminMetrics.zodiacSystems.contains(zodiac)) {
      zodiac = AdminMetrics.zodiacSystems.first;
    }
    String houses = doc == null
        ? AdminMetrics.houseSystems.first
        : _s(doc, 'houseSystem');
    if (!AdminMetrics.houseSystems.contains(houses)) {
      houses = AdminMetrics.houseSystems.first;
    }
    String nodes = doc == null
        ? AdminMetrics.nodeModes.first
        : _s(doc, 'nodeMode');
    if (!AdminMetrics.nodeModes.contains(nodes)) {
      nodes = AdminMetrics.nodeModes.first;
    }
    DateTime effective = DateTime.now();
    final String savedEffective = doc == null ? '' : _s(doc, 'effectiveDate');
    if (savedEffective.isNotEmpty) {
      effective = DateTime.tryParse(savedEffective) ?? DateTime.now();
    }
    String? error;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            Map<String, Object?> body() {
              return <String, Object?>{
                'version': version.text.trim(),
                'ayanamsha': ayanamsha,
                'zodiacSystem': zodiac,
                'houseSystem': houses,
                'nodeMode': nodes,
                'region': region.text.trim(),
                'panchangConfig': panchang.text.trim(),
                'effectiveDate':
                    '${effective.year}-${effective.month.toString().padLeft(2, '0')}-${effective.day.toString().padLeft(2, '0')}',
              };
            }

            Future<void> save(String status) async {
              final Map<String, Object?> data = body();
              if (status == 'active') {
                final List<String> problems =
                    AdminMetrics.validateCalcConfig(data);
                if (problems.isNotEmpty) {
                  setDialog(() => error = problems.first);
                  return;
                }
                final List<Map<String, dynamic>> existing =
                    await widget.firestore.watchDocs('calc_configs').first;
                for (final Map<String, dynamic> old in existing) {
                  if (_s(old, 'status') == 'active' &&
                      _s(old, 'id') != _s(doc ?? <String, dynamic>{}, 'id')) {
                    await widget.firestore.saveDoc('calc_configs',
                        _s(old, 'id'), <String, Object?>{'status': 'superseded'});
                  }
                }
              }
              data['status'] = status;
              await widget.firestore.saveDoc(
                'calc_configs',
                doc == null
                    ? DateTime.now().millisecondsSinceEpoch.toString()
                    : _s(doc, 'id'),
                data,
                isNew: doc == null,
              );
              await _audit(widget.firestore, 'calc_config_$status',
                  version.text.trim(), 'Calculation version $status.');
              if (context.mounted) {
                Navigator.of(context).pop();
                _toast9(context, 'Version saved as $status.');
              }
            }

            return AlertDialog(
              title: Text(
                doc == null
                    ? 'New version'
                    : 'Version ${_s(doc, 'version')}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _field9(label: 'Version', controller: version),
                    _dropdown9(
                      label: 'Ayanamsha',
                      value: ayanamsha,
                      options: AdminMetrics.ayanamshas,
                      onChanged: (String v) =>
                          setDialog(() => ayanamsha = v),
                    ),
                    _dropdown9(
                      label: 'Zodiac system',
                      value: zodiac,
                      options: AdminMetrics.zodiacSystems,
                      onChanged: (String v) =>
                          setDialog(() => zodiac = v),
                    ),
                    _dropdown9(
                      label: 'House system',
                      value: houses,
                      options: AdminMetrics.houseSystems,
                      onChanged: (String v) =>
                          setDialog(() => houses = v),
                    ),
                    _dropdown9(
                      label: 'Node mode',
                      value: nodes,
                      options: AdminMetrics.nodeModes,
                      onChanged: (String v) => setDialog(() => nodes = v),
                    ),
                    _field9(label: 'Region', controller: region),
                    _field9(
                      label: 'Panchang config',
                      controller: panchang,
                      hint: 'City and panchang notes',
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Effective ${effective.day} ${_months9[effective.month - 1]} ${effective.year}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: effective,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setDialog(() => effective = picked);
                            }
                          },
                          child: const Text('Pick date'),
                        ),
                      ],
                    ),
                    if (error != null)
                      Text(
                        error!,
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.body,
                        ).copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => save('draft'),
                  child: const Text('Save draft'),
                ),
                ElevatedButton(
                  onPressed: () => save('active'),
                  child: const Text('Activate'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Widget _dropdown9({
  required String label,
  required String value,
  required List<String> options,
  required void Function(String value) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : options.first,
      decoration: InputDecoration(labelText: label),
      items: options
          .map(
            (String option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: (String? next) {
        if (next != null) onChanged(next);
      },
    ),
  );
}

/// Content management. Articles, horoscope content, festival
/// content, and remedy content, with categories, images by URL,
/// publishing status, and a publish date. A scheduled item
/// carries its date and stays a draft until the owner publishes
/// it, so nothing reaches users without an owner tap.
class ContentManagerScreen extends StatefulWidget {
  const ContentManagerScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<ContentManagerScreen> createState() => _ContentManagerScreenState();
}

class _ContentManagerScreenState extends State<ContentManagerScreen> {
  static const List<String> _types = <String>[
    'Article',
    'Horoscope content',
    'Festival content',
    'Remedy content',
  ];

  String _query = '';
  String _filter = 'All';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Content',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showForm(context, null),
              child: const Text('New content'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: (String value) =>
              setState(() => _query = value.toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Search by title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              SegmentedButton<String>(
                segments: <ButtonSegment<String>>[
                  const ButtonSegment<String>(
                      value: 'All', label: Text('All')),
                  ..._types.map(
                    (String t) =>
                        ButtonSegment<String>(value: t, label: Text(t)),
                  ),
                ],
                selected: <String>{_filter},
                onSelectionChanged: (Set<String> value) =>
                    setState(() => _filter = value.first),
              ),
              const SizedBox(width: AppSpacing.md),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'All', label: Text('All')),
                  ButtonSegment<String>(
                      value: 'draft', label: Text('Draft')),
                  ButtonSegment<String>(
                      value: 'published', label: Text('Published')),
                  ButtonSegment<String>(
                      value: 'scheduled', label: Text('Scheduled')),
                ],
                selected: <String>{_status},
                onSelectionChanged: (Set<String> value) =>
                    setState(() => _status = value.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('content_items'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_filter != 'All') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      _s(d, 'type') == _filter)
                  .toList();
            }
            if (_status != 'All') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      _s(d, 'status') == _status)
                  .toList();
            }
            if (_query.isNotEmpty) {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      (_s(d, 'title') + _s(d, 'category'))
                          .toLowerCase()
                          .contains(_query))
                  .toList();
            }
            if (docs.isEmpty) {
              if (snap.data!.isEmpty) {
                return const _Empty9(
                  title: 'No content yet',
                  body: 'Add the first article, horoscope content, festival content, or remedy content.',
                );
              }
              return const _Empty9(
                title: 'No content matches this search.',
                body: 'Try a different title, type, or status.',
              );
            }
            return Card(
              child: Column(
                children: docs.map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(_s(doc, 'title')),
                    subtitle: Text(
                      '${_s(doc, 'type')}  •  ${_s(doc, 'category')}  •  ${_s(doc, 'publishDate')}',
                    ),
                    trailing: _Pill9(
                      label: _s(doc, 'status').isEmpty
                          ? 'draft'
                          : _s(doc, 'status'),
                      color: _statusColor9(_s(doc, 'status')),
                    ),
                    onTap: () => _showForm(context, doc),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showForm(
    BuildContext context,
    Map<String, dynamic>? doc,
  ) async {
    final TextEditingController title =
        TextEditingController(text: doc == null ? '' : _s(doc, 'title'));
    final TextEditingController category =
        TextEditingController(text: doc == null ? '' : _s(doc, 'category'));
    final TextEditingController body =
        TextEditingController(text: doc == null ? '' : _s(doc, 'body'));
    final TextEditingController imageUrl = TextEditingController(
        text: doc == null ? '' : _s(doc, 'imageUrl'));
    String type = doc == null ? _types.first : _s(doc, 'type');
    if (!_types.contains(type)) type = _types.first;
    DateTime publishDate = DateTime.now();
    final String savedDate = doc == null ? '' : _s(doc, 'publishDate');
    if (savedDate.isNotEmpty) {
      publishDate = DateTime.tryParse(savedDate) ?? DateTime.now();
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialog) {
            Future<void> save(String status) async {
              if (title.text.trim().isEmpty) return;
              await widget.firestore.saveDoc(
                'content_items',
                doc == null
                    ? DateTime.now().millisecondsSinceEpoch.toString()
                    : _s(doc, 'id'),
                <String, Object?>{
                  'title': title.text.trim(),
                  'type': type,
                  'category': category.text.trim(),
                  'body': body.text.trim(),
                  'imageUrl': imageUrl.text.trim(),
                  'publishDate':
                      '${publishDate.year}-${publishDate.month.toString().padLeft(2, '0')}-${publishDate.day.toString().padLeft(2, '0')}',
                  'status': status,
                },
                isNew: doc == null,
              );
              await _audit(widget.firestore, 'content_$status',
                  title.text.trim(), 'Content $status.');
              if (context.mounted) {
                Navigator.of(context).pop();
                _toast9(context, 'Content $status.');
              }
            }

            return AlertDialog(
              title: Text(doc == null ? 'New content' : _s(doc, 'title')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _field9(label: 'Title', controller: title),
                    _dropdown9(
                      label: 'Type',
                      value: type,
                      options: _types,
                      onChanged: (String v) =>
                          setDialog(() => type = v),
                    ),
                    _field9(label: 'Category', controller: category),
                    _field9(
                      label: 'Content',
                      controller: body,
                      maxLines: 6,
                    ),
                    _field9(
                      label: 'Image URL',
                      controller: imageUrl,
                      hint: 'Leave blank when there is no image',
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Publish date ${publishDate.day} ${_months9[publishDate.month - 1]} ${publishDate.year}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: publishDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setDialog(() => publishDate = picked);
                            }
                          },
                          child: const Text('Pick date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => save('draft'),
                  child: const Text('Save draft'),
                ),
                TextButton(
                  onPressed: () => save('scheduled'),
                  child: const Text('Schedule'),
                ),
                ElevatedButton(
                  onPressed: () => save('published'),
                  child: const Text('Publish'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Consultation management. Bookings, assignment to an
/// astrologer, cancellation, disputes, status, and history.
/// History is a list on the booking document, one entry per
/// status change, with the time and the actor.
class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key, required this.firestore});

  final FirestoreService firestore;

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Consultations',
                style: AppTextStyles.themed(context, AppTextStyles.display),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showBookingForm(context),
              child: const Text('New booking'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'All', label: Text('All')),
              ButtonSegment<String>(value: 'booked', label: Text('Booked')),
              ButtonSegment<String>(
                  value: 'assigned', label: Text('Assigned')),
              ButtonSegment<String>(
                  value: 'completed', label: Text('Completed')),
              ButtonSegment<String>(
                  value: 'cancelled', label: Text('Cancelled')),
              ButtonSegment<String>(
                  value: 'disputed', label: Text('Disputed')),
            ],
            selected: <String>{_filter},
            onSelectionChanged: (Set<String> value) =>
                setState(() => _filter = value.first),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('consultations'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_filter != 'All') {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      _s(d, 'status') == _filter)
                  .toList();
            }
            if (docs.isEmpty) {
              if (snap.data!.isEmpty) {
                return const _Empty9(
                  title: 'No consultations yet',
                  body: 'Bookings appear here once a consultation is booked.',
                );
              }
              return const _Empty9(
                title: 'No consultation matches this filter.',
                body: 'Try a different status.',
              );
            }
            return Card(
              child: Column(
                children: docs.map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(
                      '${_s(doc, 'user')}  •  ${_s(doc, 'astrologer').isEmpty ? 'No astrologer yet' : _s(doc, 'astrologer')}',
                    ),
                    subtitle: Text(
                      '${_stamp(doc['createdAt'])}  •  ${_n(doc, 'durationMinutes').toInt()} minutes',
                    ),
                    trailing: _Pill9(
                      label: _s(doc, 'status').isEmpty
                          ? 'booked'
                          : _s(doc, 'status'),
                      color: _statusColor9(_s(doc, 'status')),
                    ),
                    onTap: () => _showDetail(context, doc),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    Map<String, dynamic> doc,
    String status,
    Map<String, Object?> extra,
  ) async {
    final Map<String, dynamic>? current =
        await widget.firestore.getDoc('consultations', _s(doc, 'id'));
    final List<dynamic> history =
        List<dynamic>.from(current?['history'] as List<dynamic>? ?? <dynamic>[]);
    history.add(<String, Object?>{
      'status': status,
      'by': 'owner',
      'at': DateTime.now().toIso8601String(),
    });
    await widget.firestore.saveDoc(
      'consultations',
      _s(doc, 'id'),
      <String, Object?>{'status': status, 'history': history, ...extra},
    );
    await _audit(widget.firestore, 'consultation_$status', _s(doc, 'id'),
        'Consultation $status.');
  }

  Future<void> _showDetail(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    String astrologer = _s(doc, 'astrologer');
    final TextEditingController minutes = TextEditingController(
      text: _n(doc, 'durationMinutes') == 0
          ? ''
          : _n(doc, 'durationMinutes').toInt().toString(),
    );
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('astrologers'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            final List<String> names = snap.hasData
                ? snap.data!
                    .map((Map<String, dynamic> d) => _s(d, 'name'))
                    .where((String name) => name.isNotEmpty)
                    .toList()
                : <String>[];
            if (astrologer.isNotEmpty && !names.contains(astrologer)) {
              names.add(astrologer);
            }
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialog) {
                final List<dynamic> history =
                    doc['history'] as List<dynamic>? ?? <dynamic>[];
                return AlertDialog(
                  title: Text(_s(doc, 'user')),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Status: ${_s(doc, 'status')}'),
                        Text(
                          'Astrologer: ${astrologer.isEmpty ? 'No astrologer yet' : astrologer}',
                        ),
                        Text('Note: ${_s(doc, 'note')}'),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: astrologer.isEmpty
                              ? null
                              : astrologer,
                          decoration: const InputDecoration(
                            labelText: 'Assign astrologer',
                          ),
                          items: names
                              .map(
                                (String name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setDialog(() => astrologer = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _field9(
                          label: 'Duration in minutes',
                          controller: minutes,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'History',
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.subtitle,
                          ),
                        ),
                        if (history.isEmpty)
                          const Text('No history yet.')
                        else
                          ...history.map((dynamic entry) {
                            final Map<String, dynamic> row =
                                entry is Map<String, dynamic>
                                    ? entry
                                    : <String, dynamic>{};
                            return Text(
                              '${_s(row, 'status')}  •  ${_s(row, 'at')}',
                            );
                          }),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final bool ok = await _confirm9(
                          context,
                          'Cancel this consultation?',
                          _s(doc, 'user'),
                          'Cancel',
                        );
                        if (!ok) return;
                        await _changeStatus(
                          context,
                          doc,
                          'cancelled',
                          <String, Object?>{},
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          _toast9(context, 'Consultation cancelled.');
                        }
                      },
                      child: const Text('Cancel booking'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _changeStatus(context, doc, 'disputed',
                            <String, Object?>{});
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          _toast9(context, 'Consultation disputed.');
                        }
                      },
                      child: const Text('Mark disputed'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final int mins =
                            int.tryParse(minutes.text.trim()) ?? 0;
                        await _changeStatus(
                          context,
                          doc,
                          astrologer.isEmpty ? 'booked' : 'assigned',
                          <String, Object?>{
                            'astrologer': astrologer,
                            'durationMinutes': mins,
                          },
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          _toast9(
                            context,
                            astrologer.isEmpty
                                ? 'Booking saved.'
                                : 'Astrologer assigned.',
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showBookingForm(BuildContext context) async {
    final TextEditingController user = TextEditingController();
    final TextEditingController note = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _field9(label: 'User', controller: user),
              _field9(label: 'Note', controller: note),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (user.text.trim().isEmpty) return;
                await widget.firestore.saveDoc(
                  'consultations',
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  <String, Object?>{
                    'user': user.text.trim(),
                    'astrologer': '',
                    'note': note.text.trim(),
                    'status': 'booked',
                    'durationMinutes': 0,
                    'history': <Map<String, Object?>>[
                      <String, Object?>{
                        'status': 'booked',
                        'by': 'owner',
                        'at': DateTime.now().toIso8601String(),
                      },
                    ],
                  },
                  isNew: true,
                );
                await _audit(widget.firestore, 'consultation_booked',
                    user.text.trim(), 'Consultation booked.');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _toast9(context, 'Booking saved.');
                }
              },
              child: const Text('Save booking'),
            ),
          ],
        );
      },
    );
  }
}

/// Security and audit. Audit log list with search, role and
/// permission summary from the admins collection, and session
/// controls for the signed in admin. Ending another session
/// needs the Firebase console; this screen says so instead of
/// pretending to end sessions from the device.
class SecurityAuditScreen extends StatefulWidget {
  const SecurityAuditScreen({
    super.key,
    required this.firestore,
    required this.auth,
  });

  final FirestoreService firestore;
  final AuthService auth;

  @override
  State<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends State<SecurityAuditScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Security and Audit',
          style: AppTextStyles.themed(context, AppTextStyles.display),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Signed in as ${widget.auth.currentUserEmail ?? ''}.',
          style: AppTextStyles.themed(context, AppTextStyles.body),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Ending another session needs the Firebase console. No session is ended from here.',
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () => widget.auth.signOut(),
          child: const Text('Sign out'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Roles and permissions',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('admins'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data!.isEmpty) {
              return const Text('No admin records yet.');
            }
            return Card(
              child: Column(
                children: snap.data!.map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(_s(doc, 'email')),
                    subtitle: const Text(
                      'Owner reads and writes every admin collection. Other roles read and write only what the owner allows in the rules.',
                    ),
                    trailing: _Pill9(
                      label:
                          _s(doc, 'role').isEmpty ? 'admin' : _s(doc, 'role'),
                      color: _statusColor9(_s(doc, 'role')),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Audit logs',
          style: AppTextStyles.themed(context, AppTextStyles.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          onChanged: (String value) =>
              setState(() => _query = value.toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Search by action, target, or detail',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: widget.firestore.watchDocs('audit_logs'),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snap,
          ) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> docs = snap.data!;
            if (_query.isNotEmpty) {
              docs = docs
                  .where((Map<String, dynamic> d) =>
                      (_s(d, 'action') + _s(d, 'target') + _s(d, 'detail'))
                          .toLowerCase()
                          .contains(_query))
                  .toList();
            }
            if (docs.isEmpty) {
              if (snap.data!.isEmpty) {
                return const _Empty9(
                  title: 'No audit entries yet',
                  body: 'Admin actions are recorded here once they run.',
                );
              }
              return const _Empty9(
                title: 'No entry matches this search.',
                body: 'Try a different action or target.',
              );
            }
            return Card(
              child: Column(
                children: docs.take(50).map((Map<String, dynamic> doc) {
                  return ListTile(
                    title: Text(
                      '${_s(doc, 'action')}  •  ${_s(doc, 'target')}',
                    ),
                    subtitle: Text(
                      '${_s(doc, 'detail')}  •  ${_s(doc, 'actor')}  •  ${_stamp(doc['createdAt'])}',
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
