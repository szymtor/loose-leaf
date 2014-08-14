//
//  MMTwitterShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTwitterShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "Reachability.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation MMTwitterShareItem{
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"twitterLarge"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        NSLog(@"available");
    }else{
        NSLog(@"not available");
    }
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if(tweetSheet){
        // TODO: fix twitter share when wifi enabled w/o any network
        // this hung with the modal "open" in the window, no events triggered when tryign to draw
        // even though the twitter dialog never showed. wifi was on but not connected.
        [tweetSheet setInitialText:@"Quick sketch drawn in Loose Leaf @getlooseleaf"];
        [tweetSheet addImage:self.delegate.imageToShare];
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result){
            NSString* strResult;
            if(result == SLComposeViewControllerResultCancelled){
                strResult = @"Cancelled";
            }else if(result == SLComposeViewControllerResultDone){
                strResult = @"Sent";
            }
            if(result == SLComposeViewControllerResultDone){
                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
            }
            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Twitter",
                                                                         kMPEventExportPropResult : strResult}];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
        };
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:tweetSheet animated:YES completion:^{
            NSLog(@"finished");
        }];
    }

    [delegate didShare];
}

-(BOOL) isAtAllPossible{
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] != nil;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
