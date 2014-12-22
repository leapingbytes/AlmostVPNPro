//
//  Tunnel.h
//  SSHAgent
//
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

#import <Cocoa/Cocoa.h>

@class SSHTunnel;

@interface Tunnel : NSDocument
{
    IBOutlet id smallView;
    IBOutlet id largeView;
    IBOutlet id localPort;
    IBOutlet id remotePort;
    IBOutlet id tunnelPort;
    IBOutlet id remoteHost;
    IBOutlet id tunnelHost;
    IBOutlet id tunnelAccount;
    IBOutlet id smallFrom;
    IBOutlet id smallTo;
    IBOutlet id openButton;
    IBOutlet id closeButton;

    NSSize smallSize, largeSize;
    NSView *blankView;
    SSHTunnel *theTunnel;
    NSWindow *mainWindow;
}

- (IBAction)openTunnel:(id)sender;
- (IBAction)closeTunnel:(id)sender;

- (SSHTunnel *)tunnel;
- (void)setTunnel:(SSHTunnel *)tunnel;
- (void)updateTunnel;
- (void)updateUI;

- (void)goSmall;
- (void)goLarge;
- (void)resizeWindowToSize:(NSSize)newSize
                 oldCenter:(NSPoint)oldCenter
                 newCenter:(NSPoint)newCenter;

@end
