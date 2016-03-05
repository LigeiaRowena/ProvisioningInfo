//
//  QLPreviewCont.h
//  Provisioning_Info
//
//  Created by Pavel Yankelevich on 9/8/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
#import <QuickLook/QuickLook.h>
#import <Quartz/Quartz.h>

@interface QLPreviewCont : NSResponder <QLPreviewPanelDataSource, QLPreviewPanelDelegate>
{
    NSMutableArray *profiles;
}

-(void)setProfiles:(NSArray*)theArray;

@end
