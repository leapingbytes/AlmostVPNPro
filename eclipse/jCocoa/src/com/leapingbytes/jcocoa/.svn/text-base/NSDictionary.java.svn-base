package com.leapingbytes.jcocoa;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;

public class NSDictionary extends HashMap {

	/**
	 * 
	 */
	private static final long serialVersionUID = 3459673061189842865L;

	public static NSDictionary dictionaryWithContentOfTheFile( String filePath ) {
		File file = new File( filePath );
		try {
			URL fileURL = file.toURL();
			return dictionaryWithContentOfTheURL( fileURL );
		} catch (MalformedURLException e) {
			return null;
		}
	}
	
	public static NSDictionary dictionaryWithContentOfTheURL( URL url ) {
		try {
			return (NSDictionary)PListSupport.objectWithContentOfURL(url);
		} catch (Exception e) {
			return null;
		}
	}
	
	public static NSDictionary dictionaryWithObjectsAndKeys( Object[] objectsAndKeys ) {
		NSDictionary result = new NSDictionary();
		for( int i = 0; i < objectsAndKeys.length; i+=2 ) {
			result.put( objectsAndKeys[i+1], objectsAndKeys[i]);
		}
		return result;
	}
	
	public int count() {
		return this.size();
	}
	
	public Object objectForKey( Object key ) {
		return this.get( key );
	}
	
	public Object objectForKey( Object key, Object defaultValue ) {
		Object result = this.objectForKey( key );
		return result == null ? defaultValue : result;
	}
	
	public int intForKey( Object key, int defaultValue ) {
		Object result = this.objectForKey( key );
		return result == null ? defaultValue : Integer.parseInt( result.toString());		
	}
	
	public boolean booleanForKey( Object key, boolean defaultValue ) {
		Object result = this.objectForKey( key );
		return result == null ? defaultValue : "yes".equalsIgnoreCase( result.toString()) || "true".equalsIgnoreCase( result.toString());		
	}
	
	public Iterator keyIterator() {
		return this.keySet().iterator();
	}
	
	public Iterator entryIterator() {
		return this.entrySet().iterator();
	}
	
	public Object objectAtPath( String path ) {
		return PListSupport.getObjectByPath( this, path);
	}
	
	public Object[] objectsAtPath( String path ) {
		return PListSupport.getObjectsByPath( this, path);
	}
	
	public Object[] objectsAtPath( String path, Class clazz ) {
		return PListSupport.getObjectsByPath( this, path, clazz );
	}
	
	public void writeToFileAtomically( String filePath ) {
		File file = new File( filePath );
		try {
			URL fileURL = file.toURL();
			writeToURLAtomically( fileURL );
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void writeToURLAtomically( URL url ) {
		try {
			PListSupport.writeObjectToURL( this, url);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
