
package ch.ethz.ssh2;

import java.io.IOException;
import java.net.Socket;

/**
 * An abstract marker interface implemented by all proxy data implementations.
 * 
 * @see HTTPProxyData
 * 
 * @author Christian Plattner, plattner@inf.ethz.ch
 * @version $Id: ProxyData.java,v 1.3 2006/08/02 12:17:22 cplattne Exp $
 */

public abstract interface ProxyData 
{
	public void setAuthentication( String userName, String password );
	
	public Socket connect( String hostname, int port, int connectTimeout ) throws IOException;
}
