package com.leapingbytes.almostvpn.util;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Map.Entry;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class Env {
		private static final Log log = LogFactory.getLog( Env.class );
		
		private static boolean _initialized = false;
		
		public static void init() {
			if( _initialized ) {
				return;
			}
			
			Properties p = new Properties();
			try {
				p.load( new FileInputStream( "almostvpn.properties" ));
				for( Iterator i = p.entrySet().iterator(); i.hasNext(); ) {
					Map.Entry e = (Entry) i.next();
					System.setProperty( (String)e.getKey(), (String)e.getValue());
					
					String dummy = System.getProperty( (String)e.getKey());
					log.info( (String)e.getKey() + "=" + dummy );
				}
			} catch (FileNotFoundException e) {
				// DO NOTHING. It is OK
			} catch (IOException e) {
				log.error( "Fail to load : almostvpn.properties", e );
			}
		}
}
