
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
#import "CaptainHook/CaptainHook.h"
#import <Gremlin/Gremlin.h>

#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "BButton.h"


void printIvarValues (id someObject);
void printIvarValues (id someObject)
{
    unsigned int numMethods = 0;
    unsigned int numIvars = 0;
    Method * methods = class_copyMethodList([someObject class], &numMethods);
    Ivar * ivars = class_copyIvarList([someObject class], &numIvars);
    
    NSMutableArray * selectors = [NSMutableArray array];
    for (int i = 0; i < numMethods; ++i) {
        SEL selector = method_getName(methods[i]);
        [selectors addObject:NSStringFromSelector(selector)];
    }
    free(methods);
    
    NSMutableArray * vars = [NSMutableArray array];
    for (int i = 0; i < numIvars; ++i)
    {
        NSString* ivarName = [NSString stringWithCString:ivar_getName(ivars[i])
                                                encoding:NSASCIIStringEncoding];
        CHLog(@"Value for: %@ is:%@", ivarName, [someObject valueForKeyPath:ivarName]);
        [vars addObject:ivarName];
    }
    free(ivars);
    
}

BOOL fileExtensionSupported(NSString *extension);
BOOL fileExtensionSupported(NSString *extension)
{
    extension = [extension lowercaseString];
    if ([extension isEqualToString:@"mp3"])
    {
        return YES;
    }
    
    if ([extension isEqualToString:@"m4v"])
    {
        return YES;
    }
    
    if ([extension isEqualToString:@"mp4"])
    {
        return YES;
    }
    
    if ([extension isEqualToString:@"m4r"])
    {
        return YES;
    }
    
    return NO;
}

%hook EditingFileInfoViewController
-(void)viewDidLoad
{
    %log;
    %orig; // Call the original implementation of this method
    
    id file = [self valueForKeyPath:@"_file"];
    NSString *extension = [file valueForKeyPath:@"_extension"];
    
    if(fileExtensionSupported(extension))
    {
        UIView *header = [(UITableView *)[self tableView] tableHeaderView];
        if(!header)
        {
            header = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,50)];
            [(UITableView *)[self tableView] setTableHeaderView:header];
        }
        
        BButton *btn = [[BButton alloc] initWithFrame:CGRectMake((header.frame.size.width-112.0)/2.0f, 5.0, 112.0, 40.0)];
        [btn setTitle:@"Add To iPod" forState:UIControlStateNormal]; // Set the button title
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.color = [UIColor colorWithRed:0.32f green:0.64f blue:0.32f alpha:1.00f]; // Set purple color
        [header addSubview:btn];
        [btn release];
    }
    return;
}

%new
-(void)beginImportForFile:(id)file withMediaKind:(NSString *)kind
{
    NSLog(@"Available destinations: %@", [Gremlin allAvailableDestinations]);
    NSString *filePath = [file valueForKeyPath:@"_path"];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          filePath,@"path",
                          kind, @"mediaKind", nil];
    
    NSLog(@"Importing file with info: %@", info);
    [Gremlin importFileWithInfo:info];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Started!"
                                                    message:@"Your import has started and you should see it in your iPod soon"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

%new
- (NSString *)mediaKindForExtension:(NSString *)extension
{
    extension = [extension lowercaseString];
    if([extension isEqualToString:@"mp3"])
    {
        return @"song";
    }
    
    if([extension isEqualToString:@"m4r"])
    {
        return @"ringtone";
    }
    
    return @"song";
}

%new
- (void)buttonClicked:(id)sender
{
    %log;
    __unsafe_unretained NSObject *file = [self valueForKeyPath:@"_file"];
    NSString *extension = [file valueForKeyPath:@"_extension"];
    if([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"])
    {
        __unsafe_unretained EditingFileInfoViewController *blockSafeSelf = self;
        
        RIButtonItem *movieItem = [RIButtonItem item];
        movieItem.label = @"Movie";
        movieItem.action = ^
        {
            [blockSafeSelf beginImportForFile:file withMediaKind:@"feature-movie"];
        };
        
        RIButtonItem *tvItem = [RIButtonItem item];
        tvItem.label = @"TV Episode";
        tvItem.action = ^
        {
            [blockSafeSelf beginImportForFile:file withMediaKind:@"tv-episode"];
        };
        
        RIButtonItem *cancelItem = [RIButtonItem item];
        cancelItem.label = @"Cancel";
        cancelItem.action = ^
        {

        };
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                        message:@"Is this a movie or a tv episode?"
                                              cancelButtonItem:cancelItem
                                              otherButtonItems:movieItem,tvItem, nil];
        [alert show];
    }
    else
    {
        [self beginImportForFile:file withMediaKind:[self mediaKindForExtension:extension]];
    }
    
}

%end