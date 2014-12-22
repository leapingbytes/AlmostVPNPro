package com.leapingbytes.almostvpn.util.ssh;

import java.io.InputStream;
import java.io.OutputStream;

import com.leapingbytes.almostvpn.server.profile.ProfileException;

public interface ISSHSession {
	
	public interface IStateListener {
		public void event( ISSHSession session, String comment, Throwable t );
	}
	
	public interface IChannel {
		public void close();
	}
	
	public abstract void setPassword(String value);
	public abstract void addIdentity(String sshIdentityPath, String passphrase) throws ProfileException;

	public abstract String	sshUserName();
	public abstract String	sshServerName();
	public abstract int		sshPort();

	public abstract boolean addListener( IStateListener listener);
	public abstract boolean deleteListener( IStateListener listener);

	public abstract int timeout();
	public abstract void setTimeout(int v);

	public abstract int keepAlive();
	public abstract void setKeepAlive(int v);

	public abstract void setSOCKS5Proxy(String proxyHost, int proxyPort);
	public abstract void setHTTPProxy(String proxyHost, int proxyPort);

	public abstract void start() throws ProfileException;
	public abstract void stop() throws ProfileException;

	public abstract boolean isConnected();

	public abstract void addLocalTunnel(String bindToAddress, int sourcePort, String targetHostName, int targetPort) throws ProfileException;
	public abstract void delLocalTunnel(String bindToAddress, int sourcePort) throws ProfileException;

	public abstract void addRemoteTunnel(String bindToAddress, int sourcePort, String targetHostName, int targetPort) throws ProfileException;
	public abstract void delRemoteTunnel(int sourcePort) throws ProfileException;

	public abstract IChannel streamTunnel(InputStream in, OutputStream out, String hostName, int port) throws ProfileException;
	
	public abstract void scpTo( String srcFilePath, String destFilePath) throws ProfileException;
//	public abstract OutputStream scpTo( String destFilePath ) throws ProfileException;
	
	public abstract void scpFrom( String srcFilePath, String destFilePath) throws ProfileException;	
//	public abstract InputStream scpFrom( String srcFilePaht ) throws ProfileException;
	
	public abstract IChannel exec( String command, boolean x11, InputStream input, OutputStream output ) throws ProfileException;
	public abstract IChannel shell( String command ) throws ProfileException;
	
	public abstract long getSendBytes();
	public abstract long getRecievedBytes();
}