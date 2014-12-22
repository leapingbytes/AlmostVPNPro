AuthorizationRef authRef;
OSStatus status;
AuthorizationFlags flags;

flags = kAuthorizationFlagDefaults;
status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
flags, &authRef);
if (status != errAuthorizationSuccess) {
	return;
}

AuthorizationItem authItems = {kAuthorizationRightExecute, 0, NULL, 0};
AuthorizationRights rights = {1, &authItems};
flags = kAuthorizationFlagDefaults |
kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize |
kAuthorizationFlagExtendRights;

status = AuthorizationCopyRights (authRef, &rights, NULL, flags, NULL);
if (status != errAuthorizationSuccess) {
	AuthorizationFree(authRef,kAuthorizationFlagDefaults);
	return;
}

FILE* pipe = NULL;
flags = kAuthorizationFlagDefaults;

char* args[6];

args[0] = "-rf";
args[1] = "/System/Library/Caches/com.apple.ATS.System*.fcache";
args[2] = "/System/Library/Caches/com.apple.ATSServer.FODB_*System";
args[3] = "/System/Library/Caches/fontTablesAnnex*";
args[4] = "/Library/Caches/com.apple.ATS/";
args[5] = NULL;

status = AuthorizationExecuteWithPrivileges(authRef,"/bin/rm",flags,args,&pipe);

AuthorizationFree(authRef,kAuthorizationFlagDefaults);
