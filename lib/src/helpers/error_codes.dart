/*
  Error codes for authentication <ErrorCode, Name, Description>
    [900] `SUCCESSFUL LOGIN/ SIGNUP` - If the user gets succesfully signed in or logged in.

      *** Thrown by createUserWithEmailAndPassword() ***
    [901] `ERROR_WEAK_PASSWORD` - If the password is not strong enough. 
    [902] `ERROR_INVALID_CREDENTIAL` - If the email address is malformed.
    [903] `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.'

      *** Thrown by signInWithEmailAndPassword() ***
    [904] `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
    [905] `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
    [906] `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
    [907] `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
    
      *** Thrown by signInWithCredential() ***
    [908] `ERROR_INVALID_CREDENTIAL` - If the credential data is malformed or has expired.
    [909] `ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL` - If there already exists an account with the email address asserted by Google. 
           Resolve this case by calling [fetchSignInMethodsForEmail] and then asking the user to sign in using one of them.
    [910] `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Google accounts are not enabled.

    [911] `UNKNOWN_ERROR` - Unknown Error
    [912] 'REGISTRED_WITH_GOOGLE` - If the user is already registered using google.com account.
*/

class ErrorCodeSkeleton{
  int code;
  String name, userMessage;

  ErrorCodeSkeleton(int code, String name, String userMessage){
    this.code = code;
    this.name = name;
    this.userMessage = userMessage;
  }
}

class CustomFirebaseErrorCodes{
  static final List<ErrorCodeSkeleton> customFirebaseErrors = [
    ErrorCodeSkeleton(900, "SUCCESS", "None"),
    ErrorCodeSkeleton(901, "ERROR_WEAK_PASSWORD", "Password is too weak!"),
    ErrorCodeSkeleton(902, "ERROR_INVALID_CREDENTIAL", "Invalid Email!"),
    ErrorCodeSkeleton(903, "ERROR_EMAIL_ALREADY_IN_USE", "This email is already been registered"),
    ErrorCodeSkeleton(904, "ERROR_WRONG_PASSWORD", "Invalid password!"),
    ErrorCodeSkeleton(905, "ERROR_USER_NOT_FOUND", "No account registered with this email. Please Sign Up!"),
    ErrorCodeSkeleton(906, "ERROR_USER_DISABLED", "This account has been disabled!"),
    ErrorCodeSkeleton(907, "ERROR_TOO_MANY_REQUESTS", "Too many requests. Please try again later!"),
    ErrorCodeSkeleton(908, "ERROR_INVALID_CREDENTIAL", "Invalid Credentials!"),
    ErrorCodeSkeleton(909, "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL", "Account already exists with other login method!"),
    ErrorCodeSkeleton(910, "ERROR_OPERATION_NOT_ALLOWED", "Sign in/ Login disabled by Admin!"),
    ErrorCodeSkeleton(911, "UNKNOWN_ERROR", "Unknown Error!"),
    ErrorCodeSkeleton(912, "REGISTRED_WITH_GOOGLE", "Email already registered using Google account."),
    ErrorCodeSkeleton(913, "REGISTRED_WITH_FB_TWITTER", "Email already registered using Facebook/Twitter account."),
  ];
}