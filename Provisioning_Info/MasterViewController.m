//
//  MasterViewController.m
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "MasterViewController.h"
#import "ProvisioningProfileBean.h"
#import "NSScrollView+MultiLine.h"
#import "AppDelegate.h"
#import <QuickLook/QuickLook.h>
#import <Quartz/Quartz.h>
#import "QLPreviewCont.h"

#define kDefaultPath @"/Library/MobileDevice/Provisioning Profiles"

@interface MasterViewController ()
{
	NSArray *extensions;
    QLPreviewCont *quickLookCont;
}

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

#pragma mark - QuickView

-(void)spacePressed{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        [[QLPreviewPanel sharedPreviewPanel] updateController]; //not sure if this is really needed as it should update itself…
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
    }
}

-(BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel{

    return YES;
}


-(void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    if (!quickLookCont) {
        quickLookCont = [[QLPreviewCont alloc]init];
    }

    NSMutableArray* files = [NSMutableArray array];
    for (ProvisioningProfileBean* profile in [self getSelectedProfiles]) {
        [files addObject:[profile path]];
    }

    [quickLookCont setProfiles:files];
    
    [[QLPreviewPanel sharedPreviewPanel] setDelegate:quickLookCont];
    [[QLPreviewPanel sharedPreviewPanel] setDataSource:quickLookCont];
}

-(void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
}

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
	extensions = @[@"mobileprovision", @"provisionprofile"];

    
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
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(ProvisioningProfileBean *p_1, ProvisioningProfileBean *p_2) {
                NSString *n_1 = p_1.name;
                NSString *n_2 = p_2.name;
                return [n_1 compare: n_2];
            }];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
        else if ([tableColumn.identifier isEqualToString:@"TeamName"])
        {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(ProvisioningProfileBean *p_1, ProvisioningProfileBean *p_2) {
                NSString *n_1 = p_1.teamName;
                NSString *n_2 = p_2.teamName;
                return [n_1 compare: n_2];
            }];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
        else if ([tableColumn.identifier isEqualToString:@"ExpirationDate"])
        {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES comparator:^(ProvisioningProfileBean *p_1, ProvisioningProfileBean *p_2) {
                NSDate *n_1 = p_1.expirationDate;
                NSDate *n_2 = p_2.expirationDate;
                return [n_1 compare: n_2];
            }];
            [tableColumn setSortDescriptorPrototype:sortDescriptor];
        }
    }
}

-(void)keyDown:(NSEvent *)theEvent{
    unsigned short keyPress = [theEvent keyCode];
    if (keyPress == 49){
        [self spacePressed];
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
	provisioningProfiles = [provisioningProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];
    for (NSString *path in provisioningProfiles)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", self.profilesPath, path] isDirectory:NO]) {
            ProvisioningProfileBean *profile = [[ProvisioningProfileBean alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", self.profilesPath, path]];
            [self.profiles addObject:profile];
        }
    }
    self.profiles = [[self.profiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((ProvisioningProfileBean *)obj1).name compare:((ProvisioningProfileBean *)obj2).name];
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
        ProvisioningProfileBean *profile = (ProvisioningProfileBean*)obj;
        if ([profile.debug isEqualToString:@"YES"])
            [self.filterProfiles addObject:profile];
    }];
}

- (void)filterProfilesByDistribution
{
    [self.filterProfiles removeAllObjects];
    [self.profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ProvisioningProfileBean *profile = (ProvisioningProfileBean*)obj;
        if ([profile.debug isEqualToString:@"NO"])
            [self.filterProfiles addObject:profile];
    }];
}

- (void)filterProfilesByExpiration
{
    [self.filterProfiles removeAllObjects];
    [self.profiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ProvisioningProfileBean *profile = (ProvisioningProfileBean*)obj;
        if ([profile.expirationDate isLessThan:[NSDate date]])
            [self.filterProfiles addObject:profile];
    }];
}

- (void)loadProfileAtPath:(NSString*)path
{
	// load profile from the path
	ProvisioningProfileBean *profile = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
	{
		profile = [[ProvisioningProfileBean alloc] initWithPath:path];
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

- (void)showProfile:(ProvisioningProfileBean*)profile
{
    [self.textView setStringValue:@""];

    NSMutableString *string = @"".mutableCopy;
    [string appendFormat:@"Profile name: %@", profile.name];
    [string appendFormat:@"\nBundle identifier: %@", profile.bundleIdentifier];
	[string appendFormat:@"\nPlatform(s): %@", profile.platform];
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

-(NSArray*)getSelectedProfiles
{
    NSMutableArray *selectedProfiles = [NSMutableArray new];
    NSIndexSet* rows = self.table.selectedRowIndexes;
    [rows enumerateIndexesUsingBlock:^(NSUInteger selectedRow, BOOL *stop) {
        ProvisioningProfileBean *profile = nil;
        profile = self.profiles[selectedRow];
        if (self.isFilter)
        {
            if (self.filterProfiles.count > selectedRow)
            {
                profile = self.filterProfiles[selectedRow];
                if (profile.name == nil)
                    profile = nil;
            }
        }
        else
        {
            if (self.profiles.count > selectedRow)
            {
                profile = self.profiles[selectedRow];
                if (profile.name == nil)
                    profile = nil;
            }
        }
        if (profile != nil)
            [selectedProfiles addObject:profile];
    }];
    
    return selectedProfiles;
}

- (ProvisioningProfileBean*)getProfileSelected
{
    ProvisioningProfileBean *profile = nil;
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
	[opanel setAllowedFileTypes:extensions];
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
    ProvisioningProfileBean *profile = [self getProfileSelected];
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

    // Filter by distribution profiles
    else if (self.filter.selectedSegment == 3)
    {
        self.isFilter = YES;
        [self filterProfilesByExpiration];
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
    NSArray *profiles = [self getSelectedProfiles];
    for (ProvisioningProfileBean *profile in profiles) {
        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:profile.path] resultingItemURL:nil error:nil];
    }

    [self refreshList:nil];
    return;
    
//    ProvisioningProfileBean *profile = [self getProfileSelected];
//    if (profile == nil)
//        [NSApp presentError:[NSError errorWithDomain:@"Failed to delete the provisioning profile" code:0 userInfo:@{}]];
//    else
//    {
//        [[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:profile.path] resultingItemURL:nil error:nil];
//        [self refreshList:nil];
//    }
}

- (IBAction)changeDefaultPath:(id)sender
{
    [self loadLocalProfiles:self.pathField.stringValue];
}

#pragma mark - NSTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    ProvisioningProfileBean *profile;
    if (self.isFilter)
        profile = (ProvisioningProfileBean*)self.filterProfiles[row];
    else
        profile = (ProvisioningProfileBean*)self.profiles[row];
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
    else if ([tableColumn.identifier isEqualToString:@"Platform"])
    {
        NSString *platform = profile.platform ? profile.platform : @"";
        cellView.textField.stringValue = platform;
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
    ProvisioningProfileBean *profile = [self getProfileSelected];
    if (profile == nil && self.table.selectedRow >=0)
        [NSApp presentError:[NSError errorWithDomain:@"Failed to load the provisioning profile" code:0 userInfo:@{}]];
    else if (self.table.selectedRow >=0)
        [self showProfile:profile];
}



@end
