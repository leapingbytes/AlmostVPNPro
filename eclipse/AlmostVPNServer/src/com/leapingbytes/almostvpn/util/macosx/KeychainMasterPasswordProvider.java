package com.leapingbytes.almostvpn.util.macosx;

import java.io.File;
import java.io.UnsupportedEncodingException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.path.PathLocator;
import com.leapingbytes.almostvpn.util.MasterPasswordProvider;

public class KeychainMasterPasswordProvider extends MasterPasswordProvider {
	private static final Log log = LogFactory.getLog( KeychainMasterPasswordProvider.class );
	
	public KeychainMasterPasswordProvider() {
		// JNILoader.load();
	}
	
	boolean fileCanRead( String path ) {
		return ( new File( path )).canRead();
	}
	boolean fileCanWrite( String path ) {
		return ( new File( path )).canWrite();
	}
	
	String getMasterPassword( String keychainPath ) {
		keychainPath = keychainPath == null ? null : PathLocator.sharedInstance().resolveHomePath( keychainPath );
		String masterPassword = getKeychainPassword( 
				null, new StringBuffer( "almostVPN" ), "almostVPN", null, keychainPath );
		
		if( masterPassword != null ) {
			log.info( "getMasterPassword : got it from " + ( keychainPath == null ? "default keychain" : keychainPath ));			
		}
		return masterPassword;
	}
	
	String defaultUserKeychain() {
		String path = PathLocator.sharedInstance().resolveHomePath( "~/Library/Keychains/login.keychain" );
		
		if( (new File( path ).canRead()) ) {
			return path;
		}
		path = PathLocator.sharedInstance().resolveHomePath( "~/Library/Keychains/" + PathLocator.sharedInstance().userName() );
		
		if( (new File( path ).canRead()) ) {
			return path;
		}
		
		return null;
	}
	
	public String masterPassword() {
		// TODO Auto-generated method stub
		// try in this order:
		// 	1)  ~/Library/Keychains/login.keychain		
		// 	2)  ~/Library/Keychains/<user name>
		//  3) null ( default keychain )
		
		String masterPassword = null;
		
		masterPassword = masterPassword != null ? masterPassword : getMasterPassword( defaultUserKeychain() );
		masterPassword = masterPassword != null ? masterPassword : getMasterPassword( "/Library/Keychains/System.keychain" );
		masterPassword = masterPassword != null ? masterPassword : getMasterPassword( null );
			
		if( masterPassword == null ) {
			log.info( "masterPassword : Need to generate new password\n");
			masterPassword = generatePassword( 64 );
			setKeychainPassword( masterPassword, null, "almostVPN", "almostVPN", null, defaultUserKeychain()  );
		} else {
			log.info( "masterPassword : Got password from keychain\n");
		}
		if( ! masterPassword.equals( getMasterPassword( "/Library/Keychains/System.keychain" ))) {
 			setKeychainPassword( masterPassword, null, "almostVPN", "almostVPN", null, "/Library/Keychains/System.keychain"  );
		}

		return masterPassword;
	}
	
	private String generatePassword( int length ) {
		byte[]	bytes = new byte[ length ];
		int offset = '0';
		int range = 'z' - '0';
		
		for( int i = 0; i < length; i++ ) {
			int code = (int)((offset + (int)(Math.random() * range))) & 0xff;
			bytes[ i ] = (byte) code;
		}
		try {
			return new String( bytes, "UTF-8" );
		} catch (UnsupportedEncodingException e) {
			log.error( "Fail to generate password : " + e, e );
			return null;
		}
	}

	/*
		+ (NSString*) retrivePasswordOfType: (SecProtocolType) type 
				                 forAccount: (NSString*) account 
								   onServer: (NSString*) serverName 
								    forPath: (NSString*)path 
							   fromKeychain: (SecKeychainRef)keychain ;
		}
	 */
	public native String getKeychainPassword( 
		String type,
		StringBuffer account,
		String serverName,
		String path,
		String keychainPath
	);
	/*	
		+ (void) savePassword: (NSString*) password 
	                   ofType: (SecProtocolType) type 
				   forAccount: (NSString*) account 
	                 onServer: (NSString*) serverName 
	                  forPath: (NSString*)path
                 intoKeychain: (SecKeychainRef)keychain ;
 	*/
	
	public native void setKeychainPassword(
		String password,
		String type,
		String account,
		String serverName,
		String path,
		String keychainPath
	);
	
	public static void main( String[] args ) {
		KeychainMasterPasswordProvider p = new KeychainMasterPasswordProvider();
		StringBuffer account = new StringBuffer( args[1] );
		String password = p.getKeychainPassword( args[0], account, args[2], null, args.length > 3 ? args[3] : null );
		
		System.out.println( 
			args[0] + "://" + account + "@" + args[2] + 
			" = " + 
			password
		);
	}
}
