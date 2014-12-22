//
//  NSImage_SMExtensions.m
//  Part of the SM2DGraphView framework.
//
//    SM2DGraphView Copyright 2002-2005 Snowmint Creative Solutions LLC.
//    http://www.snowmintcs.com/
//
#import "NSImage_SMExtensions.h"

@implementation NSImage(SMExtensions)

+ (NSImage *)imageNamed:(NSString *)inImageName inBundleForClass:(Class)inClass
{
    // Just grab the correct bundle and call the other method.
    return [ self imageNamed:inImageName inBundle:[ NSBundle bundleForClass:inClass ] ];
}

+ (NSImage *)imageNamed:(NSString *)inImageName inBundle:(NSBundle *)inBundle
{
    NSImage		*result = nil;
    NSString	*path;

    // First try to find it in the default bundle.
    result = [ self imageNamed:inImageName ];
    if ( nil == result || 0 == [ result size ].width )
    {
        // Otherwise, find the path to the image in the specific bundle.
        path = [ inBundle pathForImageResource:inImageName ];
        if ( nil != path )
        {
            // Make the image.
            result = [ [ [ NSImage alloc ] initWithContentsOfFile:path ] autorelease ];
            [ result setName:inImageName ];
        }
    }

    return result;
}

@end
