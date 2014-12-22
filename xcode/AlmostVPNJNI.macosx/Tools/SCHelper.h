//
//  SCHelper.h
//  TrafficWidgetPlugin
//
//  Created by andrei tchijov on 10/24/05.
//  Copyright 2005 Leaping Bytes, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface SCHelper : NSObject {

}
+(NSArray*) listKeys: (NSString*) pattern;
+(NSDictionary*) objectForKey: (NSString*) key;
+(BOOL) setObject: (NSDictionary*) anObject forKey: (NSString*) key;

+ (NSString*)primaryInterface;
+ (NSString*)localAddress;
+ (BOOL)isProxyEnabled: (NSString*) proxyName;
+ (void)setProxyEnabled: (NSString*) proxyName to: (BOOL) value;

@end
