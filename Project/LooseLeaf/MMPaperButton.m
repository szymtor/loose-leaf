//
//  MMPaperButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"


@implementation MMPaperButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    CGRect frame = [self drawableFrame];

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];

    //// Page Corner Drawing
    UIBezierPath* pageCornerPath = [UIBezierPath bezierPath];
    [pageCornerPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [pageCornerPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.67 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37 * CGRectGetHeight(frame))];
    [pageCornerPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37 * CGRectGetHeight(frame))];
    [pageCornerPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.56 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26 * CGRectGetHeight(frame))];
    [pageCornerPath closePath];
    [halfGreyFill setFill];
    [pageCornerPath fill];


    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [ovalPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.71 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.31 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21 * CGRectGetHeight(frame))];
    [ovalPath closePath];

    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    [halfGreyFill setFill];
    [ovalPath fill];
}


@end
