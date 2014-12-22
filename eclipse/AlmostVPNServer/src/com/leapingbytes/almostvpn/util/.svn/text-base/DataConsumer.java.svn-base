package com.leapingbytes.almostvpn.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class DataConsumer implements Runnable {
	StringBuffer		_data = new StringBuffer();
	BufferedReader 		_reader;
	IOException			_e = null;
	Thread				_thread;
	
	public DataConsumer( InputStream is ) {
		_reader = new BufferedReader( new InputStreamReader( is ));
		_thread = new Thread( this );
		_thread.start();
	}
	
	public synchronized String	data() throws IOException {
		if( _e != null ) {
			throw _e;
		}
		return _data.toString();
	}
	
	public synchronized void run() {
		String line;		
		boolean firstLine = true;
		do {
			try {
				line = _reader.readLine();
				if( line != null ) {
					if ( ! firstLine ) {
						_data.append( "\n" );						
					}
					firstLine = false;
					_data.append( line );
				}
			} catch (IOException e) {
				_e = e;
				break;
			}
			
		} while( line != null );
		try {
			_reader.close();
		} catch (IOException e1) {
			// DO NOTHING
		}
		_reader = null;
		_thread = null;
	}
}
