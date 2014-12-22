package com.leapingbytes.almostvpn.util.GUI;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.util.DataConsumer;

public class PasswordHelper {
	private static final Log log = LogFactory.getLog( PasswordHelper.class );

	public static String getPassword( String title, String prompt ) {
		Process p;
		try {
			p = Runtime.getRuntime().exec( 
				"./askPassword.sh " + 
				"com.leapingbytes.almostvpn.util.GUI.PasswordDialog" + " " + 
				title + " " +
				URLEncoder.encode( prompt, "UTF-8" )
			);
		} catch (IOException e) {
			log.error( "Fail to ask password : " + title, e );
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
			log.error( "Fail to ask password : " + title, e );
			return null;
		}
		
		return result;
			
	}

}
