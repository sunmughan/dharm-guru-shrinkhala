# Dharm Guru Shrinkhala Phase 16 Admin App Browser Test Report

Ye report Roman Hindi aur English me hai. Isme hyphen sirf exact file names, branch names aur repo names ke andar hai, kyunki wo identifiers badle nahi ja sakte. Baaki poori prose me koi hyphen nahi hai.

## PHASE

Phase 16, admin app browser testing. Baseline release 10, HEAD `eb0c471`, CI run `46043847890` green, 111 tests. Kaam sirf admin app browser testing aur cross role testing tak limited hai.

## STATUS

Partial. Sign in gate tak browser me poora test hua aur pass hua. Sign in ke baad ke saare admin modules Blocked hain, kyunki QA accounts provision nahi hue, web Firebase config placeholder hai, aur sandbox Google APIs tak pahunch nahi pata. Task me list kiye gaye 7 modules ka code hi release 10 me nahi hai, wo Not Tested hain.

## IMPLEMENTED

1. Apna clone aur branch banayi, main ko haath nahi lagaya.
2. CI par admin web build ke liye QA workflow banaya, kyunki release 10 ke CI run me koi web artifact tha hi nahi, sirf 2 APK artifacts the.
3. CI se web build download karke local server par serve kiya aur Playwright headless Chromium se test kiya.
4. Sign in gate ke 10 browser tests chalaye, screenshots aur console logs capture kiye.
5. Har task module ka code inventory kiya, kya bana hai aur kya nahi, file aur line ke saath.
6. Koi dummy data nahi bhara, live production data ko haath nahi lagaya, koi destructive test nahi kiya, live deploy nahi kiya.

## FILES CHANGED

Branch `phase16-qa-admin` par, repo `sunmughan/dharm-guru-shrinkhala` me:

- `.github/workflows/qa-web-build.yml` (new, QA web build workflow)
- `docs/qa/ADMIN_APP_BROWSER_TEST_REPORT.md` (new, ye report)
- `docs/qa/ASTROLOGER_WORKFLOW_TEST_REPORT.md` (new, cross role workflow report)
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

Koi nahi. Live Firestore me koi document create, update ya delete nahi hua. Koi sign in kabhi success nahi hua. Admin seed ne har launch par Auth signUp call karne ki koshish ki, par sandbox network ne use roka, isliye koi account bana hi nahi. Firestore rules ko haath nahi lagaya.

## TESTS EXECUTED

Commands, exact:

- `gh run list --repo sunmughan/dharm-guru-shrinkhala --limit 5`
- `gh api repos/sunmughan/dharm-guru-shrinkhala/actions/runs/46043847890/artifacts`
- `gh run download 46056580700 --repo sunmughan/dharm-guru-shrinkhala --name dharm-guru-admin-web-qa --dir ./web-build`
- `gh run download 46057202658 --repo sunmughan/dharm-guru-shrinkhala --name dharm-guru-admin-web-qa --dir ./web-build`
- `gh run watch 46056580700 --repo sunmughan/dharm-guru-shrinkhala --exit-status`
- `gh run watch 46056995095 --repo sunmughan/dharm-guru-shrinkhala --exit-status`
- `gh run watch 46057202658 --repo sunmughan/dharm-guru-shrinkhala --exit-status`
- `python3 -m http.server 8317 --directory web-build`
- `node qa-run1.js` (run1, run3, run5, same harness, alag run folders)
- `node qa-run6.js` (run6, first interactive run)
- `node qa-run7.js` (run7, retest run, har step fresh load ke saath)

Test IDs: ADM001 se ADM029 tak, neeche table me.

## TEST RESULTS

Passed 8, Failed 0, Blocked 14, Not Tested 7. Pehle run6 ke ADM006 aur ADM007 inconclusive the, kyunki validation error aane ke baad layout neeche shift hua aur mere clicks purane coordinates par lage. Dono ko run7 me fresh load ke saath retest kiya, dono pass hue. Retest result har row me likha hai.

## BROWSER VERIFICATION

Playwright headless Chromium, cached build `chromium-1248`, viewport 1280x800 aur 390x844. Local server `http://127.0.0.1:8317/`, build CI run `46057202658` se. App boot hui, title `Dharm Guru Admin` dikha, sign in gate render hua. CDN substitution ka detail neeche Environment notes me hai. Screenshots `docs/qa/screenshots/` me hain, logs `docs/qa/browser-logs/` me hain.

## KNOWN DEFECTS

- D001 P2: Web build sandbox me boot nahi hoti jab tak CanvasKit, Firebase JS SDK aur fonts public CDN se na aayein. Sandbox `www.gstatic.com` aur `fonts.gstatic.com` ko block karta hai. Pehla run blank white screen par ruka. Evidence `run1-canvaskit-cdn-fail.txt`.
- D002 P2: Web Firebase config sirf placeholder hai. `lib/firebase_options.dart` me web values placeholder hain, console me koi web app register nahi hai. Isliye web par koi bhi sign in kabhi success nahi ho sakta. Evidence har run ke log me `PROJECT_ID_PLACEHOLDER` aur placeholder key wali Auth calls.
- D003 P1: Admin seed har pehle web launch par Auth signUp call karta hai, user ke kuch karne se pehle. Asli web config milte hi ye production Auth me default admin account bana dega, bina kisi se pooche. Evidence `lib/services/admin_seed_service.dart` aur har run ke log me `Admin seed failed` wali line. Master order me seed hatane ka order bhi hai, isliye ye jaldi decide hona chahiye.
- D004 P3: Continue with Google par tap karne se saare buttons 8 second tak disabled rehte hain aur koi error text nahi aata, jab Google script unreachable ho. Evidence `google-signin-busy.png` aur `run7-retest-interactive.txt`.
- D005 P3: Admin app ke sign in screen ka app bar `Dharm Guru Shrinkhala` dikhata hai, jo user app ka title hai, admin title nahi. Evidence `desktop-signin-1280.png`.
- D006 P2: Scope gap, runtime defect nahi. Task me list kiye 7 modules ka code release 10 me hai hi nahi: KYC, audit logs, calculation settings, user management screen, admin management screen, bookings, astrologer role workflows. Evidence neeche Not Tested rows me grep result ke saath.

## REMAINING WORK

1. QA accounts provision karna: owner admin, non owner user, aur ek astrologer account, taaki sign in ke baad ke modules test ho sakein.
2. Firebase console me web app register karna aur asli web config dena, taaki web build live Firebase se baat kar sake.
3. D001 ka fix: CanvasKit aur Firebase JS SDK ko self host karna ya loader config me local base URL dena.
4. D003 par decision: default admin seed hatana hai ya secure owner provisioning se replace karna hai.
5. D006 ke 7 missing modules ko Phase 16 implementation me banana, phir unka browser test dobara chalana.
6. Cross role workflow ka end to end browser test, jab QA accounts aur bookings flow ban jayein.

## NEXT PHASE

Phase 17 ya Phase 16 ka retest round, jab QA accounts aur web config mil jayein. Tab ADM011 se ADM029 tak ke Blocked tests aur cross role workflow dobara chalenge, isi harness se.

## ENVIRONMENT NOTES

Ye notes test result ko samajhne ke liye zaroori hain, bahana nahi hain.

1. Release 10 ke CI run `46043847890` me koi web artifact nahi tha, sirf 2 APK artifacts the. Isliye QA web build ke liye naya workflow banaya gaya. CI run `46056580700` green hua aur artifact `dharm-guru-admin-web-qa` mila.
2. CI run `46056995095` fail hua, kyunki Flutter 3.50.1 me `flutter build web` par `--web-renderer` option hai hi nahi, exit code 64 aaya. HTML renderer option ab Flutter me nahi hai.
3. CI run `46057202658` green hua, par `FLUTTER_WEB_CANVASKIT_URL` define ka koi asar nahi hua, engine phir bhi CDN se CanvasKit mangta raha. Iska reason `flutter_bootstrap.js` me loader logic hai, jo define ko ignore karta hai.
4. Sandbox me `www.gstatic.com`, `fonts.gstatic.com`, `accounts.google.com` aur `*.googleapis.com` blocked hain, `ERR_TUNNEL_CONNECTION_FAILED` aata hai. Isliye harness ne CDN URLs ko local files se serve kiya: CanvasKit ke liye wahi files jo CI build khud `build/web/canvaskit` me bundle karta hai, Firebase JS SDK 11.9.1 ke liye npm `firebase@11.9.1` package ki wahi files jo CDN serve karta hai, aur fonts ke liye local Roboto woff2. App ka code aur Firebase traffic bilkul asli raha, sirf CDN file delivery substitute hui. Ye mock live test nahi hai.
5. Fonts ke bina saara text blank render hota tha, sirf boxes dikhte the. Local Roboto milne ke baad text dikhne laga.
6. Flutter CanvasKit renderer text ko canvas par paint karta hai, DOM me nahi. Isliye DOM text probe hamesha khaali aata hai. Screen ki pehchan sirf screenshots se hui.

## ADMIN MODULE INVENTORY

Release 10 code me admin app ke ye screens bane hain, file `lib/screens/admin_screens.dart`:

- Dashboard, `AdminDashboardScreen`, line 852. Live counts users, astrologers, horoscopes se, earnings payments se.
- Astrologers, `AstrologersScreen`, line 1160. List, approve, reject, slots, add form.
- Daily Content, `DailyContentScreen`, line 1598. Horoscope grid 12 rashis aur panchang form.
- Chats, `AdminChatsScreen`, line 1509. Saare user chat rooms.
- Subscriptions, `SubscriptionsScreen`, line 2080. Plans aur payments list, refund record.
- Analytics, `AnalyticsScreen`, line 2442. Firestore aggregates aur charts.
- Notifications, `NotificationsScreenAdmin`, line 2846. Compose, draft, send, schedule.
- Moderation, `ModerationScreen`, line 3172. Chats, reports aur remedies ka queue, Reports tab ke saath.
- Account, `AdminAccountScreen`, line 3451. Profile, change email, change password, Google linking.

Admin gate: sirf ek role hai, `owner`. File `lib/services/firestore_service.dart`, function `isAdminUser`, seeded email check ya `admins` document me role `owner`. Koi lower role code me nahi hai. Firestore collections jo admin code use karta hai: `admins`, `astrologers`, `chats`, `horoscopes`, `moderation`, `notifications`, `panchang`, `payments`, `plans`, `users`. Rules file `firebase/firestore.rules`: owner hi likh sakta hai, payments aur moderation sirf owner padh sakta hai.

## TEST TABLE

Har row me: Test ID, Module, Feature, Preconditions, Test input, Action, Expected result, Actual result, Verdict, Evidence, Firebase verification, Defect ID, Retest result.

### ADM001 App boot desktop

- Module: Admin app shell
- Feature: Web build boot aur sign in gate render
- Preconditions: CI web build local server par serve ho rahi hai, CDN substitution active hai
- Test input: Koi nahi, bas page load
- Action: `http://127.0.0.1:8317/` khola, 15 second wait kiya, desktop 1280x800
- Expected result: App boot hoti hai aur sign in gate dikhta hai
- Actual result: App boot hui, title `Dharm Guru Admin` bana, sign in gate render hua, Email aur Password fields, Sign In button, Continue with Google button dikhe
- Verdict: Pass
- Evidence: `docs/qa/screenshots/desktop-signin-1280.png`, `docs/qa/browser-logs/run5-signin-gate.txt`
- Firebase verification: Firebase init hua, par placeholder config ke saath. Remote Config aur Messaging ke optional steps fail hue aur log hue, app phir bhi chali
- Defect ID: D001, D002 (environment, gate pass hone ke baad bhi note kiye)
- Retest result: Nahi chahiye tha

### ADM002 Reload persistence

- Module: Admin app shell
- Feature: Reload ke baad wahi screen
- Preconditions: ADM001 pass
- Test input: Koi nahi
- Action: Page reload kiya, 12 second wait kiya
- Expected result: Reload ke baad wahi sign in gate dikhe
- Actual result: Wahi sign in gate dikha, title wahi raha
- Verdict: Pass
- Evidence: `docs/qa/browser-logs/run5-signin-gate.txt`, log line `after reload same text=true`
- Firebase verification: Koi nahi, reload par koi document read ya write nahi hua
- Defect ID: Koi nahi
- Retest result: Nahi chahiye tha

### ADM003 Auth boundary probe

- Module: Admin login
- Feature: DOM me sign in form ki maujoodgi check
- Preconditions: ADM001 pass
- Test input: Koi nahi
- Action: DOM inputs aur body text probe kiye
- Expected result: Canvas renderer ki limit pata chale, DOM probe khaali aayega
- Actual result: DOM me koi input nahi mila, body text length 0 mili, kyunki CanvasKit text ko canvas par paint karta hai. Screen ki pehchan sirf screenshot se hui
- Verdict: Pass, method limit note ke saath
- Evidence: `docs/qa/browser-logs/run5-signin-gate.txt`, probe JSON
- Firebase verification: Koi nahi
- Defect ID: Koi nahi
- Retest result: Nahi chahiye tha

### ADM004 Mobile render 390px

- Module: Admin app shell
- Feature: Narrow viewport render
- Preconditions: ADM001 pass
- Test input: Koi nahi
- Action: 390x844 viewport par page khola, 12 second wait kiya
- Expected result: Sign in gate bina horizontal overflow ke dikhe
- Actual result: Gate saaf dikha, koi horizontal overflow nahi mila, saare controls readable the
- Verdict: Pass
- Evidence: `docs/qa/screenshots/mobile-signin-390.png`, `docs/qa/browser-logs/run5-signin-gate.txt`
- Firebase verification: Koi nahi
- Defect ID: Koi nahi
- Retest result: Nahi chahiye tha

### ADM005 Invalid email validation

- Module: Admin login
- Feature: Client side email validation
- Preconditions: Sign in gate dikh raha hai
- Test input: Email `notanemail`, password khaali
- Action: Email field par click kiya, text type kiya, Sign In par click kiya
- Expected result: Laal error `Enter a valid email address, like name@example.com.` dikhe, koi network call na ho
- Actual result: Wahi error laal rang me dikha, koi Auth network call log me nahi aayi
- Verdict: Pass
- Evidence: `docs/qa/screenshots/invalid-email-error.png`, `docs/qa/browser-logs/run6-first-interactive.txt`
- Firebase verification: Koi Auth call nahi hui, sahi hai
- Defect ID: Koi nahi
- Retest result: Nahi chahiye tha

### ADM006 Short password validation

- Module: Admin login
- Feature: Client side password length validation
- Preconditions: Sign in gate dikh raha hai
- Test input: Email `qa.probe@example.com`, password `abc`
- Action: Dono fields bhare, Sign In par click kiya
- Expected result: Laal error `Password must be at least 6 characters.` dikhe
- Actual result: Wahi error dikha
- Verdict: Pass
- Evidence: `docs/qa/screenshots/short-password-error.png`, `docs/qa/browser-logs/run7-retest-interactive.txt`
- Firebase verification: Koi Auth call nahi hui, sahi hai
- Defect ID: Koi nahi
- Retest result: Run6 me ye test inconclusive tha, kyunki purana error layout shift kar gaya tha aur click galat jagah laga. Run7 me fresh load ke saath retest kiya, pass hua

### ADM007 Probe sign in, real Auth boundary

- Module: Admin login
- Feature: Sign in attempt aur honest Auth error
- Preconditions: Sign in gate dikh raha hai, QA accounts nahi hain
- Test input: Email `qa.probe@example.com`, probe password string. Ye koi real account nahi hai, sirf QA probe input hai, aur koi real credential use nahi hua
- Action: Dono fields bhare, Sign In par click kiya, 8 second wait kiya
- Expected result: App real Auth call kare aur network failure par imaandaar error dikhaye, gate par hi rahe
- Actual result: Real `signInWithPassword` request `identitytoolkit.googleapis.com` par gayi aur network par fail hui. App ne laal error dikhaya `No internet connection. Check your connection and try again.` aur gate par hi rahi. Koi sign in nahi hua
- Verdict: Pass, boundary test ke taur par. Asli sign in Blocked hai, aage ADM011 se ADM029 dekho
- Evidence: `docs/qa/screenshots/probe-signin-network-error.png`, `docs/qa/browser-logs/run7-retest-interactive.txt`, log me `accounts:signInWithPassword?key=WEB_API_KEY_PLACEHOLDER` wali line
- Firebase verification: Koi document read ya write nahi hua, koi session nahi bana. Placeholder key ke saath request fail hui, sahi hai
- Defect ID: D002
- Retest result: Run6 me ye test inconclusive tha, stale coordinates ki wajah se submit hua hi nahi. Run7 me fresh load ke saath retest kiya, real Auth call hui aur error dikha

### ADM008 Create account mode

- Module: Admin login
- Feature: Sign in se create account mode switch
- Preconditions: Sign in gate dikh raha hai
- Test input: Koi nahi
- Action: `Create account` link par click kiya
- Expected result: Title `Create account` bane, Confirm password field dikhe, `Create Account` button dikhe, `Back to sign in` dikhe
- Actual result: Sab waisa hi dikha, Email, Password, Confirm password, Create Account button, Continue with Google, Back to sign in
- Verdict: Pass
- Evidence: `docs/qa/screenshots/create-account-mode.png`, `docs/qa/browser-logs/run7-retest-interactive.txt`
- Firebase verification: Koi account create nahi hua, sirf mode switch hua
- Defect ID: Koi nahi
- Retest result: Run6 me ye step galat control par click hua tha, kyunki layout shift hua tha. Run7 me fresh load ke saath retest kiya, pass hua

### ADM009 Forgot password mode

- Module: Admin login
- Feature: Forgot password mode switch
- Preconditions: Sign in gate dikh raha hai
- Test input: Koi nahi
- Action: `Forgot password?` link par click kiya
- Expected result: Title `Forgot password` bane, sirf Email field dikhe, `Send reset link` button dikhe, `Back to sign in` dikhe
- Actual result: Sab waisa hi dikha
- Verdict: Pass
- Evidence: `docs/qa/screenshots/forgot-password-mode.png`, `docs/qa/browser-logs/run7-retest-interactive.txt`
- Firebase verification: Koi reset email nahi bheja gaya, sirf mode switch hua
- Defect ID: Koi nahi
- Retest result: Run6 me ye step galat control par click hua tha. Run7 me fresh load ke saath retest kiya, pass hua

### ADM010 Continue with Google

- Module: Admin login
- Feature: Google sign in attempt
- Preconditions: Sign in gate dikh raha hai
- Test input: Koi nahi
- Action: `Continue with Google` par click kiya, 8 second wait kiya
- Expected result: Google sign in flow khule ya imaandaar error dikhe
- Actual result: Saare buttons disabled ho gaye aur 8 second tak koi error text nahi aaya. Google script `accounts.google.com/gsi/client` sandbox me blocked hai, isliye flow aage badha hi nahi
- Verdict: Blocked
- Evidence: `docs/qa/screenshots/google-signin-busy.png`, `docs/qa/browser-logs/run7-retest-interactive.txt`
- Firebase verification: Koi Google sign in nahi hua, koi session nahi bana
- Defect ID: D004
- Retest result: Blocked hi rahega jab tak sandbox Google script tak na pahunche ya real device par test na ho

### ADM011 Dashboard live metrics

- Module: Dashboard
- Feature: Live Firestore derived metrics
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Sign in ke baad Dashboard kholna tha
- Expected result: Users, astrologers, horoscopes ke live counts aur earnings dikhein
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result, `probe-signin-network-error.png`
- Firebase verification: Koi nahi, Firestore read hua hi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `AdminDashboardScreen`, line 852, `watchDocs` se users, astrologers, horoscopes aur payments padhta hai

### ADM012 User management

- Module: User management
- Feature: Search, open, update QA user
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA user
- Action: User management screen kholna tha
- Expected result: User list, search, profile open aur update
- Actual result: Screen hai hi nahi. Code me sirf `getUserProfile` aur Dashboard count ke liye users collection read hoti hai, koi user management screen nahi hai
- Verdict: Not Tested
- Evidence: Code grep, `lib/services/firestore_service.dart` line 99 aur line 112, `lib/screens/admin_screens.dart` me koi Users screen nahi hai
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Implementation ke baad test hoga

### ADM013 Admin management

- Module: Admin management
- Feature: Role based restrictions, admin list aur role change
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Admin management screen kholna tha
- Expected result: Admin list aur role controls dikhein
- Actual result: Screen hai hi nahi. Sirf owner role hai, `isAdminUser` function me. Admins collection sirf gate check ke liye use hoti hai
- Verdict: Not Tested
- Evidence: Code grep, `lib/services/firestore_service.dart` line 54 se 98
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Implementation ke baad test hoga

### ADM014 Astrologer management

- Module: Astrologer management
- Feature: QA astrologer review, approve, reject, slots, add form
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA astrologer
- Action: Astrologers screen kholna tha
- Expected result: List, approve, reject, slots aur add form kaam karein
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `AstrologersScreen`, line 1160

### ADM015 KYC submit aur review

- Module: KYC
- Feature: KYC submit aur review
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA KYC
- Action: KYC queue kholna tha
- Expected result: KYC submit aur review flow dikhe
- Actual result: KYC ka code hai hi nahi. Case insensitive grep me sirf `lucky` shabd ke andar `kyc` letters mile, jo false match hai. Koi KYC collection, screen ya field nahi hai
- Verdict: Not Tested
- Evidence: Code grep, `lib/` me `kyc` ka koi asli match nahi hai
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Implementation ke baad test hoga

### ADM016 Astrology library create edit version

- Module: Astrology library
- Feature: Library rule create, edit, version
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA rule
- Action: Library admin screen kholna tha
- Expected result: Rule create, edit aur version dikhe
- Actual result: Admin app me library screen hai hi nahi. Library sirf user app me hai, `lib/services/library_content.dart`, admin usko manage nahi kar sakta
- Verdict: Not Tested
- Evidence: Code grep, admin screens list me koi Library screen nahi hai
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Implementation ke baad test hoga

### ADM017 Calculation settings

- Module: Calculation settings
- Feature: Permitted QA configuration update
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA configuration
- Action: Calculation settings screen kholna tha
- Expected result: Settings dikhein aur update ho
- Actual result: Settings ka code hai hi nahi. Engine `lib/services/astro.dart` me hardcoded logic hai, koi settings screen ya collection nahi hai
- Verdict: Not Tested
- Evidence: Code grep, `lib/` me calculation settings ka koi match nahi hai
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Implementation ke baad test hoga

### ADM018 Panchang management

- Module: Panchang management
- Feature: Regional content create aur edit
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA panchang
- Action: Daily Content me panchang form kholna tha
- Expected result: Panchang form dikhe aur save ho
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Form bana hua hai, `_PanchangForm`, line 1920, Daily Content screen ke andar

### ADM019 Content management

- Module: Content management
- Feature: Create, edit, publish QA content, horoscope grid
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA content
- Action: Daily Content screen kholna tha
- Expected result: Horoscope grid aur publish kaam kare
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `DailyContentScreen`, line 1598, `_HoroscopeGrid` line 1701

### ADM020 Subscription plans

- Module: Subscription plans
- Feature: Create aur update QA plan
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA plan
- Action: Subscriptions screen kholna tha
- Expected result: Plan create aur update kaam kare
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `SubscriptionsScreen`, line 2080, plans collection se

### ADM021 Payments

- Module: Payments
- Feature: Actual transaction records inspect aur refund record
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Subscriptions screen me payments list kholna tha
- Expected result: Payment records dikhein aur refund record ho
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Payments list bana hua hai, line 2265, refund record line 2394

### ADM022 Consultations

- Module: Consultations
- Feature: Inspect aur update QA booking
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA booking
- Action: Consultations ya chats kholna tha
- Expected result: Booking dikhe, accept ya reject ho
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua. Upar se bookings ka code hi nahi hai, sirf chats hain, aur Analytics me `Consult bookings` sirf ek label hai, line 2605
- Verdict: Blocked
- Evidence: ADM007 ka boundary result, code grep me `booking` ka koi collection ya flow nahi hai
- Firebase verification: Koi nahi
- Defect ID: D002 aur D006
- Retest result: QA accounts, web config aur bookings implementation milne par dobara chalega
- Code note: `AdminChatsScreen`, line 1509, chats ke liye bana hua hai

### ADM023 Notifications

- Module: Notifications
- Feature: Test notification send aur schedule
- Preconditions: Owner admin se sign in hona chahiye
- Test input: QA notification
- Action: Notifications screen kholna tha
- Expected result: Compose, draft, send aur schedule kaam kare
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `NotificationsScreenAdmin`, line 2846. Device push delivery ke liye console composer ya Cloud Function chahiye, admin app khud FCM nahi bhejta

### ADM024 Reports

- Module: Reports
- Feature: Generate aur inspect reports
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Reports generate karna tha
- Expected result: Report generate ho aur dikhe
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua. Upar se reports generate karne ka code hi nahi hai, sirf Moderation screen me Reports tab hai jo queue dikhata hai
- Verdict: Blocked
- Evidence: ADM007 ka boundary result, code grep
- Firebase verification: Koi nahi
- Defect ID: D002 aur D006
- Retest result: QA accounts, web config aur report generation implementation milne par dobara chalega
- Code note: `ModerationScreen`, line 3172, Reports tab line 3227

### ADM025 Analytics

- Module: Analytics
- Feature: Actual aggregate values
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Analytics screen kholna tha
- Expected result: Firestore se asli aggregate values dikhein
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `AnalyticsScreen`, line 2442

### ADM026 Audit logs

- Module: Audit logs
- Feature: Privileged actions recorded
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Audit log screen kholna tha
- Expected result: Privileged actions ka log dikhe
- Actual result: Audit ka code hai hi nahi. `lib/` me audit shabd ka ek bhi match nahi hai, koi audit collection ya screen nahi hai
- Verdict: Not Tested
- Evidence: Code grep, `lib/` me audit ka zero match
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Implementation ke baad test hoga

### ADM027 Security lower roles

- Module: Security
- Feature: Prohibited operations lower roles se attempt karna
- Preconditions: Lower role account hona chahiye
- Test input: Koi nahi
- Action: Lower role se prohibited operation attempt karna tha
- Expected result: Operation block ho aur denied dikhe
- Actual result: Lower role hai hi nahi. Gate me sirf owner role hai, baaki sab ko denied screen milti hai. Test karne ke liye koi lower role account nahi hai aur na hi code me koi lower role hai
- Verdict: Not Tested
- Evidence: Code grep, `isAdminUser` sirf owner check karta hai, `lib/services/firestore_service.dart` line 67 se 76
- Firebase verification: Koi nahi
- Defect ID: D006
- Retest result: Role design banne ke baad test hoga

### ADM028 Admin denied screen non owner

- Module: Security
- Feature: Non owner signed in user ko denied screen dikhe
- Preconditions: Non owner QA account hona chahiye
- Test input: Koi nahi
- Action: Non owner account se sign in karna tha
- Expected result: Denied screen dikhe, admin screens kabhi na khulein
- Actual result: Test ho hi nahi paya, koi QA account nahi hai
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: Non owner QA account milne par dobara chalega
- Code note: Screen bana hua hai, `_AdminDeniedScreen`, line 372

### ADM029 Account change email password

- Module: Account
- Feature: Change email aur change password
- Preconditions: Owner admin se sign in hona chahiye
- Test input: Koi nahi
- Action: Account screen kholna tha
- Expected result: Change email aur change password dikhein
- Actual result: Test ho hi nahi paya, sign in gate ke aage jaana possible nahi hua
- Verdict: Blocked
- Evidence: ADM007 ka boundary result
- Firebase verification: Koi nahi
- Defect ID: D002
- Retest result: QA accounts aur web config milne par dobara chalega
- Code note: Screen bana hua hai, `AdminAccountScreen`, line 3451

## NOTES

1. Koi password ya token is report me ya kisi script me nahi likha gaya hai. Default admin credential ka zikr bhi nahi kiya gaya hai, sirf itna likha hai ke seed service usko use karti hai.
2. Probe input `qa.probe@example.com` koi real user nahi hai. Wo request kabhi asli project tak pahunchi hi nahi.
3. Run6 ke ADM006, ADM007, ADM008 aur ADM009 ke pehle attempts inconclusive the, harness ki coordinate galti ki wajah se. Unko chhupaya nahi gaya hai, retest ke saath upar likha hai.
4. Blocked ko Pass nahi banaya gaya hai. Jahan test hua hi nahi, wahan wahi likha hai.
