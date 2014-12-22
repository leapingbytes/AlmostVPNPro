package com.leapingbytes.almostvpn.server.profile.item.impl;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.util.ssh.ISSHSession;

public class SSHCommandPipe extends BaseProfileItem {

	SSHSession		_session;

	String 			_localCommand;
	String 			_remoteCommand;
	
	
	InputStream		_localOut;
	OutputStream 	_localIn;
	Process			_localProcess;
	
	ISSHSession.IChannel	_remoteChannel;
	
	public SSHCommandPipe( SSHSession session ) {
		initialize( session, null, null );
	}
	
	public SSHCommandPipe( SSHSession session, String localCommand, String remoteCommand ) {
		initialize( session, localCommand, remoteCommand );
	}
	
	public void initialize(SSHSession session, String localCommand, String remoteCommand  ) {
		_session = session == null ? _session : session;
		_localCommand = localCommand;
		_remoteCommand = remoteCommand;		
	}
	
	public void setLocalCommand( String v ) {
		_localCommand = v;
	}
	
	public void setRemoteCommand( String v ) {
		_remoteCommand = v;
	}
	
	public String _title() {
		return _localCommand + "<->" + _remoteCommand;
	}

	public void start() throws ProfileException {
		if( isStartable()) {
			startLocal();
			startRemote();
			
			startDone( title() );
		}
	}
	
	public void stop() throws ProfileException {
		if( isStoppable()) {
			stopLocal();
			stopRemote();			
			stopDone( title() );
		}
	}
	
	private void startLocal() throws ProfileException {
		try {
			_localProcess = Runtime.getRuntime().exec( _localCommand );
			_localOut = _localProcess.getInputStream();
			_localIn = _localProcess.getOutputStream();			
		} catch (IOException e) {
			throw new ProfileException( "Fail to start local command : " + _localCommand, e );
		}		
	}
	
	private void startRemote() throws ProfileException {
		_remoteChannel = _session._session.exec( _remoteCommand, false, _localOut, _localIn ); 
	}

	private void stopLocal() {
		_localProcess.destroy();
	}
	
	private void stopRemote() {
		_remoteChannel.close();
	}
}
