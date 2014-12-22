package com.leapingbytes.almostvpn.server.profile.item.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.profile.Profile;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.util.ScriptRunner;

public class Script extends BaseProfileItem {
	private static final Log log = LogFactory.getLog( Script.class );
	
	public static final String _DO_RESULT_MARKER_	= "@DO-RESULT@";

	boolean		_countStartStop;
	int			_startStopCounter = 0;
	
	String 		_doScript;
	String 		_undoScript;
	String[] 	_env = null;
	String		_user = null;
	
	String 		_doResult = null;
	
	public Script( String doScript, String undoScript ) {
		this( doScript, undoScript, false );
	}
	public Script( String doScript, String undoScript, boolean countStartStop ) {
		_doScript = doScript;
		_undoScript = undoScript;
		_countStartStop = countStartStop;
	}
	
	public boolean equals( Object o ) {
		if( ! super.equals( o )) {
			return false;
		}
		Script other = (Script)o;
		if( _env == null ) {
			return other._env == null;
		}
		return _env.equals( other._env );
	}
	
	public void setEnv( String[] v ) {
		_env = v;
	}
	
	public void setUser( String v ) {
		_user = v;
	}
	
	private String[] runScriptEnv() {
		String[] profileEnv = Profile.threadCurrentProfile().getEnv();
		
		if( _env == null ) {
			return profileEnv;
		}
		
		String[] result = new String[ profileEnv.length + _env.length ];
		int j = 0;
		for( int i = 0; i < profileEnv.length; i++, j++ ) {
			result[ j ] = profileEnv[ i ];
		}
		for( int i = 0; i < _env.length; i++, j++ ) {
			result[ j ] = _env[ i ];
		}
		
		return result;
	}
	
	public void start() throws ProfileException {
		if( _startStopCounter == 0 ) {
			_doResult = ScriptRunner.runScript( _doScript, runScriptEnv(), _user );
			startDone( _doScript + " -> " + _doResult );
		}
		if( _countStartStop ) {
			_startStopCounter++;
		}
	}

	public void stop() throws ProfileException {
		if( _countStartStop ) {
			_startStopCounter--;
		}
		if( _startStopCounter < 0 ) {
			log.error( "unbalanced stop : " + this );
			_startStopCounter = 0;
		}
		if( _startStopCounter == 0 ) {
			String script = _undoScript;
			if( script.indexOf( _DO_RESULT_MARKER_ ) > 0 ) {
				script = script.replaceAll( _DO_RESULT_MARKER_, _doResult == null ? "" : _doResult );
			}
			ProfileException pe = null;
			try {
				ScriptRunner.runScript( script, runScriptEnv(), _user );
			} catch ( ProfileException e ) {
				pe = e;
			}
			stopDone( script );
			if( pe != null ) {
				throw pe;
			}
		}
	}

	public String _title() {
		return "]" + _doScript + "[]" + _undoScript + "[";
	}

}
