package com.leapingbytes.almostvpn.util.ssh;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Timer;
import java.util.TimerTask;

import com.leapingbytes.almostvpn.server.MonitorLogHandler;
import com.leapingbytes.almostvpn.server.profile.ProfileException;

public class SSHSessionFactory {
	private static Hashtable	_sessions = new Hashtable();
	private static final long	_UTILIZATION_REPORT_INTERVAL_	= 5 * 1000; // 5 sec
	private static Timer _utilizationReportTimer = null;
		
	public static ISSHSession getSession( String userName, String hostName, int port, boolean createNew ) {
		String key = sshSessionKey( userName, hostName, port );
		ISSHSession result = (ISSHSession) _sessions.get( key );
		
		if( result != null || ( ! createNew )) {
			return result;
		}
		
		result = new GanimedSSHSSession( userName, hostName, port );
		synchronized ( _sessions ) {
			_sessions.put( key, result );
		}

		if( _utilizationReportTimer == null ) {
			_utilizationReportTimer = new Timer();
			_utilizationReportTimer.schedule( new ReportUtilization(), _UTILIZATION_REPORT_INTERVAL_, _UTILIZATION_REPORT_INTERVAL_);
		}
				
		return result;
	}
	
	private static String sshSessionKey( String userName, String hostName, int port ) {
		return userName + "@" + hostName + ":" + port;
	}

	public static int countConnectedSessions() {
		synchronized( _sessions ) {
			Iterator sessions = _sessions.values().iterator();
			int result = 0;
			while( sessions.hasNext() ) {
				ISSHSession session = (ISSHSession) sessions.next();
				if( session.isConnected() ) {
					result++;
				}
			}
			return result;
		}
	}

	public static ISSHSession.IChannel anyStreamTunnel( InputStream outIn, OutputStream inOut, String host, int port) {
		synchronized( _sessions ) {
			Iterator sessions = _sessions.values().iterator();
			ISSHSession.IChannel result = null;
			while( sessions.hasNext() ) {
				ISSHSession session = (ISSHSession) sessions.next();
				if( ! session.isConnected() ) {
					continue;
				}
				
				try {
					result = session.streamTunnel( outIn, inOut, host, port );
					break;
				} catch (ProfileException e) {
					// Do nothing
				}
			}
			return result;
		}
	}
	
	static final class ReportUtilization extends TimerTask {
		
		public void run() {
			SSHSessionFactory.reportUtilization();
		}
		
}

	static void reportUtilization() {
		long totalReadCount = 0;
		long totalWriteCount = 0;
		int sessionCount = 1;
		synchronized( _sessions ) {
			Iterator sessions = _sessions.values().iterator();
			while( sessions.hasNext() ) {
				ISSHSession session = (ISSHSession) sessions.next();
				if( ! session.isConnected() ) {
					continue;
				}
	
				long readCount = session.getRecievedBytes();
				long writeCount = session.getSendBytes(); 
				long writeExtCount = 0; 
				
				totalReadCount += readCount;
				totalWriteCount += writeCount + writeExtCount;
				
				sessionCount += sessions.hasNext() ? 1 : 0;
				if( sessionCount > 1 ) {
					MonitorLogHandler.utilization( session.toString(), readCount, writeCount + writeExtCount );
				}
			}
			MonitorLogHandler.utilization( "_TOTAL_", totalReadCount, totalWriteCount );
		}
	}	
}
