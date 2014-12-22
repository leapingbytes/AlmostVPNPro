package com.leapingbytes.almostvpn.util.ssh;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Hashtable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import ch.ethz.ssh2.Connection;
import ch.ethz.ssh2.ConnectionMonitor;
import ch.ethz.ssh2.HTTPProxyData;
import ch.ethz.ssh2.InteractiveCallback;
import ch.ethz.ssh2.KnownHosts;
import ch.ethz.ssh2.LocalPortForwarder;
import ch.ethz.ssh2.LocalStreamForwarder;
import ch.ethz.ssh2.ProxyData;
import ch.ethz.ssh2.ProxyException;
import ch.ethz.ssh2.SCPClient;
import ch.ethz.ssh2.SOCKS5ProxyData;
import ch.ethz.ssh2.ServerHostKeyVerifier;
import ch.ethz.ssh2.Session;

import com.leapingbytes.almostvpn.path.PathLocator;
import com.leapingbytes.almostvpn.server.profile.Profile;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.util.DataConsumer;
import com.leapingbytes.almostvpn.util.DataCopier;
import com.leapingbytes.almostvpn.util.ScriptRunner;
import com.leapingbytes.almostvpn.util.GUI.PasswordHelper;
import com.leapingbytes.almostvpn.util.GUI.YesNoHelper;
import com.leapingbytes.almostvpn.util.macosx.KeychainMasterPasswordProvider;
import com.leapingbytes.almostvpn.util.otp.OTP;

public class GanimedSSHSSession extends SSHSessionBase implements InteractiveCallback, ConnectionMonitor {
	static final Log log = LogFactory.getLog( GanimedSSHSSession.class );

	private Connection				_connection;

	static File 					_knownHosts = new File(PathLocator.sharedInstance().resolveHomePath( "~/.ssh/known_hosts" ));
	static KnownHosts 				_database = new KnownHosts();
	static ServerHostKeyVerifier 	_verifier = null;
	
	static {
		if (_knownHosts.exists()) {
			try {
				_database.addHostkeys(_knownHosts);
				
				_verifier = new SimpleVerifier( _database );
			} catch (IOException e) {
				log.warn( "Fail to add host keys from " + _knownHosts, e );
			}
		} else {
			log.warn( _knownHosts + " does not exist");			
		}
	}

	GanimedSSHSSession(String userName, String sshServerName, int sshPort) {
		super(userName, sshServerName, sshPort);
		
		_connection = new Connection( sshServerName, sshPort );
		
		_connection.addConnectionMonitor( this );
	}

	Hashtable	_localTunnels = new Hashtable();
	
	public void addLocalTunnel(String bindToAddress, int sourcePort, String targetHostName, int targetPort) throws ProfileException {		
		try {
			LocalPortForwarder tunnel = _connection.createLocalPortForwarder(
				new InetSocketAddress( bindToAddress, sourcePort ), 
				targetHostName, 
				targetPort
			);
			
			_localTunnels.put( bindToAddress + ":" + sourcePort  , tunnel );
		} catch (IOException e) {
			throw new ProfileException( "Fail to setup port forwarding '-L " + sourcePort + ":" + targetHostName + ":" + targetPort + "'", e );
		}
	}
	public void delLocalTunnel(String bindToAddress, int sourcePort) throws ProfileException {
		LocalPortForwarder tunnel = (LocalPortForwarder) _localTunnels.get( bindToAddress + ":" + sourcePort );
		if( tunnel != null ) {
			try {
				tunnel.close();
			} catch (IOException e) {
				log.warn( "Fail to teardown local port forwarding " + bindToAddress + ":" + sourcePort, e );
			}
		} else {
			log.warn( "No such local port forwarding " + bindToAddress + ":" + sourcePort );
		}
	}


	public void addRemoteTunnel(String bindToAddress, int sourcePort, String targetHostName, int targetPort) throws ProfileException {
		try {
			_connection.requestRemotePortForwarding( bindToAddress, sourcePort, targetHostName, targetPort );
		} catch (IOException e) {
			throw new ProfileException( "Fail to setup port forwarding '-R " + sourcePort + ":" + targetHostName + ":" + targetPort + "'", e );
		}
	}

	public void delRemoteTunnel(int sourcePort) throws ProfileException {
		try {
			_connection.cancelRemotePortForwarding( sourcePort );
		} catch (IOException e) {
			log.warn( "Fail to teardown remote port forwarding " + sourcePort, e );
		}
	}

	public boolean isConnected() {
		return _connection.isAuthenticationComplete();
	}

	String _sshIdentityPath = null;
	String _sshIdentityPassphrase = null;

	private int _getPassphraseCount;

	private int _getPasswordCount;

	public void addIdentity(String sshIdentityPath, String passphrase) throws ProfileException {
		_sshIdentityPath = sshIdentityPath;
		_sshIdentityPassphrase = passphrase;		
	}

	private boolean methodPossible( String method ) {
		String[] methods = null;
		try {
			methods = _connection.getRemainingAuthMethods( _sshUserName );
		} catch (IOException e ) {
			log.warn( "Fail to get auth methods", e );
			return true;
		}
		
		for( int i = 0; i < methods.length; i++ ) {
			if( methods[ i ].equalsIgnoreCase( method )) {
				return true;
			}
		}
		return false;
	}
	
	private int _startCount = 0;
	public synchronized void start() throws ProfileException {
		if(! "No Proxy".equals( this._proxyType )) {
			ProxyData proxyData = null;
			String protocolId = null;
			
			if( "HTTP".equalsIgnoreCase( _proxyType )) {
				protocolId = "htpx";
				proxyData = new HTTPProxyData( _proxyHost, _proxyPort );
			} else if( "HTTPS".equalsIgnoreCase( _proxyType )) {
				protocolId = "htsx";
				proxyData = new HTTPProxyData( _proxyHost, _proxyPort );
			} else if( "SOCKS".equalsIgnoreCase( _proxyType )) {
				protocolId = "sox";
				proxyData = new SOCKS5ProxyData( _proxyHost, _proxyPort );
			}
			
			if( protocolId != null ) {
				StringBuffer proxyUserName = new StringBuffer();								
				String proxyPassword = null;

				KeychainMasterPasswordProvider p = new KeychainMasterPasswordProvider();
				
				proxyPassword = p.getKeychainPassword( protocolId, proxyUserName, _proxyHost + ":" + _proxyPort, null, null );
				
				if( proxyPassword != null ) {
					// 	log.info( "start() : " + protocolId + "://" + proxyUserName + "@" + _proxyHost + ":" + _proxyPort + " -> " + proxyPassword );
					proxyData.setAuthentication( proxyUserName.toString(), proxyPassword );
				}
			}
			_connection.setProxyData(proxyData);
		}

		if( _startCount == 0 ) {
			log.info( "Starting connection : " + this );
			boolean keepTrying = "did wakeup".equals( Profile.threadCurrentProfile().reason());
			
			for( int tryAgain = _timeout; tryAgain > 0 ; tryAgain-- ) {
				try {
					_connection.connect(null, _timeout, _timeout );
					break;
				} catch ( ProxyException e ) {
					throw new ProfileException( "Fail to connect to " + this, e );						
				} catch (IOException e) {
					if( keepTrying ) {
						synchronized( this ) {
							try {
								this.wait( 1000 );
							} catch (InterruptedException e1) {
								// DO NOTHING
							}
						}
					} else {
						throw new ProfileException( "Fail to connect to " + this, e );
					}
				}
			}
			
			String message = null;
			if( ! _connection.isAuthenticationComplete() && methodPossible( "keyboard-interactive" )) {
				try {
					log.info( "Trying to authenticate using keyboard interactive" );
					_connection.authenticateWithKeyboardInteractive( _sshUserName, this );
				} catch (Throwable e) {
					message = "Fail to authenticate using keyboard interactive";
					log.info( message, e );
				}
			}
			if(( ! _connection.isAuthenticationComplete()) && methodPossible( "password") && ( _sshPassword != null )) {
				try {
					log.info( "Trying to authenticate using password" );
					_connection.authenticateWithPassword( _sshUserName, getPassword());
				} catch (Throwable e) {
					message = "Fail to authenticate using password ";
					log.info( message, e );
				}
			}
			if(( ! _connection.isAuthenticationComplete()) && methodPossible( "publickey") && ( _sshIdentityPath != null )) {
				try {
					log.info( "Trying to authenticate using identity " + _sshIdentityPath );
					_connection.authenticateWithPublicKey( _sshUserName, new File( PathLocator.sharedInstance().resolveHomePath( _sshIdentityPath )), this.getPassphrase());
				} catch (Throwable e) {
					message ="Fail to authenticate using identity " + _sshIdentityPath;
					log.info( message, e );
				}
			} 
			if( ! _connection.isAuthenticationComplete()) {
				throw new ProfileException( message != null ? message : "Fail to authenticate" );
			} else {
				log.info( "Connection started : " + this );				
			}
		} 
		_startCount++;
	}

	public synchronized void stop() throws ProfileException {
		_startCount--;
		if( _startCount <= 0 ) {
			_startCount = 0;
			_connection.close();
			log.info( "Connection stopped : " + this );				
		}
	}

	public ISSHSession.IChannel streamTunnel(InputStream in, OutputStream out, String hostName, int port) throws ProfileException {		
		try {
			LocalStreamForwarder forwarder = _connection.createLocalStreamForwarder( hostName, port );
			
			ISSHSession.IChannel result = new LocalStreamForwarderIChannelWrapper( forwarder, in, out );
			
			return result;
		} catch (IOException e) {
			throw new ProfileException( "Fail to create stream forwarder " + hostName + ":" + port, e );
		}
	}
	
	public IChannel exec(String command, boolean x11, InputStream in, OutputStream out ) throws ProfileException {
		try {
			Session session = _connection.openSession();
			
			if( x11 ) {
				session.requestX11Forwarding( "127.0.0.1", 6000, null, false );
			}
			
			session.execCommand( command );
			
			return new SessionIChannelWrapper( session, in, out );
		} catch ( IOException e ) {
			throw new ProfileException("Fail to start shell", e );
		}
	}
	public IChannel shell(final String command) throws ProfileException {
		try {
			final ISSHSession thisSession = this;
			
			final Session session = _connection.openSession();
	
			int x_width = 0;
			int y_width = 0;
	
			session.requestPTY("xterm-color", x_width, y_width, 0, 0, null);
			session.startShell();
						
			final OutputStream out = session.getStdin();
			final InputStream err = session.getStderr();
			final InputStream in = session.getStdout();

//			session..setXForwarding(true);			
			
			final ServerSocket server = new ServerSocket(0, 50, InetAddress.getByName( "::1" ));
			int serverPort = server.getLocalPort();
			log.info( "Console server port : " + serverPort );
			
			final String title = this.toString();

			Thread shellRepeaterThread = new Thread(
				new Runnable() {
					ServerSocket _thisServer = server;
					ISSHSession _thisSession = thisSession;
					public void run() {
						Socket s;
						while( _thisSession.isConnected()) {
							try {
								s = _thisServer.accept();
								
								log.info( "Console client port : " + s.getLocalPort());
	
								InputStream pInput = s.getInputStream();
								OutputStream pOutput = s.getOutputStream();
								
								int ch1, ch2, ch3;
								for( int i = 0; i < 2; i++ ) {
									ch1 = pInput.read();
									if( ch1 == 255 ) {
										ch2 = pInput.read();
										ch3 = pInput.read();
										
										if( ch2 == 253 && ch3 == 1 ) { // DO see http://www.networksorcery.com/enp/protocol/telnet.htm
											pOutput.write( 255 );
											pOutput.write( 252 );
											pOutput.write( 1 );
											pOutput.write( 255 );
											pOutput.write( 251 );
											pOutput.write( 1 );
										} 
									} else {
										out.write( ch1 );
										break;
									}
								}
								
								
								DataCopier inOutCopier = new DataCopier( in, pOutput )
									.setInteractive( true )
									.setName( "fromSSH" );
								DataCopier errOutCopier = new DataCopier( err, pOutput )
									.setInteractive( true )
									.setName( "fromSSH-err" );
								
								DataCopier outInCopier = new DataCopier( pInput, out, command + "\n" )
									.setInteractive( true )
									.setName( "fromConsole" );
								
								outInCopier.setCollege( inOutCopier );
								
								errOutCopier.start();
								inOutCopier.start();
								outInCopier.start();	
								
//								inOutCopier.join();
//								
//								s.close();
							} catch (IOException e) {
								log.error( "shell server fail", e );
							}
						}
						try {
							_thisServer.close();
						} catch (IOException e) {
							// DO NOTHING
						}
					}					
				}
			);
			shellRepeaterThread.start();
			ScriptRunner.runScript(
				"./startTerminal.sh " + serverPort + " " + title + " " + x_width + " " + y_width
			);
			return new SessionIChannelWrapper( session );
		} catch ( IOException e ) {
			throw new ProfileException("Fail to start shell", e );
		}
	}
	public void scpFrom(String srcFilePath, String destFilePath) throws ProfileException {
		SCPClient scpClient = null;
		try {
			scpClient = _connection.createSCPClient();			
		} catch (IOException e) {
			throw new ProfileException( "Fail to create SCPClient", e );
		}
		
		try {
			scpClient.get( srcFilePath, destFilePath );
		} catch (IOException e) {
			throw new ProfileException( "Fail to copy " + this.toString() + srcFilePath + " -> " + destFilePath , e );
		} 
	}
	public void scpTo(String srcFilePath, String destFilePath) throws ProfileException {
		SCPClient scpClient = null;
		try {
			scpClient = _connection.createSCPClient();			
		} catch (IOException e) {
			throw new ProfileException( "Fail to create SCPClient", e );
		}
		
		try {
			scpClient.put( srcFilePath, destFilePath );
		} catch (IOException e) {
			throw new ProfileException( "Fail to copy " + this.toString() + srcFilePath + " -> " + destFilePath , e );
		}
	}

	public long getSendBytes() {
		return _connection.getSendBytes();
	}
	
	public long getRecievedBytes() {
		return _connection.getRecievedBytes();
	}

	// ========================================================================
	//  Keyboar Interactive Callback
	// ========================================================================	
	public String getOtp( String challenge ) {
		String[] challengeParts = challenge.split( " " );
		boolean useMD5 =  challengeParts[ 0 ].indexOf( "md5" ) >= 0;
		String sequence = challengeParts[ 1 ];
		String seed = challengeParts[ 2 ];
		
		String password = null;
		
		String oneTimePassword = null;
		
		if( _sshPassword == null || _sshPassword.length() == 0 ) {
			oneTimePassword = PasswordHelper.getPassword( 
					this.toString(), 
					"Please enter one time password for\n" + (useMD5 ? "md5" : "md4" ) + " " + sequence + " " + seed  
				);
		} else if( "@ask@".equals( _sshPassword )) {
			password = PasswordHelper.getPassword( 
					this.toString(), 
					"Please enter your OTP secret password"  
				);
		} else {
			password = _sshPassword;
		}
		
		if( oneTimePassword == null && password != null ) {
			OTP otp = new OTP(Integer.parseInt( sequence ), seed, password, useMD5 ? 5 : 4 );
			otp.calc();
			oneTimePassword = otp.toString();
		}
		
		return oneTimePassword != null ? oneTimePassword : "" ;
	}

	public String getPassphrase() {
		if( "@ask@".equals( _sshIdentityPassphrase )) {
			return PasswordHelper.getPassword( 
				this.toString(), 
				"Please enter passphrase for user " + _sshUserName + " on ssh server " + _sshServerName 
			);
		} else {
			_getPassphraseCount++;
			return _sshIdentityPassphrase == null ? "" : _sshIdentityPassphrase;
		}
	}

	public String getPassword() {
		
		if( _sshPassword == null || _sshPassword.length() == 0 || "@ask@".equals( _sshPassword )) {
			return PasswordHelper.getPassword( 
				this.toString(), 
				"Please enter password for user " + _sshUserName + " on ssh server " + _sshServerName 
			);
		} else {
			_getPasswordCount++;
			return _sshPassword == null ? "" : _sshPassword;
		}
	}


	/*
	 * (non-Javadoc)
	 * @see ch.ethz.ssh2.InteractiveCallback#replyToChallenge(java.lang.String, java.lang.String, int, java.lang.String[], boolean[])
	 */
	public String[] replyToChallenge(String name, String instruction, int numPrompts, String[] prompt, boolean[] echo) throws Exception {
		// log.info( "replyToChallenge : " + name + " " + instruction );
		String[] result = new String[ prompt.length ];
		for( int i = 0; i < prompt.length; i++ ) {
			// log.info( "replyToChallenge : " + i + ") " + prompt[ i ]  );
			if( prompt[ i ].indexOf( "otp-" ) == 0 ) {
				result[ i ] = getOtp( prompt[ i ] );
			} else if( prompt[ i ].indexOf( "assword:" ) > 0 ) {
				result[ i ] = getPassword();
			} else if( prompt[ i ].indexOf( "passphrase for") >= 0 ) {
				result[ i ] = getPassphrase();
			} else {
				result [ i ] = PasswordHelper.getPassword( 
					this.toString(), 
					name + ":" + instruction + "\n" +
					prompt[ i ]
				);
			}
			
//			log.info( "REMOVE : replyToChallenge : " + i + ") " + prompt[ i ] + " -> " + result [ i ] );
		}
		return result;
	}
	public void connectionLost(Throwable reason) {
		this.stateEvent( "Connection Lost", reason );
	}
}

class LocalStreamForwarderIChannelWrapper implements ISSHSession.IChannel {
	LocalStreamForwarder	_forwarder;
	InputStream				_is;
	OutputStream			_os;
	
	DataCopier				_in2out;
	DataCopier				_out2in;
	
	public LocalStreamForwarderIChannelWrapper( LocalStreamForwarder forwarder, InputStream is, OutputStream os ) throws ProfileException {
		_forwarder = forwarder;
		_is = is;
		_os = os;
		try {
			_in2out = new DataCopier( is, _forwarder.getOutputStream() );
			_in2out.setName( "in2out:" + _forwarder );
			_out2in = new DataCopier( _forwarder.getInputStream(), os );
			_out2in.setName( "out2in:" + _forwarder );
			_out2in.setCollege( _in2out );
			
			_in2out.start();
			_out2in.start();
		} catch (IOException e) {
			throw  new ProfileException( "Fail to connect streams " + _forwarder ,e );
		}
	}
	
	public void close() {
		try {
			_in2out.setTimeToClose();
			_forwarder.close();
		} catch (IOException e) {
			GanimedSSHSSession.log.warn("Fail to close stream forwarder " + _forwarder, e );
		}
	}	
}

class SessionIChannelWrapper implements ISSHSession.IChannel {
	Session _session;
	InputStream				_is;
	OutputStream			_os;
	
	DataCopier				_in2out = null;
	DataCopier				_out2in = null;
	
	public SessionIChannelWrapper( Session session ) {
		_session = session;
	}

	public SessionIChannelWrapper( Session session, InputStream is, OutputStream os  ) {
		_session = session;
		_is = is;
		_os = os;

		if( is != null ) {
			_in2out = new DataCopier( is, _session.getStdin() );
		} 
		if( os != null ) {
			_out2in = new DataCopier( _session.getStdout(), os );
		} else {
			new DataConsumer( _session.getStdout());
		}
	}

	public void close() {
		if( _in2out != null ) {
			_in2out.setTimeToClose();
		} else if( _out2in != null ){
			_out2in.setTimeToClose();
		}
		_session.close();
	}
}

class SimpleVerifier implements ServerHostKeyVerifier
{
	KnownHosts database;

	/*
	 * This class is being used by the UsingKnownHosts.java example.
	 */
	
	public SimpleVerifier(KnownHosts database)
	{
		if (database == null)
			throw new IllegalArgumentException();

		this.database = database;
	}

	public boolean verifyServerHostKey(String hostname, int port, String serverHostKeyAlgorithm, byte[] serverHostKey) 	throws Exception {
		int result = database.verifyHostkey(hostname, serverHostKeyAlgorithm, serverHostKey);

		switch (result) {
		case KnownHosts.HOSTKEY_IS_OK: {

			return true; // We are happy
		}
		case KnownHosts.HOSTKEY_IS_NEW: {

			// Unknown host? Blindly accept the key and put it into the cache.
			// Well, you definitely can do better (e.g., ask the user).

			// The following call will ONLY put the key into the memory cache!
			// To save it in a known hosts file, also call "KnownHosts.addHostkeyToFile(...)"
			
			String yesOrNo = YesNoHelper.getYesNo( this.toString(), "New host key:\n" + bytesToString( serverHostKey ) + "\nDo you want to accept it?"  );
			
			if( "yes".equals( yesOrNo )) {
				database.addHostkey(new String[] { hostname }, serverHostKeyAlgorithm, serverHostKey);
				KnownHosts.addHostkeyToFile( GanimedSSHSSession._knownHosts, new String[] { hostname }, serverHostKeyAlgorithm, serverHostKey);
				return true;
			} else {
				return false;
			}
		}
		case KnownHosts.HOSTKEY_HAS_CHANGED: {

			// Close the connection if the hostkey has changed.
			// Better: ask user and add new key to database.
			String yesOrNo = YesNoHelper.getYesNo( 
					this.toString(), "Host identity has been changed. New identity is:.\n" + bytesToString( serverHostKey ) + "\nDo you want to accept it?"  );
			
			if( "yes".equals( yesOrNo )) {
				database.addHostkey(new String[] { hostname }, serverHostKeyAlgorithm, serverHostKey);
				KnownHosts.addHostkeyToFile( GanimedSSHSSession._knownHosts, new String[] { hostname }, serverHostKeyAlgorithm, serverHostKey);
				return true;
			} else {
				return false;
			}

		}
		default:
			throw new IllegalStateException();
		}
	}
	
	static private String bytesToString(byte[] bytes)
	{
		final char[] alpha = "0123456789abcdef".toCharArray();

		StringBuffer sb = new StringBuffer();

		for (int i = 0; i < bytes.length; i++)
		{
			if (i != 0)
				sb.append(':');
			int b = bytes[i] & 0xff;
			sb.append(alpha[b >> 4]);
			sb.append(alpha[b & 15]);
		}

		return sb.toString();
	}

}