//
//  ProvisioningProfileBean.h
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProvisioningProfileBean : NSObject

- (id)initWithPath:(NSString *)path;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *teamName;
@property (nonatomic, strong) NSString *valid;
@property (nonatomic, strong) NSString *debug;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic) NSInteger timeToLive;
@property (nonatomic, strong) NSString *applicationIdentifier;
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSArray *certificates;
@property (nonatomic) NSInteger version;
@property (nonatomic, strong) NSArray *prefixes;
@property (nonatomic, strong) NSString *appIdName;
@property (nonatomic, strong) NSString *teamIdentifier;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *platform;


@end
