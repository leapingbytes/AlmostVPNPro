package com.leapingbytes.almostvpn.util;

import java.io.ByteArrayOutputStream;
import java.io.CharArrayReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.PBEParameterSpec;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.path.PathLocator;
import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.NSMutableDictionary;
import com.leapingbytes.jcocoa.PListSupport;

public class SecureStorageProvider {
	private static final Log log = LogFactory.getLog( SecureStorageProvider.class );
	
	private static final String _KEY_FACTORY_ALGORITHM_ = "PBEWithMD5AndDES";
	static final int _SALT_SIZE_ = 8;
	static NSMutableDictionary	_secureStorage = null;
	
	
	static Object _secureStorageLock = new Object();
	
	public static void reload() {
		synchronized( _secureStorageLock ) {
			String sspPath =  PathLocator.sharedInstance().sspPath();
			File ssp = new File( sspPath );
			
			log.info( "ssp path = " + sspPath + " " + ssp.length() + " bytes");
			try {
				InputStream is = new FileInputStream( ssp );
				byte[] originalBytes = new byte[ (int)ssp.length() ];
				int bytesToRead = originalBytes.length;
				int readSoFar = 0;
				int readBytes;
				while( bytesToRead > 0 ) {
					readBytes = is.read( originalBytes, readSoFar, bytesToRead );
					if( readBytes < 0 ) {
						break;
					}
					bytesToRead -= readBytes;
					readSoFar += readBytes;
				}
				is.close();
				
				if( bytesToRead > 0 ) {
					throw new Exception( "Fail to read all bytes from .almostVPN.ssp" );
				}
				
				byte[] salt = new byte[ _SALT_SIZE_ ];
				for( int i = 0; i < salt.length; i++ ) {
					salt[ i ] = originalBytes[ i ];
				}
				
				String passwordString = MasterPasswordProvider.defaultProvider().masterPassword(); 
				char[] password = passwordString.toCharArray();
				PBEKeySpec keySpec = new PBEKeySpec( password );
				
				SecretKeyFactory keyFactory = 
					SecretKeyFactory.getInstance( _KEY_FACTORY_ALGORITHM_ );
				SecretKey theKey = keyFactory.generateSecret( keySpec );
				
				PBEParameterSpec paramSpec = new PBEParameterSpec( salt, 1000 );
				Cipher cipher = Cipher.getInstance( _KEY_FACTORY_ALGORITHM_ +"/CBC/PKCS5Padding" );
				cipher.init( Cipher.DECRYPT_MODE, theKey, paramSpec );
				
//				try {
					byte[] decriptedBytes = cipher.doFinal( originalBytes, _SALT_SIZE_, originalBytes.length - _SALT_SIZE_ );
				
					Reader r = new CharArrayReader( new String( decriptedBytes ).toCharArray() );
				
					_secureStorage = (NSMutableDictionary) PListSupport.objectFromReader( r );
//				} catch (Exception e) {
//					Reader r = new CharArrayReader( new String( originalBytes ).toCharArray() );
//					try {
//						_secureStorage = (NSMutableDictionary) PListSupport.objectFromReader( r );
//						save();
//					} catch (Exception e1) {
//						log.error( "Fail to read ~/.almostVPN.ssp as clear text", e1 );
//					}
//				}
			} catch ( FileNotFoundException e ) {
				// DO NOTHING
			} catch ( Throwable e) {
				log.error( "Fail to read ~/.almostVPN.ssp", e );
			}
			
			if( _secureStorage == null ) {
				_secureStorage = new NSMutableDictionary();
			}
		}
	}
	
	private static void save() {
		synchronized( _secureStorageLock ) {		
			try {
				byte[] salt = new byte[ 8 ];
				Random random = new Random();
				random.nextBytes( salt );
				
				char[] password = MasterPasswordProvider.defaultProvider().masterPassword().toCharArray();
				PBEKeySpec keySpec = new PBEKeySpec( password );
				
				SecretKeyFactory keyFactory = 
					SecretKeyFactory.getInstance( _KEY_FACTORY_ALGORITHM_ );
				SecretKey theKey = keyFactory.generateSecret( keySpec );
				
				PBEParameterSpec paramSpec = new PBEParameterSpec( salt, 1000 );
				Cipher cipher = Cipher.getInstance( _KEY_FACTORY_ALGORITHM_ +"/CBC/PKCS5Padding" );
				cipher.init( Cipher.ENCRYPT_MODE, theKey, paramSpec );
				
				ByteArrayOutputStream ws = new ByteArrayOutputStream();
				Writer w = new OutputStreamWriter( ws );
				PListSupport.writeObject( _secureStorage, w );
				w.close();
				byte[] originalBytes = ws.toByteArray();
				byte[] encryptedBytes = cipher.doFinal( originalBytes );
				
				File newSsp = new File( PathLocator.sharedInstance().sspPath() + ".new" );
				OutputStream os = new FileOutputStream( newSsp );
				os.write( salt );
				os.write( encryptedBytes );
				os.flush();
				os.close();
				
				if( newSsp.length() != salt.length + encryptedBytes.length ) {
					throw new Exception( ".almostVPN.ssp.new has wrong size." );
				}
				
				File ssp = new File( PathLocator.sharedInstance().sspPath() );
				File oldSsp = new File( PathLocator.sharedInstance().sspPath() + ".old" );
				if( ! ssp.exists() ) {
					if( newSsp.renameTo( ssp )) {
						throw new Exception( "save : fail to rename " + newSsp + " to " + ssp );
					}
				} if( ssp.renameTo( oldSsp )) {
					if( newSsp.renameTo( ssp )) {
						if( ! oldSsp.delete() ) {
							log.warn( "save : fail to delete " + oldSsp );
						}
					} else {
						throw new Exception( "save : fail to rename " + newSsp + " to " + ssp );
					}
				} else {
					throw new Exception( "save : fail to rename " + ssp + " to " + oldSsp );
				}			
			} catch ( Exception e ) {
				log.error( "save : " + e, e ); 
			}
		}
	}
	
	public static String retriveSecureObject( String key, NSDictionary anObject ) {
		synchronized( _secureStorageLock ) {		
			return retriveSecureObject( keyForObjectAndKey( anObject, key ));
		}
	}
	
	public static String retriveSecureObject( String key  ) {
		synchronized( _secureStorageLock ) {		
			if( _secureStorage == null ) {
				reload();
			}
			String result = (String) _secureStorage.objectForKey( key );
//			log.info( "REMOVE : retriveSecureObject " + key + " => " + result );
			return result;
		}
	}
	
	public static void saveSecureObject( String key, String value, NSDictionary anObject ) {
		synchronized( _secureStorageLock ) {		
			if( _secureStorage == null ) {
				reload();
			}
			saveSecureObject( keyForObjectAndKey( anObject, key ), value );
		}
	}
	public static void saveSecureObject( String key, String value ) {
		synchronized( _secureStorageLock ) {		
//			log.info( "REMOVE : saveSecureObject " + key + " <= " + value );
			if( _secureStorage == null ) {
				reload();
			}
			_secureStorage.put( key, value );
			save();
		}
	}
	
	static String keyForObjectAndKey( NSDictionary anObject, String aKey ) {
		return (String) anObject.objectForKey( "uuid" ) + ":" + aKey;
	}

	public static void deleteSecureObject(String key) {
		synchronized( _secureStorageLock ) {		
			if( _secureStorage == null ) {
				reload();
			}
			_secureStorage.remove( key );
			save();
		}
	}
}
