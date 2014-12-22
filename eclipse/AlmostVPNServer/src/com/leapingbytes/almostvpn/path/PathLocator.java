package com.leapingbytes.almostvpn.path;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class PathLocator {
	private static final Log log = LogFactory.getLog( PathLocator.class );
	
	public static final String PRODUCT_ID					= "com.leapingbytes.almostvpn"; 
	public static final String PRODUCT_NAME 				= "AlmostVPNPRO"; 
	
	public static final String USER_NAME_PROPERTY			= PRODUCT_ID + ".userName";
	public static final String USER_HOME_PROPERTY			= PRODUCT_ID + ".userHome";

	public static final String RESOURCES_PATH_PROPERTY		= PRODUCT_ID + ".resourcesPath";
	public static final String APP_SUPPORT_PATH_PROPERTY	= PRODUCT_ID + ".applicationSupportPath";
	public static final String PREFERENCES_PATH_PROPERTY	= PRODUCT_ID + ".preferencesPath";
	public static final String KEYCHAIN_PATH_PROPERTY		= PRODUCT_ID + ".keychainPath";
	public static final String SSP_PATH_PROPERTY			= PRODUCT_ID + ".sspPath";
	

	static String 	_user_name;
	static String 	_user_home;
	
	static String 	_almostvpn_resources;
	
	static String 	_almostvpn_support;
	static boolean	_almostvpn_support_exists = false;
	
	static String 	_almostvpn_preferences;
	static String 	_almostvpn_ssp;
	static String	_almostvpn_keychain;
	
	private static PathLocator _sharedInstance = null;
	
	public static PathLocator sharedInstance() {
		if( _sharedInstance == null ) {
			_sharedInstance = new PathLocator();
			_sharedInstance.resetEnv();
		}
		return _sharedInstance; 
	}
	
	public void resetEnv() {				
		_user_name			= System.getProperty( USER_NAME_PROPERTY, System.getProperty( "user.name" ));
		_user_home 			= System.getProperty( USER_HOME_PROPERTY, System.getProperty( "user.home" ));
	
		// AlmostVPNServer always starts from Contents/Resources 
		_almostvpn_resources 	= System.getProperty( RESOURCES_PATH_PROPERTY, "." );
		
		_almostvpn_support 	= System.getProperty( APP_SUPPORT_PATH_PROPERTY, _user_home + "/Library/Application Support/" + PRODUCT_NAME );
		_almostvpn_support_exists = false;
		
		_almostvpn_ssp = _almostvpn_support.startsWith( "/Library" ) ? "/.almostVPN.ssp" : this.resolveHomePath( "~/.almostVPN.ssp" );
		_almostvpn_ssp = System.getProperty( SSP_PATH_PROPERTY, _almostvpn_ssp );
		
		_almostvpn_preferences = System.getProperty( PREFERENCES_PATH_PROPERTY, _user_home + "/Library/Preferences/com.leapingbytes." + PRODUCT_NAME + ".plist" );
		
		_almostvpn_keychain = System.getProperty( KEYCHAIN_PATH_PROPERTY, _user_home + "/Library/Keychains/login.keychain" );

		log.info( "resetEnv :" +
				"\n       user = " + _user_name + 
				"\n       home = " + _user_home +
				"\n  resources = " + _almostvpn_resources +
				"\n    support = " + _almostvpn_support +
				"\npreferences = " + _almostvpn_preferences +
				"\n        ssp = " + _almostvpn_ssp );
	}
	
	public String userName() {
		return _user_name;
	}
	
	public String resourcesDirPath() {
		return _almostvpn_resources;
	}
	
	public String resourceFilePath( String fileName ) {
		return resourcesDirPath() + File.separator + fileName;
	}
	public String supportDirPath() {
		if( ! _almostvpn_support_exists ) {
			try {
				File f = new File( _almostvpn_support );
				if( ! f.exists()) {
					f.mkdirs();
				} else if( ! f.isDirectory()) {
					log.error( "Support Path exist and it is not directory");
					return null;
				}
				_almostvpn_support_exists = true;
			} catch( Throwable t ) {
				log.error( "Fail to create support dirrectory : " + _almostvpn_support, t );
			}
		}
		return  _almostvpn_support;
	}
	
	public String supportFilePath( String fileName ) {
		return supportDirPath() + File.separator + fileName;
	}
	
	public String preferencesFilePath() {
		return _almostvpn_preferences;
	}
	
	public File preferecesFile() {
		return new File( preferencesFilePath());
	}
	
	public String resolveHomePath( String path ) {
		return path.replaceAll( "~", _user_home );
	}
	
	public String keychainPath() {
		return _almostvpn_keychain;
	}
	
	public String sspPath() {
		return _almostvpn_ssp;
	}
}
