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

// For the image to actually appear when you draw the NSAttributedString,
// you MUST call +drawImages AFTER creating the frame but BEFORE actually
// drawing the frame (since drawing invalidates the frame).
+ (void)drawImagesForFrame:(CTFrameRef)frame fromAttributedString:(NSAttributedString *)string;

@end
