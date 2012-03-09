//
//  AEImageAttributedString.m
//  TransitMaps
//
//  Created by Adam Ernst on 3/7/12.
//  Copyright (c) 2012 cosmicsoft. All rights reserved.
//

#import "AEImageAttributedString.h"

void AEImageAttributedStringRunDelegateDeallocationCallback(void *refCon) {
    [(id)refCon release];
}

CGFloat AEImageAttributedStringRunDelegateAscentCallback(void *refCon) {
    return [(UIImage *)refCon size].height - 4.0f; // Let image extend past the ascender a bit
}

CGFloat AEImageAttributedStringRunDelegateDescentCallback(void *refCon) {
    return 0.0f;
}

CGFloat AEImageAttributedStringRunDelegateWidthCallback(void *refCon) {
    return [(UIImage *)refCon size].width;
}

static NSString *kAEImageAttributeName = @"kAEImageAttributeName";

@implementation AEImageAttributedString

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image {
    const CTRunDelegateCallbacks callbacks = {
        .version = kCTRunDelegateVersion1,
        .dealloc = AEImageAttributedStringRunDelegateDeallocationCallback,
        .getAscent = AEImageAttributedStringRunDelegateAscentCallback,
        .getDescent = AEImageAttributedStringRunDelegateDescentCallback,
        .getWidth = AEImageAttributedStringRunDelegateWidthCallback,
    };
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, [image retain]);
    NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:
                             (id)runDelegate, (id)kCTRunDelegateAttributeName,
                             image, kAEImageAttributeName, nil];
    NSAttributedString *r = [[[NSAttributedString alloc] initWithString:@"\uFFFC" attributes:attribs] autorelease];
    CFRelease(runDelegate);
    return r;
}

+ (CGSize)sizeForAttributedString:(NSAttributedString *)str constrainedToSize:(CGSize)dimensions {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)str);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, dimensions, NULL);
    CFRelease(framesetter);
    return suggestedSize;
}

+ (void)drawAttributedString:(NSAttributedString *)str inRect:(CGRect)rect {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)str);
    [AEImageAttributedString drawAttributedString:str framesetter:framesetter inRect:rect];
    CFRelease(framesetter);
}

+ (void)drawAttributedString:(NSAttributedString *)str framesetter:(CTFramesetterRef)framesetter inRect:(CGRect)rect {
    CGRect zeroYRect = rect;
    zeroYRect.origin.y = 0.0f;
    CGPathRef path = CGPathCreateWithRect(zeroYRect, NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(c, CGAffineTransformIdentity);
    CGContextSaveGState(c);
    // Flip the CTM for iOS style top-left origin.
    CGContextConcatCTM(c, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, rect.origin.y + rect.size.height));
    [AEImageAttributedString drawImagesForFrame:frame fromAttributedString:str];
    CTFrameDraw(frame, c);
    CGContextRestoreGState(c);
    
    CFRelease(frame);
}

+ (void)drawImagesForFrame:(CTFrameRef)frame fromAttributedString:(NSAttributedString *)string {
    CGRect rect = CGPathGetBoundingBox(CTFrameGetPath(frame));
    CFArrayRef lines = CTFrameGetLines(frame);
    
    // Flip the CTM. We assume that the CTM is *currently* the Core Text/Mac 
    // style, with the origin in bottom left. UIImage uses a top left origin.
    // If we don't flip the CTM, images will be drawn upside down.
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    CGContextConcatCTM(c, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, rect.origin.y + rect.size.height));
    
    [string enumerateAttribute:(id)kAEImageAttributeName 
                       inRange:NSMakeRange(0, [string length]) 
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        UIImage *image = (UIImage *) value;
                        
                        CGFloat x = 0.0f;
                        CGFloat y = 0.0f;
                        
                        for (CFIndex i = 0; i < CFArrayGetCount(lines); i++) {
                            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                            CFRange r = CTLineGetStringRange(line);
                            int localIndex = range.location - r.location;
                            if (localIndex >= 0 && localIndex < r.length) {
                                x = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                                CGPoint lineOrigin;
                                CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &lineOrigin);
                                y = lineOrigin.y;
                                break;
                            }
                        }
                        [image drawAtPoint:CGPointMake(rect.origin.x + x, rect.size.height - y - [image size].height + 2.0f)];
                    }];
    
    CGContextRestoreGState(c);
}

@end
