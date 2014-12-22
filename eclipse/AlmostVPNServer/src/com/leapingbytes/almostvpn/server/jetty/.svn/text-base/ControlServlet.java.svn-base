package com.leapingbytes.almostvpn.server.jetty;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Iterator;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.leapingbytes.almostvpn.server.MonitorLogHandler;
import com.leapingbytes.almostvpn.server.RegistrationCenter;
import com.leapingbytes.almostvpn.server.ToolException;
import com.leapingbytes.almostvpn.server.profile.ProfileException;
import com.leapingbytes.jcocoa.NSArray;
import com.leapingbytes.jcocoa.NSDictionary;
import com.leapingbytes.jcocoa.PListSupport;

public class ControlServlet extends HttpServlet {
	private static final Log log = LogFactory.getLog( ControlServlet.class );	

	/**
	 * 
	 */
	private static final long serialVersionUID = 4255966980891766021L;


	protected void logParameters( String preffix, HttpServletRequest request ) {
		for( Iterator i = request.getParameterMap().keySet().iterator(); i.hasNext(); ) {
			String name = (String) i.next();
			String[] values = request.getParameterValues( name );
			StringBuffer message = new StringBuffer( preffix + " : " );
			
			message.append( name );
			if( values.length == 0 ) {
				// nothing
			} else if( values.length == 1 ) {
				message.append( " = " );
				message.append( values [ 0 ] );
			} else {
				message.append( " = [ " );
				for( int j = 0; j < values.length; j++ ) {
					if( j > 0 ) {
						message.append( ", " );
					}
					message.append( values[ j ] );
				}
				message.append( " ]" );
			}
			
			log.debug( message );			
		}
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logParameters( "doGet", request );
		String action = request.getParameter( "action" );
		Object result = null;
		try {
			if( "start".equals( action )) {
				String profileName = request.getParameter( "profile" );
				result = JettyServer.toolServer().doStartProfile( profileName );
			} else if( "stop".equals( action )) {
				String profileName = request.getParameter( "profile" );
				result = JettyServer.toolServer().doStopProfile( profileName );
			} else if( "pause".equals( action )) {
				String profileName = request.getParameter( "profile" );
				result = JettyServer.toolServer().doPauseProfile( profileName );
			} else if( "resume".equals( action )) {
				String profileName = request.getParameter( "profile" );
				result = JettyServer.toolServer().doResumeProfile( profileName );
			} else if( "status".equals( action )) {
				result = JettyServer.toolServer().doReportStatus();
			} else if( "exit".equals( action )) {
				MonitorLogHandler.timeToExit();
				JettyServer.toolServer().doExit();
				System.exit(0);
			}  else if( "save-registration".equals( action )) {
				String name = request.getParameter( "name" );
				String email = request.getParameter( "email" );
				String registration = request.getParameter( "registration" );
				result = RegistrationCenter.saveRegistration( name, email, registration);
			}  else if( "verify-registration".equals( action )) {
				String name = request.getParameter( "name" );
				String email = request.getParameter( "email" );
				result = RegistrationCenter.verifyRegistration( name, email );
			}  else if( "forget-registration".equals( action )) {
				result = RegistrationCenter.forgetRegistration();
			}  else if( "save-secret".equals( action )) {
				String key = request.getParameter( "key" );
				String value = request.getParameter( "value" );
				JettyServer.toolServer().saveSecret( key, value );
				result = "OK\n";
			} else if( "check-secret".equals( action )) {
				String key = request.getParameter( "key" );
				result = JettyServer.toolServer().checkSecret( key );
			} else if( "forget-secret".equals( action )) {
				String key = request.getParameter( "key" );
				JettyServer.toolServer().forgetSecret( key );
				result = "OK\n";
			} else if( "monitor".equals( action )) {
				response.setBufferSize(0);
				MonitorLogHandler mlh = new MonitorLogHandler( response.getOutputStream());				
				mlh.join();
				return;
			} else if( "event".equals( action )) {
				String event = request.getParameter( "event" );
				JettyServer.toolServer().event( event );
				result = "OK\n";
			} else if( "test-location".equals( action )) {
				String uuid = request.getParameter( "uuid" );
				result = JettyServer.toolServer().testLocation( uuid );
			} else {
				log.warn( "doGet : unknown action = " + action );				
			}
		} catch (ProfileException e) {
			throw new ServletException( e );
		} catch (ToolException e) {
			throw new ServletException( e );
		}
		
		if( result instanceof String ) {
			response.getWriter().write( (String)result );
			response.getWriter().close();			
		} else if( result != null ) {
			String reportFormat = request.getParameter( "report-format" ) == null ? "html" : request.getParameter( "report-format" );
			try {
				Writer output = new BufferedWriter( new OutputStreamWriter( response.getOutputStream() ));
				NSArray profiles = (NSArray) ((NSDictionary)result).objectForKey( "profiles" );
				if( profiles != null ) {
					if( "txt".equals( reportFormat )) {
						for( int i = 0; i < MonitorLogHandler.STATUS_ATTRIBUTES.length; i++ ) {
							output.write( MonitorLogHandler.STATUS_ATTRIBUTES[ i ] );
							output.write( "|" );
						}
						output.write( "\n" );

						for( int i = 0; i < profiles.count(); i++ ) {
							NSDictionary profile = (NSDictionary) profiles.objectAtIndex( i );
							for( int j = 0; j < MonitorLogHandler.STATUS_ATTRIBUTES.length; j++ ) {
								output.write( profile.objectForKey( MonitorLogHandler.STATUS_ATTRIBUTES[ j ] ).toString());
								output.write( "|" );								
							}
							output.write("\n" );
						}
					} else if( reportFormat.startsWith( "js:" ) ) {
						String varName = reportFormat.substring( reportFormat.indexOf( ":" ) + 1 );
						
						output.write( varName + " = new Array();\n" );
						for( int i = 0; i < profiles.count(); i++ ) {
							output.write( varName + "[ " + varName + ".length ] = new Object();\n" );
							NSDictionary profile = (NSDictionary) profiles.objectAtIndex( i );
							for( int j = 0; j < MonitorLogHandler.STATUS_ATTRIBUTES.length; j++ ) {
								output.write( varName + "[ " + varName + ".length - 1 ]." );
								output.write( asValidJSId( MonitorLogHandler.STATUS_ATTRIBUTES[ j ] ) );
								output.write( "='" );								
								output.write( escapeSymbol( profile.objectForKey( MonitorLogHandler.STATUS_ATTRIBUTES[ j ] ).toString(), "'" ));
								output.write( "';\n" );								
							}
							output.write("\n" );
						}
					} else if( reportFormat.equals( "html" )) {
						output.write( "<HTML><BODY><TABLE>\n");
						output.write( "<TR>" );
						for( int i = 0; i < MonitorLogHandler.STATUS_ATTRIBUTES.length; i++ ) {
							output.write( "<TH>" + MonitorLogHandler.STATUS_ATTRIBUTES[ i ] + "<TH>");
						}
						output.write( "<TR>\n" );

						for( int i = 0; i < profiles.count(); i++ ) {
							output.write( "<TR>" );
							NSDictionary profile = (NSDictionary) profiles.objectAtIndex( i );
							for( int j = 0; j < MonitorLogHandler.STATUS_ATTRIBUTES.length; j++ ) {
								output.write( "<TD>" + profile.objectForKey( MonitorLogHandler.STATUS_ATTRIBUTES[ j ] ).toString() + "</TD>" );
							}
							output.write( "<TR>\n" );
						}
						output.write( "</TABLE></BODY></HTML>\n");						
					} else {
						PListSupport.writeObject( result, output );
					}
				}
				output.close();
			} catch (IOException e) {
				System.err.println( "ERROR : Fail to open file : " + reportFormat );
			}	
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	}

	private static String asValidJSId( String s ) {
		String result = s;
		result = result.replace( '-', '_' );
		return result;
	}
	
	private static String escapeSymbol( String s, String symbol ) {
		String result = s;
		result = result.replaceAll( symbol, "\\" + symbol );
		return result;
	}	
}
