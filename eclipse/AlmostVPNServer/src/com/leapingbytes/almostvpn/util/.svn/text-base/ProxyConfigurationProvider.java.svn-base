package com.leapingbytes.almostvpn.util;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.UnknownHostException;

import com.leapingbytes.almostvpn.util.macosx.SystemConfigurationProvider;

public abstract class ProxyConfigurationProvider {
	static final ProxyConfigurationProvider _defaultProvider = new SystemConfigurationProvider();
	
	public static ProxyConfigurationProvider defaultProvider() {
		return _defaultProvider;
	}
	
	abstract public boolean proxyEnabled( String proxyName );
	
	abstract public String proxyHost( String proxyName );
	abstract public int proxyPort( String proxyName );

	abstract public void setProxyHost( String proxyName, String hostName );
	abstract public void setProxyPort( String proxyName, int port );
	abstract public void setProxyEnabled( String proxyName, boolean onOff );

	abstract public boolean proxyAutoConfigEnabled();
	abstract public String proxyAutoConfigURL();
	
	abstract public boolean proxyAutoDiscoveryEnabled();
	
	public String findProxyAutoConfigURL() {
		if( proxyAutoConfigEnabled()) {
			return proxyAutoConfigURL();
		}
		
		String result = null;
		
		InetAddress localhost;
		try {
			localhost = InetAddress.getLocalHost();
			String canonicalLocalHostName = localhost.getCanonicalHostName();
//			canonicalLocalHostName = "host.tchijov.com";
			if( localhost.getHostAddress().equals( canonicalLocalHostName )) {
				result = null;
			} else {
				String[] parts = canonicalLocalHostName.split("\\.");
				for( int i = 1; i < parts.length - 1; i++ ) {
					String wpadURL = testWpadURL( parts, i );
					if( wpadURL != null ) {
						result = wpadURL;
						break;
					}
				}
			}
		} catch (UnknownHostException e) {
			// DO NOTHING
		}
		
		
		return result;
	}
	
	protected String testWpadURL( String[] hostNameParts, int i ) {
		StringBuffer URLString = new StringBuffer( "http://wpad" );
		for( ; i < hostNameParts.length; i++ ) {
			URLString.append( '.' );
			URLString.append( hostNameParts[ i ] );
		}
		URLString.append( "/wpad.dat" );
		
		return testWpadURL( URLString.toString());
	}
	
	protected String testWpadURL( String URLString ) {
		URL url = null;
		String result = null;
		try {
			url = new URL( URLString.toString());
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod( "HEAD" );
			connection.setUseCaches( false );
			connection.connect();
			int contentLength = connection.getContentLength();
			connection.disconnect();
			if( contentLength >= 0 ) {
				result = URLString.toString();
			}
		} catch (MalformedURLException e) {
			// DO NOTHING. result stays null
		} catch (IOException e) {
			// DO NOTHING. result stays null
		}
		return result;
	}
	
}
