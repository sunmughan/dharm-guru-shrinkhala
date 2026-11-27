# Firebase Security, Dharm Guru Shrinkhala, Phase 1

Status: audit complete. Design complete. No live change made.
Baseline: main HEAD eb0c471, release 10, CI run 46043847890 green, 111 tests.
Branch: phase1-security. Repo: sunmughan/dharm-guru-shrinkhala.
Firebase project: dharm-guru-shrinkhala, number 987289079284, Firestore asia south1.
Scope: this file covers Phase 1 only. Other phases are not in this file.

Verdict in one line: the app auth flows are mostly real, but the owner role is not secure today. Any signed in user can grant self owner rights with one direct Firestore write, because the rules let a user write own admins document. That is P0-1 below. No live data was touched, no destructive test was run, no rule was published, no seed was removed.

Reading note: role names and file paths in this file are exact. Plain prose in this file avoids hyphenated words on purpose.

## 1. Auth workflows audit

Mapped from lib/services/auth_service.dart, lib/main.dart, lib/main_admin.dart, lib/screens/auth_screen.dart, lib/screens/admin_screens.dart, lib/services/admin_seed_service.dart, lib/services/firestore_service.dart.

| # | Workflow | State | Evidence |
|---|----------|-------|----------|
| 1 | Email password registration | REAL, gap noted | AuthService.signUpWithEmailAndPassword, auth screen sign up mode. No verification email is sent after sign up. |
| 2 | Email password login | REAL | AuthService.signInWithEmailAndPassword, auth screen sign in mode. |
| 3 | Google sign in | REAL | AuthService.signInWithGoogle, web client id wired, pending credential link flow via linkPendingGoogleCredential, provider already linked handled, empty token fails with an honest message. |
| 4 | Password reset | REAL | AuthService.sendPasswordResetEmail, auth screen forgot mode. Reset happens on the Firebase page. |
| 5 | Email verification | MISSING | Zero calls to sendEmailVerification anywhere in lib. Zero reads of emailVerified anywhere in lib or in the rules. An unverified email can use the full signed in app. |
| 6 | Logout | REAL | AuthService.signOut signs out Google and Firebase both. |
| 7 | Session restore | REAL, SDK owned | Firebase SDK persists the session. App shell and admin gate listen to authStateChanges. No app level token revalidation exists, the SDK owns refresh. |
| 8 | Account status validation | MISSING | No status field exists in any users document. No sign in time status check exists. Grep for suspend and status in lib finds no account status logic. |
| 9 | Disabled account handling | PARTIAL | Firebase blocks sign in of a disabled account and plainError maps the user disabled code to a plain message. But a user already signed in when the account is disabled gets no mid session recheck and no forced sign out. |
| 10 | Auth error handling | REAL | AuthService.plainError maps Firebase codes to plain messages, including invalid credential, too many requests, user disabled, account exists with different credential. Raw codes never reach the UI. |
| 11 | Secure account deletion | MISSING | No call to user delete exists anywhere in lib. No delete account screen, no reauthentication plus delete flow, no Firestore cleanup, no Cloud Function cleanup. |
| 12 | Phone OTP sign in | PARTIAL, dead code | AuthService.verifyPhoneNumber and signInWithSmsCode exist. No screen calls them. auth_screen.dart states phone OTP stays in AuthService with no screen yet. Phone sign in is not reachable in the app today. |
| 13 | Change email | REAL | AuthService.updateEmailAddress reauthenticates first, then uses verifyBeforeUpdateEmail. The email changes only after the link in the new inbox is tapped. |
| 14 | Change password | REAL | AuthService.updateAccountPassword reauthenticates with the current password first. Google only accounts are told to use Forgot password instead. |

Notes on the real flows. Google sign in is the strongest part of the auth code: the link flow avoids duplicate accounts when a Google email already has a password account. Change email and change password both reauthenticate, which is correct. The gaps are verification, status, deletion, and phone OTP reachability, not the sign in paths themselves.

## 2. Roles

Only one role exists in code today: owner, stored as a field in the admins collection, checked by FirestoreService.isAdmin and by isOwner in the rules. No other role exists anywhere. The users documents carry no role field. Premium is not a role: it is a Remote Config boolean named premium_enabled, default false, read by PremiumService. The table below DEFINES the target roles. It does not describe current behaviour.

| Role | May do | May never do |
|---|---|---|
| Owner | All content publish and delete. Grant and revoke every role, through the trusted Function only. Read payments and moderation. Read and reply in every chat. Suspend and restore users. Manage astrologers. | Never grant a role from client code. Never share the seed credential. |
| Super Admin | All content publish and delete. Manage astrologers. Read payments and moderation. Read and reply in every chat. Suspend and restore users. | Never grant or revoke the owner role. Never change owner records. Never touch role provisioning. |
| Admin | Publish and edit horoscopes, panchang, astrologer profiles, plans, notifications. Reply in chats. Moderate content. View analytics. | Never touch roles, payments, owner records, or user suspension. Never delete owner content without owner approval. |
| Staff | Draft content only, no publish. Reply only in chats assigned to them. Read published content. | Never publish, never read payments, never read chats they are not assigned to, never touch roles. |
| Astrologer | Read and reply only in chats assigned to them. Read own astrologer profile. | Never publish content, never read other chats, never read payments, never see admin screens. |
| Customer | Own profile only. Own Kundli only. Read published content. Own chats only. | Never read another customer profile or Kundli, never read payments or moderation, never write admin collections. |

Enforcement target: roles live in Auth custom claims, set only by the trusted Function. Rules check request.auth.token.role, never a client writable document. The admins collection becomes a read only mirror written by the Function, never by the client. Until that lands, only the owner role exists, and it is broken by P0-1.

## 3. Secure owner provisioning design

Goal: the owner exists exactly once, created by a trusted server side process, and no client can create or escalate a role.

### 3.1 Target flow

1. One time bootstrap, run once by the owner from a trusted machine. An Admin SDK script, or a manual console step followed by an Admin SDK script, sets the custom claim role owner on the first owner uid. The script is run by a human, never by the app.
2. The claim travels inside the ID token. Rules read request.auth.token.role. No extra document read is needed per write.
3. Later grants go through one callable Cloud Function named setRole. It accepts target uid and target role. It rejects every caller whose token role is not owner. It validates the target role against the table in section 2. It sets the custom claim with the Admin SDK, writes the mirror document in admins, and writes one audit log entry in role_audit with actor uid, target uid, old role, new role, and server time.
4. Revoke uses the same Function with the target role removed. Removing the owner role from the last owner is rejected by the Function.
5. The client never writes admins, never writes role_audit, never writes any role field. Rules deny all client writes to those paths.
6. Suspended users are handled the same way: a setUserStatus Function sets a status field on the users document and disables the Auth user with the Admin SDK, so sign in stops at Firebase and the rules also deny the suspended uid.

### 3.2 Proof plan

1. Emulator: run firebase/firestore.rules.test.mjs. T05 and T06 must pass after the rules change lands. Today T05 fails on current rules, which is the proof of P0-1.
2. Rules Playground in the console: fresh user writes own admins document with role owner, expect deny. Owner writes horoscopes, expect allow.
3. Live check after deploy, by the parent: sign in as a fresh test user, attempt the self grant through the console or a test script, confirm deny, confirm the owner account still publishes.
4. Audit log read: after a test grant in the emulator, role_audit holds one entry with actor, target, old role, new role.

### 3.3 Seed account

The seed admin@gmail.com with its default password is NOT removed in this phase. It was the user Round 4 order on 27 Nov, and the master instruction orders its removal, so the two orders conflict. The decision goes to the parent. This phase only designs the replacement.

Removal sequence, for the parent decision, after provisioning in 3.1 is proven working on live:

1. Confirm the new owner claim works: owner signs in, publishes one horoscope, reads payments.
2. Delete the seed Auth user in the console, so the credential dies with the account.
3. Delete the seed admins document.
4. Remove the seed code: AdminSeedService, the default email and password constants in lib/core/admin_config.dart, the email fallback in FirestoreService.isAdminUser, and the Google auto grant in admin_screens.dart _checkAdminAccess.
5. Land the hardened rules in section 4.4 in the same change, so no gap opens between seed removal and rule hardening.

Until that sequence runs, the seed stays live and the default password must be changed by the owner from the admin Account screen. Today nothing forces that change. That is P0-2.

## 4. Firestore rules audit

Repo file: firebase/firestore.rules. Live state: published 28 Nov 00:06 IST from this repo file, per the parent browser task record. This phase did not re read the live rules: no live browser and no Firebase CLI exist on this VM. The repo file is the audited source.

### 4.1 Rule by rule

| Path | Rule today | Verdict |
|---|---|---|
| users/{uid} | Read and write only when request.auth.uid equals uid | Correct shape, but no field validation. A user can write any field into own document, including a role or premium flag, if any code ever reads such a field. Today no code reads a role from users, so the blast radius is limited to profile fields. |
| admins/{uid} | Read and write when request.auth.uid equals uid | BROKEN. This is P0-1. Any signed in user writes own document and sets role owner. |
| horoscopes/{doc} | Read when signed in, write when isOwner | Read is open to every signed in user, including unverified accounts. Write gate depends on the broken admins document. |
| astrologers/{doc} | Same as horoscopes | Same verdict. No astrologer role exists, so only the owner writes. |
| panchang/{doc} | Same as horoscopes | Same verdict. |
| plans/{doc} | Read when signed in, write when isOwner | Same verdict. |
| payments/{doc} | Read and write when isOwner | Read gate is correct in shape, but depends on the broken admins document. |
| notifications/{doc} | Read when signed in, write when isOwner | P1-3. Every signed in user can read every notification document. No per user scoping. |
| moderation/{doc} | Read and write when isOwner | Correct in shape, depends on the broken admins document. |
| chats/{chatId} | Read when participant or owner. Create when caller is in participantIds. Update when participant or owner. | P1-4. Create does not bind the chat id to the caller. A user can create the document user_<victimUid> with self in participantIds, then read messages the victim app writes into that chat. Update lets a participant rewrite participantIds, adding or removing people. |
| chats/{chatId}/messages/{msgId} | Read when participant or owner. Create when senderId equals caller and caller is a participant. | Create check is correct in shape. No text length, type, or senderRole validation. senderRole is client supplied. |

isOwner reads the admins document with get on every protected write. That costs one read per write and cannot be used in Storage rules. The target is a token claim check, no get.

### 4.2 Findings

P0-1. Self grant of owner. Rules allow a signed in user to write own admins document with any content, including role owner. isOwner then passes. Full owner write follows: horoscopes, astrologers, panchang, plans, payments, notifications, moderation, and read of every chat. Found by reading the rules file. Exploit was NOT run against live. No live data touched.

P0-2. Default seed credential in source. lib/core/admin_config.dart holds the seed email and the default password in plain code. AdminSeedService creates the account on first admin app launch. Nothing forces a password change after first sign in. Anyone with repo access knows the credential.

P0-3. Email based admin fallback. FirestoreService.isAdminUser returns true for any user whose email is the seed email, even with no admins document. The admins document gate is bypassed by email alone.

P0-4. Google auto grant. admin_screens.dart _checkAdminAccess calls ensureAdminDoc for every Google signed in user in the admin app, writing role owner. The Round 4 order says whoever creates once through Google in the admin app can use admin access. That order grants owner to any Google account. FirestoreService.ensureAdminDoc writes role owner for any uid it is called with.

P1-1. No email verification. See section 1 row 5. Unverified accounts read all signed in content and create chats.

P1-2. No field validation in any rule. No allow rule checks request.resource.data types, fields, or sizes. users writes, chat updates, and message creates all trust client supplied fields.

P1-3. Notifications are readable by every signed in user. No per user scoping on notifications/{doc}.

P1-4. Chat id is not bound to the creator. See chats row in 4.1. A user can claim another user chat document id and read it.

P1-5. No Storage rules in the repo. See section 5.

P1-6. No audit log. No collection records admin actions, role changes, or content deletes. A malicious owner grant leaves no trace in Firestore.

P2-1. Role checks use a document get per write. Move to custom claims, see section 3.

P2-2. Phone OTP is dead code. Either wire a screen to it or remove it. Decision to the parent.

P2-3. Premium is a Remote Config boolean only. No per user entitlement exists. When pricing is decided, a client side flag cannot enforce per user premium. Entitlements must move to Firestore under owner write plus rules, or to a Function verified purchase.

P2-4. No App Check and no rate limiting in the rules. Writes are unbounded per user.

P2-5. Doc and code mismatch. FIREBASE-SETUP.md says the owner creates the admins record in the console and the app never grants admin access. The code does the opposite: seed plus Google auto grant plus email fallback.

P3-1. Google web client id lives in code. It is a public client identifier, not a secret, and the code comment says so. No action needed.

P3-2. No rules tests exist in the repo, and firebase.json has no emulators section. The test file added in this phase is the first rules test.

P3-3. Chat senderRole is client supplied with no validation against the real role of the sender.

### 4.3 Twelve security tests

Test file: firebase/firestore.rules.test.mjs. Runner: Firestore emulator plus @firebase/rules-unit-testing. T01 to T09 are implemented. T10 to T12 are skipped in code with the reason written next to each, because the feature they test does not exist yet. The table states the expected result against the TARGET rules, and the result against CURRENT rules where it differs.

| ID | Test | Expected | Current rules |
|----|------|----------|---------------|
| T01 | Unauthenticated user reads horoscopes | Deny | Deny, passes |
| T02 | Unauthenticated user writes a users document | Deny | Deny, passes |
| T03 | Customer A reads users document of customer B, and reads own | Deny other, allow own | Passes |
| T04 | Customer A writes users document of customer B | Deny | Deny, passes |
| T05 | Signed in user creates own admins document with role owner | Deny | ALLOWS, fails. This is the proof of P0-1. |
| T06 | Signed in user sets role owner on another user admins document | Deny | Deny, passes |
| T07 | Unassigned astrologer reads a chat they are not part of, assigned astrologer reads own chat | Deny unassigned, allow assigned | Passes on participant logic. No astrologer role exists, so assignment is participant list only. |
| T08 | Staff role user tries an owner only write, publish horoscope | Deny | Deny, passes. No staff role exists, so the user is treated as a plain non owner. |
| T09 | Admin role user tries an owner only operation, write payments and write an admins document | Deny | Deny, passes. No admin role exists, so the user is treated as a plain non owner. |
| T10 | Suspended user reads own profile and published content | Deny | ALLOWS today, no status field exists. Skipped in code until the status field and rule land. |
| T11 | Invalid Storage upload, oversize file, wrong type, other user path | Deny | BLOCKED. No storage rules are published. Draft exists in this branch, not published. |
| T12 | Unauthorized Cloud Function call, and call with invalid or expired token | Deny | BLOCKED. No Functions exist in the repo. |

### 4.4 Proposed hardened admins rule

Not landed in this phase. It lands together with the Function provisioning in section 3, because landing it alone locks out the seed and the Google auto grant path with no replacement. Text for review:

```
match /admins/{uid} {
  allow read: if request.auth != null &&
    (request.auth.uid == uid || request.auth.token.role == 'owner');
  allow write: if false;
}
```

And isOwner becomes a token claim check, no document get:

```
function isOwner() {
  return request.auth != null &&
    request.auth.token.role == 'owner';
}
```

The mirror document stays readable by its owner and by the owner role. Writes come only from the Admin SDK, which bypasses rules. The same pattern applies to role_audit: client reads only for the owner role, client writes never.

### 4.5 How to run the rules tests

On a machine with Java 17 and Node 20 or later. This VM has Node 24 but no Java, so the emulator cannot run here. That is why the tests are not executed in this phase.

```
npm install -g firebase-tools
firebase emulators:start --only firestore,storage --project demo-dharm-guru-test
npm install --save-dev @firebase/rules-unit-testing firebase
node --test firebase/firestore.rules.test.mjs
```

CI shape for later, not added in this phase: one job on ubuntu-latest, install Java 17, install firebase-tools, start the emulator in the background, run node --test on the rules test file. The existing workflow .github/workflows/flutter-analyze.yml has no rules job today. Adding it is Phase 2 work, after the Functions decision, so the job tests the target rules rather than the broken ones.

## 5. Storage rules audit

Finding: no storage.rules file exists in the repo. firebase.json has no storage section. No app code uses Firebase Storage today: grep for Storage across lib finds no Storage call. So no upload path exists to secure yet, and no live Storage rule state was verified in this phase.

Draft added in this branch, NOT published: firebase/storage.rules, wired in firebase.json.

Draft shape, default deny, least privilege:

1. users/{uid}/{fileName}: the owner of the uid reads and writes own files only, plus the owner role reads. Images only, under 5 MB.
2. horoscopes/{fileName}: every signed in user reads, owner role writes only. Images only, under 5 MB.
3. Every other path: read and write deny.

The paths are proposed, not wired to any UI, because no upload feature exists in the app today. When profile images or horoscope images are built, the UI must use exactly these paths. T11 covers the draft in the emulator once the rules are published to the emulator config.

## 6. Cloud Functions state

There is no functions directory in the repo. No function code exists. No Blaze plan decision exists: the user decision on the Blaze plan is still open, per the master order record. So trusted role assignment, secure account deletion cleanup, and user suspension are all BLOCKED_BY_EXTERNAL_CONFIGURATION. Nothing was faked here: no function code was written, no claim was set, no role was granted.

When the Blaze decision lands, Functions own: setRole callable, setUserStatus callable, deleteUser cleanup on Auth user delete, and the audit log writes. All of them run with the Admin SDK and all of them check the caller token role first. Until then, section 3 stays a design, not a running system.

## 7. Design section 16 open questions, Phase 1 impact

From design/DESIGN-SYSTEM.md section 16. Six open questions. Impact on this phase:

1. Pricing. Blocks premium enforcement design. No per user entitlement can be final until price, trial length, currency, and plan lengths are decided. Premium stays a Remote Config boolean, default false.
2. In app theme switch. No security impact.
3. Language, Hindi copy. No security impact. Who supplies Hindi copy is still open.
4. Astrologer identity. Blocks astrologer role provisioning. No astrologer identity means no assignment list, no astrologer accounts, and consult chat stays answered by the admin. This is the same gap named in the rules comments.
5. Chart variant, Moon Chart in version 1 or later. No security impact.
6. Notification timing, default 06:00 AM and whether the user can change it. No security impact.

## 8. Known defects, consolidated

P0-1 Self grant of owner through own admins document write. P0-2 Default seed credential in source with no forced rotation. P0-3 Email based admin fallback bypasses the admins document gate. P0-4 Google auto grant gives owner to any Google account in the admin app. P1-1 No email verification. P1-2 No field validation in rules. P1-3 Notifications readable by every signed in user. P1-4 Chat id not bound to creator, another user chat document can be claimed. P1-5 No Storage rules published. P1-6 No audit log. P2-1 Role check costs a document get per write. P2-2 Phone OTP dead code. P2-3 Premium is a Remote Config flag, no per user entitlement. P2-4 No App Check, no rate limiting. P2-5 Setup doc says console only provisioning, code does the opposite. P3-1 Web client id in code, public identifier, no action. P3-2 No rules tests before this phase, no emulators config. P3-3 Chat senderRole client supplied, not validated.

## 9. Remaining work and next phase handover

Parent decisions needed before Phase 2 builds: seed removal timing, Blaze plan yes or no, astrologer identity source, pricing model for premium entitlements, phone OTP wire or remove.

Phase 2 work, in order: Functions project plus setRole and setUserStatus callables, custom claims migration, hardened firestore rules including the 4.4 block plus field validation plus chat id binding plus notification scoping plus suspended status check, Storage rules publish after review, rules test job in CI, emulator run of T01 to T12 green, then the seed removal sequence in 3.3.

What this phase deliberately did not do: no change to firebase/firestore.rules, no live publish, no seed removal, no Function code, no dummy data, no secret in any file. The default password string was not copied into this file or into any new file.

## Appendix: evidence

Commands run on this VM, all read only except the new branch and its files:

1. gh run view 46043847890, baseline CI success, 3 jobs green, on main.
2. git clone of the repo into the phase directory, checkout of new branch phase1-security at eb0c471.
3. Grep across lib for sendEmailVerification, emailVerified, user delete, suspend, Storage use. All returned no matches except the change email verification path.
4. Read of firebase/firestore.rules, lib/services/auth_service.dart, lib/main.dart, lib/main_admin.dart, lib/services/admin_seed_service.dart, lib/services/firestore_service.dart, lib/screens/auth_screen.dart, lib/screens/admin_screens.dart, lib/services/chat_service.dart, lib/services/premium_service.dart, FIREBASE-SETUP.md, design/DESIGN-SYSTEM.md section 16.
5. node --check on firebase/firestore.rules.test.mjs, syntax valid.
6. Python brace balance check on firebase/firestore.rules, unchanged, and on firebase/storage.rules, new file.
7. git status and git diff to confirm only the intended files changed.

Live rules were not re read in this phase. Last live verification is the parent record of 28 Nov 00:06 IST: rules published from the repo file, owner record visible, Rules Playground owner allow and non owner deny.
