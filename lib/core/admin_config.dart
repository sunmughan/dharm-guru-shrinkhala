/// Default admin account for the admin app, ordered by the owner.
/// The account is created through Firebase Auth on first launch of
/// the admin app (see AdminSeedService), never by skipping Auth:
/// sign in still checks the password against Firebase. Change the
/// password from the admin Account screen after the first sign in.
const String kDefaultAdminEmail = 'admin@gmail.com';
const String kDefaultAdminPassword = 'admin123';
