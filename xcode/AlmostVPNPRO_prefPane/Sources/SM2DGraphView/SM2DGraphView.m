//
//  SM2DGraphView.m
//  Part of the SM2DGraphView framework.
//
//    SM2DGraphView Copyright 2002-2005 Snowmint Creative Solutions LLC.
//    http://www.snowmintcs.com/
//
#import <vecLib/vecLib.h>
#import "SM2DGraphView.h"
#import "NSImage_SMExtensions.h"

// Set this to zero if you want to use NSBezierPath.  I don't know why you would, since NSBezierPath is slightly slower.
#define SM2D_USE_CORE_GRAPHICS		1
// Set this to one to turn on a timer that NSLogs how long it takes to draw all the lines on a graph.
// Set to zero for no timer.  Set to 1 for timing all drawing.  Set to 2 for scaling timing.
#define	SM2D_TIMER					0

/*!	@enum	SM2DGraphScaleTypeEnum
    @discussion	Scale types to be used on each graph axis.  This is unimplemented currently.
    @constant	kSM2DGraphScaleType_Linear	Normal linear scale.
    @constant	kSM2DGraphScaleType_Log10	Log base 10 scale.
    @constant	kSM2DGraphScaleType_Default	Default scale for both axis - equal to linear.
*/
typedef enum
{
    kSM2DGraphScaleType_Linear,
    kSM2DGraphScaleType_Log10,

    kSM2DGraphScaleType_Default = kSM2DGraphScaleType_Linear
} SM2DGraphScaleTypeEnum;

// Some unimplemented methods.
//- (void)setScaleType:(SM2DGraphScaleTypeEnum)inNewValue forAxis:(SM2DGraphAxisEnum)inAxis;
//- (SM2DGraphScaleTypeEnum)scaleTypeForAxis:(SM2DGraphAxisEnum)inAxis;

/*	Some unimplemented symbol types.
    kSM2DGraph_Symbol_Square,
    kSM2DGraph_Symbol_Star,
    kSM2DGraph_Symbol_InvertedTriangle,
    kSM2DGraph_Symbol_FilledSquare,
    kSM2DGraph_Symbol_FilledTriangle,
    kSM2DGraph_Symbol_FilledDiamond,
    kSM2DGraph_Symbol_FilledInvertedTriangle*/

// Some unimplemented line attributes.
// SM2DGraphLineDashAttributeName		NSDictionary *										solid
//extern NSString *SM2DGraphLineDashAttributeName;
//NSString *SM2DGraphLineDashAttributeName = @"SM2DGraphLineDashAttributeName";

// The attribute keys.
NSString *SM2DGraphLineSymbolAttributeName = @"SM2DGraphLineSymbolAttributeName";
NSString *SM2DGraphBarStyleAttributeName = @"SM2DGraphBarStyleAttributeName";
NSString *SM2DGraphLineWidthAttributeName = @"SM2DGraphLineWidthAttributeName";
NSString *SM2DGraphDontAntialiasAttributeName = @"SM2DGraphDontAntialiasAttributeName";

// Data stored for each axis.
typedef struct
{
    NSString				*label;
    SM2DGraphScaleTypeEnum	scaleType;
    int						numberOfTickMarks, numberOfMinorTickMarks;
    float					inset;
    BOOL					drawLineAtZero;
    NSTickMarkPosition		tickMarkPosition;
} SM2DGraphAxisRecord;

typedef struct
{
    // Data that is encoded with the object.
    NSColor	*backgroundColor;
    NSColor	*gridColor;
    NSColor	*borderColor;

    int		tag;

    SM2DGraphAxisRecord	yAxisInfo;
    SM2DGraphAxisRecord	yRightAxisInfo;
    SM2DGraphAxisRecord	xAxisInfo;

    // From here down is mostly cached data used during an object's lifetime only.
    NSMutableDictionary	*textAttributes;
    NSMutableArray		*lineAttributes;
    NSMutableArray		*lineData;
    int					barCount;

    NSRect				graphPaperRect;
    NSRect				graphRect;

    struct
    {
        unsigned char   useVectorComputation : 1;
        unsigned char	liveRefresh : 1;
        unsigned char	drawsGrid : 1;		// This flag is stored in the coding/decoding process.
        unsigned char	dataSourceIsValid : 1;
        unsigned char	dataSourceDecidesAttributes : 1;
        unsigned char	dataSourceWantsDataArray : 1;
        unsigned char	dataSourceWantsDataChunk : 1;
        unsigned char	delegateLabelsTickMarks : 1;
        unsigned char   delegateChangesBarAttrs : 1;
        unsigned char	delegateWantsMouseDowns : 1;
        unsigned char	delegateWantsEndDraw : 1;
    } flags;

} SM2DPrivateData;

// Macro for easily getting to the private data structure of an object.
#define myPrivateData	((SM2DPrivateData *)_SM2DGraphView_Private)

// Pixels between the label and edges of other things (labels, graph paper, etc).
#define kSM2DGraph_LabelSpacing	4

// Prototypes for internal functions and methods.
static SM2DGraphAxisRecord *_sm_local_determineAxis( SM2DGraphAxisEnum inAxis, SM2DPrivateData *inPrivateData );
static NSString *_sm_local_getSymbolForEnum( SM2DGraphSymbolTypeEnum inValue );
static NSDictionary *_sm_local_defaultLineAttributes( unsigned int inLineIndex );
static NSDictionary *_sm_local_encodeAxisInfo( SM2DGraphAxisRecord *inAxis );
static void _sm_local_decodeAxisInfo( NSDictionary *inInfo, SM2DGraphAxisRecord *outAxis );

#if __ppc__
	static BOOL _sm_local_isAltiVecPresent( void );
	static void _sm_local_scaleDataUsingVelocityEngine( NSPoint *ioPoints, unsigned long inDataCount,
                                float minX, float xScale, float xOrigin,
                                float minY, float yScale, float yOrigin );
#endif

@interface SM2DGraphView(Private)
- (void)_sm_drawGridInRect:(NSRect)inRect;
#if SM2D_USE_CORE_GRAPHICS
- (void)_sm_drawSymbol:(SM2DGraphSymbolTypeEnum)inSymbol onLine:(NSPoint *)inLine count:(int)inPointCount
            inColor:(NSColor *)inColor inRect:(NSRect)inRect;
#else
- (void)_sm_drawSymbol:(SM2DGraphSymbolTypeEnum)inSymbol onLine:(NSBezierPath *)inLine inColor:(NSColor *)inColor
            inRect:(NSRect)inRect;
#endif
- (void)_sm_drawVertBarFromPoint:(NSPoint)inFromPoint toPoint:(NSPoint)inToPoint barNumber:(int)inBarNumber
            of:(int)inBarCount inColor:(NSColor *)inColor;
- (void)_sm_frameDidChange:(NSNotification *)inNote;
- (void)_sm_calculateGraphPaperRect;
@end

@implementation SM2DGraphView

+ (void)initialize
{
    // Set our class version number.  This is used during encoding/decoding.
    [ SM2DGraphView setVersion:3 ];

    // Possibly expose some bindings.
    if ( [ SM2DGraphView respondsToSelector:@selector(exposeBinding:) ] )
    {
        [ SM2DGraphView exposeBinding:@"backgroundColor" ];
        [ SM2DGraphView exposeBinding:@"borderColor" ];
        [ SM2DGraphView exposeBinding:@"gridColor" ];
        [ SM2DGraphView exposeBinding:@"drawsGrid" ];
        [ SM2DGraphView exposeBinding:@"liveRefresh" ];
    }
}

+ (float)barWidth
{
    NSImage		*pattern = [ NSImage imageNamed:@"BarGraphPattern" inBundleForClass:[ SM2DGraphView class ] ];
    NSSize		imageSize = NSZeroSize;

    if ( nil != pattern )
        imageSize = [ pattern size ];

    return imageSize.width;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [ super initWithFrame:frame ];
    if ( nil != self )
    {
        // Initialization code here.
        _SM2DGraphView_Private = calloc( 1, sizeof(SM2DPrivateData) );
        NSAssert( nil != _SM2DGraphView_Private, NSLocalizedString( @"SM2DGraphView failed private memory allocation",
                    @"SM2DGraphView failed private memory allocation" ) );
        myPrivateData->backgroundColor = [ [ NSColor whiteColor ] copy ];
        myPrivateData->gridColor = [ [ [ NSColor blueColor ] colorWithAlphaComponent:0.5 ] retain ];
        myPrivateData->borderColor = [ [ NSColor blackColor ] retain ];
        myPrivateData->textAttributes = [ [ NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [ NSFont labelFontOfSize:[ NSFont labelFontSize ] ], NSFontAttributeName,
                    nil ] retain ];

        myPrivateData->graphRect = frame;

#if __ppc__
        myPrivateData->flags.useVectorComputation = _sm_local_isAltiVecPresent( );
#else
        myPrivateData->flags.useVectorComputation = NO;
#endif
        myPrivateData->flags.dataSourceIsValid = NO;
        myPrivateData->flags.dataSourceDecidesAttributes = NO;
        myPrivateData->flags.dataSourceWantsDataArray = NO;
        myPrivateData->flags.dataSourceWantsDataChunk = NO;
        myPrivateData->flags.delegateLabelsTickMarks = NO;
        myPrivateData->flags.delegateChangesBarAttrs = NO;
        myPrivateData->flags.delegateWantsMouseDowns = NO;
        myPrivateData->flags.delegateWantsEndDraw = NO;

        [ self _sm_calculateGraphPaperRect ];
        [ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(_sm_frameDidChange:)
                    name:NSViewFrameDidChangeNotification object:self ];
    }
    return self;
}

- (void)dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver:self ];

	[ myPrivateData->backgroundColor release ];
    [ myPrivateData->gridColor release ];
    [ myPrivateData->borderColor release ];
    [ myPrivateData->lineAttributes release ];
    [ myPrivateData->lineData release ];
    [ myPrivateData->textAttributes release ];
    [ myPrivateData->yAxisInfo.label release ];
    [ myPrivateData->yRightAxisInfo.label release ];
    [ myPrivateData->xAxisInfo.label release ];
    free( _SM2DGraphView_Private );

    [ super dealloc ];
}

#pragma mark -

- (id)initWithCoder:(NSCoder *)decoder
{
    BOOL			tempBool;
    int             tempInt;
    NSDictionary	*dict;
    unsigned		versionNumber;

    self = [ super initWithCoder:decoder ];

    // Allocate our private memory.
    _SM2DGraphView_Private = calloc( 1, sizeof(SM2DPrivateData) );
    NSAssert( nil != _SM2DGraphView_Private, NSLocalizedString( @"SM2DGraphView failed private memory allocation",
                @"SM2DGraphView failed private memory allocation" ) );

    // Start filling in objects.
    myPrivateData->backgroundColor = [ [ decoder decodeObject ] copy ];
    myPrivateData->gridColor = [ [ decoder decodeObject ] copy ];

    [ decoder decodeValueOfObjCType:@encode(BOOL) at:&tempBool ];
    myPrivateData->flags.drawsGrid = tempBool;

    dict = [ decoder decodeObject ];
    _sm_local_decodeAxisInfo( dict, &myPrivateData->xAxisInfo );

    dict = [ decoder decodeObject ];
    _sm_local_decodeAxisInfo( dict, &myPrivateData->yAxisInfo );

    // Determine version number of encoded class.
    versionNumber = [ decoder versionForClassName:NSStringFromClass( [ SM2DGraphView class ] ) ];

    if ( versionNumber > 0 )
    {
        // This was added in version 1.
        dict = [ decoder decodeObject ];
        _sm_local_decodeAxisInfo( dict, &myPrivateData->yRightAxisInfo );
    }

    if ( versionNumber > 1 )
    {
        // This was added in version 2.
        myPrivateData->borderColor = [ [ decoder decodeObject ] copy ];
    }
    else
        myPrivateData->borderColor = [ [ NSColor blackColor ] retain ];

    if ( versionNumber > 2 )
    {
        // This was added in version 3.
        [ decoder decodeValueOfObjCType:@encode(int) at:&tempInt ];
        myPrivateData->tag = tempInt;
    }

    myPrivateData->textAttributes = [ [ NSMutableDictionary dictionaryWithObjectsAndKeys:
                [ NSFont labelFontOfSize:[ NSFont labelFontSize ] ], NSFontAttributeName,
                nil ] retain ];

#if __ppc__
    myPrivateData->flags.useVectorComputation = _sm_local_isAltiVecPresent( );
#else
    myPrivateData->flags.useVectorComputation = NO;
#endif

    myPrivateData->flags.dataSourceIsValid = NO;
    myPrivateData->flags.dataSourceDecidesAttributes = NO;
    myPrivateData->flags.dataSourceWantsDataArray = NO;
    myPrivateData->flags.dataSourceWantsDataChunk = NO;
    myPrivateData->flags.delegateLabelsTickMarks = NO;
    myPrivateData->flags.delegateChangesBarAttrs = NO;
    myPrivateData->flags.delegateWantsMouseDowns = NO;
    myPrivateData->flags.delegateWantsEndDraw = NO;

    [ self _sm_calculateGraphPaperRect ];
    [ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(_sm_frameDidChange:)
                name:NSViewFrameDidChangeNotification object:self ];

    return self;
}

- (void)awakeFromNib
{
    // This is not called in Interface Builder, but it is called when this view has been saved in a nib file
    // and loaded into an application.
    [ self _sm_calculateGraphPaperRect ];

    [ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(_sm_frameDidChange:)
                name:NSViewFrameDidChangeNotification object:self ];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    BOOL			tempBool;
    int             tempInt;
    NSDictionary	*dict;

    [ super encodeWithCoder:coder ];

    // NOTE: The class version number is automatically encoded by Cocoa.

	// Archive our data here.
    [ coder encodeObject:myPrivateData->backgroundColor ];
    [ coder encodeObject:myPrivateData->gridColor ];

    tempBool = myPrivateData->flags.drawsGrid;
    [ coder encodeValueOfObjCType:@encode(BOOL) at:&tempBool ];

    dict = _sm_local_encodeAxisInfo( &myPrivateData->xAxisInfo );
    [ coder encodeObject:dict ];

    dict = _sm_local_encodeAxisInfo( &myPrivateData->yAxisInfo );
    [ coder encodeObject:dict ];

    // Added this in version 1.
    dict = _sm_local_encodeAxisInfo( &myPrivateData->yRightAxisInfo );
    [ coder encodeObject:dict ];

    // Added this in version 2.
    [ coder encodeObject:myPrivateData->borderColor ];

    // Added this in version 3.
    tempInt = myPrivateData->tag;
    [ coder encodeValueOfObjCType:@encode(int) at:&tempInt ];
}

- (Class)valueClassForBinding:(NSString *)binding
{
    Class   result = nil;

    if ( [ binding isEqualToString:@"backgroundColor" ] ||
                [ binding isEqualToString:@"borderColor" ] ||
                [ binding isEqualToString:@"gridColor" ] )
        result = [ NSColor class ];
    else if ( [ binding isEqualToString:@"drawsGrid" ] ||
                [ binding isEqualToString:@"liveRefresh" ] )
        result = [ NSNumber class ];
    else if ( [ [ super class ] instancesRespondToSelector:@selector(valueClassForBinding:) ] )
        result = [ super valueClassForBinding:binding ];

    return result;
}

#pragma mark -

- (void)drawRect:(NSRect)rect
{
    unsigned int	lineCount, lineIndex, dataCount, dataIndex;
    id				dataObj;
    CGContextRef	context = (CGContextRef)[ [ NSGraphicsContext currentContext ] graphicsPort ];
#if defined( SM2D_TIMER ) && ( SM2D_TIMER != 0 )
    NSDate			*timer;
    NSTimeInterval	timeInterval;
#endif
#if SM2D_USE_CORE_GRAPHICS
    NSPoint			*points = nil;
    unsigned long	pointsSize = 0;
#else
    NSBezierPath	*line;
#endif
    NSString		*tempString;
    NSColor			*tempColor = nil;
    NSMutableDictionary *attr;
    NSPoint			*dataLinePoints;
    NSPoint			fromPoint, toPoint;
    NSRect			bounds = [ self bounds ], graphRect, graphPaperRect, drawRect;
    double			xScale, minX, yScale, minY;
    int				i, barNumber;
    BOOL			drawBar;

    graphPaperRect = myPrivateData->graphPaperRect;
    graphRect = myPrivateData->graphRect;

    if ( nil != [ self labelForAxis:kSM2DGraph_Axis_X ] )
    {
        // Draw the X axis label.
        tempString = [ self labelForAxis:kSM2DGraph_Axis_X ];
        drawRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
        drawRect.origin.y = bounds.origin.y;
        drawRect.origin.x = graphRect.origin.x + ( graphRect.size.width - drawRect.size.width ) / 2.0;
        if ( NSIntersectsRect( drawRect, rect ) )
        {
            [ tempString drawInRect:drawRect withAttributes:myPrivateData->textAttributes ];
#if defined( SM_DEBUG_DRAWING ) && ( SM_DEBUG_DRAWING == 1 )
            NSFrameRect( drawRect );
#endif
        }
    }

    for ( i = 0; i < [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ]; i++ )
    {
        // Draw the X axis ticks.

        // Figure out the default label.
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            minX = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ] -
                        [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ] ) *
                        (double)i / (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1 );
            minX += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ];
        }
        else
            minX = i;

        tempString = [ NSString stringWithFormat:@"%g", minX ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i forAxis:kSM2DGraph_Axis_X
                        defaultLabel:tempString ];

        if ( nil != tempString )
        {
            drawRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
            drawRect.origin.y = bounds.origin.y;
            if ( nil != [ self labelForAxis:kSM2DGraph_Axis_X ] )
                drawRect.origin.y += drawRect.size.height + kSM2DGraph_LabelSpacing;
            drawRect.origin.x = graphRect.origin.x - ( drawRect.size.width / 2.0 ) +
                        ( graphRect.size.width / ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1 ) ) * i;
            if ( NSIntersectsRect( drawRect, rect ) )
            {
                [ tempString drawInRect:drawRect withAttributes:myPrivateData->textAttributes ];
#if defined( SM_DEBUG_DRAWING ) && ( SM_DEBUG_DRAWING == 1 )
                NSFrameRect( drawRect );
#endif
            }
        }
    }

    if ( nil != [ self labelForAxis:kSM2DGraph_Axis_Y ] )
    {
        // Draw the Y Axis label.
        NSAffineTransform	*transform;

        tempString = [ self labelForAxis:kSM2DGraph_Axis_Y ];
        drawRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];

        // Tip it to draw from bottom to top.
        transform = [ NSAffineTransform transform ];
        [ transform translateXBy:drawRect.size.height yBy:0 ];
        [ transform rotateByDegrees:90 ];
        [ transform concat ];

        drawRect.origin.y = bounds.origin.y;
        drawRect.origin.x = graphRect.origin.y + ( graphRect.size.height - drawRect.size.width ) / 2.0;
// stub - find a better test...this doesn't seem to work correctly because of the transformations.
//        if ( NSIntersectsRect( drawRect, rect ) )
//        {
            [ tempString drawInRect:drawRect withAttributes:myPrivateData->textAttributes ];
#if defined( SM_DEBUG_DRAWING ) && ( SM_DEBUG_DRAWING == 1 )
            NSFrameRect( drawRect );
#endif
//        }

        [ transform invert ];
        [ transform concat ];
    }

    for ( i = 0; i < [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ]; i++ )
    {
        // Draw the Y axis ticks.

        // Figure out the default label.
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            minX = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ] -
                        [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ] ) *
                        (double)i / (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ] - 1 );
            minX += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ];
        }
        else
            minX = i;

        tempString = [ NSString stringWithFormat:@"%g", minX ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i forAxis:kSM2DGraph_Axis_Y defaultLabel:tempString ];

        if ( nil != tempString )
        {
            drawRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
            drawRect.origin.y = graphRect.origin.y - ( drawRect.size.height / 2.0 ) +
                        ( graphRect.size.height / ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ] - 1 ) ) * i;
            if ( nil != [ self labelForAxis:kSM2DGraph_Axis_Y ] )
                drawRect.origin.x = ( bounds.origin.x + graphPaperRect.origin.x + drawRect.size.height +
                            kSM2DGraph_LabelSpacing - drawRect.size.width ) / 2;
            else
                drawRect.origin.x = ( bounds.origin.x + graphPaperRect.origin.x - drawRect.size.width ) / 2;
            if ( NSIntersectsRect( drawRect, rect ) )
            {
                [ tempString drawInRect:drawRect withAttributes:myPrivateData->textAttributes ];
#if defined( SM_DEBUG_DRAWING ) && ( SM_DEBUG_DRAWING == 1 )
                NSFrameRect( drawRect );
#endif
            }
        }
    }

    if ( nil != [ self labelForAxis:kSM2DGraph_Axis_Y_Right ] )
    {
        // Draw the Y Axis right side label.
        NSAffineTransform	*transform;

        tempString = [ self labelForAxis:kSM2DGraph_Axis_Y_Right ];
        drawRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];

        // Tip it to draw from top to bottom.
        transform = [ NSAffineTransform transform ];
        [ transform translateXBy:bounds.size.width - drawRect.size.height yBy:bounds.size.height ];
        [ transform rotateByDegrees:-90 ];
        [ transform concat ];

        drawRect.origin.y = bounds.origin.y;
        drawRect.origin.x = ( bounds.size.height - graphRect.origin.y - graphRect.size.height ) +
                    ( graphRect.size.height - drawRect.size.width ) / 2.0;
// stub - find a better test...this doesn't seem to work correctly because of the transformations.
//        if ( NSIntersectsRect( drawRect, rect ) )
//        {
            [ tempString drawInRect:drawRect withAttributes:myPrivateData->textAttributes ];
#if defined( SM_DEBUG_DRAWING ) && ( SM_DEBUG_DRAWING == 1 )
            NSFrameRect( drawRect );
#endif
//        }

        [ transform invert ];
        [ transform concat ];
    }

    for ( i = 0; i < [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y_Right ]; i++ )
    {
        // Draw the Y axis right side ticks.

        // Figure out the default label.
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            minX = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_Y_Right ] - [ [ self dataSource ] twoDGraphView:self
                        minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y_Right ] ) * (double)i /
                        (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y_Right ] - 1 );
            minX += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_Y_Right ];
        }
        else
            minX = i;

        tempString = [ NSString stringWithFormat:@"%g", minX ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i forAxis:kSM2DGraph_Axis_Y_Right
                        defaultLabel:tempString ];

        if ( nil != tempString )
        {
            drawRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
            drawRect.origin.y = graphRect.origin.y - ( drawRect.size.height / 2.0 ) +
                        ( graphRect.size.height / ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y_Right ] - 1 ) ) *
                        i;
            drawRect.origin.x = graphPaperRect.origin.x + graphPaperRect.size.width + kSM2DGraph_LabelSpacing;
            if ( NSIntersectsRect( drawRect, rect ) )
            {
                [ tempString drawInRect:drawRect withAttributes:myPrivateData->textAttributes ];
#if defined( SM_DEBUG_DRAWING ) && ( SM_DEBUG_DRAWING == 1 )
                NSFrameRect( drawRect );
#endif
            }
        }
    }

    if ( NSIntersectsRect( graphPaperRect, rect ) )
    {
        // Draw the background of the graph paper.
        if ( nil != myPrivateData->backgroundColor )
        {
            [ myPrivateData->backgroundColor set ];
            NSRectFill( graphPaperRect );
        }

        // Frame it in the border color.
        [ [ self borderColor ] set ];
        NSFrameRect( graphPaperRect );

        // Possibly draw the grid on the graph paper.
        //if ( [ self drawsGrid ] )
            [ self _sm_drawGridInRect:rect ];

        if ( [ self drawsLineAtZeroForAxis:kSM2DGraph_Axis_Y ] && myPrivateData->flags.dataSourceIsValid && 
                    [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ] > 0.0 &&
                    [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ] < 0.0 )
        {
            // Need to draw a horizontal line through zero since it's on the graph and not at the max or minimum.
            fromPoint.x = graphPaperRect.origin.x;
            toPoint.x = graphPaperRect.origin.x + graphPaperRect.size.width;

            minY = [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ];
            yScale = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ]
                        - minY;
            yScale = ( graphRect.size.height - 2.0 ) / yScale;

            toPoint.y = fromPoint.y = ( 0.0 - minY ) * yScale + graphRect.origin.y + 1.0;

            [ [ [ NSColor blackColor ] colorWithAlphaComponent:0.6 ] set ];
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }

        if ( [ self drawsLineAtZeroForAxis:kSM2DGraph_Axis_X ] && myPrivateData->flags.dataSourceIsValid &&
                    [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ] > 0.0 &&
                    [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ] < 0.0 )
        {
            // Need to draw a vertical line through zero since it's on the graph and not at the max or minimum.
            fromPoint.y = graphPaperRect.origin.y;
            toPoint.y = graphPaperRect.origin.y + graphPaperRect.size.height;

            minX = [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ];
            xScale = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ]
                        - minX;
            xScale = ( graphRect.size.width - 2.0 ) / xScale;

            toPoint.x = fromPoint.x = ( 0.0 - minX ) * xScale + graphRect.origin.x + 1.0;

            [ [ [ NSColor blackColor ] colorWithAlphaComponent:0.6 ] set ];
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }

        if ( nil != myPrivateData->lineData && [ myPrivateData->lineData count ] > 0
                    && ![ self inLiveResize ] )
        {
#if defined( SM2D_TIMER ) && ( SM2D_TIMER == 1 )
            timer = [ NSDate date ];
#endif

            // Draw the data (but not when we're in a live resize).
            [ NSBezierPath clipRect:NSInsetRect( graphPaperRect, 1.0, 1.0 ) ];

            lineCount = [ myPrivateData->lineData count ];
            barNumber = 0;
            for ( lineIndex = 0; lineIndex < lineCount; lineIndex++ )
            {
                dataObj = [ myPrivateData->lineData objectAtIndex:lineIndex ];
                if ( [ dataObj isKindOfClass:[ NSArray class ] ] )
                {
                    dataCount = [ (NSArray *)dataObj count ];
                    dataLinePoints = nil;
                }
                else
                {
                    dataCount = [ (NSData *)dataObj length ] / sizeof(NSPoint);
                    dataLinePoints = (NSPoint *)[ dataObj bytes ];
                }

                // Calculate the minimum X value and the X scale.
                minX = [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:lineIndex
                            forAxis:kSM2DGraph_Axis_X ];
                xScale = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:lineIndex
                            forAxis:kSM2DGraph_Axis_X ] - minX;
				if ( 0.0 == xScale )
				{
					NSLog( @"SM2DGraphView - min and max X values for line index: %d are both equal to: %g",
								lineIndex, minX );
					continue;	// Try moving on to the next line.
				}
                xScale = ( graphRect.size.width - 1.0 ) / xScale;

                // Calculate the minimum Y value and the Y scale.
                minY = [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:lineIndex
                            forAxis:kSM2DGraph_Axis_Y ];
                yScale = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:lineIndex
                            forAxis:kSM2DGraph_Axis_Y ]
                            - minY;
				if ( 0.0 == yScale )
				{
					NSLog( @"SM2DGraphView - min and max Y values for line index: %d are both equal to: %g",
								lineIndex, minY );
					continue;	// Try moving on to the next line.
				}
                yScale = ( graphRect.size.height - 2.0 ) / yScale;


                // Allocate memory for the scaled data points.
                if ( sizeof(NSPoint) * dataCount > pointsSize )
                {
                    pointsSize = sizeof(NSPoint) * dataCount;
                    if ( nil != points )
                        free( points );
                    points = malloc( pointsSize );
                }

                // First, just copy all of the data points into a local array.
                if ( nil != dataLinePoints )
                    memcpy( points, dataLinePoints, sizeof(NSPoint) * dataCount );
                else
                {
                    // Get the values out of the string and into an array of NSPoints.
                    for ( dataIndex = 0; dataIndex < dataCount; dataIndex++ )
                        points[ dataIndex ] = NSPointFromString( [ (NSArray *)dataObj objectAtIndex:dataIndex ] );
                }

#if defined( SM2D_TIMER ) && ( SM2D_TIMER == 2 )
                timer = [ NSDate date ];
#endif

#if __ppc__
                if ( myPrivateData->flags.useVectorComputation && 63 < dataCount )
                    // If CPU has Velocity Engine and we have at least 64 data points, we'll use V.E.
                    // Doesn't really make sense to use it for small data sets because the setup time can be big.
                    // 64 data points is 32 passes through the inner loop for V.E. (two points at a time for V.E.)
                    _sm_local_scaleDataUsingVelocityEngine( points, dataCount,
                                minX, xScale, graphRect.origin.x + 1.0,
                                minY, yScale, graphRect.origin.y + 1.0 );
                else
#endif // __ppc__

                {
                    // Scale the points using the CPU as normal.
                    for ( dataIndex = 0; dataIndex < dataCount; dataIndex++ )
                    {
                        // Scale the data point into the graphRect correctly.
                        points[ dataIndex ].x = ( points[ dataIndex ].x - minX ) * xScale + graphRect.origin.x + 1.0;
                        points[ dataIndex ].y = ( points[ dataIndex ].y - minY ) * yScale + graphRect.origin.y + 1.0;
                    }
                }

#if defined( SM2D_TIMER ) && ( SM2D_TIMER == 2 )
                timeInterval = [ timer timeIntervalSinceNow ];
                NSLog( @"Scaling %d points took %g microseconds", dataCount, -timeInterval * 1000000 );
#endif

#if !SM2D_USE_CORE_GRAPHICS
                line = nil;
#endif
                drawBar =  ( nil != [ [ myPrivateData->lineAttributes objectAtIndex:lineIndex ]
                            objectForKey:SM2DGraphBarStyleAttributeName ] );
                if ( drawBar )
                {
                    // If we're drawing a bar graph, that's a simple loop and draw each bar.
                    barNumber++;
                    tempColor = [
						[ myPrivateData->lineAttributes objectAtIndex:lineIndex ]
                        objectForKey:NSForegroundColorAttributeName 
					];

                    tempColor = tempColor != nil ? tempColor : [ NSColor blackColor ];

                    attr = [ NSMutableDictionary dictionaryWithObjectsAndKeys:
						tempColor, NSForegroundColorAttributeName,
						nil
					];
					[ self _sm_setupVertBarAttributes: attr ];
					
					
					
                    // Draw all bars starting at the zero vertical location...
                    fromPoint.y = ( 0.0 - minY ) * yScale + graphRect.origin.y + 1.0;
                    fromPoint.y = floor( fromPoint.y + 0.5 );	// Make it an integer.

                    // Limit the bars to actually draw inside the graph area.
                    if ( fromPoint.y < graphRect.origin.y + 1.0 )
                        fromPoint.y = graphRect.origin.y + 1.0;
                    else if ( fromPoint.y > graphRect.origin.y + graphRect.size.height - 1 )
                        fromPoint.y = graphRect.origin.y + graphRect.size.height - 1;

                    for ( dataIndex = 0; dataIndex < dataCount; dataIndex++ )
                    {
                        fromPoint.x = points[ dataIndex ].x;

                        if ( myPrivateData->flags.delegateChangesBarAttrs )
                        {
                            [ delegate twoDGraphView:self willDisplayBarIndex:dataIndex forLineIndex:lineIndex
                                        withAttributes:attr ];
//                            tempColor = [ attr objectForKey:NSForegroundColorAttributeName ];
//                            if ( tempColor == nil )
//                                tempColor = [ NSColor blackColor ];
                        }

                        [ self _sm_drawVertBarFromPoint:fromPoint toPoint:points[ dataIndex ] barNumber:barNumber
                                    of:myPrivateData->barCount withAttributes: attr ];
                    }
                }
#if !SM2D_USE_CORE_GRAPHICS
                else
                {
                    // We're not drawing a bar.  We're drawing a line (or symbols only).
                    // Since we're not using Core Graphics, we'll make the data points into an NSBezierPath.
                    for ( dataIndex = 0; dataIndex < dataCount; dataIndex++ )
                    {
                        if ( 0 == dataIndex )
                        {
                            // Start a new NSBezierPath with a -moveToPoint;
                            line = [ NSBezierPath bezierPath ];
                            [ line moveToPoint:points[ dataIndex ] ];
                        }
                        else
                            // All others are -lineToPoint;
                            [ line lineToPoint:points[ dataIndex ] ];
                    }
                }
#endif

#if SM2D_USE_CORE_GRAPHICS
                if ( nil != points && !drawBar && 0 < dataCount )
#else
                if ( nil != line )
#endif
                {
                    NSNumber	*tempNumber = nil;
                    BOOL		tempBool = YES;

                    // Possibly turn off anti-aliasing for this line.
                    CGContextSetShouldAntialias( context, ( nil == [ [ myPrivateData->lineAttributes
                            objectAtIndex:lineIndex ] objectForKey:SM2DGraphDontAntialiasAttributeName ] ) );

                    tempNumber = [ [ myPrivateData->lineAttributes objectAtIndex:lineIndex ]
                                objectForKey:SM2DGraphLineWidthAttributeName ];

                    if ( nil != tempNumber )
                    {
                        switch ( [ tempNumber intValue ] )
                        {
                        case kSM2DGraph_Width_Fine:
#if SM2D_USE_CORE_GRAPHICS
                            CGContextSetLineWidth( context, 0.5 );
#else
                            [ line setLineWidth:0.5 ];
#endif
                            break;
                        case kSM2DGraph_Width_Wide:
#if SM2D_USE_CORE_GRAPHICS
                            CGContextSetLineWidth( context, 2.0 );
#else
                            [ line setLineWidth:2.0 ];
#endif
                            break;
                        case kSM2DGraph_Width_None:
                            tempBool = NO;
                            break;
                        default:
#if SM2D_USE_CORE_GRAPHICS
                            CGContextSetLineWidth( context, 1.0 );
#else
                            [ line setLineWidth:1.0 ];
#endif
                            break;
                        }
                    }

                    // Go ahead and draw the line as an NSBezierPath.
                    tempColor = [ [ myPrivateData->lineAttributes objectAtIndex:lineIndex ]
                                objectForKey:NSForegroundColorAttributeName ];
                    if ( nil != tempColor )
                        [ tempColor set ];
                    else
                        [ [ NSColor blackColor ] set ];

                    if ( tempBool )
                    {
#if SM2D_USE_CORE_GRAPHICS
                        // Add the points to the current path and stroke it.
                        // NOTE: stroking a path also clears the path (thus we need to store the path for later use).
                        // NOTE: CGPoint == NSPoint.
                        CGContextAddLines( context, (CGPoint *)points, dataCount );
                        CGContextStrokePath( context );
#else
                        [ line stroke ];
#endif

                        if ( nil == tempNumber || kSM2DGraph_Width_3D == [ tempNumber intValue ] )
                        {
#if !SM2D_USE_CORE_GRAPHICS
                            NSAffineTransform	*offsetUp = [ NSAffineTransform transform ];
                            NSAffineTransform	*offsetDown = [ NSAffineTransform transform ];
#endif

                            // Make a lighter color above it.
                            if ( nil != tempColor )
                                [ [ tempColor blendedColorWithFraction:0.3 ofColor:[ NSColor whiteColor ] ] set ];
#if SM2D_USE_CORE_GRAPHICS
                            CGContextTranslateCTM( context, 0.0, 1.0 );
                            CGContextAddLines( context, (CGPoint *)points, dataCount );
                            CGContextStrokePath( context );
#else
                            [ offsetUp translateXBy:0.0 yBy:1.0 ];
                            [ offsetDown translateXBy:0.0 yBy:-1.0 ];

                            [ line transformUsingAffineTransform:offsetUp ];
                            [ line stroke ];
#endif

                            // Make a darker color below it.
                            if ( nil != tempColor )
                                [ [ tempColor blendedColorWithFraction:0.3 ofColor:[ NSColor blackColor ] ] set ];
#if SM2D_USE_CORE_GRAPHICS
                            CGContextTranslateCTM( context, 0.0, -2.0 );
                            CGContextAddLines( context, (CGPoint *)points, dataCount );
                            CGContextStrokePath( context );
                            CGContextTranslateCTM( context, 0.0, 1.0 );
#else
                            [ line transformUsingAffineTransform:offsetDown ];
                            [ line transformUsingAffineTransform:offsetDown ];
                            [ line stroke ];
                            [ line transformUsingAffineTransform:offsetUp ];
#endif
                        } // if line width is "normal" - 3 pixels wide
                    } // if line width is not "none".

                    // Make sure antialiasing is on.
                    CGContextSetShouldAntialias( context, YES );

                    // Possibly draw symbols on the line.
                    tempNumber = [ [ myPrivateData->lineAttributes objectAtIndex:lineIndex ]
                                objectForKey:SM2DGraphLineSymbolAttributeName ];
#if SM2D_USE_CORE_GRAPHICS
                    if ( nil != tempNumber && [ tempNumber intValue ] != kSM2DGraph_Symbol_None )
                        [ self _sm_drawSymbol:[ tempNumber intValue ] onLine:points count:dataCount
                                    inColor:tempColor inRect:rect ];

//                    free( points );
//                    points = nil;
#else
                    if ( nil != tempNumber && [ tempNumber intValue ] != kSM2DGraph_Symbol_None )
                        [ self _sm_drawSymbol:[ tempNumber intValue ] onLine:line inColor:tempColor inRect:rect ];
#endif
                } // if bezier path ( line != nil ) or ( points != nil )

                // Signal the delegate that we're done.
                if ( myPrivateData->flags.delegateWantsEndDraw )
                    [ [ self delegate ] twoDGraphView:self doneDrawingLineIndex:lineIndex ];
            } // end of this line.

            if ( nil != points )
                free( points );
#if defined( SM2D_TIMER ) && ( SM2D_TIMER == 1 )
            timeInterval = [ timer timeIntervalSinceNow ];
            NSLog( @"drawing all lines took this long: %g", -timeInterval );
#endif
        } // end have to draw our lines.
    }
}

- (void)viewDidEndLiveResize
{
    // Make sure we redisplay so the data lines show up in the graph.
    [ super viewDidEndLiveResize ];
    [ self setNeedsDisplay:YES ];
}

- (void)mouseDown:(NSEvent *)inEvent
{
    if ( myPrivateData->flags.delegateWantsMouseDowns )
    {
        NSPoint		curPoint;

        curPoint = [ self convertPoint:[ inEvent locationInWindow ] fromView:nil ];

        // Do we want to track until mouse up and THEN call the delegate?
        [ [ self delegate ] twoDGraphView:self didClickPoint:curPoint ];
    }
    else
        [ super mouseDown:inEvent ];
}

#pragma mark -
#pragma mark ¥ ACCESSORS

- (void)setDataSource:(id)inDataSource
{
    BOOL	failed = NO;

	dataSource = inDataSource;

    // Assert some checks on the data source.
    if ( ![ dataSource respondsToSelector:@selector(numberOfLinesInTwoDGraphView:) ] )
    {
        failed = YES;
        NSLog( @"SM2DGraphView data source does not respond to selector -numberOfLinesInTwoDGraphView:" );
    }
    if ( ![ dataSource respondsToSelector:@selector(twoDGraphView:dataForLineIndex:) ] &&
                ![ dataSource respondsToSelector:@selector(twoDGraphView:dataObjectForLineIndex:) ] )
    {
        failed = YES;
        NSLog( @"SM2DGraphView data source does not respond to selector -twoDGraphView:dataForLineIndex: or twoDGraphView:dataObjectForLineIndex:" );
    }
    if ( ![ dataSource respondsToSelector:@selector(twoDGraphView:maximumValueForLineIndex:forAxis:) ] )
    {
        failed = YES;
        NSLog( @"SM2DGraphView data source does not respond to selector -twoDGraphView:maximumValueForLineIndex:forAxis:" );
    }
    if ( ![ dataSource respondsToSelector:@selector(twoDGraphView:minimumValueForLineIndex:forAxis:) ] )
    {
        failed = YES;
        NSLog( @"SM2DGraphView data source does not respond to selector -twoDGraphView:minimumValueForLineIndex:forAxis:" );
    }

    myPrivateData->flags.dataSourceIsValid = !failed;

    // Check for optional methods.
    myPrivateData->flags.dataSourceDecidesAttributes = [ dataSource
                respondsToSelector:@selector(twoDGraphView:attributesForLineIndex:) ];

    myPrivateData->flags.dataSourceWantsDataArray = [ dataSource
                respondsToSelector:@selector(twoDGraphView:dataForLineIndex:) ];
    myPrivateData->flags.dataSourceWantsDataChunk = [ dataSource
                respondsToSelector:@selector(twoDGraphView:dataObjectForLineIndex:) ];
}

- (id)dataSource
{	return dataSource;	}

- (void)setDelegate:(id)inDelegate
{
    delegate = inDelegate;

    myPrivateData->flags.delegateLabelsTickMarks = [ delegate
                respondsToSelector:@selector(twoDGraphView:labelForTickMarkIndex:forAxis:defaultLabel:) ];

    myPrivateData->flags.delegateChangesBarAttrs = [ delegate
                respondsToSelector:@selector(twoDGraphView:willDisplayBarIndex:forLineIndex:withAttributes:) ];

    myPrivateData->flags.delegateWantsMouseDowns = [ delegate
                respondsToSelector:@selector(twoDGraphView:didClickPoint:) ];

    myPrivateData->flags.delegateWantsEndDraw = [ delegate
                respondsToSelector:@selector(twoDGraphView:doneDrawingLineIndex:) ];
}

- (id)delegate
{	return delegate;	}

- (void)setTag:(int)inTag
{	myPrivateData->tag = inTag;	}

- (int)tag
{	return myPrivateData->tag;	}

- (void)setLiveRefresh:(BOOL)inFlag
{
	myPrivateData->flags.liveRefresh = inFlag;
}

- (BOOL)liveRefresh
{
	return myPrivateData->flags.liveRefresh;
}

- (void)setDrawsGrid:(BOOL)inFlag
{
	myPrivateData->flags.drawsGrid = inFlag;
    [ self setNeedsDisplay:YES ];
}

- (BOOL)drawsGrid
{	return myPrivateData->flags.drawsGrid;	}

- (void)setBackgroundColor:(NSColor *)inColor
{
	[ myPrivateData->backgroundColor release ];
    myPrivateData->backgroundColor = [ inColor copy ];
    [ self setNeedsDisplay:YES ];
}

- (NSColor *)backgroundColor
{	return [ [ myPrivateData->backgroundColor retain ] autorelease ];	}

- (void)setGridColor:(NSColor *)inColor
{
	[ myPrivateData->gridColor release ];
    myPrivateData->gridColor = [ inColor copy ];
    [ self setNeedsDisplay:YES ];
}

- (NSColor *)gridColor
{	return [ [ myPrivateData->gridColor retain ] autorelease ];	}

- (void)setBorderColor:(NSColor *)inColor
{
	[ myPrivateData->borderColor release ];
    myPrivateData->borderColor = [ inColor copy ];
    [ self setNeedsDisplay:YES ];
}

- (NSColor *)borderColor
{	return [ [ myPrivateData->borderColor retain ] autorelease ];	}

- (void)setLabel:(NSString *)inNewLabel forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->label != inNewLabel )
    {
        [ info->label release ];
        info->label = [ inNewLabel copy ];
        [ self _sm_calculateGraphPaperRect ];
        [ self setNeedsDisplay:YES ];
    }
}

- (NSString *)labelForAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    return [ [ info->label retain ] autorelease ];
}

- (void)setNumberOfTickMarks:(int)count forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->numberOfTickMarks != count )
    {
        info->numberOfTickMarks = count;
        [ self _sm_calculateGraphPaperRect ];
        [ self setNeedsDisplay:YES ];
    }
}

- (int)numberOfTickMarksForAxis:(SM2DGraphAxisEnum)inAxis
{    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

	return info->numberOfTickMarks;
}

- (void)setNumberOfMinorTickMarks:(int)count forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->numberOfMinorTickMarks != count )
    {
        info->numberOfMinorTickMarks = count;
        [ self setNeedsDisplay:YES ];
    }
}

- (int)numberOfMinorTickMarksForAxis:(SM2DGraphAxisEnum)inAxis
{    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

	return info->numberOfMinorTickMarks;
}

- (void)setTickMarkPosition:(NSTickMarkPosition)position forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->tickMarkPosition != position )
    {
        info->tickMarkPosition = position;
        NSLog( @"Tick mark positions are currently unimplemented" );
// stub - implement this to actually do something.
//        [ self _sm_calculateGraphPaperRect ];
//        [ self setNeedsDisplay:YES ];
    }
}

- (NSTickMarkPosition)tickMarkPositionForAxis:(SM2DGraphAxisEnum)inAxis
{    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

	return info->tickMarkPosition;
}

/*- (void)setScaleType:(SM2DGraphScaleTypeEnum)inNewValue forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->scaleType != inNewValue )
    {
        info->scaleType = inNewValue;
        [ self _sm_calculateGraphPaperRect ];
        [ self setNeedsDisplay:YES ];
    }
}

- (SM2DGraphScaleTypeEnum)scaleTypeForAxis:(SM2DGraphAxisEnum)inAxis
{    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

	return info->scaleType;
}*/

- (void)setAxisInset:(float)inInset forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->inset != inInset )
    {
        info->inset = inInset;
        [ self _sm_calculateGraphPaperRect ];
        [ self setNeedsDisplay:YES ];
    }
}

- (float)axisInsetForAxis:(SM2DGraphAxisEnum)inAxis
{    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

	return info->inset;
}

- (void)setDrawsLineAtZero:(BOOL)inNewValue forAxis:(SM2DGraphAxisEnum)inAxis
{
    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

    if ( info->drawLineAtZero != inNewValue )
    {
        info->drawLineAtZero = inNewValue;
        [ self setNeedsDisplay:YES ];
    }
}

- (BOOL)drawsLineAtZeroForAxis:(SM2DGraphAxisEnum)inAxis
{    SM2DGraphAxisRecord	*info;

    info = _sm_local_determineAxis( inAxis, myPrivateData );

	return info->drawLineAtZero;
}

#pragma mark -
#pragma mark ¥ OTHER METHODS

- (IBAction)refreshDisplay:(id)sender
{
    [ self reloadData ];
    [ self reloadAttributes ];
}

- (void)reloadData
{
    unsigned int	numLines, i;
    id				lineData;

    if ( myPrivateData->flags.dataSourceIsValid )
    {
        numLines = [ [ self dataSource ] numberOfLinesInTwoDGraphView:self ];

        [ myPrivateData->lineData release ];
        myPrivateData->lineData = [ [ NSMutableArray arrayWithCapacity:numLines ] retain ];

        for ( i = 0; i < numLines; i++ )
        {
            lineData = nil;
            if ( myPrivateData->flags.dataSourceWantsDataChunk )
            {
                // Try grabbing an NSData chunk.
                lineData = [ [ self dataSource ] twoDGraphView:self dataObjectForLineIndex:i ];
                if ( nil == lineData && myPrivateData->flags.dataSourceWantsDataArray )
                    // Otherwise grab an NSArray.
                    lineData = [ [ self dataSource ] twoDGraphView:self dataForLineIndex:i ];
            }
            else if ( myPrivateData->flags.dataSourceWantsDataArray )
                // Don't want NSData chunks...grab an NSArray.
                lineData = [ [ self dataSource ] twoDGraphView:self dataForLineIndex:i ];

            if ( lineData == nil )
                // Didn't get anything...make it into an NSMutableData for speed purposes.
                lineData = [ NSMutableData dataWithLength:0 ];

            [ myPrivateData->lineData addObject:lineData ];
        }

        [ self _sm_calculateGraphPaperRect ];

        [ self setNeedsDisplay:YES ];
    }
}

- (void)reloadDataForLineIndex:(unsigned int)inLineIndex
{
    id		lineData = nil;

    if ( myPrivateData->flags.dataSourceIsValid )
    {
        if ( myPrivateData->flags.dataSourceWantsDataChunk )
        {
            // Try grabbing an NSData chunk.
            lineData = [ [ self dataSource ] twoDGraphView:self dataObjectForLineIndex:inLineIndex ];
            if ( nil == lineData && myPrivateData->flags.dataSourceWantsDataArray )
                // Otherwise grab an NSArray.
                lineData = [ [ self dataSource ] twoDGraphView:self dataForLineIndex:inLineIndex ];
        }
        else if ( myPrivateData->flags.dataSourceWantsDataArray )
            // Don't want NSData chunks...grab an NSArray.
            lineData = [ [ self dataSource ] twoDGraphView:self dataForLineIndex:inLineIndex ];

        if ( lineData == nil )
            // Didn't get anything...make it into an NSMutableData for speed purposes.
            lineData = [ NSMutableData dataWithLength:0 ];

        [ myPrivateData->lineData replaceObjectAtIndex:inLineIndex withObject:lineData ];

        [ self _sm_calculateGraphPaperRect ];
        [ self setNeedsDisplay:YES ];
    }
}

- (void)reloadAttributes
{
    unsigned int	numLines, i;
    NSDictionary	*lineData;

    numLines = [ [ self dataSource ] numberOfLinesInTwoDGraphView:self ];
    [ myPrivateData->lineAttributes release ];
    myPrivateData->lineAttributes = [ [ NSMutableArray arrayWithCapacity:numLines ] retain ];
    myPrivateData->barCount = 0;

    if ( myPrivateData->flags.dataSourceDecidesAttributes )
    {
        for ( i = 0; i < numLines; i++ )
        {
            lineData = [ [ self dataSource ] twoDGraphView:self attributesForLineIndex:i ];
            if ( nil == lineData )
                lineData = _sm_local_defaultLineAttributes( i );
            [ myPrivateData->lineAttributes addObject:lineData ];

            // Count the number of bars to show.
            if ( nil != [ lineData objectForKey:SM2DGraphBarStyleAttributeName ] )
                myPrivateData->barCount++;
        }
    }
    else
    {
        for ( i = 0; i < numLines; i++ )
        {
            lineData = _sm_local_defaultLineAttributes( i );
            [ myPrivateData->lineAttributes addObject:lineData ];

            // Count the number of bars to show.
            if ( nil != [ lineData objectForKey:SM2DGraphBarStyleAttributeName ] )
                myPrivateData->barCount++;
        }
    }

    [ self _sm_calculateGraphPaperRect ];
    [ self setNeedsDisplay:YES ];
}

- (void)reloadAttributesForLineIndex:(unsigned int)inLineIndex
{
    NSDictionary	*lineData, *replacingData;
    BOOL			wasBar;

    // Determine if the attribute being replaced was a bar or not (so we can keep the bar count correct).
    replacingData = [ myPrivateData->lineAttributes objectAtIndex:inLineIndex ];
    wasBar = ( nil != [ replacingData objectForKey:SM2DGraphBarStyleAttributeName ] );

    if ( myPrivateData->flags.dataSourceDecidesAttributes )
    {
        // Let the dataSource object figure it out.
        lineData = [ [ self dataSource ] twoDGraphView:self attributesForLineIndex:inLineIndex ];
        if ( nil == lineData )
            lineData = _sm_local_defaultLineAttributes( inLineIndex );
    }
    else
        lineData = _sm_local_defaultLineAttributes( inLineIndex );

    [ myPrivateData->lineAttributes replaceObjectAtIndex:inLineIndex withObject:lineData ];

    // Count the number of bars to show.
    if ( nil != [ lineData objectForKey:SM2DGraphBarStyleAttributeName ] )
    {
        // New line attribute is a bar...
        if ( !wasBar )
            // ...old line was NOT a bar; added a bar.
            myPrivateData->barCount++;
    }
    else
    {
        // New line attribute is NOT a bar...
        if ( wasBar )
            // ...old line was a bar; removed a bar.
            myPrivateData->barCount--;
    }

    [ self _sm_calculateGraphPaperRect ];
    [ self setNeedsDisplay:YES ];
}

- (void)addDataPoint:(NSPoint)inPoint toLineIndex:(unsigned int)inLineIndex
{
    id		dataObj;

    dataObj = [ myPrivateData->lineData objectAtIndex:inLineIndex ];
    if ( [ dataObj isKindOfClass:[ NSMutableArray class ] ] )
        [ (NSMutableArray *)dataObj addObject:NSStringFromPoint( inPoint ) ];
    else if ( [ dataObj isKindOfClass:[ NSMutableData class ] ] )
        [ (NSMutableData *)dataObj appendBytes:&inPoint length:sizeof(inPoint) ];
    else
    {
        NSLog( @"SM2DGraphView -addDataPoint:toLineIndex: can't add a point to line %d", inLineIndex );
        return;
    }
    [ self _sm_calculateGraphPaperRect ];
    if ( myPrivateData->flags.liveRefresh )
        [ self setNeedsDisplay:YES ];
}

- (NSImage *)imageOfView
{
    NSImage		*result = nil;

    result = [ [ [ NSImage alloc ] initWithSize:[ self bounds ].size ] autorelease ];

    // This provides a cached representation.
    [ result lockFocus ];

    // Fill with a white background.
    [ [ NSColor whiteColor ] set ];
    NSRectFill( [ self bounds ] );

    // Draw the graph.
    [ self drawRect:[ self bounds ] ];

    [ result unlockFocus ];

    return result;
}

- (NSPoint)convertPoint:(NSPoint)inPoint fromView:(NSView *)inView toLineIndex:(unsigned int)inLineIndex
{
    NSPoint		result = inPoint;
    double		minX = 0, xScale = 1.0;
    double		minY = 0, yScale = 1.0;

    // First, get the point into the coordinate system of this view.
    if ( inView != self )
        result = [ self convertPoint:result fromView:inView ];

    if ( myPrivateData->flags.dataSourceIsValid )
    {
        // Now, determine the scales of this line index.
        minX = [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:inLineIndex
                    forAxis:kSM2DGraph_Axis_X ];
        xScale = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:inLineIndex
                    forAxis:kSM2DGraph_Axis_X ] - minX;
        if ( 0.0 != xScale )
            xScale = ( myPrivateData->graphRect.size.width - 1.0 ) / xScale;

        minY = [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:inLineIndex
                    forAxis:kSM2DGraph_Axis_Y ];
        yScale = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:inLineIndex
                    forAxis:kSM2DGraph_Axis_Y ] - minY;
        if ( 0.0 != yScale )
            yScale = ( myPrivateData->graphRect.size.height - 2.0 ) / yScale;
    }

    // Scale the result into the graphRect correctly.
    if ( 0.0 != xScale )
        result.x = ( result.x - 1.0 - myPrivateData->graphRect.origin.x ) / xScale + minX;
    if ( 0.0 != yScale )
        result.y = ( result.y - 1.0 - myPrivateData->graphRect.origin.y ) / yScale + minY;

    return result;
}

#pragma mark -
#pragma mark ¥ PRIVATE METHODS

- (void)_sm_frameDidChange:(NSNotification *)inNote
{
    [ self _sm_calculateGraphPaperRect ];
}

- (void)_sm_calculateGraphPaperRect
{
    NSString	*tempString = nil, *lowerString = nil;
    NSRect		bounds = [ self bounds ], graphPaperRect;
    NSRect		tempRect = NSZeroRect;
    int			i;
    double		tempDouble;

    graphPaperRect = bounds;

    for ( i = 0; i < [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ]; i++ )
    {
        // Find the y axis labels, so we can get the max width and size the graph paper accordingly.
        // Figure out the default label.
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            tempDouble = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_Y ] - [ [ self dataSource ] twoDGraphView:self
                        minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y ] ) * (double)i /
                        (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ] - 1 );
            tempDouble += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_Y ];
        }
        else
            tempDouble = i;

        // This is the default label.
        tempString = [ NSString stringWithFormat:@"%g", tempDouble ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i forAxis:kSM2DGraph_Axis_Y
                        defaultLabel:tempString ];

		if ( 0 == i )
			lowerString = tempString;

        if ( nil != tempString )
        {
            tempRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
            if ( graphPaperRect.origin.x - bounds.origin.x < tempRect.size.width )
                graphPaperRect.origin.x = bounds.origin.x + tempRect.size.width;
        }
    }

    if ( graphPaperRect.origin.x != bounds.origin.x )
    {
        // Give a couple pixels spacing between labels and graph.
        graphPaperRect.origin.x += kSM2DGraph_LabelSpacing;
        graphPaperRect.size.width -= graphPaperRect.origin.x - bounds.origin.x;

        // Leave room at the top for half of the Y axis tick mark label that goes above the graph.
		if ( nil != tempString )	// This is the topmost Y axis tick mark string.
		{
			if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < 1.0 )
				graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1;
			else
			{
				if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < ( tempRect.size.height / 2 ) + 1 )
					graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1 - [ self
								axisInsetForAxis:kSM2DGraph_Axis_Y ];
			}
		}

        if ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] == 0 && nil != lowerString )
        {
            // Leave room at the bottom for half of the Y axis tick mark label that goes below the graph.
            if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < 1.0 )
            {
                graphPaperRect.origin.y += ( tempRect.size.height / 2 ) + 1;
                graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1;
            }
            else
            {
                if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < ( tempRect.size.height / 2 ) + 1 )
                {
                    graphPaperRect.origin.y += ( tempRect.size.height / 2 ) + 1 - [ self
                                axisInsetForAxis:kSM2DGraph_Axis_Y ];
                    graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1 - [ self
                                axisInsetForAxis:kSM2DGraph_Axis_Y ];
                }
            }
        }
    }

	lowerString = nil;
    for ( i = 0; i < [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y_Right ]; i++ )
    {
        // Find the y right axis labels, so we can get the max width and size the graph paper accordingly.
        // Figure out the default label.
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            tempDouble = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_Y_Right ] - [ [ self dataSource ] twoDGraphView:self
                        minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y_Right ] ) * (double)i /
                        (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y_Right ] - 1 );
            tempDouble += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_Y_Right ];
        }
        else
            tempDouble = i;

        // This is the default label.
        tempString = [ NSString stringWithFormat:@"%g", tempDouble ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i
						forAxis:kSM2DGraph_Axis_Y_Right defaultLabel:tempString ];

		if ( 0 == i )
			lowerString = tempString;

        if ( nil != tempString )
        {
            tempRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
            if ( bounds.size.width - ( graphPaperRect.origin.x + graphPaperRect.size.width ) < tempRect.size.width )
                graphPaperRect.size.width = bounds.size.width - graphPaperRect.origin.x - tempRect.size.width;
        }
    }

    if ( graphPaperRect.origin.x + graphPaperRect.size.width != bounds.size.width )
    {
        // Give a couple pixels spacing between labels and graph.
        graphPaperRect.size.width -= kSM2DGraph_LabelSpacing;

        if ( graphPaperRect.origin.x == bounds.origin.x )
        {
            // Only have to do this part if it was not done above.
            // Leave room at the top for half of the y axis label that goes above the graph.
			if ( nil != tempString )
			{
				if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < 1.0 )
					graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1;
				else
				{
					if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < ( tempRect.size.height / 2 ) + 1 )
						graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1 - [ self
									axisInsetForAxis:kSM2DGraph_Axis_Y ];
				}
			}

            if ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] == 0 && nil != lowerString )
            {
                // Leave room at the bottom for half of the y axis label that goes below the graph.
                if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < 1.0 )
                {
                    graphPaperRect.origin.y += ( tempRect.size.height / 2 ) + 1;
                    graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1;
                }
                else
                {
                    if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] < ( tempRect.size.height / 2 ) + 1 )
                    {
                        graphPaperRect.origin.y += ( tempRect.size.height / 2 ) + 1 - [ self
                                    axisInsetForAxis:kSM2DGraph_Axis_Y ];
                        graphPaperRect.size.height -= ( tempRect.size.height / 2 ) + 1 - [ self
                                    axisInsetForAxis:kSM2DGraph_Axis_Y ];
                    }
                }
            }
        }
    }

    if ( nil != [ self labelForAxis:kSM2DGraph_Axis_X ] )
    {
        // Leave room for the X Axis label.
        tempRect.size = [ @"Any" sizeWithAttributes:myPrivateData->textAttributes ];
        graphPaperRect.origin.y += tempRect.size.height + kSM2DGraph_LabelSpacing;
        graphPaperRect.size.height -= tempRect.size.height + kSM2DGraph_LabelSpacing;
    }

    if ( 0 != [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] )
    {
        // Leave room for the X axis tick mark labels.
        tempRect.size = [ @"Any" sizeWithAttributes:myPrivateData->textAttributes ];
        graphPaperRect.origin.y += tempRect.size.height + kSM2DGraph_LabelSpacing;
        graphPaperRect.size.height -= tempRect.size.height + kSM2DGraph_LabelSpacing;

        // Leave room at the left for half of the first X axis label that goes past the left edge of the graph.
        i = 0;
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            tempDouble = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_X ] - [ [ self dataSource ] twoDGraphView:self
                        minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ] ) *
                        (double)i / (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1 );
            tempDouble += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_X ];
        }
        else
            tempDouble = i;

        tempString = [ NSString stringWithFormat:@"%g", tempDouble ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i forAxis:kSM2DGraph_Axis_X
                        defaultLabel:tempString ];
        if ( nil != tempString )
            tempRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
        else
            tempRect.size.width = 0;

        if ( [ self axisInsetForAxis:kSM2DGraph_Axis_X ] < 1.0 )
        {
            // No inset, so have to make room for half the width of the string off the edge.
            if ( graphPaperRect.origin.x - bounds.origin.x < ( tempRect.size.width / 2 ) + 1 )
            {
                tempDouble = bounds.origin.x + ( tempRect.size.width / 2 ) + 1 - graphPaperRect.origin.x;
                // Need to adjust the origin to the right by this amount (but keep right edge at same point)
                graphPaperRect.origin.x += tempDouble;
                graphPaperRect.size.width -= tempDouble;
            }
        }
        else if ( graphPaperRect.origin.x - bounds.origin.x + [ self axisInsetForAxis:kSM2DGraph_Axis_X ] <
                    ( tempRect.size.width / 2 ) + 1 )
        {
            // Not enough inset, so make room for half the width of the string (minus the inset) off the edge.
            tempDouble = bounds.origin.x + ( tempRect.size.width / 2 ) + 1 - [ self
                        axisInsetForAxis:kSM2DGraph_Axis_X ] - graphPaperRect.origin.x;
            graphPaperRect.origin.x += tempDouble;
            graphPaperRect.size.width -= tempDouble;
        }

        // Leave room at the right for half of the last X axis label that goes past the right edge of the graph.
        i = [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1;
        if ( myPrivateData->flags.dataSourceIsValid )
        {
            tempDouble = ( [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_X ] - [ [ self dataSource ] twoDGraphView:self
                        minimumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_X ] ) *
                        (double)i / (double)( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1 );
            tempDouble += [ [ self dataSource ] twoDGraphView:self minimumValueForLineIndex:0
                        forAxis:kSM2DGraph_Axis_X ];
        }
        else
            tempDouble = i;

        tempString = [ NSString stringWithFormat:@"%g", tempDouble ];

        if ( myPrivateData->flags.delegateLabelsTickMarks )
            tempString = [ [ self delegate ] twoDGraphView:self labelForTickMarkIndex:i forAxis:kSM2DGraph_Axis_X
                        defaultLabel:tempString ];
        if ( nil != tempString )
            tempRect.size = [ tempString sizeWithAttributes:myPrivateData->textAttributes ];
        else
            tempRect.size.width = 0;

        if ( [ self axisInsetForAxis:kSM2DGraph_Axis_X ] < 1.0 )
        {
            // No inset, so have to make room for half the width of the string off the edge.
            if ( bounds.size.width - ( graphPaperRect.origin.x + graphPaperRect.size.width ) <
                        ( tempRect.size.width / 2 ) + 1 )
            {
                graphPaperRect.size.width = bounds.size.width - graphPaperRect.origin.x -
                            ( tempRect.size.width / 2 ) - 1;
            }
        }
        else if ( [ self axisInsetForAxis:kSM2DGraph_Axis_X ] < ( tempRect.size.width / 2 ) + 1 )
        {
            // Not enough inset so make room for half the width of the string (minus the inset) off the edge.
            if ( bounds.size.width - ( graphPaperRect.origin.x + graphPaperRect.size.width ) <
                        ( tempRect.size.width / 2 ) + 1 - [ self axisInsetForAxis:kSM2DGraph_Axis_X ] )
            {
                graphPaperRect.size.width = bounds.size.width - graphPaperRect.origin.x -
                            ( tempRect.size.width / 2 ) - 1 + [ self axisInsetForAxis:kSM2DGraph_Axis_X ];
            }

        }
    }

    if ( nil != [ self labelForAxis:kSM2DGraph_Axis_Y ] )
    {
        // Leave room for the Y Axis label.
        tempRect.size = [ @"Any" sizeWithAttributes:myPrivateData->textAttributes ];
        graphPaperRect.origin.x += tempRect.size.height + kSM2DGraph_LabelSpacing;
        graphPaperRect.size.width -= tempRect.size.height + kSM2DGraph_LabelSpacing;
    }

    if ( nil != [ self labelForAxis:kSM2DGraph_Axis_Y_Right ] )
    {
        // Leave room for the Y Axis right side label.
        tempRect.size = [ @"Any" sizeWithAttributes:myPrivateData->textAttributes ];
        graphPaperRect.size.width -= tempRect.size.height + kSM2DGraph_LabelSpacing;
    }

    myPrivateData->graphPaperRect = graphPaperRect;

    // Now that we know how big the graphPaper will be, how big is the graph itself?
    if ( [ self axisInsetForAxis:kSM2DGraph_Axis_Y ] >= 1.0 || [ self axisInsetForAxis:kSM2DGraph_Axis_X ] >= 1.0 )
        myPrivateData->graphRect = NSInsetRect( graphPaperRect, [ self axisInsetForAxis:kSM2DGraph_Axis_X ], [ self
                    axisInsetForAxis:kSM2DGraph_Axis_Y ] );
    else
        myPrivateData->graphRect = graphPaperRect;
}

- (void)_sm_drawGridInRect:(NSRect)inRect {
    [ [ self gridColor ] set ];
	
	NSRect paperRect = myPrivateData->graphPaperRect;

	double maxY = [ [ self dataSource ] twoDGraphView:self maximumValueForLineIndex:0 forAxis:kSM2DGraph_Axis_Y_Left ];
	
	double yStep = paperRect.size.height / maxY;

	NSPoint left = paperRect.origin;
	NSPoint right = paperRect.origin;
		right.x += inRect.size.width;
		
	NSDictionary* labelAttributes = [ NSDictionary dictionaryWithObjectsAndKeys:
		[ self gridColor ], NSForegroundColorAttributeName,
		nil
	];
	NSArray*	labels = [ NSArray arrayWithObjects:
		@"10",
		@"100",
		@"1K",
		@"10K",
		@"100K",
		@"1M",
		@"10M",
		@"100M",
		@"1G",
		@"10G",
		@"100G",
		nil
	];
	NSString* label = @"10";
	for( double i = 1.0; i < maxY; i += 1.0 ) {
		left.y += yStep;
		right.y += yStep;
		[[ labels objectAtIndex: (int) i - 1 ] drawAtPoint: left withAttributes: labelAttributes ];
		label = [ NSString stringWithFormat: @"%@0", label ];
		[ NSBezierPath strokeLineFromPoint: left toPoint: right ];
	} 
}

- (void)_sm_drawGridInRectOFF:(NSRect)inRect
{
    int				index, index2;
    NSPoint			fromPoint, toPoint, dataPoint;
    double			xScale = 1.0, yScale = 1.0;
    NSRect			graphRect, graphPaperRect;

    graphPaperRect = myPrivateData->graphPaperRect;
    graphRect = myPrivateData->graphRect;

    // Draw the grid (default is blue at half transparency).
    [ [ self gridColor ] set ];

    if ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] > 2 )
    {
        // Draw the vertical grid lines.
        dataPoint.x = graphRect.size.width / ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1 );
        xScale = dataPoint.x / (double)( [ self numberOfMinorTickMarksForAxis:kSM2DGraph_Axis_X ] + 1 );

        fromPoint.y = graphPaperRect.origin.y;
        toPoint.y = graphPaperRect.origin.y + graphPaperRect.size.height;
        if ( [ self borderColor ] != nil )
        {
            // Don't draw on top of the border.
            fromPoint.y++;
            toPoint.y--;
        }

        fromPoint.x = toPoint.x = graphRect.origin.x;
        if ( graphPaperRect.size.width > graphRect.size.width )
        {
            // Draw that first major line.
            [ NSBezierPath setDefaultLineWidth:1 ];
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }
        [ NSBezierPath setDefaultLineWidth:0.5 ];
        for ( index2 = 0; index2 < [ self numberOfMinorTickMarksForAxis:kSM2DGraph_Axis_X ]; index2++ )
        {
            fromPoint.x = toPoint.x += xScale;
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }
        for ( index = 1; index < ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_X ] - 1 ); index++ )
        {
            [ NSBezierPath setDefaultLineWidth:1 ];
            toPoint.x = fromPoint.x = graphRect.origin.x + ( index * dataPoint.x );
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
            [ NSBezierPath setDefaultLineWidth:0.5 ];
            for ( index2 = 0; index2 < [ self numberOfMinorTickMarksForAxis:kSM2DGraph_Axis_X ]; index2++ )
            {
                fromPoint.x = toPoint.x += xScale;
                [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
            }
        }

        if ( graphPaperRect.size.width > graphRect.size.width )
        {
            // Draw that last major line.
            [ NSBezierPath setDefaultLineWidth:1 ];
            toPoint.x = fromPoint.x = graphRect.origin.x + graphRect.size.width;
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }
    }

    if ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ] > 2 )
    {
        dataPoint.y = graphRect.size.height / ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ] - 1 );
        yScale = dataPoint.y / (double)( [ self numberOfMinorTickMarksForAxis:kSM2DGraph_Axis_Y ] + 1 );

        fromPoint.x = graphPaperRect.origin.x;
        toPoint.x = graphPaperRect.origin.x + graphPaperRect.size.width;
        if ( [ self borderColor ] != nil )
        {
            // Don't draw on top of the border.
            fromPoint.x++;
            toPoint.x--;
        }

        fromPoint.y = toPoint.y = graphRect.origin.y;
        if ( graphPaperRect.size.height > graphRect.size.height )
        {
            // Draw that first major line.
            [ NSBezierPath setDefaultLineWidth:1 ];
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }
        [ NSBezierPath setDefaultLineWidth:0.5 ];
        for ( index2 = 0; index2 < [ self numberOfMinorTickMarksForAxis:kSM2DGraph_Axis_Y ]; index2++ )
        {
            fromPoint.y = toPoint.y += yScale;
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }
        for ( index = 1; index < ( [ self numberOfTickMarksForAxis:kSM2DGraph_Axis_Y ] - 1 ); index++ )
        {
            [ NSBezierPath setDefaultLineWidth:1 ];
            toPoint.y = fromPoint.y = graphRect.origin.y + ( index * dataPoint.y );
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
            [ NSBezierPath setDefaultLineWidth:0.5 ];
            for ( index2 = 0; index2 < [ self numberOfMinorTickMarksForAxis:kSM2DGraph_Axis_Y ]; index2++ )
            {
                fromPoint.y = toPoint.y += yScale;
                [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
            }
        }
        if ( graphPaperRect.size.height > graphRect.size.height )
        {
            // Draw that last major line.
            [ NSBezierPath setDefaultLineWidth:1 ];
            toPoint.y = fromPoint.y = graphRect.origin.y + graphRect.size.height;
            [ NSBezierPath strokeLineFromPoint:fromPoint toPoint:toPoint ];
        }
    }

    [ NSBezierPath setDefaultLineWidth:1 ];
}

#if SM2D_USE_CORE_GRAPHICS
- (void)_sm_drawSymbol:(SM2DGraphSymbolTypeEnum)inSymbol onLine:(NSPoint *)inLine count:(int)inPointCount
            inColor:(NSColor *)inColor inRect:(NSRect)inRect
#else
- (void)_sm_drawSymbol:(SM2DGraphSymbolTypeEnum)inSymbol onLine:(NSBezierPath *)inLine inColor:(NSColor *)inColor
            inRect:(NSRect)inRect
#endif
{
    NSMutableDictionary	*coloredAttributes;
    NSString			*tempString;
    int					pointIndex;
    NSPoint				offset;
#if !SM2D_USE_CORE_GRAPHICS
    NSBezierPathElement	element;
    NSPoint				pointArray[ 3 ];
    int					pointCount;
#endif
    NSRect				drawRect;

    // Make sure it draws in the correct color.
    if ( nil != inColor )
    {
        coloredAttributes = [ [ myPrivateData->textAttributes mutableCopy ]
                    autorelease ];
        [ coloredAttributes setObject:inColor forKey:NSForegroundColorAttributeName ];
    }
    else
        coloredAttributes = myPrivateData->textAttributes;

    // Get the symbol (as text) and it's size.
    tempString = _sm_local_getSymbolForEnum( inSymbol );
    drawRect.size = [ tempString sizeWithAttributes:coloredAttributes ];
    offset.x = drawRect.size.width / 2;
    offset.y = drawRect.size.height / 2;

#if SM2D_USE_CORE_GRAPHICS
    for ( pointIndex = 0; pointIndex < inPointCount; pointIndex++ )
    {
        drawRect.origin.x = inLine[ pointIndex ].x - offset.x;
        drawRect.origin.y = inLine[ pointIndex ].y - offset.y;

        if ( NSIntersectsRect( inRect, drawRect ) )
            [ tempString drawInRect:drawRect withAttributes:coloredAttributes ];
    } // for all elements in inLine
#else
    pointCount = [ inLine elementCount ];
    for ( pointIndex = 0; pointIndex < pointCount; pointIndex++ )
    {
        element = [ inLine elementAtIndex:pointIndex associatedPoints:pointArray ];
        if ( element == NSMoveToBezierPathElement || element == NSLineToBezierPathElement )
        {
            drawRect.origin.x = pointArray[ 0 ].x - offset.x;
            drawRect.origin.y = pointArray[ 0 ].y - offset.y;

            if ( NSIntersectsRect( inRect, drawRect ) )
                [ tempString drawInRect:drawRect withAttributes:coloredAttributes ];
        }
    } // for all elements in inLine
#endif
}

- (NSImage*) colorizeImage: (NSImage*) image withColor: (NSColor*) color {
	NSSize	imageSize = [ image size ];
	NSRect	imageRect;
		imageRect.origin = NSZeroPoint;
		imageRect.size = imageSize;
	NSImage* resultImage = [ [ NSImage alloc ] initWithSize: imageSize ];
	[ resultImage lockFocus ];
		[ image compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:1.0 ];
		NSRectFillListWithColorsUsingOperation( &imageRect, &color, 1, NSCompositeSourceAtop );
	[ resultImage unlockFocus ];
	return resultImage;
}

#define _BAR_TOP_IMAGE_	@"bar-top-image"
#define	_PATTERN_IMAGE_	@"pattern-image"

- (void) _sm_setupVertBarAttributes: (NSMutableDictionary*) attributes {	
	NSColor*	barColor = [ attributes objectForKey: NSForegroundColorAttributeName ];
	barColor = [ barColor colorWithAlphaComponent:0.5 ];
	
	NSString*	barTopImageName = @"BarGraphTop.png";
    NSImage*	top = [ NSImage imageNamed: barTopImageName inBundleForClass:[ SM2DGraphView class ] ];
	
	top = [ self colorizeImage: top withColor: barColor ];
	
	[ attributes setObject: top forKey: _BAR_TOP_IMAGE_ ];
	
	NSString*	patternImageName = @"BarGraphPattern.png";
    NSImage*	pattern = [ NSImage imageNamed:patternImageName inBundleForClass:[ SM2DGraphView class ] ];
	
	pattern = [ self colorizeImage: pattern withColor: barColor ];
	
	[ attributes setObject: pattern forKey: _PATTERN_IMAGE_ ];	
}

- (void)_sm_drawVertBarFromPoint:(NSPoint)inFromPoint toPoint:(NSPoint)inToPoint barNumber:(int)inBarNumber
            of:(int)inBarCount withAttributes:(NSDictionary*) attributes
{
    NSImage		*pattern = [ attributes objectForKey: _PATTERN_IMAGE_ ];
    NSImage		*top = [ attributes objectForKey: _BAR_TOP_IMAGE_ ];
//    NSImage		*tempImage;
//    NSColor		*seeThroughColor = nil;
    NSRect		drawRect, fromRect;
    NSRect		tempDrawRect, tempFromRect;
    float		heightLeft;

//    if ( nil != inColor )
//        seeThroughColor = [ inColor colorWithAlphaComponent:0.5 ];

    drawRect.size.width = [ pattern size ].width;
    drawRect.origin.x = inFromPoint.x - ( drawRect.size.width / 2.0 );

    // Now offset the origin by the bar index.
    if ( inBarCount > 1 )
    {
        if ( inBarNumber < ( (float)inBarCount / 2.0 ) )
            drawRect.origin.x -= ( ( inBarCount / 2 ) - inBarNumber ) * drawRect.size.width;
        else
            drawRect.origin.x += ( inBarNumber - ( inBarCount / 2 ) ) * drawRect.size.width;
        if ( ( inBarCount % 2 ) == 0 )
            drawRect.origin.x -= drawRect.size.width / 2.0;
    }

    heightLeft = inToPoint.y - inFromPoint.y;

    drawRect.origin.y = floor( inToPoint.y + 0.5 );
    fromRect.origin = NSZeroPoint;

    if ( heightLeft > 0.0 )
    {
        // Draw the top first.
        fromRect.size = [ top size ];
        drawRect.size.height = fromRect.size.height;
        if ( floor( heightLeft + 0.5 ) > 1 )
        {
//            if ( nil != seeThroughColor )
//            {
//                // Colorize the top peice.
//                tempImage = [ [ NSImage alloc ] initWithSize:fromRect.size ];
//                [ tempImage lockFocus ];
//                [ top compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:1.0 ];
//                NSRectFillListWithColorsUsingOperation( &fromRect, &seeThroughColor, 1, NSCompositeSourceAtop );
//                [ tempImage unlockFocus ];
//
//                top = tempImage;
//            }

            if ( drawRect.size.height > heightLeft )
            {
                drawRect.size.height = floor( heightLeft + 0.5 );
                if ( drawRect.size.height < 1.0 )
                    drawRect.size.height = 1.0;		// Make sure we draw at least one pixel, or Cocoa may crash.
                fromRect.origin.y = fromRect.size.height - drawRect.size.height;
                fromRect.size.height = drawRect.size.height;
                drawRect.origin.y = inFromPoint.y;
            }
            else
                drawRect.origin.y -= drawRect.size.height;

            // Draw the top once.
            [ top drawInRect:drawRect fromRect:fromRect operation:NSCompositeSourceAtop fraction:1.0 ];
//            if ( nil != seeThroughColor )
//                [ top release ];

            heightLeft -= drawRect.size.height;
        }

        // Then draw the pattern.
        fromRect.size = [ pattern size ];
        fromRect.origin = NSZeroPoint;

        drawRect.size.height = fromRect.size.height;

//        if ( nil != seeThroughColor )
//        {
//            // Colorize the pattern.
//            tempImage = [ [ NSImage alloc ] initWithSize:fromRect.size ];
//            [ tempImage lockFocus ];
//            [ pattern compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:1.0 ];
//            NSRectFillListWithColorsUsingOperation( &fromRect, &seeThroughColor, 1, NSCompositeSourceAtop );
//            [ tempImage unlockFocus ];
//
//            pattern = tempImage;
//        }

        while ( drawRect.origin.y > inFromPoint.y )
        {
            // Keep drawing the pattern until we hit the bottom.
            if ( drawRect.size.height > heightLeft )
            {
                drawRect.size.height = floor( heightLeft + 0.5 );
                if ( drawRect.size.height < 1.0 )
                    drawRect.size.height = 1.0;		// Make sure we draw at least one pixel, or Cocoa may crash.
                fromRect.origin.y = fromRect.size.height - drawRect.size.height;
                fromRect.size.height = drawRect.size.height;
                drawRect.origin.y = inFromPoint.y;
            }
            else
                drawRect.origin.y -= drawRect.size.height;

            [ pattern drawInRect:drawRect fromRect:fromRect operation:NSCompositeSourceAtop fraction:1.0 ];

            heightLeft -= drawRect.size.height;
        }

//        if ( nil != seeThroughColor )
//            [ pattern release ];
    }
    else if ( heightLeft < 0.0 )
    {
        heightLeft = -heightLeft;

        // Draw the bottom first.
        fromRect.size = [ top size ];
        drawRect.size.height = fromRect.size.height;
        if ( floor( heightLeft + 0.5 ) > 1 )
        {
//            if ( nil != seeThroughColor )   {
//                // Colorize the bottom peice.
//                tempImage = [ [ NSImage alloc ] initWithSize:fromRect.size ];
//                [ tempImage lockFocus ];
//                [ top compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:1.0 ];
//                NSRectFillListWithColorsUsingOperation( &fromRect, &seeThroughColor, 1, NSCompositeSourceAtop );
//                [ tempImage unlockFocus ];
//
//                top = tempImage;
//            }

            if ( drawRect.size.height > heightLeft )
            {
                drawRect.size.height = floor( heightLeft + 0.5 );
                if ( drawRect.size.height < 1.0 )
                    drawRect.size.height = 1.0;		// Make sure we draw at least one pixel, or Cocoa may crash.
                fromRect.origin.y = fromRect.size.height - drawRect.size.height;
                fromRect.size.height = drawRect.size.height;
                drawRect.origin.y = inFromPoint.y - drawRect.size.height;
            }

            // Draw the bottom once.  Need to draw the bottom upside down.
            tempFromRect = fromRect;
            tempFromRect.size.height = 1.0;
            tempFromRect.origin.y = fromRect.origin.y + fromRect.size.height - 1.0;
            tempDrawRect = drawRect;
            tempDrawRect.size.height = 1.0;
            while ( drawRect.origin.y + drawRect.size.height > tempDrawRect.origin.y )
            {
                [ top drawInRect:tempDrawRect fromRect:tempFromRect operation:NSCompositeSourceAtop fraction:1.0 ];
                tempDrawRect.origin.y++;
                tempFromRect.origin.y--;
            }
//            if ( nil != seeThroughColor )
//                [ top release ];

            heightLeft -= drawRect.size.height;
        }

        // Then draw the pattern.
        fromRect.size = [ pattern size ];
        fromRect.origin = NSZeroPoint;

        // Adjust origin for the location of the first part of the pattern.
        drawRect.origin.y += drawRect.size.height - fromRect.size.height;
        drawRect.size.height = fromRect.size.height;

//        if ( nil != seeThroughColor )
//        {
//            // Colorize the pattern.
//            tempImage = [ [ NSImage alloc ] initWithSize:fromRect.size ];
//            [ tempImage lockFocus ];
//            [ pattern compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:1.0 ];
//            NSRectFillListWithColorsUsingOperation( &fromRect, &seeThroughColor, 1, NSCompositeSourceAtop );
//            [ tempImage unlockFocus ];
//
//            pattern = tempImage;
//        }

        while ( drawRect.origin.y + drawRect.size.height < inFromPoint.y )
        {
            // Keep drawing the pattern until we hit the bottom.
            if ( drawRect.size.height > heightLeft )
            {
                drawRect.size.height = floor( heightLeft + 0.5 );
                if ( drawRect.size.height < 1.0 )
                    drawRect.size.height = 1.0;		// Make sure we draw at least one pixel, or Cocoa may crash.
                fromRect.origin.y = fromRect.size.height - drawRect.size.height;
                fromRect.size.height = drawRect.size.height;
                drawRect.origin.y = inFromPoint.y - drawRect.size.height;
            }
            else
                drawRect.origin.y += drawRect.size.height;

            [ pattern drawInRect:drawRect fromRect:fromRect operation:NSCompositeCopy fraction:1.0 ];

            heightLeft -= drawRect.size.height;
        }

//        if ( nil != seeThroughColor )
//            [ pattern release ];
    }
}

#pragma mark -
#pragma mark ¥ LOCAL FUNCTIONS

static SM2DGraphAxisRecord *_sm_local_determineAxis( SM2DGraphAxisEnum inAxis, SM2DPrivateData *inPrivateData )
{
    SM2DGraphAxisRecord *result = nil;

    if ( inAxis == kSM2DGraph_Axis_X )
        result = &inPrivateData->xAxisInfo;
    else if ( inAxis == kSM2DGraph_Axis_Y_Right )
        result = &inPrivateData->yRightAxisInfo;
    else
        result = &inPrivateData->yAxisInfo;

    return result;
}

static NSString *_sm_local_getSymbolForEnum( SM2DGraphSymbolTypeEnum inValue )
{
    NSString	*result = nil;

    switch ( inValue )
    {
    default:
    case kSM2DGraph_Symbol_None:
        // Nothing.
        break;
    case kSM2DGraph_Symbol_Triangle:
        result = NSLocalizedStringFromTableInBundle( @"com_snowmint_sm2dgraphview_triangle", @"InfoPlist",
					[ NSBundle bundleForClass:[ SM2DGraphView class ] ], nil );
        // result = @"Æ";
        break;
    case kSM2DGraph_Symbol_Diamond:
        result = NSLocalizedStringFromTableInBundle( @"com_snowmint_sm2dgraphview_diamond", @"InfoPlist",
					[ NSBundle bundleForClass:[ SM2DGraphView class ] ], nil );
		// result = @"×";
        break;
    case kSM2DGraph_Symbol_Circle:
        result = @"o";
        break;
    case kSM2DGraph_Symbol_X:
        result = @"x";
        break;
    case kSM2DGraph_Symbol_Plus:
        result = @"+";
        break;
    case kSM2DGraph_Symbol_FilledCircle:
        result = NSLocalizedStringFromTableInBundle( @"com_snowmint_sm2dgraphview_filledcircle", @"InfoPlist",
					[ NSBundle bundleForClass:[ SM2DGraphView class ] ], nil );
        // result = @"¥";
        break;
/*    case kSM2DGraph_Symbol_Square:
        break;
    case kSM2DGraph_Symbol_Star:
        break;
    case kSM2DGraph_Symbol_InvertedTriangle:
        break;
    case kSM2DGraph_Symbol_FilledSquare:
        break;
    case kSM2DGraph_Symbol_FilledTriangle:
        break;
    case kSM2DGraph_Symbol_FilledDiamond:
        break;
    case kSM2DGraph_Symbol_FilledInvertedTriangle:
        break;*/
    }

    return result;
}

static NSDictionary *_sm_local_defaultLineAttributes( unsigned int inLineIndex )
{
    NSColor		*tempColor;

    switch ( inLineIndex % 7 )
    {
    default:
    case 0:		tempColor = [ NSColor blackColor ];		break;
    case 1:		tempColor = [ NSColor redColor ];		break;
    case 2:		tempColor = [ NSColor greenColor ];		break;
    case 3:		tempColor = [ NSColor blueColor ];		break;
    case 4:		tempColor = [ NSColor yellowColor ];	break;
    case 5:		tempColor = [ NSColor cyanColor ];		break;
    case 6:		tempColor = [ NSColor magentaColor ];	break;
    }

    return [ NSDictionary dictionaryWithObject:tempColor forKey:NSForegroundColorAttributeName ];
}

static NSString *kSM2DGraph_Key_Label = @"Label";
static NSString *kSM2DGraph_Key_ScaleType = @"Scale";
static NSString *kSM2DGraph_Key_NumberOfTicks = @"Ticks";
static NSString *kSM2DGraph_Key_NumberOfMinorTicks = @"MinorTicks";
static NSString *kSM2DGraph_Key_Inset = @"Inset";
static NSString *kSM2DGraph_Key_DrawLineAtZero = @"DrawLineAtZero";
static NSString *kSM2DGraph_Key_TickMarkPosition = @"TickMarkPosition";

static NSDictionary *_sm_local_encodeAxisInfo( SM2DGraphAxisRecord *inAxis )
{
    NSMutableDictionary	*result = [ NSMutableDictionary dictionaryWithCapacity:7 ];

    if ( nil != inAxis->label )
        if ( 0 != [ inAxis->label length ] )
            [ result setObject:inAxis->label forKey:kSM2DGraph_Key_Label ];

    [ result setObject:[ NSNumber numberWithInt:inAxis->scaleType ] forKey:kSM2DGraph_Key_ScaleType ];
    [ result setObject:[ NSNumber numberWithInt:inAxis->numberOfTickMarks ] forKey:kSM2DGraph_Key_NumberOfTicks ];
    [ result setObject:[ NSNumber numberWithInt:inAxis->numberOfMinorTickMarks ] forKey:kSM2DGraph_Key_NumberOfMinorTicks ];
    [ result setObject:[ NSNumber numberWithDouble:inAxis->inset ] forKey:kSM2DGraph_Key_Inset ];
    [ result setObject:[ NSNumber numberWithBool:inAxis->drawLineAtZero ] forKey:kSM2DGraph_Key_DrawLineAtZero ];
    [ result setObject:[ NSNumber numberWithInt:inAxis->tickMarkPosition ] forKey:kSM2DGraph_Key_TickMarkPosition ];

    return [ [ result copy ] autorelease ];
}

static void _sm_local_decodeAxisInfo( NSDictionary *inInfo, SM2DGraphAxisRecord *outAxis )
{
    if ( nil != inInfo && nil != outAxis )
    {
        outAxis->label = [ [ inInfo objectForKey:kSM2DGraph_Key_Label ] retain ];
        outAxis->scaleType = [ [ inInfo objectForKey:kSM2DGraph_Key_ScaleType ] intValue ];
        outAxis->numberOfTickMarks = [ [ inInfo objectForKey:kSM2DGraph_Key_NumberOfTicks ] intValue ];
        outAxis->numberOfMinorTickMarks = [ [ inInfo objectForKey:kSM2DGraph_Key_NumberOfMinorTicks ] intValue ];
        outAxis->inset = [ [ inInfo objectForKey:kSM2DGraph_Key_Inset ] doubleValue ];
        outAxis->drawLineAtZero = [ [ inInfo objectForKey:kSM2DGraph_Key_DrawLineAtZero ] boolValue ];
        outAxis->tickMarkPosition = [ [ inInfo objectForKey:kSM2DGraph_Key_TickMarkPosition ] boolValue ];
    }
}

#pragma mark -
#pragma mark ¥ ALTIVEC IMPLEMENTATION

#if __ppc__

static BOOL _sm_local_isAltiVecPresent( void )
{
    long	cpuAttributes;
    BOOL	result = NO;
    OSErr	err;

	// First, check that we're greater than a G3 processor.
	// This is needed because some old processors return unreliable results from
	// the gestaltPowerPCProcessorFeatures check.
	err = Gestalt( gestaltNativeCPUtype, &cpuAttributes );
	if ( noErr == err && cpuAttributes > gestaltCPU750 )
	{
		// Now check to see if we have AltiVec.
		err = Gestalt( gestaltPowerPCProcessorFeatures, &cpuAttributes );
		if ( noErr == err )
			result = ( 0 != ( ( 1 << gestaltPowerPCHasVectorInstructions ) & cpuAttributes ) );
	}

    return result;
}

static vector float vecFromFloats( float a, float b, float c, float d )
{
   vector float		returnme;
   float			*returnme_ptr; 

   returnme_ptr = (float *)&returnme;

   returnme_ptr[ 0 ] = a;
   returnme_ptr[ 1 ] = b; 
   returnme_ptr[ 2 ] = c; 
   returnme_ptr[ 3 ] = d; 

   return returnme; 
}

static void _sm_local_scaleDataUsingVelocityEngine( NSPoint *ioPoints, unsigned long inDataCount,
                                float minX, float xScale, float xOrigin,
                                float minY, float yScale, float yOrigin )
{
    vector float    *pointsPtr, *endPtr;

    // Set up the vectors for the minimum, scale, and origin.
    // Note: each NSPoint is an X and Y float.  There are two NSPoints within each vector.
    // The even indices of the 4 floats are the X coordinates and the odd indices are the Y coordinates.
    vector float    minimumVec = vecFromFloats( minX, minY, minX, minY );
	vector float	scaleVec = vecFromFloats( xScale, yScale, xScale, yScale );
	vector float	originVec = vecFromFloats( xOrigin, yOrigin, xOrigin, yOrigin );

	// Point at the beginning of the data.
    pointsPtr = (vector float *)ioPoints;
    // Velocity Engine does 4 floats at a time, and each NSPoint is 2 floats.
    // Thus we can go through two points per loop.
    endPtr = &pointsPtr[ inDataCount / 2 ];

    while ( pointsPtr != endPtr )
    {
        // First, subtract the minimum values.
        // Next, multiply by the scale and add the origin (ALL IN ONE INSTRUCTION!).
        // That's the finished point.
        *pointsPtr = vec_madd( vec_sub( *pointsPtr, minimumVec ), scaleVec, originVec );

        pointsPtr++;    // Work on the next set of four floats.
    }

    // We may have a number of points not divisible by 2.
    if ( 0 != ( inDataCount % 2 ) )
    {
        // Do the last point using the normal CPU.
        ioPoints[ inDataCount - 1 ].x = ( ioPoints[ inDataCount - 1 ].x - minX ) * xScale + xOrigin;
        ioPoints[ inDataCount - 1 ].y = ( ioPoints[ inDataCount - 1 ].y - minY ) * yScale + yOrigin;
    }
}

#endif // __ppc__

@end
