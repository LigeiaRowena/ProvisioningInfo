//
//  MasterViewController.m
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "MasterViewController.h"
#import "YAProvisioningProfile.h"
#import "NSScrollView+MultiLine.h"

#define kDefaultPath @"/Library/MobileDevice/Provisioning Profiles"

@interface MasterViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *pathField;
@property (nonatomic, weak) IBOutlet NSTableView *table;
@property (nonatomic, weak) IBOutlet NSScrollView *textView;
@property (weak) IBOutlet NSSegmentedControl *filter;
@property (weak) IBOutlet NSButton *defaultPathRatioButton;


@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSMutableArray *profiles;
@property (nonatomic, strong) NSMutableArray *filterProfiles;
@property (nonatomic, strong) NSString *profilesPath;
@property (nonatomic) BOOL isFilter;

@end

@implementation MasterViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)loadView
{
	[super loadView];
	
	self.profiles = @[].mutableCopy;
    self.filterProfiles = @[].mutableCopy;
	self.formatter = [[NSDateFormatter alloc] init];
	self.formatter.dateFormat = @"dd-MM-yyyy";
    
    // set default value of the filter: show all profiles
    self.isFilter = NO;
    [self.filter setSelected:YES forSegment:2];
   	
    // load default local profiles
	[self loadLocalProfiles:nil];
    
    // set NSSortDescriptor to the colums of the table
    for (NSTableColumn *tableColumn in self.table.tableColumns)
    {
        if ([tableColumn.identifier isEqualToString:@"Name"])
        {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(YAProvisioningProfile *p_1, YAProvisioningProfile *p_2) {
                NSString *n_1 = p_1.name;
                NSString *n_2 = p_2.name;
                return [n_1 compare: n_2];
            }];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
        else if ([tableColumn.identifier isEqualToString:@"TeamName"])
        {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(YAProvisioningProfile *p_1, YAProvisioningProfile *p_2) {
                NSString *n_1 = p_1.teamName;
                NSString *n_2 = p_2.teamName;
                return [n_1 compare: n_2];
            }];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
        else if ([tableColumn.identifier isEqualToString:@"ExpirationDate"])
        {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(YAProvisioningProfile *p_1, YAProvisioningProfile *p_2) {
                NSDate *n_1 = p_1.expirationDate;
                NSDate *n_2 = p_2.expirationDate;
                return [n_1 compare: n_2];
            }];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
    }
}

#pragma mark - Manage Profiles

- (void)loadLocalProfiles:(NSString*)customPath
{
    // clean
    [self.profiles removeAllObjects];
    
    // setting the profiles path
    if (customPath == nil)
        self.profilesPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), kDefaultPath];
    else
        self.profilesPath = customPath;
    [self.pathField setStringValue:self.profilesPath];
    
    // searching for the profiles
    NSArray *provisioningProfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.profilesPath error:nil];
    provisioningProfiles = [provisioningProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mobileprovision'"]];
    for (NSString *path in provisioningProfiles)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", self.profilesPath, path] isDirectory:NO]) {
            YAProvisioningProfile *profile = [[YAProvisioningProfile alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", self.profilesPath, path]];
            [self.profiles addObject:profile];
        }
    }
    self.profiles = [[self.profiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((YAProvisioningProfile *)obj1).name compare:((YAProvisioningProfile *)obj2).name];
    }] mutableCopy];
    [self.textView setStringValue:@""];
    self.isFilter = NO;
    [self.filter setSelected:YES forSegment:2];
    [self.table reloadData];
}

- (void)filterProfilesByDeveloper
{
    [self.filterProfiles removeAllObjects];
    [self.profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YAProvisioningProfile *profile = (YAProvisioningProfile*)obj;
        if ([profile.debug isEqualToString:@"YES"])
            [self.filterProfiles addObject:profile];
    }];
}

- (void)filterProfilesByDistribution
{
    [self.filterProfiles removeAllObjects];
    [self.profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YAProvisioningProfile *profile = (YAProvisioningProfile*)obj;
        if ([profile.debug isEqualToString:@"NO"])
            [self.filterProfiles addObject:profile];
    }];
}


- (void)loadProfileAtPath:(NSString*)path
{
	// load profile from the path
	YAProvisioningProfile *profile = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
	{
		profile = [[YAProvisioningProfile alloc] initWithPath:path];
		if (profile.name == nil)
			profile = nil;
	}
		
	// show profile or show a popup to alert the user
	if (profile == nil)
		[NSApp presentError:[NSError errorWithDomain:@"Failed to load the provisioning profile" code:0 userInfo:@{}]];
	else
    {
        [self refreshList:nil];
        [self showProfile:profile];
    }
}

- (void)showProfile:(YAProvisioningProfile*)profile
{
    [self.textView setStringValue:@""];

    NSMutableString *string = @"".mutableCopy;
    [string appendFormat:@"Profile name: %@", profile.name];
    [string appendFormat:@"\nBundle identifier: %@", profile.bundleIdentifier];
    [string appendFormat:@"\nCreation date: %@", profile.creationDate ? [self.formatter stringFromDate:profile.creationDate] : @"Unknown"];
    [string appendFormat:@"\nExpiration date: %@", profile.expirationDate ? [self.formatter stringFromDate:profile.expirationDate] : @"Unknown"];
    [string appendFormat:@"\nTeam name: %@", profile.teamName ? profile.teamName : @""];
    [string appendFormat:@"\nIs debug: %@", profile.debug];
    [string appendFormat:@"\nVersion: %@", [NSString stringWithFormat:@"%lu", (long)profile.version]];
    [string appendFormat:@"\nApp ID name: %@", profile.appIdName];
    [string appendFormat:@"\nTeam identifier: %@", profile.teamIdentifier];
    [string appendFormat:@"\nUUID: %@", profile.UUID];
    [self.textView setStringValue:string];
}

- (YAProvisioningProfile*)getProfileSelected
{
    YAProvisioningProfile *profile = nil;
    NSInteger selectedRow = self.table.selectedRow;
    if (self.isFilter)
    {
        if (selectedRow >=0 && self.filterProfiles.count > selectedRow)
        {
            profile = self.filterProfiles[selectedRow];
            if (profile.name == nil)
                profile = nil;
        }
    }
    else
    {
        if (selectedRow >=0 && self.profiles.count > selectedRow)
        {
            profile = self.profiles[selectedRow];
            if (profile.name == nil)
                profile = nil;
        }
    }
   
    return profile;
}

#pragma mark - Actions

- (IBAction)openButton:(id)sender
{
	NSOpenPanel *opanel = [NSOpenPanel openPanel];
	NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject];
	[opanel setDirectoryURL:[NSURL fileURLWithPath:documentFolderPath]];
	
	[opanel setCanChooseFiles:TRUE];
	[opanel setCanChooseDirectories:FALSE];
	[opanel setAllowedFileTypes:@[@"mobileprovision"]];
	[opanel setPrompt:@"Open"];
	[opanel setTitle:@"Open file"];
	[opanel setMessage:@"Please select a path where to open file"];
	
	if ([opanel runModal] == NSOKButton)
	{
		NSString* path = [[opanel URL] path];
		[self loadProfileAtPath:path];
	}
}

- (IBAction)refreshList:(id)sender
{
    // set default value of the filter: show all profiles
    self.isFilter = NO;
    [self.filter setSelected:YES forSegment:2];
   	
    // load default local profiles
    [self.defaultPathRatioButton setState:NSOnState];
    [self.pathField setEditable:NO];
    [self.pathField setSelectable:YES];
    [self loadLocalProfiles:nil];
}

- (IBAction)showInFinderButton:(id)sender
{
    YAProvisioningProfile *profile = [self getProfileSelected];
    if (profile == nil)
        [NSApp presentError:[NSError errorWithDomain:@"Failed to load the provisioning profile" code:0 userInfo:@{}]];
    else
        [[NSWorkspace sharedWorkspace] selectFile:profile.path inFileViewerRootedAtPath:nil];
}

- (IBAction)defaultPathButton:(id)sender
{
    // load default path
    if (self.defaultPathRatioButton.state == NSOnState)
    {
        [self.pathField setEditable:NO];
        [self.pathField setSelectable:YES];
        [self loadLocalProfiles:nil];
    }
    
    // load custom path
    else if (self.defaultPathRatioButton.state == NSOffState)
    {
        [self.pathField setEditable:YES];
        [self.pathField setSelectable:YES];
    }
}

- (IBAction)filterByDevDistr:(id)sender
{    
    // Filter by deleloper profiles
    if (self.filter.selectedSegment == 0)
    {
        self.isFilter = YES;
        [self filterProfilesByDeveloper];
        [self.table reloadData];
    }
    
    // Filter by distribution profiles
    else if (self.filter.selectedSegment == 1)
    {
        self.isFilter = YES;
        [self filterProfilesByDistribution];
        [self.table reloadData];
    }
    
    // Filter by all profiles
    else if (self.filter.selectedSegment == 2)
    {
        self.isFilter = NO;
        [self.table reloadData];
    }
}

- (IBAction)deleteProvisioning:(id)sender
{
    YAProvisioningProfile *profile = [self getProfileSelected];
    if (profile == nil)
        [NSApp presentError:[NSError errorWithDomain:@"Failed to delete the provisioning profile" code:0 userInfo:@{}]];
    else
    {
        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:profile.path] resultingItemURL:nil error:nil];
        [self refreshList:nil];
    }
}


- (IBAction)changeDefaultPath:(id)sender
{
    [self loadLocalProfiles:self.pathField.stringValue];
}

#pragma mark - NSTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    YAProvisioningProfile *profile;
    if (self.isFilter)
        profile = (YAProvisioningProfile*)self.filterProfiles[row];
    else
        profile = (YAProvisioningProfile*)self.profiles[row];
    if( [tableColumn.identifier isEqualToString:@"Name"] )
    {
        NSString *name = profile.name ? profile.name : @"";
        cellView.textField.stringValue = name;
        return cellView;
    }
	else if( [tableColumn.identifier isEqualToString:@"TeamName"] )
	{
		NSString *teamName = profile.teamName ? profile.teamName : @"";
		cellView.textField.stringValue = teamName;
		return cellView;
	}
    else if ([tableColumn.identifier isEqualToString:@"ExpirationDate"])
    {
        NSString *expirationDate = profile.expirationDate ? [self.formatter stringFromDate:profile.expirationDate] : @"Unknown";
        cellView.textField.stringValue = expirationDate;
        return cellView;
    }
	return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (self.isFilter)
        return [self.filterProfiles count];
    else
        return [self.profiles count];
}


-(void)tableView:(NSTableView *)mtableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    NSTableColumn *selectedColumnn = (NSTableColumn*)self.table.tableColumns[self.table.selectedColumn];
    NSSortDescriptor *sortDescriptorPrototype = selectedColumnn.sortDescriptorPrototype;
    self.profiles = [self.profiles sortedArrayUsingComparator:sortDescriptorPrototype.comparator].mutableCopy;
    [self.table reloadData];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    /*
    NSLog(@"selectedRow %li", (long)self.table.selectedRow);
    NSLog(@"selectedColumn %li", (long)self.table.selectedColumn);
    NSLog(@"array tableColumns %@", self.table.tableColumns);
    NSLog(@"selectedRowIndexes %@", self.table.selectedRowIndexes);
    NSLog(@"selectedColumnIndexes %@", self.table.selectedColumnIndexes);
    NSLog(@"isColumnSelected0? %i", [self.table isColumnSelected:0]);
    NSLog(@"isColumnSelected1? %i", [self.table isColumnSelected:1]);
    NSTableColumn *columnname = [self.table tableColumnWithIdentifier:@"Name"];
    */
    
    YAProvisioningProfile *profile = [self getProfileSelected];
    if (profile == nil && self.table.selectedRow >=0)
        [NSApp presentError:[NSError errorWithDomain:@"Failed to load the provisioning profile" code:0 userInfo:@{}]];
    else if (self.table.selectedRow >=0)
        [self showProfile:profile];
}



@end
