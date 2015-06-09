//
//  ProvisioningProfileBean.m
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "ProvisioningProfileBean.h"

@interface ProvisioningProfileBean ()

@property (nonatomic, strong) NSDictionary *profile;

@end

@implementation ProvisioningProfileBean

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.path = path;
        self.profile = [self provisioningProfileAtPath:path];
        [self createBean];
    }
    return self;
}

- (void)createBean
{
	self.appIdName = self.profile[@"AppIDName"];
	self.teamIdentifier = self.profile[@"Entitlements"][@"com.apple.developer.team-identifier"];
    self.name = self.profile[@"Name"];
    self.teamName = self.profile[@"TeamName"];
	self.debug = [self.profile[@"Entitlements"][@"get-task-allow"] isEqualToNumber:@(1)] ? @"YES" : @"NO";
    self.creationDate = self.profile[@"CreationDate"];
    self.expirationDate = self.profile[@"ExpirationDate"];
    self.devices = self.profile[@"ProvisionedDevices"];
    self.timeToLive = [self.profile[@"TimeToLive"] integerValue];

	if (self.profile[@"Entitlements"][@"application-identifier"])
		self.applicationIdentifier = self.profile[@"Entitlements"][@"application-identifier"];
	else
		self.applicationIdentifier = self.profile[@"Entitlements"][@"com.apple.application-identifier"];

    self.certificates = self.profile[@"DeveloperCertificates"];
    self.valid = ([[NSDate date] timeIntervalSinceDate:self.expirationDate] > 0) ? @"NO" : @"YES";
    self.version = [self.profile[@"Version"] integerValue];
    self.bundleIdentifier = self.applicationIdentifier;
    self.UUID = self.profile[@"UUID"];
    self.prefixes = self.profile[@"ApplicationIdentifierPrefix"];
	
	NSMutableString *platforms = @"".mutableCopy;
	for (NSString *string in self.profile[@"Platform"])
	{
		[platforms appendFormat:@"%@  ", string];
	}
	self.platform = platforms;
		
    for (NSString *prefix in self.prefixes) {
		NSRange range = [self.bundleIdentifier rangeOfString:prefix];
		if (range.location != NSNotFound)
		{
            self.bundleIdentifier = [self.bundleIdentifier stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.", prefix] withString:@""];
        }
    }
    
}

- (NSDictionary *)provisioningProfileAtPath:(NSString *)path
{
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
    NSDictionary *plist = nil;
    
    @try {
        CMSDecoderCreate(&decoder);
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
        CMSDecoderFinalizeMessage(decoder);
        CMSDecoderCopyContent(decoder, &dataRef);
        plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
        NSData *plistData = [plistString dataUsingEncoding:NSUTF8StringEncoding];
        
        plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:nil error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not decode file.\n");
    }
    @finally {
        if (decoder) CFRelease(decoder);
        if (dataRef) CFRelease(dataRef);
    }
    
    return plist;
}

@end
