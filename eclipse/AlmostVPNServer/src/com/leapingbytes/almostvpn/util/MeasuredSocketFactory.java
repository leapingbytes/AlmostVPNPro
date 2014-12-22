package com.leapingbytes.almostvpn.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.UnknownHostException;

import com.jcraft.jsch.SocketFactory;

public class MeasuredSocketFactory implements SocketFactory {
	MeasuredInputStream 	_measuredInput = null;
	MeasuredOutputStream 	_measuredOutput = null;
	
	public long getInputBytesCount() {
		return _measuredInput == null ? 0 : _measuredInput.bytesCount();
	}
	
	public long getOutputBytesCount() {
		return _measuredOutput == null ? 0 : _measuredOutput.bytesCount();
	}
	
	public void resetBytesCount() {
		if( _measuredInput != null )  _measuredInput.resetBytesCount();
		if( _measuredOutput != null )  _measuredOutput.resetBytesCount();
	}
	
	public Socket createSocket(String host, int port) throws IOException, UnknownHostException {
		return new Socket( host, port );
	}

	public InputStream getInputStream(Socket socket) throws IOException {		
		_measuredInput = new MeasuredInputStream( socket );
		return _measuredInput;
	}

	public OutputStream getOutputStream(Socket socket) throws IOException {
		_measuredOutput = new MeasuredOutputStream( socket );
		return _measuredOutput;
	}
}

class MeasuredInputStream extends InputStream {
	
	Socket			_socket;
	InputStream 	_is;
	
	long			_bytesCount = 0;
	
	public MeasuredInputStream( Socket socket ) throws IOException {
		_socket = socket;
		_is = _socket.getInputStream();
	}
	
	public void resetBytesCount() {
		_bytesCount = 0;
	}
	public long bytesCount() {
		return _bytesCount;
	}

	/* ==============================================================
	 * Measured methods 
	 * 
	 */
	public int read() throws IOException {
		int result = _is.read();
		if( result > 0 ) {
			_bytesCount++;
		}
		return result;
	}

	public int read(byte[] b, int off, int len) throws IOException {
		int result = _is.read(b, off, len);
		if( result > 0 ) {
			_bytesCount += result;
		}
		return result;
	}

	public int read(byte[] b) throws IOException {
		int result = _is.read(b);
		if( result > 0 ) {
			_bytesCount += result;
		}
		return result;
	}

	/* ==============================================================
	 * Proxy methods 
	 * 
	 */

	public int available() throws IOException {
		return _is.available();
	}

	public void close() throws IOException {
		_is.close();
	}

	public void mark(int readlimit) {
		_is.mark(readlimit);
	}

	public boolean markSupported() {
		return _is.markSupported();
	}

	public void reset() throws IOException {
		_is.reset();
	}

	public long skip(long n) throws IOException {
		return _is.skip(n);
	}

	public String toString() {
		return _is.toString();
	}
	
}

class MeasuredOutputStream extends OutputStream {
	
	Socket			_socket;
	OutputStream 	_os;
	
	long			_bytesCount = 0;
	
	public MeasuredOutputStream( Socket socket ) throws IOException {
		_socket = socket;
		_os = _socket.getOutputStream();
	}

	public void resetBytesCount() {
		_bytesCount = 0;
	}
	public long bytesCount() {
		return _bytesCount;
	}

	/* ==============================================================
	 * Measured methods 
	 * 
	 */
	public void write(int arg0) throws IOException {
		_os.write( arg0 );
		_bytesCount++;
	}

	public void write(byte[] b, int off, int len) throws IOException {
		_os.write(b, off, len);
		_bytesCount += len;
	}

	public void write(byte[] b) throws IOException {
		_os.write(b);
		_bytesCount += b.length;
	}

	/* ==============================================================
	 * Proxy methods 
	 * 
	 */
	public void close() throws IOException {
		_os.close();
	}

	public void flush() throws IOException {
		_os.flush();
	}

	public String toString() {
		return _os.toString();
	}
	
}
