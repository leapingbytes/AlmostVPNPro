package com.leapingbytes.almostvpn.util.GUI;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.util.DataConsumer;

public class YesNoHelper {
	private static final Log log = LogFactory.getLog( YesNoHelper.class );

	public static String getYesNo( String title, String question ) {
		Process p;
		try {
			p = Runtime.getRuntime().exec( 
				"./askPassword.sh " + 
				"com.leapingbytes.almostvpn.util.GUI.YesNoDialog" + " " + 
				title + " " +
				URLEncoder.encode( question, "UTF-8" )
			);
		} catch (IOException e) {
			log.error( "Fail to ask question : " + title, e );
			return null;
		}
			
		InputStream pInput = p.getInputStream();
		DataConsumer reader = new DataConsumer( pInput );
	
		while( true ) {
			try {
				p.waitFor();
				break;
			} catch (InterruptedException e1) {
				// do nothing
			}
		}
		
		String result;
		try {
			result = reader.data();
		} catch (IOException e) {
			log.error( "Fail to ask question : " + title, e );
			return null;
		}
		
		return result;
			
	}

}
