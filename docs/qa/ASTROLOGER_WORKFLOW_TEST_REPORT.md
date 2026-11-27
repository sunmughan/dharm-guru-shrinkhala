# Dharm Guru Shrinkhala Phase 16 Astrologer Workflow Test Report

Ye report Roman Hindi aur English me hai. Isme hyphen sirf exact file names, branch names aur repo names ke andar hai, kyunki wo identifiers badle nahi ja sakte. Baaki poori prose me koi hyphen nahi hai.

## PHASE

Phase 16, cross role workflow testing. Baseline release 10, HEAD `eb0c471`, CI run `46043847890` green, 111 tests. Kaam sirf admin app browser testing aur cross role testing tak limited hai.

## STATUS

Blocked. Workflow ka ek bhi step sign in gate ke aage test nahi ho paya. QA accounts provision nahi hue, web Firebase config placeholder hai, aur sandbox Google APIs tak pahunch nahi pata. Upar se workflow ke 3 zaroori hisse release 10 code me hain hi nahi: astrologer identity, bookings flow, aur audit logs. Isliye saare steps Blocked hain, ek bhi Pass nahi hai.

## IMPLEMENTED

1. Admin app ka web build CI se banaya aur browser me sign in gate tak test kiya. Uska poora evidence `docs/qa/ADMIN_APP_BROWSER_TEST_REPORT.md` me hai.
2. Cross role workflow ke har step ko code ke against check kiya, kya bana hai aur kya nahi.
3. Koi dummy data nahi bhara, live production data ko haath nahi lagaya, koi destructive test nahi kiya, live deploy nahi kiya.
4. Koi fake login nahi banaya, koi mock live test nahi kiya. Jahan auth ne roka, wahan Blocked likha hai.

## FILES CHANGED

Branch `phase16-qa-admin` par, repo `sunmughan/dharm-guru-shrinkhala` me:

- `docs/qa/ASTROLOGER_WORKFLOW_TEST_REPORT.md` (new, ye report)
- `docs/qa/ADMIN_APP_BROWSER_TEST_REPORT.md` (new, admin app report, isi run ka hissa)
- `.github/workflows/qa-web-build.yml` (new, QA web build workflow)
- `docs/qa/screenshots/desktop-signin-1280.png`
- `docs/qa/screenshots/mobile-signin-390.png`
- `docs/qa/screenshots/invalid-email-error.png`
- `docs/qa/screenshots/short-password-error.png`
- `docs/qa/screenshots/probe-signin-network-error.png`
- `docs/qa/screenshots/create-account-mode.png`
- `docs/qa/screenshots/forgot-password-mode.png`
- `docs/qa/screenshots/google-signin-busy.png`
- `docs/qa/browser-logs/run1-canvaskit-cdn-fail.txt`
- `docs/qa/browser-logs/run5-signin-gate.txt`
- `docs/qa/browser-logs/run6-first-interactive.txt`
- `docs/qa/browser-logs/run7-retest-interactive.txt`
- `docs/qa/qa-harness/qa-run1.js`
- `docs/qa/qa-harness/qa-run6.js`
- `docs/qa/qa-harness/qa-run7.js`

Shared local clone `~/workspace/dharm-guru-shrinkhala` ko edit nahi kiya. Main branch par push nahi kiya, sirf `phase16-qa-admin` branch push ki.

## FIREBASE CHANGES

Koi nahi. Live Firestore me koi document create, update ya delete nahi hua. Koi sign in kabhi success nahi hua. Koi birth profile, kundli, booking, chat ya audit record banaya hi nahi gaya.

## TESTS EXECUTED

Commands, exact:

- `gh run list --repo sunmughan/dharm-guru-shrinkhala --limit 5`
- `gh api repos/sunmughan/dharm-guru-shrinkhala/actions/runs/46043847890/artifacts`
- `gh run download 46057202658 --repo sunmughan/dharm-guru-shrinkhala --name dharm-guru-admin-web-qa --dir ./web-build`
- `python3 -m http.server 8317 --directory web-build`
- `node qa-run1.js` (run5, sign in gate)
- `node qa-run7.js` (run7, retest run)

Test IDs: X001 se X010 tak, neeche table me.

## TEST RESULTS

Passed 0, Failed 0, Blocked 10, Not Tested 0. Saare 10 steps Blocked hain. Koi step Pass nahi hai, aur Blocked ko Pass nahi banaya gaya hai.

## BROWSER VERIFICATION

Playwright headless Chromium, cached build `chromium-1248`, viewport 1280x800 aur 390x844. Local server `http://127.0.0.1:8317/`, build CI run `46057202658` se. App boot hui aur sign in gate par ruki. Uske aage ka har step isi gate par Blocked hua. User app ka alag web build is run me nahi chalaya gaya, kyunki user app wahi `AuthScreen`, wahi Firebase project aur wahi placeholder web config use karta hai, isliye uska gate bilkul wahi hai. Ye baat X001 me saaf likhi hai.

## KNOWN DEFECTS

Ye defects admin report se liye gaye hain, kyunki workflow unhi par ruka hai.

- D002 P2: Web Firebase config sirf placeholder hai. `lib/firebase_options.dart` me web values placeholder hain, console me koi web app register nahi hai. Isliye web par koi bhi sign in kabhi success nahi ho sakta. Evidence har run ke log me placeholder key wali Auth calls.
- D003 P1: Admin seed har pehle web launch par Auth signUp call karta hai, user ke kuch karne se pehle. Asli web config milte hi ye production Auth me default admin account bana dega, bina kisi se pooche. Evidence `lib/services/admin_seed_service.dart` aur har run ke log me `Admin seed failed` wali line.
- D006 P2: Scope gap, runtime defect nahi. Workflow ke 3 zaroori hisse code me hain hi nahi: astrologer identity, bookings flow, audit logs. Koi `bookings` collection nahi hai, koi booking accept ya reject flow nahi hai, aur `lib/` me audit shabd ka ek bhi match nahi hai. Rules file `firebase/firestore.rules` me bhi astrologer ke liye koi rule nahi hai, sirf owner aur chat participants hain.

## REMAINING WORK

1. QA accounts provision karna: ek QA customer, ek QA astrologer, ek owner admin, ek non owner user.
2. Firebase console me web app register karna aur asli web config dena.
3. Astrologer identity decide karna aur implement karna, kyunki uske bina astrologer role ka koi test possible nahi hai.
4. Bookings flow implement karna: consultation request, accept, reject, status update.
5. Audit logs implement karna, taaki privileged operations record ho sakein.
6. Ye 10 steps dobara chalana, jab upar ke 5 kaam ho jayein.

## NEXT PHASE

Phase 17 ya Phase 16 ka retest round, jab QA accounts, web config, astrologer identity aur bookings flow mil jayein. Tab X001 se X010 tak dobara chalenge, isi harness se, pehle customer app par phir admin app par.

## WORKFLOW INVENTORY

Code me workflow ke hisse kahan tak bane hain, file aur line ke saath:

- Customer birth profile: user app me `lib/screens/profile_form_screen.dart` aur `lib/services/user_profile.dart` bane hain, par sign in ke bina khulte nahi hain.
- Kundli generate: engine `lib/services/astro.dart` me bana hua hai, release 9 aur 10 me prove hua hai, par sign in ke bina browser me test nahi ho paya.
- Consultation request: sirf chats hain, `lib/services/chat_service.dart` aur `AdminChatsScreen` line 1509. Koi booking request flow nahi hai.
- Astrologer authorized information: koi astrologer identity nahi hai. Rules me astrologer ka koi zikr nahi hai.
- Booking accept ya reject: koi code nahi hai. `booking` shabd ka code me ek hi match hai, Analytics label `Consult bookings`, line 2605, jo koi flow nahi hai.
- Admin booking review: koi code nahi hai, kyunki bookings hain hi nahi.
- Customer ko updated booking status: koi code nahi hai, kyunki bookings hain hi nahi.
- Customer report access: reports ka code nahi hai. Moderation screen me Reports tab sirf queue dikhata hai, line 3227.
- Audit history: koi code nahi hai, `lib/` me audit ka zero match hai.

## TEST TABLE

Har row me: Test ID, Module, Feature, Preconditions, Test input, Action, Expected result, Actual result, Verdict, Evidence, Firebase verification, Defect ID, Retest result.

### X001 Customer birth profile banata hai

- Module: Cross role workflow, customer side
- Feature: Birth profile create karna
- Preconditions: QA customer account se user app me sign in hona chahiye
- Test input: QA birth profile, date, time aur place
- Action: User app me profile form kholna aur bharna tha
- Expected result: Birth profile save ho aur dikhe
- Actual result: Test ho hi nahi paya. User app ka alag web build is run me nahi chalaya gaya, kyunki user app wahi `AuthScreen`, wahi Firebase project aur wahi placeholder web config use karta hai jo admin app use karta hai. Admin app ke browser test me sign in gate par hi rukawat prove ho chuki hai, aur wahi rukawat user app par bhi laagu hoti hai. Isliye ye step Blocked hai, dobara prove karne ke liye alag build chalane ka koi matlab nahi tha
- Verdict: Blocked
- Evidence: `docs/qa/ADMIN_APP_BROWSER_TEST_REPORT.md`, ADM007, `docs/qa/screenshots/probe-signin-network-error.png`
- Firebase verification: Koi nahi, koi profile document bana hi nahi
- Defect ID: D002
- Retest result: QA customer account aur web config milne par dobara chalega

### X002 Customer Kundli generate karta hai

- Module: Cross role workflow, customer side
- Feature: Birth profile se Kundli generate karna
- Preconditions: X001 pass hona chahiye, birth profile saved hona chahiye
- Test input: X001 ka saved QA birth profile
- Action: Kundli screen kholna aur generate karna tha
- Expected result: Asli Kundli chart dikhe, engine se calculate hua
- Actual result: Test ho hi nahi paya, X001 Blocked hai isliye Kundli tak pahuncha hi nahi ja sakta
- Verdict: Blocked
- Evidence: X001 ka result, admin report ADM007
- Firebase verification: Koi nahi, koi kundli document bana hi nahi
- Defect ID: D002
- Retest result: X001 ke baad dobara chalega
- Code note: Engine bana hua hai, `lib/services/astro.dart`, release 9 aur 10 me unit tests se prove hua hai, par browser me is run me test nahi hua

### X003 Customer consultation request karta hai

- Module: Cross role workflow, customer side
- Feature: Consultation request bhejna
- Preconditions: QA customer sign in hona chahiye
- Test input: QA consultation request
- Action: Consult screen se request bhejna tha
- Expected result: Request astrologer aur admin ko dikhe
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua. Upar se consultation request ka flow code me hai hi nahi, sirf chat rooms hain
- Verdict: Blocked
- Evidence: Admin report ADM007, code grep me booking request ka koi flow nahi hai
- Firebase verification: Koi nahi, koi chat ya booking document bana hi nahi
- Defect ID: D002 aur D006
- Retest result: QA accounts, web config aur bookings implementation milne par dobara chalega

### X004 Astrologer sirf authorized information dekhta hai

- Module: Cross role workflow, astrologer side
- Feature: Astrologer ko sirf authorized information dikhe
- Preconditions: QA astrologer account hona chahiye, consultation request maujood honi chahiye
- Test input: QA astrologer sign in
- Action: Astrologer ke taur par sign in karke request kholni thi
- Expected result: Astrologer ko sirf authorized fields dikhein, baaki na dikhein
- Actual result: Test ho hi nahi paya. Astrologer identity hai hi nahi, isliye koi astrologer account bhi nahi hai aur koi authorized view bhi define nahi hai. Rules file me astrologer ka koi rule nahi hai
- Verdict: Blocked
- Evidence: Admin report ADM027, `firebase/firestore.rules` me astrologer ka koi zikr nahi hai
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Astrologer identity aur role design banne ke baad test hoga

### X005 Astrologer booking accept ya reject karta hai

- Module: Cross role workflow, astrologer side
- Feature: Booking accept ya reject
- Preconditions: X003 aur X004 pass hone chahiye
- Test input: QA booking
- Action: Booking par accept ya reject karna tha
- Expected result: Booking status accept ya reject me badle
- Actual result: Test ho hi nahi paya, bookings ka code hi nahi hai. Koi booking document, koi status field aur koi accept ya reject button nahi hai
- Verdict: Blocked
- Evidence: Code grep, `lib/` me booking flow ka koi match nahi hai, sirf Analytics label line 2605
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Bookings implementation milne par dobara chalega

### X006 Admin booking review karta hai

- Module: Cross role workflow, admin side
- Feature: Admin booking review kare
- Preconditions: Owner admin sign in hona chahiye, booking maujood honi chahiye
- Test input: QA booking
- Action: Admin app me booking review karna tha
- Expected result: Admin ko booking dikhe aur review kar sake
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua, aur bookings hain hi nahi
- Verdict: Blocked
- Evidence: Admin report ADM007 aur ADM022
- Firebase verification: Koi nahi
- Defect ID: D002 aur D006
- Retest result: QA accounts, web config aur bookings implementation milne par dobara chalega

### X007 Customer ko updated booking status dikhta hai

- Module: Cross role workflow, customer side
- Feature: Updated booking status customer ko dikhe
- Preconditions: X005 pass hona chahiye, status badla hona chahiye
- Test input: QA booking
- Action: Customer ke taur par sign in karke status dekhna tha
- Expected result: Updated status dikhe
- Actual result: Test ho hi nahi paya, X005 Blocked hai isliye status badla hi nahi
- Verdict: Blocked
- Evidence: X005 ka result
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: X005 ke baad dobara chalega

### X008 Customer report access karta hai

- Module: Cross role workflow, customer side
- Feature: Consultation report access karna
- Preconditions: QA customer sign in hona chahiye, report maujood honi chahiye
- Test input: QA report
- Action: Report kholna tha
- Expected result: Report dikhe
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua, aur report ka code hi nahi hai
- Verdict: Blocked
- Evidence: Admin report ADM007 aur ADM024
- Firebase verification: Koi nahi
- Defect ID: D002 aur D006
- Retest result: QA accounts, web config aur report implementation milne par dobara chalega

### X009 Audit history privileged operations record karta hai

- Module: Cross role workflow, audit
- Feature: Privileged operations audit history me record hon
- Preconditions: Owner admin sign in hona chahiye, koi privileged operation hua hona chahiye
- Test input: Koi nahi
- Action: Audit history kholna tha
- Expected result: Privileged operations ka record dikhe, kisne kab kya kiya
- Actual result: Test ho hi nahi paya, audit ka code hai hi nahi. `lib/` me audit shabd ka ek bhi match nahi hai
- Verdict: Blocked
- Evidence: Admin report ADM026, code grep me audit ka zero match
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Audit logs implementation milne par dobara chalega

### X010 End to end cross role flow dobara verify

- Module: Cross role workflow, poora flow
- Feature: Saare steps ek saath dobara verify karna
- Preconditions: X001 se X009 tak pass hone chahiye
- Test input: Poora QA workflow data
- Action: Customer se astrologer se admin tak poora flow dobara chalana tha
- Expected result: Har step ka status consistent dikhe
- Actual result: Test ho hi nahi paya, X001 se X009 tak sab Blocked hain
- Verdict: Blocked
- Evidence: X001 se X009 tak ke results
- Firebase verification: Koi nahi
- Defect ID: D002 aur D006
- Retest result: Saare steps pass hone ke baad dobara chalega

## NOTES

1. Koi password ya token is report me ya kisi script me nahi likha gaya hai.
2. Sirf QA data use karne ka order follow hua hai, par QA data banaya hi nahi ja saka, kyunki sign in gate ke aage jaana possible nahi hua.
3. Blocked ko Pass nahi banaya gaya hai. Jahan test hua hi nahi, wahan wahi likha hai.
4. User app ka alag web build nahi chalaya gaya, iska reason X001 me likha hai. Ye koi chhupa hua kaam nahi hai, saaf likha hai.
