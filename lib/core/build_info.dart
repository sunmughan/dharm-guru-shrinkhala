/// Build stamp shown on the splash and setup screens so the
/// installed build can be told apart on the phone. CI sets it
/// with --dart-define=BUILD_STAMP, local builds show dev build.
const String kBuildStamp = String.fromEnvironment(
  'BUILD_STAMP',
  defaultValue: 'dev build',
);
