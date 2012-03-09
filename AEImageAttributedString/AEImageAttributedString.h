//
//  AEImageAttributedString.h
//  TransitMaps
//
//  Created by Adam Ernst on 3/7/12.
//  Copyright (c) 2012 cosmicsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface AEImageAttributedString : NSObject

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image;

// If you don't want to mess with Core Text, here are two convenience methods.
//   - They use UIGraphicsGetCurrentContext() to get the context to draw in
//   - They assume you're using flipped UIKit coordinates (the default).
//   - +drawAttributedString:inRect: calls +drawImagesForFrame:fromAttributedString:
//     for you.
+ (CGSize)sizeForAttributedString:(NSAttributedString *)str constrainedToSize:(CGSize)dimensions;
+ (void)drawAttributedString:(NSAttributedString *)str inRect:(CGRect)rect;

// Calling sizeForAttributedString followed by drawAttributedString is somewhat
// wasteful; it creates a framesetter twice. If you want to be more efficient:
//   1. Create the framesetter yourself with CTFramesetterCreateWithAttributedString
//   2. Get the ideal size from CTFramesetterSuggestFrameSizeWithConstraints
//      (sizeForAttributedString just wraps this function)
//   3. Call drawAttributedString:framesetter:inRect: to do the actual drawing.
//      (The NSAttributedString is only needed for drawImagesForFrame:.)
+ (void)drawAttributedString:(NSAttributedString *)str framesetter:(CTFramesetterRef)framesetter inRect:(CGRect)rect;

// If you ARE using Core Text directly, for the image to actually appear when
// you draw the NSAttributedString, you MUST call 
// +drawImagesForFrame:fromAttributedString: AFTER creating the frame but 
// BEFORE actually drawing the frame (since drawing invalidates the frame).
+ (void)drawImagesForFrame:(CTFrameRef)frame fromAttributedString:(NSAttributedString *)string;

@end
