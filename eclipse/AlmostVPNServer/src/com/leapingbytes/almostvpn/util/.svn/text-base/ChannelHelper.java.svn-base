package com.leapingbytes.almostvpn.util;


public class ChannelHelper {
//	static private final Log log = LogFactory.getLog( ChannelHelper.class );
	
//	public static int Scp( ISSHSession srcSession, String srcFilePath, ISSHSession dstSession, String dstFilePath ) throws ProfileException {
//		if( srcSession == null && dstSession == null ) { // This is local copy. Why?
//			throw new ProfileException( "Scp : Both src and dst sessions are null. Use Script class to do local copy");
//		}
//		
//		if( srcSession == null ) { // ScpTo
//			return ScpTo( srcFilePath, dstSession, dstFilePath );
//		} else if( dstSession == null ) { // ScpFrom
//			return ScpFrom( srcSession, srcFilePath, dstFilePath );
//		} else {
//			return ScpFromTo( srcSession, srcFilePath, dstSession, dstFilePath );
//		}
//	}
	
//	public static int ScpFromTo(  ISSHSession srcSession, String srcFilePath, ISSHSession dstSession, String dstFilePath ) throws ProfileException {
//		String fromCommand = "scp -f " + srcFilePath;
//		Channel fromChannel = srcSession.openChannel("exec");
//		((ChannelExec) fromChannel).setCommand(fromCommand);
//		
//		String toCommand = "scp -p -t " + dstFilePath;
//		Channel toChannel = dstSession.openChannel("exec");
//		((ChannelExec) toChannel).setCommand(toCommand);
//
//		try {
//			OutputStream fromOut = fromChannel.getOutputStream();
//			InputStream fromIn = fromChannel.getInputStream();
//			
//			OutputStream toOut = toChannel.getOutputStream();
//			InputStream toIn = toChannel.getInputStream();
//
//			fromChannel.connect();
//			sendByte(0, fromOut );
//
//			toChannel.connect();
//			if (checkAck(toIn) != 0) {
//				return -1;
//			}
//
//			byte[] ioBuffer = new byte[64*1024];
//
//			while (true) {
//				// Expecting something like C0644 <file size> <file name>\n
//				int c = checkAck(fromIn);
//				if (c != 'C') { // Got 'C'
//					break;
//				}
//
//				// skip '0644 '
//				fromIn.read(ioBuffer, 0, 5);
//				// read file size
//				long filesize = readFileSize( fromIn, ioBuffer );
//				// read file name
//				String srcFileName = readFileName( fromIn, ioBuffer );
//				sendByte( 0, fromOut );
//
//				log.info( "Scp : " + srcFileName + " (" + filesize + ") bytes" );
//				
//				// CC to toChannel
//				toOut.write(( "C0644 " + filesize + " " + srcFileName + "\n" ).getBytes());
//
//				copyFromTo( fromIn, toOut, filesize, ioBuffer );
//
//				sendByte( 0, fromOut );
//				sendByte( 0, toOut );
//
//				if (checkAck(fromIn) != 0) {
//					return -1;
//				}
//				if (checkAck(toIn) != 0) {
//					return -1;
//				}
//			}
//		} catch (Exception e) {
//			throw new ProfileException("Fail to ScpFrom : ", e);
//		}
//		return 0;
//	}

//	public static int ScpTo(String srcFilePath, ISSHSession session, String destFilePath) throws ProfileException {
//		log.info( "ScpTo : " + srcFilePath + " -> " + session + ":" + destFilePath );
//		// exec 'scp -t rfile' remotely
//		String command = "scp -p -t " + destFilePath;
//		Channel channel = session.openChannel("exec");
//		((ChannelExec) channel).setCommand(command);
//
//		try {
//			OutputStream out = channel.getOutputStream();
//			InputStream in = channel.getInputStream();
//
//			channel.connect();
//
//			if (checkAck(in) != 0) {
//				return -1;
//			}
//
//			srcFilePath = PathLocator.sharedInstance().resolveHomePath( srcFilePath );
//			long filesize = writeCopyToPreambule( out, srcFilePath );
//
//			if (checkAck(in) != 0) {
//				return -1;
//			}
//
//			FileInputStream fis = new FileInputStream( srcFilePath );
//			byte[] ioBuffer = new byte[64*1024];
//			
//			copyFromTo( fis, out, filesize, ioBuffer );
//
//			sendByte( 0, out );
//
//			if (checkAck(in) != 0) {
//				return -1;
//			}
//		} catch ( Exception e) {
//			throw new ProfileException("Fail to ScpTo : ", e);
//		}
//		return 0;
//	}

//	public static int ScpFrom(ISSHSession session, String srcFilePath, String destFilePath) throws ProfileException {
//		log.info( "ScpFrom : " + session + ":" + srcFilePath + " -> " + destFilePath );
//		// exec 'scp -f rfile' remotely
//		String command = "scp -f " + srcFilePath;
//		Channel channel = session.openChannel("exec");
//		((ChannelExec) channel).setCommand(command);
//
//		try {
//			OutputStream out = channel.getOutputStream();
//			InputStream in = channel.getInputStream();
//
//			channel.connect();
//
//			byte[] ioBuffer = new byte[64*1024];
//
//			sendByte(0, out);
//
//			while (true) {
//				int c = checkAck(in);
//				if (c != 'C') {
//					break;
//				}
//
//				// skip '0644 '
//				in.read(ioBuffer, 0, 5);
//				// read file size
//				long filesize = readFileSize( in, ioBuffer );
//				// read file name
//				String srcFileName = readFileName( in, ioBuffer );
//				sendByte( 0, out );
//
//				log.info( "ScpFrom : " + srcFileName + " (" + filesize + ") bytes" );
//
//				// read a content of lfile
//				FileOutputStream fos = new FileOutputStream(PathLocator.sharedInstance().resolveHomePath( destFilePath));
//					copyFromTo( in, fos, filesize, ioBuffer );
//				fos.close();
//
//				if (checkAck(in) != 0) {
//					return -1;
//				}
//				sendByte( 0, out );
//			}
//		} catch (Exception e) {
//			throw new ProfileException("Fail to ScpFrom : ", e);
//		}
//		return 0;
//	}

//	public static Channel Excec( ISSHSession session, String command, boolean x11, InputStream input, OutputStream output ) throws ProfileException {
//		ChannelExec channel=(ChannelExec) session.openChannel("exec");
//		channel.setCommand(command);
//		channel.setXForwarding(x11);
//		
//		// err -> stderr 
//		channel.setErrStream(System.err);
//		
//		
//		// input from input or /dev/null or std in.
//		InputStream in;		
//		try {
//			in = input == null ? new FileInputStream( "/dev/null" ) : input;
//		} catch (FileNotFoundException e1) {
//			in = System.in;
//		}		
//		channel.setInputStream(in);
//		
//		try {
//			if( output == null ) {
//				InputStream chIn = channel.getInputStream();
//	
//				channel.connect();
//				
//				DataConsumer ds = new DataConsumer( chIn );
//				System.out.println( "out : " + ds.data());
//			} else {
//				channel.setOutputStream( output );
//				channel.connect();
//			}
//		} catch (JSchException e) {
//			throw new ProfileException( "Fail to open exec channel for command : " + command, e );
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//		return channel;
//	}
	
//	public static Channel Shell(final ISSHSession session, final String command ) throws ProfileException {
//		Channel channel = session.openChannel("shell");		
//		try {
//			final OutputStream out = channel.getOutputStream();
//			final InputStream in = channel.getInputStream();
//
//			channel.setXForwarding(true);			
//
//			channel.connect();
//			
//			final ServerSocket server = new ServerSocket(0, 50, InetAddress.getByName( "::1" ));
//			int serverPort = server.getLocalPort();
//			log.info( "Console server port : " + serverPort );
//
//			Thread shellRepeaterThread = new Thread(
//				new Runnable() {
//
//					public void run() {
//						Socket s;
//						try {
//							s = server.accept();
//							
//							log.info( "Console client port : " + s.getLocalPort());
//
//							server.close();
//
//							InputStream pInput = s.getInputStream();
//							OutputStream pOutput = s.getOutputStream();
//							
//							int ch1, ch2, ch3;
//							for( int i = 0; i < 2; i++ ) {
//							ch1 = pInput.read();
//								if( ch1 == 255 ) {
//									ch2 = pInput.read();
//									ch3 = pInput.read();
//									
//									if( ch2 == 253 && ch3 == 1 ) { // DO see http://www.networksorcery.com/enp/protocol/telnet.htm
//										pOutput.write( 255 );
//										pOutput.write( 252 );
//										pOutput.write( 1 );
//										pOutput.write( 255 );
//										pOutput.write( 251 );
//										pOutput.write( 1 );
//									} 
////									else {
////										ch2 = 251;		// WILL
////										pOutput.write( ch1 );
////										pOutput.write( ch2 );
////										pOutput.write( ch3 );
////									}
//								} else {
//									out.write( ch1 );
//									break;
//								}
//							}
//							
//							pOutput.write( ("\033]0;"+ session +"\007").getBytes());
//							
//							DataCopier inOutCopier = new DataCopier( 
//								in, 
//								pOutput 
//							)
//								.setInteractive( true )
//								.setName( "fromSSH" );
//							
//							DataCopier outInCopier = new DataCopier( 
//								pInput, 
//								out, 
//								command + "\n" 
//							)
//								.setInteractive( true )
//								.setName( "fromConsole" );
//							
//							outInCopier.setCollege( inOutCopier );
//							
//							outInCopier.start();	
//							inOutCopier.start();
//							
//							inOutCopier.join();
//							
//							s.close();
//						} catch (IOException e) {
//							log.error( "shell server fail", e );
//						}
//					}
//					
//				}
//			);
//			shellRepeaterThread.start();
//			
//			ScriptRunner.runScript(
//				"./startTerminal.sh " + serverPort + " " + session.sshServerName()
//			);
//			return channel;
//		} catch (IOException e) {
//			throw new ProfileException( "Fail to start Console", e );
//		} catch (JSchException e) {
//			throw new ProfileException( "Fail to start Console", e );
//		}		
//	}
//	
//	static int checkAck(InputStream in) throws ProfileException {
//		try {
//			int b = in.read();
//			// b may be 0 	- success,
//			//          1 	- error,
//			//          2 	- fatal error,
//			//          -1 	- EOF
//			// 				- "normal" byte
//			if ((b == 0) || (b == -1)) {
//				return b;
//			}
//
//			if ((b == 1) || (b == 2)) {
//				StringBuffer sb = new StringBuffer();
//				int c;
//				do {
//					c = in.read();
//					sb.append((char) c);
//				} while (c != '\n');
//
//				throw new ProfileException(((b == 1) ? "ERROR" : "FATAL") + " : " + sb);
//			}
//			return b;
//		} catch (IOException e) {
//			throw new ProfileException( "Fail to checkAck", e);
//		}
//	}
//
//	static void sendByte(int b, OutputStream os) throws ProfileException {
//		try {
//			os.write(b);
//			os.flush();
//		} catch (IOException e) {
//			throw new ProfileException("Fail to write byte : " + b, e);
//		}
//	}
//
//	static String getShortFileName( String fileName ) {
//		if (fileName.lastIndexOf('/') > 0) {
//			fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
//		} 
//		return fileName;
//	}
//	
//	private static long writeCopyToPreambule( OutputStream out, String localFilePath ) throws IOException {
//		// send "C0644 filesize filename", where filename should not include '/'
//		long filesize = (new File(localFilePath)).length();
//		out.write(("C0644 " + filesize + " " + getShortFileName( localFilePath ) + "\n").getBytes());
//		out.flush();	
//		return filesize;
//	}
//	
//	private static long readFileSize( InputStream in, byte[] ioBuffer ) throws IOException {
//		long fileSize = 0L;
//		while (true) {
//			if (in.read(ioBuffer, 0, 1) < 0) {
//				// error
//				break;
//			}
//			if (ioBuffer[0] == ' ')
//				break;
//			fileSize = fileSize * 10L + (long) (ioBuffer[0] - '0');
//		}		
//		return fileSize;
//	}
//	
//	private static String readFileName( InputStream in, byte[] ioBuffer  ) throws IOException {
//		String result = null;
//		for (int i = 0;; i++) {
//			in.read(ioBuffer, i, 1);
//			if (ioBuffer[i] == (byte) 0x0a) {
//				result = new String(ioBuffer, 0, i);
//				break;
//			}
//		}
//		return result;
//	}
//	
//	private static int copyFromTo( InputStream from, OutputStream to, long fileSize, byte[] ioBuffer  ) throws IOException {
//		int bytesToRead;
//		
//		while (true) {
//			if (ioBuffer.length < fileSize) {
//				bytesToRead = ioBuffer.length;
//			} else {
//				bytesToRead = (int) fileSize;
//			}
//			bytesToRead = from.read(ioBuffer, 0, bytesToRead);
//			if (bytesToRead < 0) {
//				// error
//				break;
//			}
//			to.write(ioBuffer, 0, bytesToRead);
//			fileSize -= bytesToRead;
//			if (fileSize == 0L)
//				break;
//		}
//		return bytesToRead;
//	}
}
