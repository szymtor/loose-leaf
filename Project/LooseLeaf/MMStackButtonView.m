//
//  MMStackButtonView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackButtonView.h"
#import "MMSingleStackManager.h"
#import "MMAllStacksManager.h"
#import "MMTextButton.h"
#import "NSArray+Extras.h"
#import <JotUI/UIImage+Alpha.h>

static UIImage* whiteThumb;
static UIImage* missingThumb;

@implementation MMStackButtonView{
    NSString* stackUUID;
    CGAffineTransform page1Transform;
    UIImageView* page1Thumbnail;
    UIImageView* page2Thumbnail;
    UIImageView* page3Thumbnail;
    UIButton* stackButton;
    UIButton* nameButton;
}

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)_stackUUID{
    if(self = [super initWithFrame:frame]){

        [self clipsToBounds];
        
        stackUUID = _stackUUID;
        
        CGFloat stackIconHeight = 220;
        CGFloat thumbOffset = 10;
        
        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
        CGFloat scale = stackIconHeight / CGRectGetHeight(screenBounds);
        CGRect thumbFrame = CGRectApplyAffineTransform(screenBounds, CGAffineTransformMakeScale(scale, scale));
        thumbFrame.origin.x += (CGRectGetWidth(self.bounds) - CGRectGetWidth(thumbFrame)) / 2;
        thumbFrame.origin.y = 30;
        CGRect pageThumbFrame = CGRectInset(thumbFrame, thumbOffset, thumbOffset);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            CGRect bounds = thumbFrame;
            bounds.origin = CGPointZero;
            
            UIGraphicsBeginImageContext(bounds.size);
            [[UIColor whiteColor] setFill];
            UIRectFill(bounds);
            whiteThumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            whiteThumb = [whiteThumb transparentBorderImage:1];
            
            UIGraphicsBeginImageContext(bounds.size);
            
            [[UIColor lightGrayColor] setStroke];
            CGRect pathRect = pageThumbFrame;
            pathRect.origin = CGPointMake(thumbOffset, thumbOffset);
            UIBezierPath* pageOutline = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:10];
            pageOutline.lineWidth = 2;
            CGFloat dashPattern[] = {12,12}; //make your pattern here
            [pageOutline setLineDash:dashPattern count:2 phase:11];
            [pageOutline stroke];
            
            
            NSDictionary* attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:20], NSForegroundColorAttributeName : [UIColor lightGrayColor] };
            CGSize strSize = [@"Empty" sizeWithAttributes:attrs];
            CGRect strRect = CGRectZero;
            strRect.origin = CGPointMake((thumbFrame.size.width - strSize.width) / 2, (thumbFrame.size.height - strSize.height) / 2);
            strRect.size = strSize;
            [@"Empty" drawInRect:strRect withAttributes:attrs];
            
            
            missingThumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        
        page3Thumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        page3Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        page3Thumbnail.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
        page3Thumbnail.layer.shadowOffset = CGSizeZero;
        page3Thumbnail.layer.shadowRadius = 2;
        page3Thumbnail.layer.shadowOpacity = 1;
        [self addSubview:page3Thumbnail];
        
        page2Thumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        page2Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        page2Thumbnail.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
        page2Thumbnail.layer.shadowOffset = CGSizeZero;
        page2Thumbnail.layer.shadowRadius = 2;
        page2Thumbnail.layer.shadowOpacity = 1;
        [self addSubview:page2Thumbnail];

        page1Thumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        page1Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        page1Thumbnail.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
        page1Thumbnail.layer.shadowOffset = CGSizeZero;
        page1Thumbnail.layer.shadowRadius = 2;
        page1Thumbnail.layer.shadowOpacity = 1;
        [self addSubview:page1Thumbnail];

        CGFloat sign = rand() % 2 ? -1 : 1;
        page1Transform = CGAffineTransformMakeRotation(sign * (((rand() % 100) / 100.0 - 1.0) * .05 + .01));
        page1Thumbnail.transform = page1Transform;
        page2Thumbnail.transform = CGAffineTransformMakeRotation(sign * (((rand() % 100) / 100.0) * .07 + .03));
        page3Thumbnail.transform = CGAffineTransformMakeRotation(sign * (((rand() % 100) / 100.0 - 1.0) * .07 + .03));
        
        stackButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [stackButton addTarget:self action:@selector(switchToStackAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stackButton];

        CGRect buttonFrame = CGRectMake(15, CGRectGetMaxY(thumbFrame), CGRectGetWidth(self.bounds) - 30, CGRectGetHeight(self.bounds) - CGRectGetMaxY(thumbFrame) - 15);
        nameButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [self addSubview:nameButton];
        [nameButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [nameButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [nameButton.titleLabel setMinimumScaleFactor:.9];
        nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        nameButton.titleLabel.numberOfLines = 2;
        nameButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [nameButton addTarget:self action:@selector(didTapNameForStack:) forControlEvents:UIControlEventTouchUpInside];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"StackCachedPagesDidUpdateNotification" object:nil];
    }
    return self;
}

-(void) refresh{
    NSString* stackName = [[MMAllStacksManager sharedInstance] nameOfStack:stackUUID];
    if([stackName length]){
        [nameButton setTitle:stackName forState:UIControlStateNormal];
        [nameButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        [nameButton setTitle:@"No Name" forState:UIControlStateNormal];
        [nameButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    
    [self loadThumb];
}

-(void) loadThumb{
    NSArray* allPages = [[MMAllStacksManager sharedInstance] cachedPagesForStack:stackUUID];
    
    NSString* page1UUID = [allPages firstObject][@"uuid"];
    BOOL hasThumb = NO;
    
    UIImage* image = [MMSingleStackManager hasThumbail:&hasThumb forPage:page1UUID forStack:stackUUID];
    CGSize thumbSize = CGSizeApplyAffineTransform(page1Thumbnail.bounds.size, CGAffineTransformMakeScale([[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]));
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:thumbSize interpolationQuality:kCGInterpolationMedium];
    image = [image transparentBorderImage:2];
    if(image || hasThumb){
        page1Thumbnail.image = image ?: whiteThumb;
        page1Thumbnail.transform = page1Transform;
    }else{
        page1Thumbnail.transform = CGAffineTransformIdentity;
    }

    if([allPages count] > 1){
        NSString* page2UUID = [allPages objectAtIndex:1][@"uuid"];
        UIImage* image = [MMSingleStackManager hasThumbail:&hasThumb forPage:page2UUID forStack:stackUUID];
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:page1Thumbnail.bounds.size interpolationQuality:kCGInterpolationMedium];
        image = [image transparentBorderImage:2];
        page2Thumbnail.image = image ?: (hasThumb ? whiteThumb : nil);
    }else{
        page2Thumbnail.image = nil;
    }

    if([allPages count] > 2){
        NSString* page3UUID = [allPages objectAtIndex:2][@"uuid"];
        UIImage* image = [MMSingleStackManager hasThumbail:&hasThumb forPage:page3UUID forStack:stackUUID];
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:page1Thumbnail.bounds.size interpolationQuality:kCGInterpolationMedium];
        image = [image transparentBorderImage:2];
        page3Thumbnail.image = image ?: (hasThumb ? whiteThumb : nil);
    }else{
        page3Thumbnail.image = nil;
    }
}

-(void) switchToStackAction:(id)sender{
    [[self delegate] switchToStackAction:stackUUID];
}

-(void) didTapNameForStack:(id)sender{
    [[self delegate] didTapNameForStack:stackUUID];
}


@end