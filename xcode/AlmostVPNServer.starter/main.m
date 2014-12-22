#include <JavaVM/jni.h>
#include <Security/Security.h>
#include <LBToolbox/LBToolbox.h>
#include <openssl/md5.h>
#include <unistd.h>


#include "almostvpn_jar_md5.h"

static int _debug_mode_ = 0;

#ifndef ALMOSTVPN_JAR_MD5
#define ALMOSTVPN_JAR_MD5 NULL
#endif

#ifndef INSTALL_SH_MD5
#define INSTALL_SH_MD5 NULL
#endif

#ifndef CLEANUP_SH_MD5
#define CLEANUP_SH_MD5 NULL
#endif

#include "/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNJNI.macosx/com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider.h"
#include "/Users/atchijov/Work/LeapingBytes/AlmostVPNPRO/xcode/AlmostVPNJNI.macosx/com_leapingbytes_almostvpn_util_macosx_KeychainMasterPasswordProvider.h"


const JNINativeMethod	_KeychainMasterPasswordProvider_nativeMethods[] = {
	// { name, signature, fnPtr }
	{ 
		"getKeychainPassword", 
		"(Ljava/lang/String;Ljava/lang/StringBuffer;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;", 
		Java_com_leapingbytes_almostvpn_util_macosx_KeychainMasterPasswordProvider_getKeychainPassword 
	},
	{ 
		"setKeychainPassword", 
		"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V", 
		Java_com_leapingbytes_almostvpn_util_macosx_KeychainMasterPasswordProvider_setKeychainPassword 
	}
};
const JNINativeMethod	_SystemConfigurationProvider_nativeMethods[] = {
	// { name, signature, fnPtr }
	{ 
		"getConfigurationObject", 
		"(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;", 
		Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_getConfigurationObject 
	},
	{ 
		"setProxyEnabled", 
		"(Ljava/lang/String;Z)V", 
		Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_setProxyEnabled 
	},
	{ 
		"setProxyHost", 
		"(Ljava/lang/String;Ljava/lang/String;)V", 
		Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_setProxyEnabled 
	},
	{ 
		"setProxyPort", 
		"(Ljava/lang/String;I)V", 
		Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_setProxyPort
	},
	{ 
		"getDHCPOption", 
		"(I)Ljava/lang/String;", 
		Java_com_leapingbytes_almostvpn_util_macosx_SystemConfigurationProvider_getDHCPOption
	},
};

static const char* _almostvpn_jar_md5 = ALMOSTVPN_JAR_MD5;
static const char* _install_sh_md5 = INSTALL_SH_MD5;
static const char* _cleanup_sh_md5 = CLEANUP_SH_MD5;

static const char* _build_date = BUILD_DATE;
#pragma unused( _build_date )

unsigned char _hex_digits [] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
 
int halfByteToChar( int byte, int oddEven ) {
	byte = ( oddEven ? byte : byte >> 4 ) & 0xf; 
	if( byte >= 0 && byte < 16  ) {
		return _hex_digits[ byte ];
	} else {
		return -1;
	}
}

int checkFileMD5( const char* fileName, const char* md5String ) {
	if( md5String == NULL ) {
		fprintf( stderr, "AlmostVPNServer : checkFileMD5 : md5 for %s == NULL\n", fileName );
		return 0;
	}

	MD5_CTX c;
	MD5_Init( &c );
	
	FILE* f = fopen( fileName, "r" );
	if( f == NULL ) {
		fprintf( stderr, "AlmostVPNServer : checkFileMD5 : can not open %s for reading\n", fileName );
		return -1;
	}
	unsigned char* buffer = malloc( 64*1024 );
	int rc;
	int size = 0;
	while(( rc = fread( buffer, 1, 64*1024, f )) > 0 ) {
		MD5_Update( &c, buffer, rc );
		size += rc;
	}
	fclose( f );	
	MD5_Final( buffer, &c );
	
	char md5[ MD5_DIGEST_LENGTH * 2 + 1 ]; // 2 char per byte + '0'
	int i, j = 0;
	for( i = 0; i < MD5_DIGEST_LENGTH; i++ ) {
		int theByte = buffer[ i ];
		md5[ j++ ] = halfByteToChar( theByte, 0 );
		md5[ j++ ] = halfByteToChar( theByte, 1 );
	}
	md5[ j ] = 0;
	
	free( buffer );
	
	if( _debug_mode_ ) {
		fprintf( stderr, "AlmostVPNServer : checkFileMD5 : md5(%s) = %s/%s\n", fileName, md5String, md5 );
	}
	
	return strcmp( md5String, md5 );
}

int checkAlmostVPNJarMd5() {
	return checkFileMD5( "AlmostVPN.jar", _almostvpn_jar_md5 );
}

int checkInstallShMd5() {
	return checkFileMD5( "install.sh", _install_sh_md5 );
}

int checkCleanupShMd5() {
	return checkFileMD5( "cleanup.sh", _cleanup_sh_md5 );
}

void registerNativeFunctions( JNIEnv* env ) {
	fprintf( stderr, "AlmostVPNServer : Register Natives : START\n" );
	char* className;
   	jclass KeychainMasterPasswordProviderClazz =(*env)->FindClass( 
		env, 
		className = "com/leapingbytes/almostvpn/util/macosx/KeychainMasterPasswordProvider"
	);   	
	if( KeychainMasterPasswordProviderClazz == NULL ) {
		fprintf( stderr, "AlmostVPNServer : Fail to FindClass : %s\n", className );
	} else {
		(*env)->RegisterNatives( 
			env, 
			KeychainMasterPasswordProviderClazz, 
			_KeychainMasterPasswordProvider_nativeMethods, 
			sizeof(_KeychainMasterPasswordProvider_nativeMethods) / sizeof(JNINativeMethod)  
		);
	}

   	jclass SystemConfigurationProviderClazz =(*env)->FindClass( 
		env, 
		className = "com/leapingbytes/almostvpn/util/macosx/SystemConfigurationProvider"
	);   	
	if( SystemConfigurationProviderClazz == NULL ) {
		fprintf( stderr, "AlmostVPNServer : Fail to FindClass : %s\n", className );
	} else {
		(*env)->RegisterNatives( 
			env, 
			SystemConfigurationProviderClazz, 
			_SystemConfigurationProvider_nativeMethods, 
			sizeof(_SystemConfigurationProvider_nativeMethods) / sizeof(JNINativeMethod)  
		);
	}
	fprintf( stderr, "AlmostVPNServer : Register Natives : END\n" );	       
}

void startJVM( int argc, const char** argv ) {
	JavaVM*			jvm = NULL;       /* denotes a Java VM */
    JNIEnv*			env = NULL;       /* pointer to native method interface */
    JavaVMInitArgs 	vm_args;
    JavaVMOption 	options[10];
	int				i;

	if( _debug_mode_ ) {
		fprintf( stderr, "AlmostVPNServer : Starting JVM : argc = %d\n", argc );
	}

    int oi = 0;
	if( _debug_mode_ ) {
		options[oi++].optionString = strdup( "-Xdebug" );
		options[oi++].optionString = strdup( "-Xnoagent" );
		options[oi++].optionString = strdup( "-Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n" );
	}
	options[oi++].optionString = strdup( "-Djava.awt.headless=true" );
   	options[oi++].optionString = strdup( "-Djava.class.path=AlmostVPN.jar:/System/Library/Frameworks/JavaVM.framework/Classes/classes.jar:." );
    options[oi++].optionString = strdup( "-Djava.library.path=/System/Library/Frameworks/JavaVM.framework/Libraries:." );
	
	if( _debug_mode_ ) {
		for( i = 0; i < oi; i++ ) {
			fprintf( stderr, "AlmostVPNServer : options[ %d ] = %s\n", i, options[ i ] );
		}
	}

    vm_args.version = JNI_VERSION_1_4;
    vm_args.options = options;
    vm_args.nOptions = oi;
    vm_args.ignoreUnrecognized = 1;
 
    setenv("JAVA_JVM_VERSION", "1.4", 1);

    JNI_CreateJavaVM( &jvm, (void**)&env, &vm_args );
	
	if( jvm == NULL ) {
		fprintf( stderr, "AlmostVPNServer : Fail to CreateJavaVM\n" );
		return;
	}
	
   	jclass stringClazz =(*env)->FindClass( env, "java/lang/String");   	

	registerNativeFunctions( env );
	
    jclass serverClazz = (*env)->FindClass( env, "com/leapingbytes/almostvpn/server/ToolServer");

    jmethodID mid = (*env)->GetStaticMethodID( env, serverClazz, "main", "([Ljava/lang/String;)V");

    jarray jArgv = (*env)->NewObjectArray( env, argc-1, stringClazz, NULL );

    for( i = 2; i < argc; i++ ) {
		fprintf( stderr, "AlmostVPNServer : args[ %d ] = %s\n", i, argv[ i ] );
    	jstring jArg = (*env)->NewStringUTF( env, argv[ i ] );
    	(*env)->SetObjectArrayElement( env, jArgv, i-2, jArg );
    }
	if( _debug_mode_ ) {
    	jstring jArg = (*env)->NewStringUTF( env, "-debug" );
    	(*env)->SetObjectArrayElement( env, jArgv, i-2, jArg );
	}

	if( _debug_mode_ ) {
		fprintf( stderr, "AlmostVPNServer : Invoking ToolServer.main\n" );
	}

    (*env)->CallStaticVoidMethod(env, serverClazz, mid, jArgv );

	if( _debug_mode_ ) {
		fprintf( stderr, "AlmostVPNServer : ToolServer.main is done\n" );
	}
}

static OSStatus ToolCommandProc( AuthorizationRef auth, CFDictionaryRef _request, CFDictionaryRef *_result) {
	*_result = CFDictionaryCreateCopy( NULL, _request );
	return 0;
}

char* buildCommand( const char* prefix, const char** argv, const int argcStart, const int argcEnd ) {
	int totalLen = strlen( prefix ) + 1;
	int i;
	for( i = argcStart; i < argcStart; i++ ) {
		totalLen += strlen( argv[ i ] );
		totalLen += 3; // '"'x2 + ' '
	}
	char* result = malloc( totalLen );
	strcpy( result, prefix );
	for( i = argcStart; i < argcStart; i++ ) {
		strcat( result, " \"" );
		strcat( result, argv[ i ] );
		strcat( result, "\"" );
	}	
	return result;
}

int main( int argc, const char** argv ) {
	if(( argc > 1 ) && (( strcmp( "--startJVM", argv[1] ) == 0 ) || ( strcmp( "--debugJVM", argv[1] ) == 0 ))) {
		_debug_mode_ = strcmp( "--debugJVM", argv[1] ) == 0;
		
		if( setuid( 0 )) {
			fprintf( stderr, "AlmostVPNServer : Fail to setuid(0);\n" );
		}
		if( checkAlmostVPNJarMd5() ) {
			fprintf( stderr, "AlmostVPNServer : AlmostVPN.jar is corupted;\n" );
			if( ! _debug_mode_ ) {
				return 1;
			}
		}
		startJVM( argc, argv );
		if( checkCleanupShMd5()) {
			system("./cleanup.sh");			
		}
		return 0;
	}
	if(( argc > 1 ) && ( strcmp( "--startService", argv[1] ) == 0 )) {
		if( setuid( 0 )) {
			fprintf( stderr, "AlmostVPNServer : Fail to setuid(0);\n" );
		}
		if( fork() == 0 ) {
			system("/sbin/SystemStarter start AlmostVPN");
		}
		return 0;
	}
	if(( argc > 1 ) && ( strcmp( "--restartService", argv[1] ) == 0 )) {
		if( setuid( 0 )) {
			fprintf( stderr, "AlmostVPNServer : Fail to setuid(0);\n" );
		}
		if( fork() == 0 ) {
			system("/sbin/SystemStarter restart AlmostVPN");
		}
		return 0;
	}
	if(( argc > 1 ) && ( strcmp( "--stopService", argv[1] ) == 0 )) {
		if( setuid( 0 )) {
			fprintf( stderr, "AlmostVPNServer : Fail to setuid(0);\n" );
		}
		if( fork() == 0 ) {
			system("/usr/bin/nohup /sbin/SystemStarter stop AlmostVPN");
		}
		return 0;
	}
	if(( argc > 1 ) && ( strcmp( "--installService", argv[1] ) == 0 )) {
		if( setuid( 0 )) {
			fprintf( stderr, "AlmostVPNServer : Fail to setuid(0);\n" );
		}
		if( checkInstallShMd5()) {
			fprintf( stderr, "AlmostVPNServer : install.sh is corupted;\n" );
			if( ! _debug_mode_ ) {
				return 1;
			}
		}
		if( fork() == 0 ) {
			signal( SIGHUP, SIG_IGN);
			signal( SIGINT, SIG_IGN);
			signal( SIGINT, SIG_IGN);
			signal( SIGKILL, SIG_IGN);
			char* command = buildCommand( "./install.sh installStartupItem", argv, 2, argc );
			system(command);
		}
		return 0;
	}
	if(( argc > 1 ) && ( strcmp( "--uninstallService", argv[1] ) == 0 )) {
		if( setuid( 0 )) {
			fprintf( stderr, "AlmostVPNServer : Fail to setuid(0);\n" );
		}
		if( checkInstallShMd5()) {
			fprintf( stderr, "AlmostVPNServer : install.sh is corupted;\n" );
			if( ! _debug_mode_ ) {
				return 1;
			}
		}
		if( fork() == 0 ) {
			signal( SIGHUP, SIG_IGN);
			signal( SIGINT, SIG_IGN);
			signal( SIGINT, SIG_IGN);
			signal( SIGKILL, SIG_IGN);
			char* command = buildCommand( "./install.sh uninstallStartupItem", argv, 2, argc );
			system(command);
		}
		return 0;
	} 
	if(( argc > 1 ) && ( strcmp( "--version", argv[1] ) == 0 )) {
		printf( "%s : %s\n", _build_date, _almostvpn_jar_md5 == NULL ? "NULL" : _almostvpn_jar_md5 );
		return 0;
	}
	int 				err;
	AuthorizationRef 	auth;
	
	auth = MoreSecHelperToolCopyAuthRef();
	
	err = MoreSecDestroyInheritedEnvironment(kMoreSecKeepStandardFilesMask, argv);
	if (err == 0) {
		err = MoreUNIXIgnoreSIGPIPE();
	}
	if (err == 0) {
		err = MoreSecHelperToolMain(STDIN_FILENO, STDOUT_FILENO, auth, ToolCommandProc, argc, argv);
	}
	
	return MoreSecErrorToHelperToolResult(err);		
    
}
