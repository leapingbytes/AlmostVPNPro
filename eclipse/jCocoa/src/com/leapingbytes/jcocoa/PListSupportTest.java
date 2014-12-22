package com.leapingbytes.jcocoa;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;

public class PListSupportTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		NSMutableDictionary result = new NSMutableDictionary();
		result.setObjectForKey( "xyz", "name" );
		result.setObjectForKey( "7907CF2A-965A-4F11-9729-84F6941CC323", "uuid" );
		result.setObjectForKey( "running", "state" );
		result.setObjectForKey( "", "state-comment" );

		Writer output = new BufferedWriter( new OutputStreamWriter( System.out ));
		try {
			PListSupport.writeObject( result, output );
			output.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

}
