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

#import <Cocoa/Cocoa.h>

#import <QuartzCore/CoreImage.h>// needed for Core Image


@interface HHRoundedBox : NSBox
{
	CGFloat _borderWidth;
	CGFloat _borderRadius;
	NSColor *_borderColor;
	NSColor *_titleColor;
	NSColor *_gradientStartColor;
	NSColor *_gradientEndColor;
	NSColor *_backgroundColor;
	BOOL	_drawsFullTitleBar;
	BOOL	_selected;
	BOOL	_drawsGradientBackground;
    BOOL    _drawsTitle;
	CGFloat _noiseOpacity;

	CIColor *_gradientStartCIColor;
	CIColor *_gradientEndCIColor;
	NSRect	_titlePathRect;
}

@property (nonatomic, assign) BOOL		drawsTitle;
@property (nonatomic, assign) BOOL		drawsFullTitleBar;
@property (nonatomic, assign) BOOL		selected;
@property (nonatomic, assign) CGFloat	borderWidth;
@property (nonatomic, assign) CGFloat	borderRadius;
@property (nonatomic, retain) NSColor	*borderColor;
@property (nonatomic, retain) NSColor	*titleColor;
@property (nonatomic, retain) NSColor	*gradientStartColor;
@property (nonatomic, retain) NSColor	*gradientEndColor;
@property (nonatomic, retain) NSColor	*backgroundColor;
@property (nonatomic, assign) BOOL		drawsGradientBackground;
@property (nonatomic, assign) CGFloat	noiseOpacity;

@end
