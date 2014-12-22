package com.leapingbytes.almostvpn.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.io.OutputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class DataCopier implements Runnable {
	private static final Log log = LogFactory.getLog( DataCopier.class );
	
	InputStream		_in;
	OutputStream 	_out;
	
	String			_feed;
	
	Thread			_thread;
	
	boolean			_interactive = false;
	String			_name = null;
	
	DataCopier		_college;
	boolean			_timeToClose = false;
	boolean			_closed = false;
	
	public DataCopier( InputStream in, OutputStream out ) {
		this( in, out, null );
	}
	public DataCopier( InputStream in, OutputStream out, String feed ) {
		_in = in;
		_out = out;
		_feed = feed;		
	}
	public DataCopier setInteractive( boolean v ) {
		_interactive = v;
		return this;
	}
	public DataCopier setName( String name ) {
		_name = name;
		return this;
	}
	public DataCopier setCollege( DataCopier v ) {
		_college = v;
		v._college = this;

		return this;
	}
	
	public void close() {
		if( _closed ) {
			return;
		}
		_closed = true;
		_thread.interrupt();
		
		try {
			_in.close();
		} catch (IOException e) {
			log.warn( this + " : Fail to close 'in' stream", e );
		} 
		try {
			_out.close();
		} catch (IOException e) {
			log.warn( this + " : Fail to close 'out' stream", e );
		}
		
		if( _college != null ) {
			_college.setTimeToClose();
		}

		_in = null;
		_out = null;
	}
	
	public synchronized void setTimeToClose() {
		_timeToClose = true;
	}
	public synchronized boolean timeToClose() {
		return _timeToClose;
	}
	
	public String toString() {
		return _name + ":" + super.toString();
	}
	
	public void start() {
		_thread = new Thread( this );
		if( _name != null ) {
			_thread.setName( _name );
		}
		_thread.start();
	}
	
	public void join() {
		while( _in != null && _out != null && _thread.isAlive() ) {
			try {
				_thread.join();
			} catch (InterruptedException e) {
				// DO NOTHING
				log.info( "join : ", e );
			}
		}
	}

	public void run() {
		byte[]	buffer = new byte[ 8*1024 ];
		int rc;
		
		try {
			if( _feed != null ) {
				_out.write( _feed.getBytes());
				_out.flush();
			}
			if( _interactive ) {
				int ch;
				while(( ch = _in.read()) >= 0 ) {
					_out.write( ch );
					_out.flush();
				}
			} else {
				while(( rc = _in.read( buffer, 0, buffer.length )) >= 0 ) {
					if( timeToClose() && rc == 0 ) {
						break;
					}
					_out.write( buffer, 0, rc );
					_out.flush();
				}
			}
		} catch ( InterruptedIOException e ) {
			// DO NOTHING
			log.info( "run() - interrupted!! : " + e, e );						
		} catch (IOException e) {
			log.debug( "Fail to copy : " + e, e );						
		}
		
		close();
	}
}
