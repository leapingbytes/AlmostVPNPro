package com.leapingbytes.almostvpn.util.macosx;

import java.net.URL;
import java.net.URLDecoder;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.util.ScriptRunner;

public class JNILoader {
	private static final Log log = LogFactory.getLog( JNILoader.class );

	public static void load() {
		ClassLoader ctxClassLoader = Thread.currentThread().getContextClassLoader();
        String mappedLibName = System.mapLibraryName( "AlmostVPNToolJNI.macosx" );
        URL libraryURL = ctxClassLoader.getResource( mappedLibName );
        String path = libraryURL.getFile();
        
        String registredChecksum = ScriptRunner.getRegistredMD5Checksum( mappedLibName );
        String actualChecksum = null;
        try {
        	path = URLDecoder.decode( path, "UTF-8" );
			actualChecksum = ScriptRunner.getMD5Checksum( path );
		} catch (Exception e) {
			log.error( "AlmostVPNServer.JNILoader : Fail to calculate checksum : " + path + ":" + e, e );
		}

		if( registredChecksum == null ) {
			log.warn( "AlmostVPNServer.JNILoader : AlmostVPNToolJNI.macosx.jnilib integrity can not be verified." );
		} else if( ! registredChecksum.equals( actualChecksum )) {
			log.fatal( "AlmostVPNServer.JNILoader : AlmostVPNToolJNI.macosx.jnilib has been tempered.\n" + registredChecksum + " != " + actualChecksum + "\nRefuse to load." );
			return;
		} 
		log.info( "AlmostVPNServer.JNILoader :  loading " + path );
		Runtime.getRuntime().load( path );
		
	}
}
