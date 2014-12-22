package com.leapingbytes.almostvpn.socks;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.net.InetAddress;
import java.net.UnknownHostException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.unknown.socks.AuthenticationNone;
import org.unknown.socks.Proxy;
import org.unknown.socks.ProxyMessage;
import org.unknown.socks.ProxyServer;
import org.unknown.socks.Socks5Proxy;
import org.unknown.socks.SocksException;
import org.unknown.socks.server.ServerAuthenticatorNone;

import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.almostvpn.util.ProxyConfigurationProvider;
import com.leapingbytes.almostvpn.util.ResourceAllocator;
import com.leapingbytes.almostvpn.util.ssh.ISSHSession;
import com.leapingbytes.almostvpn.util.ssh.SSHSessionFactory;

public class DynamicProxy extends Socks5Proxy {
	private static final Log log = LogFactory.getLog( DynamicProxy.class );
	public static InetAddress _LOCAL_;
	static {
		try {
			_LOCAL_ = InetAddress.getLocalHost();
		} catch (UnknownHostException e) {
			_LOCAL_ = null;
		}
	}
	
	static BaseProfileItem.IProfileItemWatcher 	_sessionWatcher = null;
	static boolean								_proxyEnabledOrg = false;
	static String								_proxyHostOrg = null;
	static int									_proxyPortOrg = 0;

	ISSHSession			_session				= null;
	boolean				_shareProxy				= false;
	int					_proxyPort				= 1080;
	boolean 			_controlSystemSettings	= false;

	ProxyServer			_proxyServer			= null;
	Thread				_proxyThread 			= null;
	
	private PipedInputStream		_channelIn;
	private PipedOutputStream		_channelOut;
	private PipedOutputStream		_channelInOut;
	private PipedInputStream		_channelOutIn;
	private ISSHSession.IChannel	_ch;	
	
	public static DynamicProxy start( ISSHSession session, boolean shareProxy, int proxyPort, boolean controlSystemSettings ) throws ProfileException {
		if( ! ResourceAllocator.lockPortOnAddress( shareProxy ? "0.0.0.0" : "127.0.0.1" , proxyPort)) {
			throw new ProfileException("Port conflict. Dynamic proxy fail to lock port " + proxyPort );
		}
		DynamicProxy p = new DynamicProxy();
		p._session = session;
		p._shareProxy = shareProxy;
		p._proxyPort = proxyPort;
		p._controlSystemSettings = controlSystemSettings;
		p.startProxy();	
		
		return p;
	}
	
	public void stop() {
		_proxyServer.stop();
		
		synchronized( _proxyServer ) {
			if( _proxyThread != null ) {
				try {
					_proxyThread.interrupt();
					_proxyThread.join( 10000 );
				} catch (InterruptedException e) {
					log.warn( "Wait for proxy thread to stop was interrupted" );
				}
			}
		}
		ResourceAllocator.releasePortOnAddress( _shareProxy ? "0.0.0.0" : "127.0.0.1" , _proxyPort );
	}
	
	public boolean shareProxy() {
		return _shareProxy;
	}
	public int proxyPort() {
		return _proxyPort;
	}
	
	public DynamicProxy() {
		super( _LOCAL_, 0);
		setAuthenticationMethod(0, new AuthenticationNone());
	}

	void startProxy() {
		_proxyServer = new ProxyServer(new ServerAuthenticatorNone());
		ProxyServer.setProxy( this );
		_proxyThread = new Thread( new Runnable() {
			public void run() {
				if( _shareProxy ) {
					_proxyServer.start( _proxyPort );
				} else {
					try {
						_proxyServer.start( _proxyPort, 10, InetAddress.getByName( "127.0.0.1"));
					} catch (UnknownHostException e) {
						log.error( "Fail to resolve 127.0.0.1???", e );
					}
				}
				synchronized( _proxyServer ) {
					_proxyThread = null;
				}
			}
		}
		);
		_proxyThread.setName( "Global SOCKS Thread" );
		_proxyThread.start();		

		if( _sessionWatcher == null && _controlSystemSettings ) {
			_sessionWatcher = new BaseProfileItem.IProfileItemWatcher() {
				public void event(String eventType, IProfileItem target) {
					if( BaseProfileItem._DID_START_EVENT_.equals( eventType )) {
						if( SSHSessionFactory.countConnectedSessions() == 1 ) {
							_proxyEnabledOrg = ProxyConfigurationProvider.defaultProvider().proxyEnabled( "SOCKS" );
							_proxyHostOrg = ProxyConfigurationProvider.defaultProvider().proxyHost( "SOCKS" );
							_proxyPortOrg = ProxyConfigurationProvider.defaultProvider().proxyPort( "SOCKS" );

							ProxyConfigurationProvider.defaultProvider().setProxyHost( "SOCKS", "127.0.0.1" );
							ProxyConfigurationProvider.defaultProvider().setProxyPort( "SOCKS", _proxyPort );							
							ProxyConfigurationProvider.defaultProvider().setProxyEnabled( "SOCKS", true );
						}
					} else if ( BaseProfileItem._WILL_STOP_EVENT_.equals( eventType )) {
						if( SSHSessionFactory.countConnectedSessions() == 1 ) {
							if( !_proxyEnabledOrg ) {
								ProxyConfigurationProvider.defaultProvider().setProxyEnabled( "SOCKS", false );
							}
							if( _proxyHostOrg != null ) {
								ProxyConfigurationProvider.defaultProvider().setProxyHost( "SOCKS", _proxyHostOrg );
							}
							if( _proxyPortOrg > 0 ) {
								ProxyConfigurationProvider.defaultProvider().setProxyPort( "SOCKS", _proxyPortOrg );
							}
							BaseProfileItem.removeWatcher( _sessionWatcher );
							_sessionWatcher = null;
						}
					}
				}
			};
			BaseProfileItem.addWatcher( SSHSession.class , _sessionWatcher );
		}
	}

	public boolean isDirect(InetAddress host) {
		return _session != null ? ! _session.isConnected() : SSHSessionFactory.countConnectedSessions() == 0;
	}

	public boolean isDirect(String host) {
		return _session != null ? ! _session.isConnected() : SSHSessionFactory.countConnectedSessions() == 0;
	}	
	
	protected ProxyMessage connect(InetAddress ip, int port) throws SocksException {
		return connect( ip.getCanonicalHostName(), port );
	}
	protected ProxyMessage connect(String host, int port) throws SocksException {
		_channelIn = new PipedInputStream();
		_channelOut = new PipedOutputStream();
		try {
			_channelInOut = new PipedOutputStream( _channelIn );
			_channelOutIn = new PipedInputStream( _channelOut );
		} catch (IOException e) {
			log.error( "connect : Fail to create pipes", e );
			return this.formMessage( Proxy.SOCKS_FAILURE, (InetAddress)null, 0 );
		}
			
		try {
			_ch = _session != null ? 
				_session.streamTunnel( _channelOutIn, _channelInOut, host, port) : 
				SSHSessionFactory.anyStreamTunnel( _channelOutIn, _channelInOut, host, port);
		} catch (ProfileException e) {
			throw new SocksException( "Fail to get direct tcp/ip channel to " + host + ":" + port, e );
		}
			
		if( _ch == null ) {
			return this.formMessage( Proxy.SOCKS_CONNECTION_REFUSED, (InetAddress)null, 0 );
		}
		
		in = _channelIn;
		out = _channelOut;
		
		return this.formMessage( Proxy.SOCKS_SUCCESS, _LOCAL_, 1080 );
	}		
	
	protected Proxy copy() {
		DynamicProxy result = new DynamicProxy();
		
		result._channelIn = _channelIn;
		result._channelInOut = _channelInOut;
		result._channelOut = _channelOut;
		result._channelOutIn = _channelOutIn;
		
		return result;
	}
	
	protected void endSession() {
		if( _ch != null ) {
			_ch.close();
		}
		
		super.endSession();
	}
	

	protected void startSession() throws SocksException {
		super.startSession();
	}

	protected ProxyMessage accept() throws IOException, SocksException {
		throw new SocksException(Proxy.SOCKS_CMD_NOT_SUPPORTED);
	}
	protected ProxyMessage bind(InetAddress ip, int port) throws SocksException {
		throw new SocksException(Proxy.SOCKS_CMD_NOT_SUPPORTED);
	}
	protected ProxyMessage bind(String host, int port) throws UnknownHostException, SocksException {
		throw new SocksException(Proxy.SOCKS_CMD_NOT_SUPPORTED);
	}
	protected ProxyMessage readMsg() throws SocksException, IOException {
		return super.readMsg();
	}
	protected void sendMsg(ProxyMessage msg) throws SocksException, IOException {
		super.sendMsg(msg);
	}		
}
