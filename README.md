This is a OSX utility app to obtain all the provisioning profiles (.mobileprovision files) in your mac.
You have access to all the infos about your provisioning profiles:
- list of all the provisioning profiles in your default path (/User/Library/MobileDevice/Provisioning Profiles) or a custom path by your choice
- "show in finder" option
- delete a single provisioning profile
- filter the provisioning profiles by Name/TeamName/ExpirationDate
- filter the provisioning profiles by Developer Profiles / Distribution Profiles / All Profiles

Main features:

- Minimum OS: OS 10.9
- ARC
- Language used: Objective-C

#INSTALLATION

You can open the xcode project and build it or open directly the app.

#HELPER CLASSES

- NSScrollView+MultiLine
- 
Category of NSScrollView to access directly to the textview of the scrollview.
You have two utility methods:

To append a string to the existing string value of the textview of the scrollview.

`- (void)appendStringValue:(NSString*)string;`

To set the string to the existing string value of the textview of the scrollview.

`- (void)setStringValue:(NSString*)string;`

- ProvisioningProfileBean
- 
Bean that represents the provisioning profile.
You can init it by calling:

`- (id)initWithPath:(NSString *)path;`

You have a lot of public properties you can access:

```
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
```

#RELEASE LOG

1.0
First committ

1.2
Added compatibility with OSX certificates: now the app supports also .provisionprofile extensions, parses them and shows them in the UI.
Now the app shows also the platform type: OSX or iOS.


Screens:

![alt text](https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/6382/Schermata_2015-05-09_alle_19.28.27.png "Screen")
