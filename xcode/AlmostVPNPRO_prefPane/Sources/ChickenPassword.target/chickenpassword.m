//
//  chickenpassword.m
//  AlmostVPNPRO_prefPane
//
//  Created by andrei tchijov on 8/19/06.
//  Copyright 2006 Leaping Bytes, LLC. All rights reserved.
//

#import "chickenpassword.h"


@implementation chickenpassword

@end

int main( int argc, char** argv ) {
	if( argc < 3 ) {
		printf( "chickenpassword <password> <almost vpn host name>\n" );
	}
	char* fileName = malloc( 64*1024 );
	sprintf( fileName, "%s/.vnc.password.%s", getenv("HOME"), argv[2] );
	vncEncryptAndStorePasswd( argv[1], fileName );
	
	return 0;
}