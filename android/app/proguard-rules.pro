# Dharm Guru release keep rules.
#
# Release 5 (0.1.0+3) shipped a dex that was missing the Firebase
# implementation classes: FirebaseApp, FirebaseOptions,
# ComponentRuntime, FirebaseInstallations, FirebaseRemoteConfig,
# FirebaseCrashlytics, FlutterFirebaseCorePlugin and
# FlutterFirebaseCrashlyticsPlugin were all gone, while the
# manifest referenced registrars survived. R8 shrinking removed
# every class that is only reached by reflection or manifest
# discovery, so Firebase init had no working core and startup fell
# into the setup screen with a missing Crashlytics component error.
# The Firebase SDKs ship their own consumer rules, but those did
# not keep the implementation classes in this build, so these
# explicit keeps are the fix. Do not remove them.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.internal.firebase-auth-api.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
-keep class com.google.firebase.components.** { *; }
