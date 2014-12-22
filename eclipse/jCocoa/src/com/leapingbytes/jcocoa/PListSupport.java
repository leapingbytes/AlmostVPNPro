package com.leapingbytes.jcocoa;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.lang.reflect.Array;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

public class PListSupport {
	private static final Log log = LogFactory.getLog( PListSupport.class );

	public static void writeObject( Object o, Writer osw ) throws IOException {
		if( o instanceof NSDictionary ) {
			osw.write( "<dict>\n" );
			writeDictionary( (NSDictionary)o, osw );
			osw.write( "</dict>\n" );
		} else if( o instanceof NSArray ) {
			osw.write( "<array>\n" );
			writeArray( (NSArray)o, osw );
			osw.write( "</array>\n" );
		} else if( o instanceof Integer ) {
			osw.write( "<integer>" );
			osw.write( o.toString() );
			osw.write( "</integer>");
		} else {
			osw.write( "<string>" );
			osw.write( o.toString() );
			osw.write( "</string>");
		}
	}
	
	public static Object objectFromReader( Reader in ) throws Exception {
		SAXParserFactory factory = SAXParserFactory.newInstance();
//		String id = "http://xml.org/sax/features/validation";
//		if( factory.getFeature( id )) {
//			log.info( "Turning of validation");
//			factory.setFeature( id, false );
//		}
		SAXParser parser = factory.newSAXParser();
//		parser.getXMLReader().setFeature( id, false );
				
		PListBuilder builder = new PListBuilder();
		parser.parse( new InputSource( in ), builder );
		
		return builder.getResult();				
	}
		
	static Object objectWithContentOfURL( URL url ) throws Exception {	
		SAXParserFactory factory = SAXParserFactory.newInstance();
//		String id = "http://xml.org/sax/features/validation";
//		if( factory.getFeature( id )) {
//			log.info( "Need to turn of validation");
//		}
//		factory.setFeature( id, false );
		SAXParser parser = factory.newSAXParser();
//		parser.getXMLReader().setFeature( id, false );
		
		PListBuilder builder = new PListBuilder();
		parser.parse( url.openStream(), builder );
		
		
		return builder.getResult();				
	}
	
	static void 	writeObjectToURL( Object o, URL url ) throws Exception {
		URLConnection con = url.openConnection();
		OutputStream os = con.getOutputStream();
		OutputStreamWriter osw = new OutputStreamWriter( os );
		
		osw.write( "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" );
		osw.write( "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" );
		osw.write( "<plist version=\"1.0\">\n" );
		
			writeObject( o, osw );
		
		osw.write( "</plist>\n");
		
		osw.close();
	}	
	
	private static void writeDictionary( NSDictionary o, Writer osw ) throws IOException {
		for( Iterator i = o.keyIterator(); i.hasNext(); ) {
			Object key = i.next();
			osw.write( "<key>" );
			osw.write( key.toString() );
			osw.write( "</key>");			
			Object value = o.objectForKey( key );
			writeObject( value, osw );
		}
	}

	private static void writeArray( NSArray o, Writer osw ) throws IOException {
		for( int i = 0; i < o.count(); i++ ) {
			writeObject( o.objectAtIndex( i ), osw );
		}
	}
	
	/*
	 *   Example of path:
	 *   1) children/*[class-name=AlmostVPNProfile][1]/name
	 */
	
	static Pattern childSelectorPattern = Pattern.compile( "\\*(?:\\[([^0-9][^=]*)=([^\\]]+)\\])*(?:\\[(\\d+)\\])??" );
	
	static Pattern asteriskPattern = Pattern.compile( "\\*" );
	static Pattern selectorPattern = Pattern.compile( "(?:\\[([^0-9][^=]*)=([^\\]]+)\\])|(?:\\[(\\d+)\\])");
	
	static Object getObjectByPath( Object start, String path ) {
		Object result = start;
		String[] pathComponents = path.split( "/" );
bigLoop:		
		for( int i = 0; result != null && i < pathComponents.length; i++ ) {
			if( result instanceof NSDictionary ) {
				result = ((NSDictionary)result).objectForKey( pathComponents[ i ] );
			} else if( result instanceof NSArray ){
				if( pathComponents[ i ].charAt(0) != '*' ) {					
					int idx = Integer.parseInt( pathComponents[ i ] );
					if( idx >= ((NSArray)result).count()) {
						result = null;
					} else {
						result = ((NSArray)result).objectAtIndex( idx );
					}
				} else {
					String selectors = pathComponents[ i ].substring(1);
					Matcher m = null;
					String[]	keys = new String[ 16 ];
					String[] values = new String[ 16 ];
					int	keyCount = 0;
					int skipCount = 1;
					
					m = selectorPattern.matcher( selectors );
					while( m.lookingAt()) {
						if( m.group(3) == null ) { // This is name=value
							keys[ keyCount ] = m.group(1);
							values[ keyCount ] = m.group(2);
							keyCount++;
						} else {
							skipCount = Integer.parseInt( m.group(3));
							break;
						}
						selectors = selectors.substring( m.end());
						m.reset( selectors );
//						m.region( m.end(), m.regionEnd());
					}
					
					NSArray array = (NSArray)result;
arrayLoop:					
					for( int j = 0; j < array.size(); j++ ) {
						Object o = array.objectAtIndex( j );
						if( o instanceof NSDictionary ) {
							NSDictionary dictionary = (NSDictionary)o;
							for( int k = 0; k < keyCount; k++ ) {
								if( ! values[ k ].equals( dictionary.objectForKey( keys[ k ] ))) {
									continue arrayLoop;
								} 
							}
							if( skipCount == 1 ) {
								result = o;
								continue bigLoop;
							} else {
								skipCount++;
							}
						}
					}
					result = null;
				}
			} else {
				break;
			}
		}
		return result;
	}

	static Object[] getObjectsByPath( Object start, String path ) {
		return getObjectsByPath( start, path, Object.class );
	}
	
	static Object[] getObjectsByPath( Object start, String path, Class clazz ) {
		ArrayList result = new ArrayList();
		Object cursor = start;
		String[] pathComponents = path.split( "/" );
bigLoop:		
		for( int i = 0; cursor != null && i < pathComponents.length; i++ ) {
			if( cursor instanceof NSDictionary ) {
				cursor = ((NSDictionary)cursor).objectForKey( pathComponents[ i ] );
			} else if( cursor instanceof NSArray ){
				if( pathComponents[ i ].charAt(0) != '*' ) {					
					int idx = Integer.parseInt( pathComponents[ i ] );
					if( idx >= ((NSArray)cursor).count()) {
						cursor = null;
					} else {
						cursor = ((NSArray)cursor).objectAtIndex( idx );
					}
				} else {
					String selectors = pathComponents[ i ].substring(1);
					Matcher m = null;
					String[]	keys = new String[ 16 ];
					String[] values = new String[ 16 ];
					int	keyCount = 0;
					
					m = selectorPattern.matcher( selectors );
					while( m.lookingAt()) {
						if( m.group(3) == null ) { // This is name=value
							keys[ keyCount ] = m.group(1);
							values[ keyCount ] = m.group(2);
							keyCount++;
						} else {
							log.warn( "getObjectsByPath : Count ignored" );
							break;
						}
						selectors = selectors.substring( m.end());
						m.reset( selectors );
//						m.region( m.end(), m.regionEnd());
					}
					
					NSArray array = (NSArray)cursor;
arrayLoop:					
					for( int j = 0; j < array.size(); j++ ) {
						Object o = array.objectAtIndex( j );
						if( o instanceof NSDictionary ) {
							NSDictionary dictionary = (NSDictionary)o;
							for( int k = 0; k < keyCount; k++ ) {
								if( ! values[ k ].equals( dictionary.objectForKey( keys[ k ] ))) {
									continue arrayLoop;
								} 
							}
							if(( i + 1 ) < pathComponents.length ) {
								cursor = o;
								continue bigLoop;
							} else {
								result.add( o );
							}
						}
					}
					cursor = null;
				}
			} else {
				break;
			}
		}
		return result.toArray( (Object[])Array.newInstance( clazz,  result.size()));
	}

}


class PListBuilder extends DefaultHandler {
	private static final Log log = LogFactory.getLog( PListBuilder.class );
	Object _top;
	Object _current;
	
	StringBuffer 	_lastText = new StringBuffer();
	String		_lastKey;		
	
	Stack _stack = new Stack();	
	
	public Object getResult() {
		return _top;
	}

	static byte[] propertyListDTDbytes = (
		"<!ENTITY % plistObject \"(array | data | date | dict | real | integer | string | true | false )\" >\n" 
+		"<!ELEMENT plist %plistObject;>\n"
+		"<!ATTLIST plist version CDATA \"1.0\" >\n"

+		"<!-- Collections -->\n"
+		"<!ELEMENT array (%plistObject;)*>\n"
+		"<!ELEMENT dict (key, %plistObject;)*>\n"
+		"<!ELEMENT key (#PCDATA)>\n"

+		"<!--- Primitive types -->\n"
+		"<!ELEMENT string (#PCDATA)>\n"
+		"<!ELEMENT data (#PCDATA)> <!-- Contents interpreted as Base-64 encoded -->\n"
+		"<!ELEMENT date (#PCDATA)> <!-- Contents should conform to a subset of ISO 8601 (in particular, YYYY '-' MM '-' DD 'T' HH ':' MM ':' SS 'Z'.  Smaller units may be omitted with a loss of precision) --> \n"

+		"<!-- Numerical primitives -->\n"
+		"<!ELEMENT true EMPTY>  <!-- Boolean constant true -->\n"
+		"<!ELEMENT false EMPTY> <!-- Boolean constant false -->\n"
+		"<!ELEMENT real (#PCDATA)> <!-- Contents should represent a floating point number matching (\"+\" | \"-\")? d+ (\".\"d*)? (\"E\" (\"+\" | \"-\") d+)? where d is a digit 0-9.  -->\n"
+		"<!ELEMENT integer (#PCDATA)> <!-- Contents should represent a (possibly signed) integer number in base 10 -->\n"
		).getBytes();

	public InputSource resolveEntity(String publicId, String systemId) throws SAXException {
		log.debug("resolveEntity : " + systemId );
		if( systemId.equals( "http://www.apple.com/DTDs/PropertyList-1.0.dtd")) {
			return new InputSource(
					new ByteArrayInputStream(propertyListDTDbytes));
		} else {
			try {
				return super.resolveEntity( publicId, systemId);
			} catch (IOException e) {
				throw new SAXException(e);
			}
		}
	}

	public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
		Object parent = _current;
		
		if( "dict".equals( qName )) {
			if( _current != null ) {
				_stack.push( _current );
			}			
			_current = new NSMutableDictionary();
		} else if( "array".equals( qName )) {
			if( _current != null ) {
				_stack.push( _current );
			}			
			_current = new NSMutableArray();
		} else {
			return;
		}
		
		if( parent == null ) {
			_top = _current;
		} else {
			if( parent instanceof NSMutableDictionary ) {
				((NSMutableDictionary)parent).setObjectForKey( _current, _lastKey );
				_lastText.setLength( 0 );
			} else if( parent instanceof NSMutableArray ) {
				((NSMutableArray)parent).addObject( _current );
			}
		}
	}

	public void endElement(String uri, String localName, String qName) throws SAXException {
		// log.info( "endElement : " + qName + " lastKey = " + _lastKey + " lastText = " + _lastText );
		if( "key".equals( qName )) {
			_lastKey = _lastText.toString().trim();
			_lastText.setLength( 0 );
		} else if( "string".equals( qName )) {
			if( _current instanceof NSMutableDictionary ) {
				((NSMutableDictionary)_current).setObjectForKey( _lastText.toString(), _lastKey );
			} else if( _current instanceof NSMutableArray ) {
				((NSMutableArray)_current).addObject( _lastText.toString() );
			}
			_lastText.setLength( 0 );
		} else if( "integer".equals( qName )) {
			if( _current instanceof NSMutableDictionary ) {
				((NSMutableDictionary)_current).setObjectForKey( new Integer( _lastText.toString()), _lastKey );
			} else if( _current instanceof NSMutableArray ) {
				((NSMutableArray)_current).addObject( new Integer( _lastText.toString() ));
			}
			_lastText.setLength( 0 );
		} else if( "dict".equals( qName ) || "array".equals( qName )) {
			if( _stack.size() > 0 ) {
				_current = _stack.pop();
			}
		}
	}
	
	public void characters(char[] ch, int start, int length) throws SAXException {
		_lastText.append( ch, start, length ); 
	}

	public void error(SAXParseException e) throws SAXException {
		// TODO Auto-generated method stub
		super.error(e);
	}

	public void fatalError(SAXParseException e) throws SAXException {
		// TODO Auto-generated method stub
		super.fatalError(e);
	}

	public void warning(SAXParseException e) throws SAXException {
		// TODO Auto-generated method stub
		super.warning(e);
	}
	
	
}