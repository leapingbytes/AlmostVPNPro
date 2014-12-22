#include "com_leapingbytes_almostvpn_util_macosx_KeychainMasterPasswordProvider.h"
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <stdlib.h>
#include <memory.h>

typedef signed char		BOOL; 
#define YES             (BOOL)1
#define NO              (BOOL)0

char* strndup( char* characters, int length ) {
	char* result = malloc( length + 1 );
	strncpy( result, characters, length );
	result[ length ] = 0;
	return result;
}

char* getStringUTFChars( JNIEnv* env, jstring string ) {
	if( string == NULL ) {
		return NULL;
	}
	
	const char* utf8Chars = (*env)->GetStringUTFChars( env, string, NULL );
	
	char* result = malloc( strlen( utf8Chars ) + 1 );
	strcpy( result, utf8Chars );
	
	(*env)->ReleaseStringUTFChars( env, string, utf8Chars );
	
	return result;
}

jstring newStringUTF( JNIEnv* env, char* characters, int length ) {

	length = length == 0 ? strlen( characters ) : length;
	
	char* utf8Chars = strndup( characters, length );
	
	jstring	result = (*env)->NewStringUTF( env, utf8Chars );
	
	free( utf8Chars );
	
	return result;
}

char*	toString( JNIEnv* env, jobject object ) {
	if( object == NULL ) {
		return strdup( "" );
	}
	
	jclass stringClazz = (*env)->FindClass( env, "java/lang/String" );
	
	if( stringClazz == NULL ) {
		fprintf( stderr, "toString : fail to find java.lang.String\n" );
	}
	
	if( ! (*env)->IsInstanceOf( env, object, stringClazz )) {
		jclass clazz = (*env)->GetObjectClass( env, object );		
		jmethodID toStringMethod = (*env)->GetMethodID( env, clazz, "toString", "()Ljava/lang/String;" );
		
		if( toStringMethod == NULL ) {
			fprintf( stderr, "toString : fail to find toSrtring ()Ljava/lang/String;\n" );
		}
		
		object = (*env)->CallObjectMethod( env, object, toStringMethod );
	}
	
	return getStringUTFChars( env, object );
}

void appendString( JNIEnv* env, jobject stringBuffer, char* characters ) {
	jclass stringBufferClazz = (*env)->GetObjectClass( env, stringBuffer );
	
	jmethodID appendStringMethod = (*env)->GetMethodID( env, stringBufferClazz, "append", "(Ljava/lang/String;)Ljava/lang/StringBuffer;" );
	
	
	if( appendStringMethod == NULL ) {
		fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.appendString : Fail to get append(String) method\n" );
		return;
	}
	
	jstring string = newStringUTF( env, characters, 0 );
	
	(*env)->CallObjectMethod( env, stringBuffer, appendStringMethod, string );
}

/*
	private native String getKeychainPassword( 
		String type,
		String account,
		String serverName,
		String path,
		String keychainPath
	);

 */
SecKeychainRef getKeychain( JNIEnv* env, jstring jKeychainPath ) {

	SecKeychainRef result = (SecKeychainRef)nil;
	SecKeychainStatus status = 0;
	OSStatus err = 0;
	
	const char* aPath = jKeychainPath == NULL ? NULL : (*env)->GetStringUTFChars( env, jKeychainPath, NULL );	
	
	if( jKeychainPath == NULL ) {
		err = SecKeychainCopyDefault( &result );
	} else {
		err = SecKeychainOpen( aPath, &result );	
	}
	if( err == 0 && ( result != nil )) {
		err = SecKeychainGetStatus( result, &status );
	}

	if( err || ( status == 0 )) {
		fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.getKeychain : Fail to get keychain %s : %d:%d\n", 
			(aPath == NULL) ? "DEFAULT" : aPath, err, status );
	}
	
	if( aPath != NULL ) {
		(*env)->ReleaseStringUTFChars( env, jKeychainPath, aPath );	
	}
	
	if( err || ( status == 0 )) {
		return NULL;
	} else {
		char* path = malloc( 1024 + 1 ); path[0] = 0;
		UInt32 pathLen = 1024;
		
		SecKeychainGetPath( result, &pathLen, path );
		
		fprintf( stderr, "AlmostVPN : keychain path = %s\n", path );
		
		return result;
	}
}

SecProtocolType stringToSecProtocolType( const char* str ) {
	SecProtocolType result = 0;
	for( int i = 0; i < 4; i++ ) {
		int byte = ( str[ i ] == 0 ? ' ' : str[ i ]) & 0xff;
		result = ( result << 8 ) + byte;
	}
	return result;
}

SecAccessRef createAccessWithLabel( char* label ) {
	OSStatus err;
    SecAccessRef access=nil;
    SecTrustedApplicationRef myself;
	
    err = SecTrustedApplicationCreateFromPath( NULL, &myself );
	
	if( err != noErr ) {
		fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.createAccessWithLabel : SecTrustedApplicationCreateFromPath Failed\n");
		return NULL;
	}
	
    CFMutableArrayRef trustedApplications= CFArrayCreateMutable( nil, 1, &kCFTypeArrayCallBacks );
	CFArrayAppendValue( trustedApplications, myself );
	
	CFStringRef cfLabel = CFStringCreateWithCString( NULL, label, kCFStringEncodingUTF8 );
    err = SecAccessCreate(cfLabel, (CFArrayRef)trustedApplications, &access);
    if (err) { 
		fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.createAccessWithLabel : Fail with label %s : %d\n", 
			label, err  );
		return nil;
	}
    
	return access;
}


JNIEXPORT jstring JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_KeychainMasterPasswordProvider_getKeychainPassword
  	( 
  		JNIEnv* env, 
  		jobject this, 
  		jstring jType,
  		jstring jAccount, 
  		jstring jServerName,
  		jstring jPath, 
  		jstring jKeychainPath
  	) 
{
	SecKeychainRef keychain = getKeychain( env, jKeychainPath );
	
//	if( keychain == NULL ) {
//		return NULL;
//	}

	UInt32 length;
	void* data;
	
	SecKeychainSetUserInteractionAllowed( YES );
	
	const char* type = jType == NULL ? strdup( "ssh" ) : toString( env, jType );
	char* serverName = toString( env, jServerName );
	int port = 0;
	char* colPtr = NULL;
	
	if(( colPtr = strchr( serverName, ':' )) != NULL ) {
		port = atoi( colPtr + 1 );
		(*colPtr) = 0;
	}	
	
	const char* account = toString( env, jAccount );
	const char* path = toString( env, jPath );
	
//	printf( "keychain = %x\n", keychain );
//	printf( "type = 0x%x\n", stringToSecProtocolType( type ));
//	printf( "%s %s:%d '%s' '%s'\n", type, serverName, port, account, path );
	
	SecKeychainItemRef	itemRef = NULL;
	
	OSStatus status = SecKeychainFindInternetPassword(
		keychain,
		strlen( serverName ), serverName,
		0, nil,
		strlen( account ), account,
		strlen( path ), path,
		port,
		stringToSecProtocolType( type ),
		0,
		&length, &data,
		&itemRef
	);	
	
	jstring jResult = NULL;

	if( status ) {
		fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.JNI_getKeychainPassword : SecKeychainFindInternetPassword Failed %d\n", status );

		jResult = NULL;
	} else {
		jResult = newStringUTF( env, data, length );
		
		if( strlen( account ) == 0 ) {
			struct SecKeychainAttributeList *attrList = NULL;

			//first, grab the username.
			UInt32    tags[] = { kSecAccountItemAttr };
			UInt32 formats[] = { CSSM_DB_ATTRIBUTE_FORMAT_STRING };
			struct SecKeychainAttributeInfo info = {
				.count  = 1,
				.tag    = tags,
				.format = formats,
			};
			int err = SecKeychainItemCopyAttributesAndData(itemRef,&info,NULL,&attrList,0,NULL);

			// [NSString stringWithBytes:attrList->attr[0].data length:attrList->attr[0].length encoding:NSUTF8StringEncoding];
			
			char* accountName = strndup( attrList->attr[0].data, attrList->attr[0].length );
			
			appendString( env, jAccount, accountName );
			
			SecKeychainItemFreeAttributesAndData(attrList, NULL );

		}
	}	

	free( type );
	free( serverName );
	free( account );
	free( path );
	
	if( keychain != NULL ) {
		CFRelease( keychain );
	}
		
	return jResult;
}

JNIEXPORT void JNICALL 
	Java_com_leapingbytes_almostvpn_util_macosx_KeychainMasterPasswordProvider_setKeychainPassword
  	( 
  		JNIEnv* env, 
  		jobject this,
  		jstring jPassword, 
  		jstring jType,
  		jstring jAccount, 
  		jstring jServerName,
  		jstring jPath, 
  		jstring jKeychainPath
  	) 
{
	SecKeychainRef keychain = getKeychain( env, jKeychainPath );
	
//	if( keychain == NULL ) {
//		return;
//	}

	const char* password = (*env)->GetStringUTFChars( env, jPassword, NULL );
	const char* type = jType == NULL ? "ssh" : (*env)->GetStringUTFChars( env, jType, NULL );
	const char* serverName = (*env)->GetStringUTFChars( env, jServerName, NULL );
	
	const char* account = (*env)->GetStringUTFChars( env, jAccount, NULL );
	
	const char* path = jPath == NULL ? "" : (*env)->GetStringUTFChars( env, jPath, NULL );
	
	fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.JNI_setKeychainPassword : %s://%s@%s%s", type, account, serverName, path );
	
	SecKeychainItemRef	itemRef = nil;
	OSStatus status = SecKeychainFindInternetPassword(
		keychain,
		strlen( serverName ), serverName,
		0, nil,
		strlen( account ), account,
		strlen( path ), path,
		0,
		stringToSecProtocolType( type ),
		0,
		0, nil,
		&itemRef
	);
	
	if( itemRef != nil ) {
		status = SecKeychainItemModifyAttributesAndData(
			itemRef,
			nil,
			strlen( password ), password
		);
	} else {
		SecAccessRef access = createAccessWithLabel( "AlmostVPN" );
		
		int port = 0;
		SecProtocolType protocol = stringToSecProtocolType( type );
		SecAuthenticationType authType = kSecAuthenticationTypeDefault;
		char* label = malloc( strlen( account ) + strlen( "@" ) + strlen( serverName ) + 1 );
		label[0] = 0;
		strcat( label, account );
		strcat( label, "@" );
		strcat( label, serverName );

		SecKeychainAttribute attrs[] = {
		{ kSecLabelItemAttr,	strlen( label ),			(void*)label },
		{ kSecAccountItemAttr,	strlen( account ),			(void*)account },
		{ kSecServerItemAttr,	strlen( serverName ),		(void*)serverName },
		{ kSecPortItemAttr,		sizeof(int),				(int *)&port },
		{ kSecProtocolItemAttr,	sizeof(SecProtocolType), 	(SecProtocolType *)&protocol },
		{ kSecAuthenticationTypeItemAttr,
			sizeof( SecAuthenticationType ), (SecAuthenticationType*)&authType }
			// { kSecPathItemAttr,		1,							"/" }
		};
		SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
		status = SecKeychainItemCreateFromContent(
			kSecInternetPasswordItemClass,
			&attributes,
			strlen( password ), password,
			keychain, 
			access,
			&itemRef
		);
		if( status ) {
			fprintf( stderr, "AlmostVPN : KeychainMasterPasswordProvider.JNI_setKeychainPassword : SecKeychainItemCreateFromContent Failed %d\n", status );
		}
		
		if (access) CFRelease(access);
	}
	if (itemRef) CFRelease(itemRef);				
	

	if( keychain != NULL ) {
		CFRelease( keychain );
	}
}