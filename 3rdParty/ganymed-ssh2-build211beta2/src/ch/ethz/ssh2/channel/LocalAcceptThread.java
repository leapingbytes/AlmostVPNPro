
package ch.ethz.ssh2.channel;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * LocalAcceptThread.
 * 
 * @author Christian Plattner, plattner@inf.ethz.ch
 * @version $Id: LocalAcceptThread.java,v 1.8 2006/10/20 20:50:24 cplattne Exp $
 */
public class LocalAcceptThread extends Thread implements IChannelWorkerThread
{
	private static final Log log = LogFactory.getLog( LocalAcceptThread.class );
	
	ChannelManager cm;
	String host_to_connect;
	int port_to_connect;

	final ServerSocket ss;
	boolean			stopped = false;

	public LocalAcceptThread(ChannelManager cm, int local_port, String host_to_connect, int port_to_connect)
			throws IOException
	{
		this.cm = cm;
		this.host_to_connect = host_to_connect;
		this.port_to_connect = port_to_connect;

		ss = new ServerSocket(local_port);
	}

	public LocalAcceptThread(ChannelManager cm, InetSocketAddress localAddress, String host_to_connect,
			int port_to_connect) throws IOException
	{
		this.cm = cm;
		this.host_to_connect = host_to_connect;
		this.port_to_connect = port_to_connect;

		ss = new ServerSocket();
		ss.bind(localAddress);
	}

	public void run()
	{
		try
		{
			cm.registerThread(this);
		}
		catch (IOException e)
		{
			stopWorking();
			return;
		}

		while (true)
		{
			Socket s = null;

			try
			{
				s = ss.accept();
			}
			catch (IOException e)
			{
				if( ! stopped ) {
					log.warn( "accept failed", e );
				}
				stopWorking();
				return;
			}

			Channel cn = null;
			StreamForwarder r2l = null;
			StreamForwarder l2r = null;

			try
			{
				/* This may fail, e.g., if the remote port is closed (in optimistic terms: not open yet) */

				cn = cm.openDirectTCPIPChannel(host_to_connect, port_to_connect, s.getInetAddress().getHostAddress(), s
						.getPort());

			}
			catch (IOException e)
			{
				/* Simply close the local socket and wait for the next incoming connection */
				log.warn( "fail to open channel to " + host_to_connect + ":" + port_to_connect, e );

				try
				{
					s.close();
				}
				catch (IOException ignore)
				{
				}

				continue;
			}

			try
			{
				r2l = new StreamForwarder(cn, null, null, cn.stdoutStream, s.getOutputStream(), "RemoteToLocal");
				l2r = new StreamForwarder(cn, r2l, s, s.getInputStream(), cn.stdinStream, "LocalToRemote");
			}
			catch (IOException e)
			{
				log.info( "channel to " + host_to_connect + ":" + port_to_connect + " closed", e );
				try
				{
					/* This message is only visible during debugging, since we discard the channel immediatelly */
					cn.cm.closeChannel(cn, "Weird error during creation of StreamForwarder (" + e.getMessage() + ")",
							true);
				}
				catch (IOException ignore)
				{
				}

				continue;
			}

			r2l.setDaemon(true);
			l2r.setDaemon(true);
			r2l.start();
			l2r.start();
		}
	}

	public void stopWorking()
	{
		try
		{
			stopped = true;
			/* This will lead to an IOException in the ss.accept() call */
			ss.close();
		}
		catch (IOException e)
		{
		}
	}
}
