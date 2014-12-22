/*
	isPlainHostName( "www" ) == true
	isPlainHostName( "www.abc.com" ) == false
*/
function isPlainHostName( name ) {
	return name.indexOf( "." ) == -1;
}

/*
	dnsDomainIs( "www.abc.com", ".abc.com" ) == true
	dnsDomainIn( "www.abc.com", ".xyz.com" ) == false
	dnsDomainIn( "www", ".abc.com" ) == false
*/
function dnsDomainIs( host, domain ) {
	var h = host.split( "." );
	var d = domain.split( "." );
	if( h.length != d.length ) {
		return false;
	}
	if( d[0] != "" ) {
		return false;
	}
	for( var i = 1; i < d.length; i++ ) {
		if( h[ i ] != d[ i ] ) {
			return false;
		}
	}
	return true;
}

/*
	localHostOrDomainIs( "www.abc.com", "www.abc.com" ) == true
	localHostOrDomainIs( "www", "www.abc.com" ) == true
	localHostOrDomainIs( "www.xyz.com", "www.abc.com" ) == false
	localHostOrDomainIs( "www.abc.com", "ftp.abc.com" ) == false
*/
function localHostOrDomainIs( host, hostdom ) {
	var h = host.split( "." );
	var d = domain.split( "." );
	if( host == hostdom ) {
		return true;
	}
	if( h.length == 1 && h[0] == d[0] ) {
		return true;
	}
	return false;
}

/* 
	isResolvable( "www.cnn.com" ) == true
	isResolvable( "very.bogus.name.nowhere" ) == false
*/
function isResolvable( host ) {
	try {
		return _nativeDnsResolve( host );
	} catch ( e ) {
		return true;
	}
}

/*
	isInNet( host, "10.10.0.1", "255.255.255.255" )	== host == 10.10.0.1
	isInNet( host, "10.10.0.1", "255.255.0.0" ) == host in 10.10.0.0 - 10.10.255.255
*/
function isInNet( host, pattern, mask ) {
	var h = 0, p = 0, m = 0;
	var a;
	
	host = dnsResolve( host );
	a = host.split( "." );
	for( var i = 0; i < 4; i++ ) {
		h = ( h << 8 ) | a[ i ];
	}

	a = pattern.split( "." );
	for( var i = 0; i < 4; i++ ) {
		p = ( p << 8 ) | a[ i ];
	}

	a = mask.split( "." );
	for( var i = 0; i < 4; i++ ) {
		m = ( m << 8 ) | a[ i ];
	}
	
	return ( h & m ) == ( p & m )
}

/*
	dnsResolve( host ) 
*/
function dnsResolve( host ) {
	try {
		return _nativeDnsResolve( host );
	} catch ( e ) {
		return host;
	}
}

/*
	myIpAddress()
*/
function myIpAddress() {
	try {
		return _nativeMyIpAddress();
	} catch ( e ) {
		return "127.0.0.1";
	}
}

/*
	dnsDomainLevels( "www" ) == 0
	dnsDomainLevels( "www.abc.com" ) == 2
*/
function dnsDomainLevels( host ) {
	return host.split( "." ).length;
}

/*
	shExpMatch( str, shexp )
*/
function nextShexpPart( shexp, index ) {
	if( index >= shexp.length ) {
//		java.lang.System.out.println( "OVER " + index + " >= " + shexp.length );
		return null;
	}
	var shIdx = shexp.indexOf( "*", index );
	
	if( shIdx < 0 ) {
//		java.lang.System.out.println( "NO MORE *'s shexpIdx = " + index + " result = " + shexp.substr( index ));
		return shexp.substr( index );
	}else if( shIdx == index ) {
//		java.lang.System.out.println( "STAR at " + shIdx + " shexpIdx = " + index );
		return "*";
	} else {
//		java.lang.System.out.println( "TOKEN = " + shexp.substr( index, shIdx - index )  + " shIdx = " + shIdx + " shexpIdx = " + index );
		return shexp.substr( index, shIdx - index );
	}
}

function shExpMatch( str, shexp ) {
	var strIdx = 0;
	var shexpIdx = 0;
	var wildcard = false;
	while( true ) {
		var nextPart = nextShexpPart( shexp, shexpIdx );
		if( nextPart == null ) {
			break;
		}
		if( nextPart == "*" ) {
			wildcard = true;
			shexpIdx++;
		} else {
			var nextPartIdx = str.indexOf( nextPart, strIdx );
			if( nextPartIdx < 0 ) {
				return false;
			}
			if(( ! wildcard ) && ( nextPartIdx != 0 )) {
					return false;
			}
			strIdx = nextPartIdx + nextPart.length;
			shexpIdx += nextPart.length;
			wildcard = false;
		}
	}
	return true;
}

/*	DUMMY!!!
	weekdayRange( wd1, wd2, gmt )
*/
function weekdayRange( wd1, wd2, gmt ) {
	return true;
}

/*	DUMMY!!
	dateRane( ... )
*/
function dateRange() {
	return true;
}

/* DUMMY!!
	timeRange( ... )
*/
function timeRange() {
	return true;
}
	
/* ======================================================= */
