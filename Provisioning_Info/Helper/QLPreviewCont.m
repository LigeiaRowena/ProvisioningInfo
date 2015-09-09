//
//  QLPreviewCont.m
//  Provisioning_Info
//
//  Created by Pavel Yankelevich on 9/8/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "QLPreviewCont.h"
#import "AppDelegate.h"

@implementation QLPreviewCont

-(id)init
{
    if (self == [super init]) {
        profiles = [NSMutableArray array];
        return self;
    }
    return nil;
}

-(void)setProfiles:(NSArray*)theArray
{
    [profiles removeAllObjects];
    [profiles setArray:theArray];
}

// Quick Look panel data source
-(NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return [profiles count];
}

-(id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index{
    NSString* file = [profiles objectAtIndex:index];
    return [NSURL fileURLWithPath:file];
}

-(BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event{
    return NO;
}

-(NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id<QLPreviewItem>)item{
    return NSMakeRect(0, 0, 500, 300);
}

@end