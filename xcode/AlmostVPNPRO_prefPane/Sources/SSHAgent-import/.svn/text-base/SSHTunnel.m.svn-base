//
//  SSHTunnel.m
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

#import "SSHTunnel.h"

//#import <SSHKit/SSHKit.h>


@implementation SSHTunnel

+ (void)initialize
{
    if (self == [SSHTunnel class])
        [self setVersion: 1];
}

+ (id)tunnelFromPort:(int)theLocalPort
              toPort:(int)theRemotePort
                  at:(NSString *)theRemoteHost
             through:(NSString *)theTunnelHost
              atPort:(int)theTunnelPort
                 for:(NSString *)theHostAccount;
{
    SSHTunnel *tunnel = [[[self alloc] init] autorelease];

    if (!tunnel) return nil;

    [tunnel setLocalPort: theLocalPort];
    [tunnel setRemotePort: theRemotePort];
    [tunnel setTunnelPort: theTunnelPort];
    [tunnel setRemoteHost: theRemoteHost];
    [tunnel setHostAccount: theHostAccount];
    [tunnel setTunnelHost: theTunnelHost];

    return tunnel;
}

//- (void)openWithPassphraseProvider:(SSHPassphraseProvider *)pp
//{
//    NSString *tunnelArgument;
//    NSString *tunnelHostArgument;
//
//    tunnelArgument = [NSString stringWithFormat: @"-L%d:%@:%d",
//        localPort, remoteHost, remotePort];
//    tunnelHostArgument = [NSString stringWithFormat: @"%@@%@",
//        hostAccount, tunnelHost];
//
//    closedOnPurpose = NO;
//    tunnelBuilder = [[SSHTask alloc] initWithToolName: @"ssh"];
//    [tunnelBuilder setArguments: [NSArray arrayWithObjects:
//        @"-p",
//        [NSString stringWithFormat: @"%d", tunnelPort],
//        @"-N",
//        @"-T",
//        @"-x",
//        tunnelArgument,
//        tunnelHostArgument,
//        nil]];
//    
//    [tunnelBuilder setAgent: [SSHAgent defaultAgent]];
//    [tunnelBuilder setPassphraseProvider: pp];
//
//    [tunnelBuilder launchWithTaskDelegate: self
//                     didTerminateSelector: @selector(tunnelDidClose:)
//                              contextInfo: nil];
//
//}
//
//- (void)close
//{
//    [tunnelBuilder terminate];
//    closedOnPurpose = YES;
//}
//
//- (BOOL)isOpen
//{
//    if (tunnelBuilder)
//        return [tunnelBuilder isRunning];
//    else
//        return NO;
//}
//
//- (void)tunnelDidClose:(NSDictionary *)info
//{
//    NSNotificationCenter *nc;
//
//    nc = [NSNotificationCenter defaultCenter];
//    [nc postNotificationName: @"NUPTunnelDidClose"
//                      object: self
//                    userInfo: [NSDictionary dictionaryWithObject:
//                        [NSNumber numberWithBool: closedOnPurpose] forKey: @"onpurpose"]];
//    [tunnelBuilder release];
//    tunnelBuilder = nil;
//}
//
- (void)dealloc
{
    [tunnelHost release];
    [remoteHost release];
    [hostAccount release];
    [super dealloc];
}

- (int)localPort
{
    return localPort;
}

- (int)remotePort
{
    return remotePort;
}

- (int)tunnelPort
{
    return tunnelPort;
}

- (NSString *)tunnelHost
{
    return tunnelHost;
}

- (NSString *)remoteHost
{
    return remoteHost;
}

- (NSString *)hostAccount
{
    return hostAccount;
}

- (void)setLocalPort:(int)port
{
    if (port > 1023)
        localPort = port;
    else
        localPort = -1;
}

- (void)setRemotePort:(int)port;
{
    remotePort = port;
}

- (void)setTunnelPort:(int)port
{
    tunnelPort = port;
}

- (void)setTunnelHost:(NSString *)host
{
    if (tunnelHost != host) {
        [tunnelHost release];
        tunnelHost = [host retain];
    }
}

- (void)setRemoteHost:(NSString *)host
{
    if (remoteHost != host) {
        [remoteHost release];
        remoteHost = [host retain];
    }
}

- (void)setHostAccount:(NSString *)account
{
    if (hostAccount != account) {
        [hostAccount release];
        hostAccount = [account retain];
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        int version = [coder versionForClassName: @"SSHTunnel"];
        
        [coder decodeValueOfObjCType: @encode(int) at: &localPort];
        [coder decodeValueOfObjCType: @encode(int) at: &remotePort];
        if (version > 0) {
            [coder decodeValueOfObjCType: @encode(int) at: &tunnelPort];
        } else {
            tunnelPort = 22;
        }
        [self setRemoteHost: [coder decodeObject]];
        [self setTunnelHost: [coder decodeObject]];
        [self setHostAccount: [coder decodeObject]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeValueOfObjCType: @encode(int) at: &localPort];
    [coder encodeValueOfObjCType: @encode(int) at: &remotePort];
    [coder encodeValueOfObjCType: @encode(int) at: &tunnelPort];
    [coder encodeObject: remoteHost];
    [coder encodeObject: tunnelHost];
    [coder encodeObject: hostAccount];
}
    

@end
