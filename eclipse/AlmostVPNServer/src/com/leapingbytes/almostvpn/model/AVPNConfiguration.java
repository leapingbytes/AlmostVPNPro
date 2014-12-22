package com.leapingbytes.almostvpn.model;

import java.net.URL;
import java.util.Hashtable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.NSMutableDictionary;

public class AVPNConfiguration {
	private static final Log log = LogFactory.getLog( AVPNConfiguration.class );
	/**
	 * 
	 */
	private static final long serialVersionUID = 292012308131322435L;
	
	private static Object _lock = new Object();
	
	static NSMutableDictionary	_uuids = new NSMutableDictionary();
	static NSDictionary			_dictionary;
	
	public static NSDictionary loadFromFile( String filePath ) {
		synchronized( _lock ) {
			_uuids.clear();
			NSMutableDictionary.setGlobalWatcher( new AlmostVPNWatcher());
			_dictionary = NSDictionary.dictionaryWithContentOfTheFile( filePath );
			NSMutableDictionary.setGlobalWatcher( null );
			return _dictionary;
		}		
	}

	public static NSDictionary loadFromURL( URL url ) {
		synchronized( _lock ) {
			_uuids.clear();
			NSMutableDictionary.setGlobalWatcher( new AlmostVPNWatcher());
			_dictionary = NSDictionary.dictionaryWithContentOfTheURL( url );
			NSMutableDictionary.setGlobalWatcher( null );
			return _dictionary;
		}
	}
	
	public static NSDictionary objectForUuid( String uuid ) {
		synchronized( _lock ) {
			return (NSDictionary) _uuids.objectForKey( uuid );
		}
	}	
	
	private static long _tempObjectCount = 0;
	
	public static NSMutableDictionary createTemporaryObject() {
		NSMutableDictionary result = new NSMutableDictionary();
		
		synchronized( _lock ) {
			_tempObjectCount++;
			String tempUUID = "_temp_:" + _tempObjectCount;
			
			result.setObjectForKey( tempUUID, Model.AVPNUUIDProperty );
			_uuids.setObjectForKey( result, tempUUID );			
		}
		return result;
	}
	
	public static void deleteTemporaryObject( NSMutableDictionary object ) {
		String tempUUID = (String) object.objectForKey( Model.AVPNUUIDProperty );
		if( tempUUID == null ) {
			log.error( "deleteTemporaryObject : uuid missing" );
			return;
		}
		
		if( ! tempUUID.startsWith( "_temp_:" )) {
			log.error( "deleteTemporaryObject : this is not temporary object." );
			return;
		}
		synchronized( _lock ) {
			_uuids.removeObjectForKey( tempUUID );
		}		
	}
	
	public static NSDictionary[] allProfiles() {
		synchronized( _lock ) {
			return _dictionary == null ? 
				new NSDictionary[0] :
				(NSDictionary[]) _dictionary.objectsAtPath( "children/*[class-name=AlmostVPNProfile]", NSDictionary.class );
		}
	}
	
	public static NSDictionary profileWithName( String profileName ) {
		synchronized( _lock ) {
			return _dictionary == null ? 
				null :
				(NSDictionary) _dictionary.objectAtPath( "children/*[class-name=AlmostVPNProfile][name=" + profileName + "]" );
		}
	}
	
	public static NSDictionary localhost() {
		synchronized( _lock ) {
			return _dictionary == null ? 
				null :
				(NSDictionary) _dictionary.objectAtPath( "children/*[class-name=AlmostVPNLocalhost]" );
		}
	}
	
	public static String configurationProperty( String name ) {
		return configurationProperty( name, null );
	}
	
	static Hashtable _reportedMissingProperties = new Hashtable();
	
	public static String configurationProperty( String name, String defaultValue ) {
		NSDictionary configuration = _dictionary;
		if(( configuration != null ) && configuration.containsKey( "configuration" ) ) {
			configuration = (NSDictionary) configuration.objectForKey( "configuration" );
		}		
		
		String result = (String) ( configuration == null ? null : configuration.objectForKey( name ));
		if(( result == null ) && ( ! _reportedMissingProperties.contains( name))) {
			_reportedMissingProperties.put( name, name );
			log.warn( "configurationProperty : no value for property " + name + ". using default value = " + defaultValue );
		}
		return result == null ? defaultValue : result;
	}
}

class AlmostVPNWatcher implements NSMutableDictionary.Watcher {
	public void allObjectsWillBeRemoved(NSMutableDictionary host) {
		// DO NOTHING
	}

	public void objectForKeyWillBeSet(NSMutableDictionary host, Object o, Object k) {
		if( host == AVPNConfiguration._uuids ) {
			return;
		}
		
		if( "uuid".equals( k )) {
			AVPNConfiguration._uuids.setObjectForKey( host, o );
			host.setWatcher( this );
		}
	}

	public void objectForKeyHasBeenRemoved(NSMutableDictionary host, Object o, Object k) {
		if( host == AVPNConfiguration._uuids ) {
			return;
		}
		
		if( o instanceof NSDictionary ) {
			String uuid = (String) ((NSDictionary)o).objectForKey( "uuid" );
			if( uuid != null ) {
				AVPNConfiguration._uuids.remove( uuid );
			}
		}
	}		
}