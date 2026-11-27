# Astrologer Workflow Test Report

* Status: NOT_TESTED for the live workflow, PASS for the automated chat tests
* Date: 28 Nov 2026
* Branch: phase1218-ci

## The blocking fact

No astrologer identity exists yet. The admin answers consult chats
until one is added. That decision is still owed by the owner, and
no dummy astrologer may be invented to fill the gap. Every workflow
below that needs a named astrologer stays NOT_TESTED until the
identity is decided.

## Workflows

| ID | Workflow | Status |
| BT-ASTRO-01 | Admin approves an astrologer, astrologer appears in Consult | NOT_TESTED |
| BT-ASTRO-02 | User opens Consult, sees the approved astrologer list | NOT_TESTED |
| BT-ASTRO-03 | User starts a chat with an astrologer, sends a message | NOT_TESTED |
| BT-ASTRO-04 | Astrologer replies, user receives the reply | NOT_TESTED |
| BT-ASTRO-05 | A user cannot read a chat they do not take part in | NOT_TESTED |
| BT-ASTRO-06 | A user cannot send a message as another user | NOT_TESTED |
| BT-ASTRO-07 | Admin can read and reply in every chat | NOT_TESTED |
| BT-ASTRO-08 | Live consult call flow, if a call provider is decided | NOT_TESTED |

## Automated coverage that already exists

* test/chat_test.dart: 2 tests, PASS in CI
* test/proof_test.dart: Consult Chat end to end against in memory
  Firestore, PASS in CI
* Rules audit RULES-04: chat messages can only be sent as yourself,
  PASS in CI as a static check
* BT-ASTRO-05 and BT-ASTRO-06 have no emulator test yet. They need
  the Firebase emulator rules job, so they stay BLOCKED there and
  NOT_TESTED here.

## Cross role workflows

* User to admin: publish flow, BT-ADMIN-05 and BT-ADMIN-06, NOT_TESTED
* Admin to user: notification flow, BT-ADMIN-10, NOT_TESTED
* Astrologer to user: blocked on astrologer identity, NOT_TESTED
* No cross role workflow is marked PASS anywhere in this folder.
