//
//  HHRoundedBox
//
//  Updated by Pierre Bernard on 04/09/2013
//  Copyright 2013 Pierre Bernard (http://www.bernard-web.com/pierre), Blake Seely and Matt Gemmell (see below)
//  Permissions and License are the same as below, but please include credit to me (Pierre Bernard) as well as Blake and Matt
//
//
//  BSRoundedBox
//
//  Updated by Blake Seely on 01/05/2006
//  Copyright 2006 Blake Seely (http://www.blakeseely.com) and Matt Gemmell (see below)
//  Permissions and License are the same as below, but please include credit to me (Blake Seely) as well as Matt.
//
//
//  RoundedBox
//
//  Created by Matt Gemmell on 01/11/2005.
//  Copyright 2006 Matt Gemmell. http://mattgemmell.com/
//
//  Permission to use this code:
//
//  Feel free to use this code in your software, either as-is or
//  in a modified form. Either way, please include a credit in
//  your software's "About" box or similar, mentioning at least
//  my name (Matt Gemmell). A link to my site would be nice too.
//
//  Permission to redistribute this code:
//
//  You can redistribute this code, as long as you keep these
//  comments. You can also redistribute modified versions of the
//  code, as long as you add comments to say that you've made
//  modifications (keeping these original comments too).
//
//  If you do use or redistribute this code, an email would be
//  appreciated, just to let me know that people are finding my
//  code useful. You can reach me at matt.gemmell@gmail.com
//

#import "HHRoundedBox.h"

#import "KGNoise.h"


#define MG_TITLE_INSET 3.0


@interface HHRoundedBox ()

@property (nonatomic, retain) CIColor	*gradientStartCIColor;
@property (nonatomic, retain) CIColor	*gradientEndCIColor;

@property (nonatomic, assign) NSRect titlePathRect;

- (NSBezierPath *)titlePathWithinRect:(NSRect)rect cornerRadius:(float)radius titleRect:(NSRect)titleRect;

@end


@implementation HHRoundedBox

#pragma mark -
#pragma mark Initialization

+ (void)initialize
{
	[self exposeBinding:@"borderWidth"];
	[self exposeBinding:@"borderRadius"];
	[self exposeBinding:@"borderColor"];
	[self exposeBinding:@"titleColor"];
	[self exposeBinding:@"gradientStartColor"];
	[self exposeBinding:@"gradientEndColor"];
	[self exposeBinding:@"backgroundColor"];
	[self exposeBinding:@"drawsFullTitleBar"];
    [self exposeBinding:@"drawsTitle"];
	[self exposeBinding:@"selected"];
	[self exposeBinding:@"drawsGradientBackground"];
	[self exposeBinding:@"noiseOpacity"];
}

static void commonInit(HHRoundedBox *roundedBox)
{
	[[roundedBox titleCell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[[roundedBox titleCell] setEditable:YES];

	[roundedBox setTitleFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];

	[roundedBox setBorderWidth:2.0f];
	[roundedBox setBorderRadius:4.0f];
	[roundedBox setBorderColor:[NSColor grayColor]];
	[roundedBox setTitleColor:[NSColor whiteColor]];
	[roundedBox setGradientStartColor:[NSColor colorWithCalibratedWhite:0.92 alpha:1.0]];
	[roundedBox setGradientEndColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]];
	[roundedBox setBackgroundColor:[NSColor colorWithCalibratedWhite:0.90 alpha:1.0]];
    [roundedBox setDrawsTitle:YES];
	[roundedBox setDrawsFullTitleBar:NO];
	[roundedBox setSelected:NO];
	[roundedBox setDrawsGradientBackground:YES];
	[roundedBox setNoiseOpacity:0.0f];
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		commonInit(self);
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];

	if (self) {
		commonInit(self);
	}

	return self;
}

#pragma mark -
#pragma mark Finalization

- (void)dealloc
{
	[_borderColor release], _borderColor	= nil;
	[_titleColor release], _titleColor		= nil;
	[_gradientStartColor release], _gradientStartColor	= nil;
	[_gradientEndColor release], _gradientEndColor		= nil;
	[_backgroundColor release], _backgroundColor		= nil;

	[_gradientStartCIColor release], _gradientStartCIColor	= nil;
	[_gradientEndCIColor release], _gradientEndCIColor		= nil;

	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Construct rounded rect path
	NSRect	boxRect		= [self bounds];
	CGFloat borderWidth = [self borderWidth];
	NSRect	bgRect		= NSInsetRect(boxRect, borderWidth / 2.0, borderWidth / 2.0);

	CGFloat			minX			= NSMinX(bgRect);
	CGFloat			midX			= NSMidX(bgRect);
	CGFloat			maxX			= NSMaxX(bgRect);
	CGFloat			minY			= NSMinY(bgRect);
	CGFloat			midY			= NSMidY(bgRect);
	CGFloat			maxY			= NSMaxY(bgRect);
	CGFloat			borderRadius	= [self borderRadius];
	NSBezierPath	*bgPath			= [NSBezierPath bezierPath];

	// Bottom edge and bottom-right curve
	[bgPath moveToPoint:NSMakePoint(midX, minY)];
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
									 toPoint:NSMakePoint(maxX, midY)
									  radius:borderRadius];

	// Right edge and top-right curve
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY)
									 toPoint:NSMakePoint(midX, maxY)
									  radius:borderRadius];

	// Top edge and top-left curve
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY)
									 toPoint:NSMakePoint(minX, midY)
									  radius:borderRadius];

	// Left edge and bottom-left curve
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY)
									 toPoint:NSMakePoint(midX, minY)
									  radius:borderRadius];
	[bgPath closePath];

	// Draw background

	if ([self drawsGradientBackground]) {
		// Draw gradient background using Core Image
		CIColor *startColor = [self gradientStartCIColor];
		CIColor *endColor	= [self gradientEndCIColor];

		CIFilter *ciFilter = [CIFilter filterWithName:@"CILinearGradient"];

		[ciFilter setDefaults];
		[ciFilter setValue:[CIVector vectorWithX:minX Y:minY] forKey:@"inputPoint0"];
		[ciFilter setValue:[CIVector vectorWithX:maxX Y:maxY] forKey:@"inputPoint1"];
		[ciFilter setValue:startColor forKey:@"inputColor0"];
		[ciFilter setValue:endColor forKey:@"inputColor1"];

		CIImage *ciImage = [ciFilter valueForKey:@"outputImage"];

		// Get a CIContext from the NSGraphicsContext, and use it to draw the CIImage
		CGRect	srcRect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
		CGRect	dstRect = CGRectMake(0.0f, 0.0f, maxX, maxY);

		NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];

		[nsContext saveGraphicsState];

		[bgPath addClip];

		[[nsContext CIContext] drawImage:ciImage
								  inRect:dstRect
								fromRect:srcRect];

		[nsContext restoreGraphicsState];
	}
	else {
		// Draw solid color background
		[[self backgroundColor] set];
		[bgPath fill];
	}

	CGFloat noiseOpacity = [self noiseOpacity];

	if (noiseOpacity > 0.0f) {
		[KGNoise drawNoiseWithOpacity:noiseOpacity];
	}

	// Create drawing rectangle for title
	float	titleHInset = borderWidth + MG_TITLE_INSET + 1.0;
	float	titleVInset = borderWidth;

	NSSize	titleSize	= [[self titleCell] cellSizeForBounds:boxRect];
	NSRect	titleRect	= NSMakeRect(boxRect.origin.x + titleHInset,
									 boxRect.origin.y + boxRect.size.height - titleSize.height - (titleVInset * 2.0),
									 titleSize.width + (borderWidth * 2.0),
									 titleSize.height);

	if ([self selected]) {
		[[NSColor alternateSelectedControlColor] set];
		// We use the alternate (darker) selectedControlColor since the regular one is too light.
		// The alternate one is the highlight color for NSTableView, NSOutlineView, etc.
		// This mimics how Automator highlights the selected action in a workflow.
	}
	else {
		NSColor *borderColor = [self borderColor];

		[borderColor set];
	}

    if (self.drawsTitle)
    {
        // Draw title background
        NSBezierPath *titlePath = [self titlePathWithinRect:bgRect cornerRadius:borderRadius titleRect:titleRect];
        [titlePath fill];
        
        [self setTitlePathRect:[titlePath bounds]];
    }


	// Draw rounded rect around entire box
	if (borderWidth > 0.0) {
		[bgPath setLineWidth:borderWidth];
		[bgPath stroke];
	}

    if (self.drawsTitle)
    {
        // Draw title text using the titleCell
        [[self titleCell] drawInteriorWithFrame:titleRect inView:self];
    }
}

- (NSBezierPath *)titlePathWithinRect:(NSRect)rect cornerRadius:(float)radius titleRect:(NSRect)titleRect
{
	// Construct rounded rect path

	NSRect	bgRect	= rect;
	int		minX	= NSMinX(bgRect);
	int		maxX	= minX + titleRect.size.width + ((titleRect.origin.x - rect.origin.x) * 2.0);
	int		maxY	= NSMaxY(bgRect);
	int		minY	= NSMinY(titleRect) - (maxY - (titleRect.origin.y + titleRect.size.height));
	float	titleExpansionThreshold = 20.0;
	// i.e. if there's less than 20px space to the right of the short titlebar, just draw the full one.

	NSBezierPath *path = [NSBezierPath bezierPath];

	[path moveToPoint:NSMakePoint(minX, minY)];

	if ((bgRect.size.width - titleRect.size.width >= titleExpansionThreshold) && ![self drawsFullTitleBar]) {
		// Draw a short titlebar
		[path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
									   toPoint:NSMakePoint(maxX, maxY)
										radius:radius];
		[path lineToPoint:NSMakePoint(maxX, maxY)];
	}
	else {
		// Draw full titlebar, since we're either set to always do so, or we don't have room for a short one.
		[path lineToPoint:NSMakePoint(NSMaxX(bgRect), minY)];
		[path appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bgRect), maxY)
									   toPoint:NSMakePoint(NSMaxX(bgRect) - (bgRect.size.width / 2.0), maxY)
										radius:radius];
	}

	[path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY)
								   toPoint:NSMakePoint(minX, minY)
									radius:radius];

	[path closePath];

	return path;
}

#pragma mark -
#pragma mark Accessors

@synthesize titlePathRect = _titlePathRect;

@synthesize drawsFullTitleBar = _drawsFullTitleBar;

- (void)setDrawsFullTitleBar:(BOOL)drawsFullTitleBar
{
	_drawsFullTitleBar = drawsFullTitleBar;
	[self setNeedsDisplay:YES];
}

@synthesize selected = _selected;

- (void)setSelected:(BOOL)selected
{
	_selected = selected;
	[self setNeedsDisplay:YES];
}

@synthesize borderWidth = _borderWidth;

- (void)setBorderWidth:(CGFloat)borderWidth
{
	_borderWidth = borderWidth;
	[self setNeedsDisplay:YES];
}

@synthesize borderRadius = _borderRadius;

- (void)setBorderRadius:(CGFloat)borderRadius
{
	_borderRadius = borderRadius;
	[self setNeedsDisplay:YES];
}

@synthesize borderColor = _borderColor;

- (void)setBorderColor:(NSColor *)borderColor
{
	[borderColor retain];
	[_borderColor release];
	_borderColor = borderColor;
	[self setNeedsDisplay:YES];
}

@synthesize titleColor = _titleColor;

- (void)setTitleColor:(NSColor *)titleColor
{
	[[self titleCell] setTextColor:titleColor];
	[self setNeedsDisplay:YES];
}

@synthesize gradientStartColor = _gradientStartColor;

- (void)setGradientStartColor:(NSColor *)gradientStartColor
{
	// Must ensure gradient colors are in NSCalibratedRGBColorSpace, or Core Image gets angry.
	NSColor *calibratedGradientStartColor = [gradientStartColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	[calibratedGradientStartColor retain];
	[_gradientStartColor release];
	_gradientStartColor = calibratedGradientStartColor;

	if (calibratedGradientStartColor != nil) {
		[self setGradientStartCIColor:[[[CIColor alloc] initWithColor:calibratedGradientStartColor] autorelease]];
	}
	else {
		[self setGradientStartCIColor:nil];
	}

	if ([self drawsGradientBackground]) {
		[self setNeedsDisplay:YES];
	}
}

@synthesize gradientEndColor = _gradientEndColor;

- (void)setGradientEndColor:(NSColor *)gradientEndColor
{
	// Must ensure gradient colors are in NSCalibratedRGBColorSpace, or Core Image gets angry.
	NSColor *calibratedGradientEndColor = [gradientEndColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	[calibratedGradientEndColor retain];
	[_gradientEndColor release];
	_gradientEndColor = calibratedGradientEndColor;

	if (calibratedGradientEndColor != nil) {
		[self setGradientEndCIColor:[[[CIColor alloc] initWithColor:calibratedGradientEndColor] autorelease]];
	}
	else {
		[self setGradientEndCIColor:nil];
	}
}

@synthesize gradientStartCIColor = _gradientStartCIColor;

- (void)setGradientStartCIColor:(CIColor *)gradientStartCIColor
{
	[gradientStartCIColor retain];
	[_gradientStartCIColor release];
	_gradientStartCIColor = gradientStartCIColor;

	if ([self drawsGradientBackground]) {
		[self setNeedsDisplay:YES];
	}
}

@synthesize gradientEndCIColor = _gradientEndCIColor;

- (void)setGradientEndCIColor:(CIColor *)gradientEndCIColor
{
	[gradientEndCIColor retain];
	[_gradientEndCIColor release];
	_gradientEndCIColor = gradientEndCIColor;

	if ([self drawsGradientBackground]) {
		[self setNeedsDisplay:YES];
	}
}

@synthesize backgroundColor = _backgroundColor;

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
	[backgroundColor retain];
	[_backgroundColor release];
	_backgroundColor = backgroundColor;

	if (![self drawsGradientBackground]) {
		[self setNeedsDisplay:YES];
	}
}

@synthesize noiseOpacity = _noiseOpacity;

- (void)setNoiseOpacity:(CGFloat)noiseOpacity
{
	_noiseOpacity = noiseOpacity;
	[self setNeedsDisplay:YES];
}

@synthesize drawsGradientBackground = _drawsGradientBackground;

- (void)setDrawsGradientBackground:(BOOL)drawsGradientBackground
{
	_drawsGradientBackground = drawsGradientBackground;
	[self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Overrides

- (void)setTitle:(NSString *)title
{
	[super setTitle:title];
	[self setNeedsDisplay:YES];
}

- (BOOL)preservesContentDuringLiveResize
{
	// NSBox returns YES for this, but doing so would screw up the gradients.
	return NO;
}

@end
