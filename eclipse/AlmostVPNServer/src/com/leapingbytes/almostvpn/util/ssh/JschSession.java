package com.leapingbytes.almostvpn.util.ssh;


class JschSession {

}
//class JschSession extends SSHSessionBase {
//	private static final Log log = LogFactory.getLog( JschSession.class );
//	
//	private static final NSMutableDictionary 	_sessions = new NSMutableDictionary();
//	
//	private static final long	_UTILIZATION_REPORT_INTERVAL_	= 5 * 1000; // 5 sec
//	private static Timer _utilizationReportTimer;
//		
//	String  _password;
//	int		_getPasswordCount;
//	String  _passphrase;
//	int 	_getPassphraseCount;
//	
//	JSch	_jsch =null;
//	Session	_jschSession = null;
//	int 	_connectCount;
//	
//	Proxy	_proxy = null;
//	String	_proxyToString = null;
//	
//	MeasuredSocketFactory _soketFactory = new MeasuredSocketFactory();
//	
//	public interface SessionStateListener {
//		public void event( ISSHSession session, String comment, Throwable t );
//	}
//	
//	private JschSession( String userName, String hostName, int port ) {
//		super( userName, hostName, port );
//		
//		_jsch = new JSch();
//		try {
//			_jsch.setKnownHosts( PathLocator.sharedInstance().resolveHomePath( "~/.ssh/known_hosts" ));
//		} catch (JSchException e) {
//			log.warn( "Fail to load known_hosts");
//		}
//	}
//	
//	public static ISSHSession getSession( String userName, String hostName, int port, boolean createNew ) throws ProfileException {
//		String sessionKey = makeSessionKey( userName, hostName, port );
//		ISSHSession result = (ISSHSession) _sessions.objectForKey( sessionKey );
//		if( result == null && createNew ) {
//			result = new JschSession( userName, hostName, port );
//			_sessions.setObjectForKey( result, sessionKey );
//			if( _utilizationReportTimer == null ) {
//				_utilizationReportTimer = new Timer();
//				_utilizationReportTimer.schedule( new ReportUtilization(), _UTILIZATION_REPORT_INTERVAL_, _UTILIZATION_REPORT_INTERVAL_);
//			}
//		}
//		return result;
//	}
//	
//	public static JschSession getSessionByKey( String sessionKey ) {
//		return (JschSession) _sessions.objectForKey( sessionKey );
//	}
//	
//	static final class ReportUtilization extends TimerTask {
//
//		public void run() {
//			JschSession.reportUtilization();
//		}
//		
//	}
//
//	static void reportUtilization() {
//		long totalReadCount = 0;
//		long totalWriteCount = 0;
//		int sessionCount = 1;
//		for( Iterator i = _sessions.keyIterator(); i.hasNext(); ) {
//			String sessionKey = (String) i.next();
//			JschSession session = JschSession.getSessionByKey( sessionKey );
//			if( session == null ) {
//				continue;
//			}
//			Session jschSession = session._jschSession;
//			if( jschSession == null ) {
//				continue;
//			}
//			long readCount = session._soketFactory.getInputBytesCount(); 
//			long writeCount = session._soketFactory.getOutputBytesCount(); 
//			long writeExtCount = 0; 
//			
//			totalReadCount += readCount;
//			totalWriteCount += writeCount + writeExtCount;
//			
//			sessionCount += i.hasNext() ? 1 : 0;
//			if( sessionCount > 1 ) {
//				MonitorLogHandler.utilization( session.toString(), readCount, writeCount + writeExtCount );
//			}
//		}
//		MonitorLogHandler.utilization( "_TOTAL_", totalReadCount, totalWriteCount );
//	}
//	
//	static String makeSessionKey( String userName, String hostName, int port ) {
//		return userName + "@" + hostName + ":" + port;
//	}
//	
//	public String toString() {
//		return makeSessionKey( _sshUserName, _sshServerName, _sshPort );
//	}
//	
//	int _timeout = 60 * 1000;
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#timeout()
//	 */
//	public int timeout() {
//		return _timeout;
//	}
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#setTimeout(int)
//	 */
//	public void setTimeout( int v ) {
//		_timeout = v;
//	}
//	
//	int _keepAlive = 5;
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#keepAlive()
//	 */
//	public int keepAlive() {
//		return _keepAlive;
//	}
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#setKeepAlive(int)
//	 */
//	public void setKeepAlive(int v) {
//		_keepAlive = v;
//	}
//	
//	Timer _keepAliveTimer = null;
//	void startKeepAlive() {
//		if( _keepAliveTimer == null && _keepAlive > 0 ) {
//			_keepAliveTimer = new Timer();
//			_keepAliveTimer.schedule( new TimerTask() {
//				public void run() {
//					sendKeepAlive();
//				}				
//			}, _keepAlive*1000, _keepAlive*1000);
//		}
//	}
//	void stopKeepAlive() {
//		if( _keepAliveTimer != null ) {
//			_keepAliveTimer.cancel();
//			_keepAliveTimer = null;
//		}
//	}
//	
//	void sendKeepAlive() {
//		try {
//			this._jschSession.sendKeepAliveMsg();
//			if( ! this._jschSession.isConnected() ) {
//				throw new ProfileException( "session is not connected" );
//			}
//			System.gc();
//		} catch (Exception e) {
//			stateEvent( "Fail to send keep-alive", e );
//		}
//	}
//	
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#start()
//	 */
//	public synchronized void start() throws ProfileException {
//		if( _connectCount == 0 ) {
//			String connectionDescription = _sshUserName + "@" + _sshServerName + ":" + _sshPort  + 
//				( _proxy != null ? " via " + _proxyToString : "" );
//			long startTime = System.currentTimeMillis();
//			int fraction = 4;
//			_getPasswordCount = 0;
//			_getPassphraseCount = 0;
//			for( int i = 0; i < 4; i++ ) {
//				int currentTimeout = _timeout / fraction;
//				long sleepUntil = System.currentTimeMillis() + currentTimeout;
//				try {
//					log.info( "start : trying to connect to " + connectionDescription + " with timeout " + (_timeout / fraction / 1000 ) + "sec" );
//					session().connect( currentTimeout );
//					break;
//				} catch (JSchException e) {
//					session(true).disconnect();
//					fraction = fraction / 2;
//					fraction = ( fraction <= 0 ) ? 1 : fraction;
//					if(( _getPassphraseCount + _getPasswordCount ) > 0 ) {
//						String msg;
//						log.error( 
//							msg ="Fail to connect " + connectionDescription + 
//								( ( _getPasswordCount > 0 ) ? " Incorrect password." :
//								  ( _getPassphraseCount > 0 ) ? " Incorrect passphrase." : 
//								  ( " after trying for " + ((System.currentTimeMillis() - startTime )/1000) + "sec" )) 
//						);
//						throw new ProfileException( msg, true, e );
//					}
//					while( sleepUntil < System.currentTimeMillis()) {
//						try {
//								Thread.sleep( sleepUntil - System.currentTimeMillis());
//						} catch (InterruptedException e1) {
//							// do nothing
//						}
//					}
//				} 
//			}
//			startKeepAlive();
//		}		
//		_connectCount++;
//	}
//
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#stop()
//	 */
//	public synchronized void stop() throws ProfileException {
//		_connectCount--;
//		if( _connectCount <= 0 ) {
//			_connectCount = 0;
//			stopKeepAlive();
//			session( true ).disconnect();
//		}
//	}
//	
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#isConnected()
//	 */
//	public boolean isConnected() {
//		return this._jschSession != null && this._jschSession.isConnected();
//	}
//
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#setPassword(java.lang.String)
//	 */
//	public void setPassword(String value) {
//		_password = value;		
//	}
//	
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#setPassphrase(java.lang.String)
//	 */
//	public void setPassphrase( String value ) {
//		_passphrase = value;
//	}
//
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#addIdentity(java.lang.String, java.lang.String)
//	 */
//	public void addIdentity(String sshIdentityPath, String passphrase ) {
//		try {
//			setPassphrase( passphrase );
//			_jsch.addIdentity( PathLocator.sharedInstance().resolveHomePath( sshIdentityPath ));
//		} catch (JSchException e) {
//			log.error( "addIdentity : fail to add identity ", e );
//		}
//	}
//	
//	public void addLocalTunnel( String bindToAddress, String sourcePortNumber, String targetHostName, String targetPortNumber) throws ProfileException {
//		try {
//		addLocalTunnel( bindToAddress, Integer.parseInt( sourcePortNumber ), targetHostName, Integer.parseInt( targetPortNumber ));
//		} catch ( NumberFormatException e ) {
//			throw new ProfileException( "Fail to parse port number : " + e );
//		}
//	}
//
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#addLocalTunnel(java.lang.String, int, java.lang.String, int)
//	 */
//	public void addLocalTunnel( String bindToAddress, int sourcePort, String targetHostName, int targetPort ) throws ProfileException {
//		log.info( "addLocalTunnel : " + sourcePort + ":" + targetHostName + ":" + targetPort );
//		ProfileException exception = null;
//		try {
//			session().setPortForwardingL( bindToAddress, sourcePort, targetHostName, targetPort );
//			//
//			// TODO : What all this "Tunnel is not active ... " ? Is it really necessary?
//			// 
//			Thread.yield();			
//			for( int i = 0; i < 10; i++ ) {
//				try {
//					Socket s = new  Socket( bindToAddress, sourcePort );
//					s.close();
//					return;
//				} catch ( Throwable t) {
//					try {
//						Thread.sleep( 1000 );
//					} catch (InterruptedException e) {
//						// DO Nothing
//					}
//				}
//			}
//			exception = new ProfileException( "Tunnel is not active in 10 second" );
//		} catch (JSchException e) {
//			exception = new ProfileException( "Fail to setup port forwarding '-L " + sourcePort + ":" + targetHostName + ":" + targetPort + "'", e );
//		}
//		if( exception != null ) {
//			try {
//				delLocalTunnel( bindToAddress, sourcePort );
//			} catch ( Throwable t ) {
//				// DO NOTHING. Will re-throw original exception
//			}
//			throw exception;
//		}
//	}
//	
//	public void delLocalTunnel( String bindToAddress, String sourcePortNumber ) throws ProfileException {
//		try {
//			delLocalTunnel( bindToAddress, Integer.parseInt( sourcePortNumber ));
//		} catch ( NumberFormatException e ) {
//			throw new ProfileException( "Fail to parse port number : " + e );
//		}
//	}
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#delLocalTunnel(java.lang.String, int)
//	 */
//	public void delLocalTunnel( String bindToAddress, int sourcePort ) throws ProfileException {
//		log.info( "delLocalTunnel : " + sourcePort );
//		try {
//			session().delPortForwardingL( bindToAddress, sourcePort );
//		} catch (JSchException e) {
////			throw new ProfileException( "Fail to teardown local port forwarding", e );
//			log.warn( "Fail to teardown local port forwarding " + bindToAddress + ":" + sourcePort, e );
//		}
//	}
//	
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#addRemoteTunnel(int, java.lang.String, int)
//	 */
//	public void addRemoteTunnel( String bindToAddress, int sourcePort, String targetHostName, int targetPort ) throws ProfileException {
//		try {
//			session().setPortForwardingR( sourcePort, targetHostName, targetPort );
//		} catch (JSchException e) {
//			throw new ProfileException( "Fail to setup port forwarding '-R " + sourcePort + ":" + targetHostName + ":" + targetPort + "'", e );
//		}
//	}
//		
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#delRemoteTunnel(int)
//	 */
//	public void delRemoteTunnel( int sourcePort ) throws ProfileException {
//		try {
//			session().delPortForwardingR( sourcePort  );
//		} catch (JSchException e) {
////			throw new ProfileException( "Fail to teardown remote port forwarding", e );
//			log.warn( "Fail to teardown remote port forwarding  *:" + sourcePort, e );
//		}
//	}
//	
//	public static int countConnectedSessions() {
//		int result = 0;
//		for( Iterator i = _sessions.entryIterator(); i.hasNext(); ) {
//			Map.Entry e = (Entry) i.next();
//			JschSession jschSession = (JschSession) e.getValue();
//			
//			if( jschSession._jschSession != null && jschSession._jschSession.isConnected()) {
//				result ++;
//			}
//		}
//		return result;
//	}
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#directTcpIpChannel(java.io.InputStream, java.io.OutputStream, java.lang.String, int)
//	 */
//	public ISSHSession.IChannel  streamTunnel( InputStream in, OutputStream out, String hostName, int port ) {
//		if( this.isConnected()) {
//			ChannelDirectTCPIP ch;
//			try {
//				ch = (ChannelDirectTCPIP) this.openChannel("direct-tcpip");
//			} catch (ProfileException e1) {
//				return null;
//			}
//			
//			ch.setHost( hostName );
//			ch.setPort( port );
//			try {
//				//
//				// It looks like we can do connect without setting in/out.
//				// channel will do all connection testing and than just disconect
//				//
//				ch.connect();
//			} catch (JSchException e1) {
//				return null;
//			}
//			try {
//				ch = (ChannelDirectTCPIP) this.openChannel("direct-tcpip");
//			} catch (ProfileException e1) {
//				return null;
//			}
//			
//			ch.setHost( hostName );
//			ch.setPort( port );
//			ch.setInputStream( in );
//			ch.setOutputStream( out );
//			try {
//				ch.connect();
//			} catch (JSchException e1) {
//				log.error( "directTcpIpChannel : Fail to connect", e1 );
//				return null;
//			}
//			return new ChannelIChannelWrapper( ch );	
//		} else {
//			return null;
//		}
//	}
//	public static ISSHSession.IChannel anyDirectTcpIpChannel( InputStream in, OutputStream out, String hostName, int port ) {		
//		for( Iterator i = _sessions.entryIterator(); i.hasNext(); ) {
//			Map.Entry e = (Entry) i.next();
//			ISSHSession jschSession = (ISSHSession) e.getValue();
//				
//			ISSHSession.IChannel  ch = jschSession.streamTunnel( in, out, hostName, port);
//			if( ch != null ) {
//				return ch;
//			}
//		}
//		
//		return null;
//	}
//	
//	public synchronized Session session() throws ProfileException {
//		return session( false );
//	}
//	private synchronized Session session( boolean clearValue ) throws ProfileException {
//		if( _jschSession == null ) {			
//			try {
//				_jschSession = _jsch.getSession( _sshUserName, _sshServerName, _sshPort );
//				_jschSession.setSocketFactory( _soketFactory );
//				_jschSession.setUserInfo( new JschUserInfo( this ));
//				if( _proxy != null ) {
//					_jschSession.setProxy( _proxy );
//				}
//				_connectCount = 0;
//			} catch (JSchException e) {
//				String msg;
//				log.error( msg = "Fail to get session " + _sshUserName + "@" + _sshServerName + ":" + _sshPort );
//				throw new ProfileException( msg, e );
//			}			
//		}
//		Session result = _jschSession;
//		if( clearValue ) {
//			_jschSession = null;
//		}
//		return result;
//	}
//	static class JschUserInfo implements UserInfo, UIKeyboardInteractive{
//		JschSession _session;
//		
//		public JschUserInfo( JschSession session ) {
//			_session = session;
//		}
//		
//		public String getOtp( String challenge ) {
//			String[] challengeParts = challenge.split( " " );
//			boolean useMD5 =  challengeParts[ 0 ].indexOf( "md5" ) >= 0;
//			String sequence = challengeParts[ 1 ];
//			String seed = challengeParts[ 2 ];
//			
//			String password = null;
//			
//			String oneTimePassword = null;
//			
//			if( _session._password == null || _session._password.length() == 0 ) {
//				oneTimePassword = PasswordHelper.getPassword( 
//						_session._sshUserName + "@" + _session._sshServerName, 
//						"Please enter one time password for\n" + (useMD5 ? "md5" : "md4" ) + " " + sequence + " " + seed  
//					);
//			} else if( "@ask@".equals( _session._password )) {
//				password = PasswordHelper.getPassword( 
//						_session._sshUserName + "@" + _session._sshServerName, 
//						"Please enter your OTP secret password"  
//					);
//			} else {
//				password = _session._password;
//			}
//			
//			if( oneTimePassword == null && password != null ) {
//				OTP otp = new OTP(Integer.parseInt( sequence ), seed, password, useMD5 ? 5 : 4 );
//				otp.calc();
//				oneTimePassword = otp.toString();
//			}
//			
//			return oneTimePassword != null ? oneTimePassword : "" ;
//		}
//	
//		public String getPassphrase() {
//			if( "@ask@".equals( _session._passphrase )) {
//				return PasswordHelper.getPassword( 
//					_session._sshUserName + "@" + _session._sshServerName, 
//					"Please enter passphrase for user " + _session._sshUserName + " on ssh server " + _session._sshServerName 
//				);
//			} else {
//				_session._getPassphraseCount++;
//				return _session._passphrase == null ? "" : _session._passphrase;
//			}
//		}
//	
//		public String getPassword() {
//			
//			if( "@ask@".equals( _session._password )) {
//				return PasswordHelper.getPassword( 
//					_session._sshUserName + "@" + _session._sshServerName, 
//					"Please enter password for user " + _session._sshUserName + " on ssh server " + _session._sshServerName 
//				);
//			} else {
//				_session._getPasswordCount++;
//				return _session._password == null ? "" : _session._password;
//			}
//		}
//	
//		public boolean promptPassword(String message) {
//			if( _session._getPasswordCount > 0 ) {
//				JschSession.log.warn( message + " : incorrect password" );
//				return false;
//			} else {
//				return true;
//			}
//		}
//	
//		public boolean promptPassphrase(String message) {
//			if( _session._getPassphraseCount > 0 ) {
//				JschSession.log.warn( message + " : incorrect passphrase" );
//				return false;
//			} else {
//				return true;
//			}
//		}
//	
//		public boolean promptYesNo(String message) {
//			String yesOrNo = YesNoHelper.getYesNo( _session._sshUserName + "@" + _session._sshServerName, message );
//			return "yes".equals( yesOrNo );
//		}
//	
//		public void showMessage(String message) {
//			// DO NOTHING
//		}
//	
//		public String[] promptKeyboardInteractive(String destination, String name, String instruction, String[] prompt, boolean[] echo) {
//			String[] result = new String[ prompt.length ];
//			for( int i = 0; i < prompt.length; i++ ) {
//				if( prompt[ i ].indexOf( "otp-" ) == 0 ) {
//					result[ i ] = getOtp( prompt[ i ] );
//				} else if( prompt[ i ].indexOf( "assword:" ) > 0 ) {
//					result[ i ] = getPassword();
//				} else if( prompt[ i ].indexOf( "passphrase for") >= 0 ) {
//					result[ i ] = getPassphrase();
//				} else {
//					result [ i ] = PasswordHelper.getPassword( 
//						_session._sshUserName + "@" + _session._sshServerName, 
//						name + ":" + instruction + "\n" +
//						prompt[ i ]
//					);
//				}
//			}
//			return result;
//		}
//	}
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#openChannel(java.lang.String)
//	 */
//	public ISSHSession.IChannel openChannel(String string) throws ProfileException {
//		try {
//			return new ChannelIChannelWrapper( _jschSession.openChannel( string ));
//		} catch (JSchException e) {
//			throw new ProfileException( "Fail to open channel : " + string, e );
//		}
//	}
//
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#setSOCKS5Proxy(java.lang.String, int)
//	 */
//	public synchronized void setSOCKS5Proxy(String proxyHost, int proxyPort) {		
//		if( _proxy == null ) {
//			_proxy = new ProxySOCKS5( proxyHost, proxyPort );
//			_proxyToString = "SOCKS " + proxyHost + ":" + proxyPort;
//			if( _jschSession != null ) {
//				_jschSession.setProxy( _proxy );
//			}
//		} else {
//			log.error( "Session " + this + " already has proxy setted " + _proxy );
//		}
//	}
//
//	/* (non-Javadoc)
//	 * @see com.leapingbytes.almostvpn.util.ssh.ISSHSession#setHTTPProxy(java.lang.String, int)
//	 */
//	public synchronized void setHTTPProxy(String proxyHost, int proxyPort) {		
//		if( _proxy == null ) {
//			_proxy = new ProxyHTTP( proxyHost, proxyPort );
//			_proxyToString = "HTTP " + proxyHost + ":" + proxyPort;
//			if( _jschSession != null ) {
//				_jschSession.setProxy( _proxy );
//			}
//		} else {
//			log.error( "Session " + this + " already has proxy setted " + _proxy );
//		}
//	}
//	
//	public String sshUserName() {
//		return this._sshUserName;
//	}
//	public int sshPort() {
//		return this._sshPort;
//	}
//	public String sshServerName() {
//		return this._sshServerName;
//	}
//}
//
//class ChannelIChannelWrapper implements ISSHSession.IChannel {
//	Channel _ch;
//	public ChannelIChannelWrapper( Channel ch ) {
//		_ch = ch;
//	}
//	public void close() {
//		_ch.disconnect();
//		_ch = null;
//	}	
//}
