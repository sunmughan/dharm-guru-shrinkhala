// Firestore security rules tests, Phase 1.
// Runner: Firestore emulator plus @firebase/rules-unit-testing.
// Run: firebase emulators:start --only firestore,storage --project demo-dharm-guru-test
// Then: node --test firebase/firestore.rules.test.mjs
// Needs Java 17 for the emulator. This VM has no Java, so these
// tests are NOT executed here. They are written against the
// TARGET rules. T05 fails against the current repo rules, which
// is the proof of P0-1 in docs/implementation/FIREBASE_SECURITY.md.
// T10 to T12 are skipped: the feature each one tests does not
// exist yet. See the matching rows in the doc.
import { test } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const rules = readFileSync(new URL('./firestore.rules', import.meta.url), 'utf8');

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-dharm-guru-test',
    firestore: { rules },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

async function seedOwner() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'admins', 'ownerUid'), { role: 'owner', email: 'owner@example.com' });
    await setDoc(doc(db, 'horoscopes', 'h1'), { title: 'seeded' });
  });
}

test('T01 unauthenticated user cannot read horoscopes', async () => {
  await seedOwner();
  const db = testEnv.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'horoscopes', 'h1')));
});

test('T02 unauthenticated user cannot write a users document', async () => {
  const db = testEnv.unauthenticatedContext().firestore();
  await assertFails(setDoc(doc(db, 'users', 'userA'), { name: 'A' }));
});

test('T03 customer A cannot read customer B profile, can read own', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users', 'userA'), { name: 'A' });
    await setDoc(doc(db, 'users', 'userB'), { name: 'B' });
  });
  const dbA = testEnv.authenticatedContext('userA').firestore();
  await assertFails(getDoc(doc(dbA, 'users', 'userB')));
  await assertSucceeds(getDoc(doc(dbA, 'users', 'userA')));
});

test('T04 customer A cannot write customer B profile', async () => {
  const dbA = testEnv.authenticatedContext('userA').firestore();
  await assertFails(setDoc(doc(dbA, 'users', 'userB'), { name: 'hijacked' }));
});

test('T05 signed in user cannot create own admins document with role owner', async () => {
  const dbA = testEnv.authenticatedContext('userA').firestore();
  await assertFails(setDoc(doc(dbA, 'admins', 'userA'), { role: 'owner', email: 'a@example.com' }));
});

test('T06 signed in user cannot set role owner on another user admins document', async () => {
  const dbA = testEnv.authenticatedContext('userA').firestore();
  await assertFails(setDoc(doc(dbA, 'admins', 'userB'), { role: 'owner', email: 'b@example.com' }));
});

test('T07 unassigned astrologer cannot read a chat, assigned astrologer can', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'chats', 'user_userB'), {
      participantIds: ['userB', 'astro1'],
      lastMessage: 'hello',
    });
  });
  const dbStranger = testEnv.authenticatedContext('astro9').firestore();
  await assertFails(getDoc(doc(dbStranger, 'chats', 'user_userB')));
  const dbAssigned = testEnv.authenticatedContext('astro1').firestore();
  await assertSucceeds(getDoc(doc(dbAssigned, 'chats', 'user_userB')));
});

test('T08 staff role user cannot publish a horoscope', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'admins', 'staff1'), { role: 'staff', email: 'staff@example.com' });
  });
  const dbStaff = testEnv.authenticatedContext('staff1').firestore();
  await assertFails(setDoc(doc(dbStaff, 'horoscopes', 'h2'), { title: 'staff publish' }));
});

test('T09 admin role user cannot write payments and cannot write an admins document', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'admins', 'admin1'), { role: 'admin', email: 'admin1@example.com' });
  });
  const dbAdmin = testEnv.authenticatedContext('admin1').firestore();
  await assertFails(setDoc(doc(dbAdmin, 'payments', 'p1'), { amount: 100 }));
  await assertFails(setDoc(doc(dbAdmin, 'admins', 'userA'), { role: 'owner' }));
});

test('T10 suspended user cannot read own profile and published content', { skip: 'no status field exists yet, rule not written' }, async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users', 'suspended1'), { name: 'S', status: 'suspended' });
  });
  const dbS = testEnv.authenticatedContext('suspended1').firestore();
  await assertFails(getDoc(doc(dbS, 'users', 'suspended1')));
  await assertFails(getDoc(doc(dbS, 'horoscopes', 'h1')));
});

test('T11 invalid Storage upload is denied', { skip: 'no storage rules published, draft only, needs storage emulator run' }, async () => {
  // Oversize file, wrong content type, and other user path.
  // Runs against firebase/storage.rules once it is published
  // to the emulator config. See doc section 5.
});

test('T12 unauthorized Cloud Function call is denied', { skip: 'no Functions exist in the repo, Blaze plan undecided' }, async () => {
  // Callable setRole with a non owner caller, and a call with
  // an invalid or expired token. Runs once Functions land.
});
