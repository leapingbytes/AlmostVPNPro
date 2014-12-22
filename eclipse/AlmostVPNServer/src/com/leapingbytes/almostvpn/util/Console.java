package com.leapingbytes.almostvpn.util;

public class Console {
	public Console() {}
}
//
//import java.io.IOException;
//import java.io.InputStream;
//import java.io.OutputStream;
//import java.net.InetAddress;
//import java.net.Socket;
//import java.net.UnknownHostException;
//
//import javax.swing.JFrame;
//import javax.swing.JMenu;
//import javax.swing.JMenuBar;
//import javax.swing.JMenuItem;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//
//import com.jcraft.jcterm.EmulatorVT100;
//import com.jcraft.jcterm.JCTerm;
//
//public class Console extends JCTerm {
//	public static final Log log = LogFactory.getLog( Console.class );
//	String 			_title;
//	String			_command;
//	
//	JFrame			_frame;
//	
//	/**
//	 * 
//	 */
//	private static final long	serialVersionUID	= 6483192313137766015L;
//
//	public static Console	start( String title, InputStream in, OutputStream out ) {
//		Console console = new Console( title, in, out );
//		
//		console._frame = new JFrame(title);
//
////		frame.addWindowListener(new WindowAdapter() {
////			public void windowClosing(WindowEvent e) {
////				System.exit(0);
////			}
////		});
////
//		JMenuBar mb = console.getJMenuBar();
//		console._frame.setJMenuBar(mb);
//
//		console._frame.setSize(console.getTermWidth(), console.getTermHeight());
//		console._frame.getContentPane().add("Center", console);
//
//		console._frame.pack();
//		console.setVisible(true);
//		console._frame.setVisible(true);
//
//		console._frame.setResizable(true);
//		{
//			int foo = console.getTermWidth();
//			int bar = console.getTermHeight();
//			foo += (console._frame.getWidth() - console._frame.getContentPane().getWidth());
//			bar += (console._frame.getHeight() - console._frame.getContentPane().getHeight());
//			console._frame.setSize(foo, bar);
//		}
//		console._frame.setResizable(false);
//
//		console.setFrame(console._frame.getContentPane());		
//		
//		console.openSession();
//		
//		return console;
//	}
//	
//	public JMenuBar getJMenuBar() {
//		JMenuBar mb = new JMenuBar();
//		JMenu m;
//		JMenuItem mi;
//
//		m = new JMenu("File");
//		mi = new JMenuItem("Quit");
//		mi.addActionListener(this);
//		mi.setActionCommand("Quit");
//		m.add(mi);
//		mb.add(m);
//
//		return mb;
//	}
//
//	
//	Console(  String title, InputStream in, OutputStream out ) {
//		super();
//		_title = title;
//		this.in = in;
//		this.out = out;
//	}
//	
//	public void setCommand( String v ) {
//		_command = v;
//	}
//	
//	public void run() {
//		requestFocus();
//
//		emulator = new EmulatorVT100(this, in);
//		emulator.reset();
//		if( _command != null ) {
//			try {
//				out.write( _command.getBytes(), 0, _command.length() );
//				out.write( "\r".getBytes(), 0, "\r".length() );
//				out.flush();
//			} catch (IOException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//		}
//		emulator.start();
//		
//		log.info( "run : Done" );
//	}
//	
//	public void join() {
//		while( true ) {
//			try {
//				thread.join();
//				return;
//			} catch (InterruptedException e) {
//				// Do Nothing
//			} catch ( Throwable t ) {
//				return;
//			}
//		}
//	}
//	
//	public void stop() {
//		_frame.dispose();
//		quit();
//	}
//	
//	public static void main( String[] args ) {
//		String title = args[0];
//
//		InputStream in;
//		OutputStream out;
//		
//		if( args.length >= 2 ) {
//			int port = Integer.parseInt( args[ 1 ] );
//			try {
//				Socket s = new Socket( InetAddress.getByName("127.0.0.1"), port );
//				in = s.getInputStream();
//				out = s.getOutputStream();
//			} catch (UnknownHostException e) {
//				return;
//			} catch (IOException e) {
//				return;
//			}
//		} else {
//			in = System.in;
//			out = System.out;
//		}
//		Console console = Console.start( title, in, out );
//		console.join();
//	}
//}
