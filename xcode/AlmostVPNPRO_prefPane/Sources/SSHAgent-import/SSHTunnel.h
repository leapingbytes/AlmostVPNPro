//
//  SSHTunnel.h
//  SSHKit.framework
//  Created by Xander Schrijen on Wed May 22 2002.
//
//        SSH Agent
//        Copyright (c) 2001-2005, Dept. of Philosophy, Utrecht University
//        All rights reserved.
//
//        Redistribution and use in source and binary forms, with or without
//        modification, are permitted provided that the following conditions
//        are met:
//
//        1. Redistributions of source code  must retain the above copyright
//           notice,  this list of  conditions  and the following disclaimer.
//        2. Redistributions  in binary  form must  reproduce the above copy-
//           right notice,  this  list of conditions  and the  following dis-
//           claimer in the documentation and / or other materials  provided
//           with the distribution.
//        3. The  name  of  the copyright holder may  not be used  to endorse
//           or   promote   products  derived  from  this  software   without
//           specific prior written permission.
//
//        THIS SOFTWARE IS  PROVIDED BY THE COPYRIGHT HOLDER "AS  IS" AND ANY
//        EXPRESS  OR IMPLIED  WARRANTIES, INCLUDING  , BUT  NOT LIMITED  TO,
//        THE  IMPLIED  WARRANTIES  OF  MERCHANTABILITY  AND  FITNESS  FOR  A
//        PARTICULAR PURPOSE ARE DISCLAIMED. IN  NO EVENT SHALL THE COPYRIGHT
//        HOLDER  BE LIABLE  FOR ANY  DIRECT, INDIRECT,  INCIDENTAL, SPECIAL,
//        EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//        PROCUREMENT OF SUBSTITUTE GOODS OR  SERVICES; LOSS OF USE, DATA, OR
//        PROFITS OR BUSINESS INTERRUPTION) HOWEVER  CAUSED AND ON ANY THEORY
//        OF  LIABILITY,  WHETHER  IN  CONTRACT, STRICT  LIABILITY,  OR  TORT
//        (INCLUDING NEGLIGENCE OR  OTHERWISE) ARISING IN ANY WAY  OUT OF THE
//        USE OF  THIS SOFTWARE, EVEN IF  ADVISED OF THE POSSIBILITY  OF SUCH
//        DAMAGE.

#import <Foundation/Foundation.h>

//@class SSHPassphraseProvider;
//@class SSHAgent;
//@class SSHTask;

@interface SSHTunnel : NSObject <NSCoding>
{
    int localPort;
    int remotePort;
    int tunnelPort;
    NSString *tunnelHost;
    NSString *remoteHost;
    NSString *hostAccount;
//    SSHTask *tunnelBuilder;
	NSObject* tunnelBuilderDummy;
    BOOL closedOnPurpose;
}

+ (id)tunnelFromPort:(int)theLocalPort
              toPort:(int)theRemotePort
                  at:(NSString *)theRemoteHost
             through:(NSString *)theTunnelHost
              atPort:(int)theTunnelPort
                 for:(NSString *)theHostAccount;

//- (void)openWithPassphraseProvider:(SSHPassphraseProvider *)pp;
//
//- (void)close;
//- (BOOL)isOpen;
//
- (int)localPort;
- (int)remotePort;
- (int)tunnelPort;
- (NSString *)tunnelHost;
- (NSString *)remoteHost;
- (NSString *)hostAccount;

- (void)setLocalPort:(int)port;
- (void)setRemotePort:(int)port;
- (void)setTunnelPort:(int)port;
- (void)setTunnelHost:(NSString *)tunnelHost;
- (void)setRemoteHost:(NSString *)remoteHost;
- (void)setHostAccount:(NSString *)hostAccount;

@end
