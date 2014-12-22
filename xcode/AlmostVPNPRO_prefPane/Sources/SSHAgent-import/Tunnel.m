//
//  Tunnel.m
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


#import "Tunnel.h"

#import <SSHKit/SSHKit.h>

#import "OpenConnectionPP.h"

#import "PowerMonitor.h"

#define MakeCenter(F) NSMakePoint(F.origin.x + (F.size.width/2), F.origin.y + (F.size.height/2))


@implementation Tunnel

- (id)init
{
    if (!(self = [super init])) return nil;

    [self setTunnel: [SSHTunnel tunnelFromPort: 8080
                                        toPort: 80
                                            at: @"some.server.com"
                                       through: @"your.server.com"
                                        atPort: 22
                                           for: @"user"]];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[PowerMonitor sharedPowerMonitor] deregisterClient: self];
    [theTunnel release];
    [blankView release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"Tunnel";
}

- (NSData *)dataRepresentationOfType:(NSString *)type
{
    [self updateTunnel];
    return [NSArchiver archivedDataWithRootObject: theTunnel];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type
{
    [self setTunnel: [NSUnarchiver unarchiveObjectWithData: data]];
    [self updateUI];
    return YES;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib: aController];
    smallSize = [smallView frame].size;
    largeSize = [largeView frame].size;

    blankView = [[NSView alloc] init];

    mainWindow = [[[[self windowControllers] objectAtIndex: 0] window] retain];
    
    [mainWindow setContentSize: largeSize];
    [mainWindow setContentView: largeView];

    [self updateUI];
}

- (SSHTunnel *)tunnel
{
    return theTunnel;
}


- (void)setTunnel:(SSHTunnel *)t
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    if (theTunnel != t) {
        [theTunnel release];
        theTunnel = [t retain];
        [nc addObserver: self
               selector: @selector(tunnelDidClose:)
                   name: @"NUPTunnelDidClose"
                 object: theTunnel];
    }
}

- (void)tunnelDidClose:(NSNotification *)note
{
    [self goLarge];
    [self updateUI];
}

- (void)updateTunnel
{
    [theTunnel setLocalPort: [localPort intValue]];
    [theTunnel setRemotePort: [remotePort intValue]];
    [theTunnel setTunnelPort: [tunnelPort intValue]];
    [theTunnel setRemoteHost: [remoteHost stringValue]];
    [theTunnel setTunnelHost: [tunnelHost stringValue]];
    [theTunnel setHostAccount: [tunnelAccount stringValue]];
}

- (void)updateUI
{
    [localPort setIntValue: [theTunnel localPort]];
    [remotePort setIntValue: [theTunnel remotePort]];
    [tunnelPort setIntValue: [theTunnel tunnelPort]];
    [remoteHost setStringValue: [theTunnel remoteHost]];
    [tunnelHost setStringValue: [theTunnel tunnelHost]];
    [tunnelAccount setStringValue: [theTunnel hostAccount]];
    [smallFrom setIntValue: [theTunnel localPort]];
    [smallTo setStringValue: [NSString stringWithFormat: @"%@:%d",
        [theTunnel remoteHost], [theTunnel remotePort]]];
}

- (IBAction)openTunnel:(id)sender
{
    [self updateTunnel];
    [self updateUI];
    [self goSmall];
    if (![theTunnel isOpen]) {
        OpenConnectionPP *pp = [OpenConnectionPP passphraseProviderForWindow: mainWindow];
        [theTunnel openWithPassphraseProvider: pp];
    }
    [[PowerMonitor sharedPowerMonitor] registerClient: self];
}

- (IBAction)closeTunnel:(id)sender
{
    if ([theTunnel isOpen]) {
        [theTunnel close];
    }
    [[PowerMonitor sharedPowerMonitor] deregisterClient: self];
}

- (void)goSmall
{
    [mainWindow setContentView: blankView];
    [self resizeWindowToSize: smallSize
                   oldCenter: MakeCenter([openButton frame])
                   newCenter: MakeCenter([closeButton frame])];
    [mainWindow setContentView: smallView];
}

- (void)goLarge
{
    [mainWindow setContentView: blankView];
    [self resizeWindowToSize: largeSize
                   oldCenter: MakeCenter([closeButton frame])
                   newCenter: MakeCenter([openButton frame])];
    [mainWindow setContentView: largeView];
}

- (void)resizeWindowToSize:(NSSize)newSize
                 oldCenter:(NSPoint)oldCenter
                 newCenter:(NSPoint)newCenter
{
    NSRect aFrame = [NSWindow contentRectForFrameRect: [mainWindow frame]
                                            styleMask: [mainWindow styleMask]];
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
    
    aFrame.origin.x += (oldCenter.x - newCenter.x);
    aFrame.origin.y += (oldCenter.y - newCenter.y);
    aFrame.size.height = newSize.height;
    aFrame.size.width = newSize.width;

    
    aFrame = [NSWindow frameRectForContentRect: aFrame
                                     styleMask: [mainWindow styleMask]];

    if (aFrame.origin.y + aFrame.size.height > screenFrame.origin.y + screenFrame.size.height)
        aFrame.origin.y = screenFrame.origin.y + screenFrame.size.height - aFrame.size.height;

    [mainWindow setFrame: aFrame display: YES animate: YES];
}

- (void)controlTextDidChange:(NSNotification *)note
{
    [self updateChangeCount: NSChangeDone];
}

- (BOOL)windowShouldClose:(id)sender
{
    if ([theTunnel isOpen]) {
        NSBeep();
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)systemWillSleep
{
    [theTunnel close];
    return YES;
}

- (BOOL)systemWillWakeUp
{
    [self goSmall];
    if (![theTunnel isOpen]) {
        OpenConnectionPP *pp = [OpenConnectionPP passphraseProviderForWindow: mainWindow];
        [theTunnel openWithPassphraseProvider: pp];
    }
    
    return YES;
}

@end
