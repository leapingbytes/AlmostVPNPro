package com.leapingbytes.almostvpn.server.profile.item.impl;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.almostvpn.util.ssh.ISSHSession;

public class SSHCommand extends BaseProfileItem {

	
	SSHSession	_session;
	String		_command;
	boolean		_runOnStart;
	boolean		_runOnStop;
	boolean 	_x11;
	boolean		_console;
	
	
	ISSHSession.IChannel		_channel;
	
	public SSHCommand( SSHSession session, String command, boolean runOnStart, boolean runOnStop, boolean x11, boolean console ) {
		_session 	= session;
		_command 	= command;
		_runOnStart	= runOnStart;
		_runOnStop	= runOnStop;
		_x11		= x11;
		_console	= console;
	}
	
	public String _title() {
		return _command;
	}

	public void start() throws ProfileException {
		if( isStartable()) {
			if( _runOnStart ) {
				run();
				if( _runOnStop ) {
					closeChannel();
				}
				startDone( _command );
			} else {
				startDone( null );
			}		
		}
	}

	public void stop() throws ProfileException {
		if( isStoppable()) {
			if( state() == IProfileItem.RUNNING ) {
				if( _runOnStop ) {
					run();
					stopDone( _command );
				} else {
					stopDone( null );
				}
			} else {
				stopDone( null );
			}
		}
	}
	
	private void run() throws ProfileException {
		if( _console ) {
			_channel = _session._session.shell( _command );
		} else {
			_channel = _session._session.exec( _command, _x11, null, null );
		}
	}

	private void closeChannel() {
		_channel.close();
	}
}
