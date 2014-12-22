package com.leapingbytes.almostvpn.server.profile.item.impl;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;

public class SSHFileCopy extends BaseProfileItem {
//	private static final Log log = LogFactory.getLog( SSHFileCopy.class );
	
	SSHSession	_srcSession;
	String		_srcPath;
	
	SSHSession	_dstSession;
	String		_dstPath;
	
	
	boolean		_runOnStart;
	boolean		_runOnStop;
	
	public SSHFileCopy( SSHSession srcSession, String srcPath, SSHSession dstSession, String dstPath, boolean runOnStart, boolean runOnStop ) {
		_srcSession = srcSession;
		_srcPath	= srcPath;
		
		_dstSession = dstSession;
		_dstPath	= dstPath;
		
		_runOnStart	= runOnStart;
		_runOnStop	= runOnStop;
	}
	
	public String _title() {
		return 
			( _srcSession == null ? "" : _srcSession.actualHostName() + ":" ) + _srcPath + 
					" -> " + 
			( _dstSession == null ? "" : _dstSession.actualHostName() + ":" ) + _dstPath;
	}

	public void start() throws ProfileException {
		if( isStartable() ) {
			if( _runOnStart ) {
				startDone( title() );
				copy();
			} else {
				startDone( null );
			}				
		}
	}

	public void stop() throws ProfileException {
		if( isStoppable()) {
			if( state() == IProfileItem.RUNNING ) {
				if( _runOnStop ) {
					stopDone( title() );
					copy();
				} else {
					stopDone( null );
				}
			} else {
				stopDone( null );
			}
		}
	}
	
	private void copy() throws ProfileException {
		if( _srcSession == null && _dstSession != null ) {
			_dstSession._session.scpTo( _srcPath, _dstPath );
		} else if( _srcSession != null && _dstSession == null ) {
			_srcSession._session.scpFrom( _srcPath, _dstPath );
		} else {
			if( _srcSession == null && _dstSession == null ) {
				throw new ProfileException("local copy is not supported");
			}
			if( _srcSession != null && _dstSession != null ) {
				throw new ProfileException("compound copy is not supported");
			}
		}
//		ChannelHelper.Scp( _srcSession == null ? null : _srcSession._session, _srcPath, _dstSession == null ? null :  _dstSession._session, _dstPath );
	}
}
