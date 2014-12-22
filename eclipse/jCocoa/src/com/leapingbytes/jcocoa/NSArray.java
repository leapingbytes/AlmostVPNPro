package com.leapingbytes.jcocoa;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;

public class NSArray extends ArrayList {
	/**
	 * 
	 */
	private static final long serialVersionUID = -4445131410905407192L;

	public static NSArray arrayWithContentOfTheFile( String filePath ) {
		File file = new File( filePath );
		try {
			URL fileURL = file.toURL();
			return arrayWithContentOfTheURL( fileURL );
		} catch (MalformedURLException e) {
			return null;
		}		
	}
	
	public static NSArray arrayWithContentOfTheURL( URL url ) {
		try {
			return (NSArray)PListSupport.objectWithContentOfURL(url);
		} catch (Exception e) {
			return null;
		}
	}

	public static NSArray arrayWithObject( Object object ) {
		NSArray result = new NSArray();
		result.add( object );
		return result;
	}
	
	public static NSArray arrayWithObjects( Object[] objects ) {
		NSArray result = new NSArray();
		for( int i = 0; i < objects.length; i++ ) {
			result.add( objects[ i ] );
		}
		return result;
	}
	
	public int count() {
		return this.size();
	}
	
	public Object objectAtIndex( int index ) {
		return this.get( index );
	}
	
	public boolean containsObject( Object object ) {
		return this.contains( object );
	}
	
	public int indexOfObject( Object object ) {
		return this.indexOf( object );
	}
	
	public Object objectAtPath( String path ) {
		return PListSupport.getObjectByPath( this, path);
	}
	
	public void writeToFileAtomically( String filePath ) {
		File file = new File( filePath );
		try {
			URL fileURL = file.toURL();
			writeToURLAtomically( fileURL );
		} catch (MalformedURLException e) {
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
