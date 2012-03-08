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
    NSDictionary *attribs = [NSDictionary dictionaryWithObject:(id)runDelegate forKey:(id)kCTRunDelegateAttributeName];
    NSAttributedString *r = [[[NSAttributedString alloc] initWithString:@"\uFFFC" attributes:attribs] autorelease];
    CFRelease(runDelegate);
    return r;
    
}

+ (void)drawImagesForFrame:(CTFrameRef)frame fromAttributedString:(NSAttributedString *)string {
    /*CGRect rect = CGPathGetBoundingBox(CTFrameGetPath(frame));
    [string enumerateAttribute:(id)kCTRunDelegateAttributeName 
                       inRange:NSMakeRange(0, [string length]) 
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        UIImage *image = (UIImage *) CTRunDelegateGetRefCon((CTRunDelegateRef)value);
                        // Attempt to get the offset for this range in the string.
                        CFArrayRef lines = CTFrameGetLines(frame);
                        
                        CGFloat xOffset = 0.0f;
                        CGFloat yOffset = 0.0f;
                        
                        for (CFIndex i = 0; i < CFArrayGetCount(lines); i++) {
                            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                            CFRange r = CTLineGetStringRange(line);
                            int localIndex = range.location - r.location;
                            if (localIndex >= 0 && localIndex < r.length) {
                                xOffset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                                CGPoint lineOrigin;
                                CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &lineOrigin);
                                // Flip coordinate system from CoreText's 0-on-bottom to
                                // UIKit's 0-on-top. This assumes you're flipping the context
                                // when you draw the CoreText frame.
                                yOffset = height - lineOrigin.y;
                                break;
                            }
                        }
                        [image drawAtPoint:CGPointMake(rect.origin.x + xOffset, rect.origin.y + yOffset - [image size].height + 2.0f)];
                    }];*/
// TODO incomplete
// TODO use separate attr for image to prevent crashing on other run delegates
}

@end
