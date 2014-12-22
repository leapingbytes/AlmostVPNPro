/*!
	@header  NSImage_SMExtensions.h
	@discussion Part of the SM2DGraphView framework.

    SM2DGraphView Copyright 2002-2005 Snowmint Creative Solutions LLC.
    http://www.snowmintcs.com/
*/
#import <AppKit/AppKit.h>

/*!	@class	NSImage(SMExtensions)
	@discussion	This category adds the ability to create images from other bundles.  The standard Cocoa
                -imageNamed: method only looks in the main bundle.
*/
@interface NSImage(SMExtensions)

/*!	@method	imageNamed:inBundleForClass:
    @discussion	This grabs an image from a specific bundle when you have an object class from that bundle.
                This method first looks in the default bundle for the image, then in the specific bundle for
                the given class.
	@param	inImageName		The name of the image file to find.  Can include the file name extension or not.
    @param	inClass			A class whose bundle you want to search in.
    @result	An autoreleased NSImage or nil if the image could not be found.
*/
+ (NSImage *)imageNamed:(NSString *)inImageName inBundleForClass:(Class)inClass;

/*!	@method	imageNamed:inBundle:
    @discussion	This grabs an image from a specific bundle if it cannot be found in the default bundle.
	@param	inImageName		The name of the image file to find.  Can include the file name extension or not.
    @param	inBundle		A bundle you want to search in.
    @result	An autoreleased NSImage or nil if the image could not be found.
*/
+ (NSImage *)imageNamed:(NSString *)inImageName inBundle:(NSBundle *)inBundle;

@end
