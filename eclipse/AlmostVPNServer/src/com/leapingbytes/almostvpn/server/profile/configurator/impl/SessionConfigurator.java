package com.leapingbytes.almostvpn.server.profile.configurator.impl;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.Function;
import org.mozilla.javascript.Script;
import org.mozilla.javascript.Scriptable;

import com.leapingbytes.almostvpn.model.Model;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.almostvpn.server.profile.configurator.BaseConfigurator;
import com.leapingbytes.almostvpn.server.profile.item.BaseProfileItem;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHPortForward;
import com.leapingbytes.almostvpn.server.profile.item.impl.SSHSession;
import com.leapingbytes.almostvpn.server.profile.item.spi.IProfileItem;
import com.leapingbytes.almostvpn.util.ProxyConfigurationProvider;
import com.leapingbytes.jcocoa.NSDictionary;

public class SessionConfigurator extends BaseConfigurator {
	private static final Log log = LogFactory.getLog( SessionConfigurator.class );
	
	protected SessionConfigurator() {
		super( Model.AVPNLocationClass );
	}

	public IProfileItem configure(NSDictionary definition) throws ProfileException {
		Model model = new Model( definition );
		
		SSHSession existingSession = profile().findSession( model );
		if( existingSession != null ) {
			return existingSession;
		}
		
		super.configure( definition );

		Model parent = model.parentModel();
		
		SSHSession parentSession = null;
		SSHPortForward parentPortForward = null;
		
		if( parent.className().equals( Model.AVPNLocationClass )) {
			parentSession = (SSHSession) configure( parent.definition() );
			parentPortForward = new SSHPortForward( 
				parentSession, 
				SSHPortForward.LOCAL, 
				0,
				model.address(),
				model.port()
			);
			parentPortForward = (SSHPortForward) profile().addItem( parentPortForward );
		}
		
		Model account = model.account();
		
		SSHSession thisSession = 
			parentPortForward == null ?
				new SSHSession( model.address(), model.port(), account.userName()) :
				new SSHSession( parentPortForward, parentPortForward.bindToAddress(), parentPortForward.srcPort(), account.userName());
				
		int timeout = model.timeout();
		if( timeout != 0 ) {
			thisSession.setTimeout( timeout * 1000 );
		}
				
		BaseProfileItem thatSession = (BaseProfileItem) profile().addItem( thisSession );
		if( thatSession != thisSession ) {
			// This SSHSession object was already configured.  Do nothing.
		} else {
			configureSSHSession( thisSession, model );
		}
		
		profile().addSession( model, (SSHSession) thatSession );
		
		return thatSession;
	}
	
	public static void configureSSHSession( SSHSession thisSession, Model model ) throws ProfileException {
		Model account = model.account();
		String proxy = model.proxy();
		
		String proxyType = null;
		String proxyHost = null;
		int proxyPort = 0;
		if( Model.AVPNSOCKSProxyMarker.equals( proxy ) || Model.AVPNHTTPProxyMarker.equals( proxy ) || Model.AVPNHTTPSProxyMarker.equals( proxy )) {
			ProxyConfigurationProvider p = ProxyConfigurationProvider.defaultProvider();
			
			proxyType = proxy;
			proxyHost = p.proxyHost( proxy );
			proxyPort = p.proxyPort( proxy );
		} else if( Model.AVPNAutomaticProxyMarker.equals( proxy )) {				
			congigureAutomaticProxy( model );
			proxyType = model.proxyType();
			proxyHost = model.proxyHost();
			proxyPort = model.proxyPort();
		}
		
		if( proxyType != null ) {
			if( proxyType.equals( Model.AVPNSOCKSProxyMarker ) ) {
				thisSession.setSOCKS5Proxy( proxyHost, proxyPort );
			} else {
				thisSession.setHTTPProxy( proxyHost, proxyPort );					
			}
		}
		
//		if( account.usePassword()) {
			String password = account.askPassword() ? 
				Model.AVPNAskMarker : 
				account.password();
			thisSession.setPassword( password );
//		}
		
		Model identity = model.identityModel();
		if( identity != null ) {
			String passphrase = null;
			if( identity.usePassphrase()) {
				passphrase = identity.askPassphrase() ? 
					Model.AVPNAskMarker : 
					identity.passphrase();
			}
			thisSession.setIdentity( identity.path(), passphrase );
		}
		
		int keepAlive = model.keepAlive();
		if( keepAlive > 0 ) {
			thisSession.setKeepAlive( keepAlive );
		}
		
		boolean runDynamicProxy = model.runDynamicProxy();
		if( runDynamicProxy ) {
			thisSession.setRunDynamicProxy( true );
			thisSession.setShareDynamicProxy( model.shareDynamicProxy());
			thisSession.setDynamicProxyPort( model.dynamicProxyPort());
		}
	}

	private static void congigureAutomaticProxy(Model model) {
		ProxyConfigurationProvider p = ProxyConfigurationProvider.defaultProvider();

		if (p.proxyEnabled("SOCKS")) {
			model.setProxyHost(p.proxyHost("SOCKS"));
			model.setProxyPort(p.proxyPort("SOCKS"));
		} else if (p.proxyEnabled("HTTPS")) {
			model.setProxyHost(p.proxyHost("HTTPS"));
			model.setProxyPort(p.proxyPort("HTTPS"));
		} else if (p.proxyEnabled("HTTP")) {
			model.setProxyHost(p.proxyHost("HTTP"));
			model.setProxyPort(p.proxyPort("HTTP"));
		} else {
			String pacURL = p.findProxyAutoConfigURL();
			if (pacURL == null) {
				log.debug("Automatic Proxy discovery found no proxy");
			} else {
				try {
					Context cx = Context.enter();
					Scriptable topScope = cx.initStandardObjects();
					
					Reader supportReader = new InputStreamReader( 
						SessionConfigurator.class.getClassLoader().getResourceAsStream( "com/leapingbytes/almostvpn/server/profile/configurator/impl/pacSupport.js" )
					);
					Script supportScript = cx.compileReader(supportReader, pacURL, 0, null);
					supportScript.exec( cx, topScope );

					URL url = new URL(pacURL);
					Reader urlReader = new InputStreamReader(url.openStream());
					Script script = cx.compileReader(urlReader, pacURL, 0, null);
					script.exec( cx, topScope );
					
					Function findProxyForURL = (Function) topScope.get( "FindProxyForURL", topScope);
					String ftpResult = (String) findProxyForURL.call( 
						cx, topScope, topScope, 
						new Object[] {
							"ftp://" + model.address(),
							model.address()
						}
					);
					String httpResult = (String) findProxyForURL.call( 
						cx, topScope, topScope, 
						new Object[] {
							"http://" + model.address(),
							model.address()
						}
					);
					String httpsResult = (String) findProxyForURL.call( 
						cx, topScope, topScope, 
						new Object[] {
							"https://" + model.address(),
							model.address()
						}
					);
					
					//
					// Trying to find SOCKS proxy
					// If failed, than any proxy
					//
					if( ftpResult.startsWith( Model.AVPNSOCKSProxyMarker )) {
						parseProxy( model, ftpResult );
					} else if( httpResult.startsWith( Model.AVPNSOCKSProxyMarker )) {
						parseProxy( model, httpResult );
					} else if( httpsResult.startsWith( Model.AVPNSOCKSProxyMarker )) {
						parseProxy( model, httpsResult );
					} else if( ! httpsResult.startsWith( "DIRECT" )) {
						parseProxy( model, httpsResult );						
					} else if( ! httpResult.startsWith( "DIRECT" )) {
						parseProxy( model, httpResult );						
					}
				} catch (MalformedURLException e) {
				} catch (IOException e) {
				} finally {
					Context.exit();
				}
			}
		}
	}
	
	private static void parseProxy( Model model, String proxyString ) {
		if( "DIRECT".equals( proxyString )) {
			return;
		}
		
		String[] parts = proxyString.split( " " );
		if( parts.length != 2 ) {
			log.error( "Can not parse : " + proxyString );
			return;
		} 
		int port;
		if( "PROXY".equals( parts[0])) {
			model.setProxyType( Model.AVPNHTTPProxyMarker );
			port = 8080;
		} else if( "SOCKS".equals( parts[0])) {
			model.setProxyType( Model.AVPNSOCKSProxyMarker );
			port = 1080;
		} else {
			log.error( "Unknown proxy type : " + proxyString );
			return;			
		}
		
		parts = parts[1].split( ":" );
		
		if( parts.length == 1 ) {
			model.setProxyHost( parts[ 0 ] );
			model.setProxyPort( port );
		} else if( parts.length == 2 ) {
			model.setProxyHost( parts[ 0 ] );
			model.setProxyPort( Integer.parseInt( parts[ 1 ] ));
		} else {
			log.error( "Can not parse host:port : " + proxyString );
			return;			
		}
	}

}
