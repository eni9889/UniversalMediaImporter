
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos
#import "CaptainHook/CaptainHook.h"
#import <Gremlin/Gremlin.h>

#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "BButton.h"


void printIvarValues (id someObject);
void beginImportForFileWithCustomInfo(NSDictionary *info);
BOOL fileExtensionSupported(NSString *extension);
NSString* mediaKindForExtension(NSString *extension);

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

NSString * mediaKindForExtension(NSString *extension)
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

void beginImportForFileWithCustomInfo(NSDictionary *info)
{
    NSLog(@"Available destinations: %@", [Gremlin allAvailableDestinations]);
    NSLog(@"Importing file with info: %@", info);
    [Gremlin importFileWithInfo:info];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import Started!"
                                                    message:@"Your import has started and you should see it in your iPod soon"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    return;
}

//Hook For Downloads and Downloads Lite
%hook EditingFileInfoViewController
-(void)viewDidLoad
{
    %log;
    %orig; // Call the original implementation of this method

    //Since apps get updated all lets try and catch any exceptions that could happen
    @try
    {
        id file = [self valueForKeyPath:@"_file"];
        NSString *extension = [file valueForKeyPath:@"_extension"];
        
        if(fileExtensionSupported(extension))
        {
            UIView *header = [(UITableView *)[self tableView] tableHeaderView];
            if(!header)
            {
                header = [[UIView alloc] initWithFrame:CGRectMake(0,0,[(UIView *)[self view] frame].size.width,50)];
                [(UITableView *)[self tableView] setTableHeaderView:header];
            }
            
            BButton *btn = [[BButton alloc] initWithFrame:CGRectMake((header.frame.size.width-112.0)/2.0f, 5.0, 112.0, 40.0)];
            [btn setTitle:@"Add To iPod" forState:UIControlStateNormal]; // Set the button title
            [btn addTarget:self action:@selector(importMediaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn.color = [UIColor colorWithRed:0.32f green:0.64f blue:0.32f alpha:1.00f]; // Set purple color
            [header addSubview:btn];
            [btn release];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught exception: %@", exception);
    }
    @finally
    {
        
    }
    
    return;
}

%new
- (void)importMediaButtonClicked:(id)sender
{
    %log;
    __unsafe_unretained NSObject *file = [self valueForKeyPath:@"_file"];
    NSString *filePath  = [file valueForKeyPath:@"_path"];
    NSString *extension = [file valueForKeyPath:@"_extension"];
    
    __block NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:filePath forKey:@"path"];
    
    if([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"])
    {
        
        RIButtonItem *movieItem = [RIButtonItem item];
        movieItem.label = @"Movie";
        movieItem.action = ^
        {
            [info setValue:@"feature-movie" forKey:@"mediaKind"];
            beginImportForFileWithCustomInfo(info);
        };
        
        RIButtonItem *tvItem = [RIButtonItem item];
        tvItem.label = @"TV Episode";
        tvItem.action = ^
        {
            [info setValue:@"tv-episode" forKey:@"mediaKind"];
            beginImportForFileWithCustomInfo(info);
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
        [info setValue:mediaKindForExtension(extension) forKey:@"mediaKind"];
        beginImportForFileWithCustomInfo(info);
    }
    return;
}

%end

//Hook for UnlimDownloads
%hook FileViewController
-(void)viewDidLoad
{
    %log;
    %orig; // Call the original implementation of this method
    
    //Since apps get updated all lets try and catch any exceptions that could happen
    @try
    {
        NSString *filePath = [self file];
        NSString *extension = [filePath pathExtension];
        
        if(fileExtensionSupported(extension))
        {
            UIView *header = [(UITableView *)[self tableView] tableHeaderView];
            if(!header)
            {
                header = [[UIView alloc] initWithFrame:CGRectMake(0,0,[(UIView *)[self view] frame].size.width,50)];
                [(UITableView *)[self tableView] setTableHeaderView:header];
            }
            
            BButton *btn = [[BButton alloc] initWithFrame:CGRectMake((header.frame.size.width-112.0)/2.0f, 5.0, 112.0, 40.0)];
            [btn setTitle:@"Add To iPod" forState:UIControlStateNormal]; // Set the button title
            [btn addTarget:self action:@selector(importMediaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn.color = [UIColor colorWithRed:0.32f green:0.64f blue:0.32f alpha:1.00f]; // Set purple color
            [header addSubview:btn];
            [btn release];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught exception: %@", exception);
    }
    @finally
    {
        
    }
    
    return;
}

%new
- (void)importMediaButtonClicked:(id)sender
{
    %log;
    NSString *filePath = [self file];
    NSString *extension = [filePath pathExtension];
    
    __block NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:filePath forKey:@"path"];
    
    if([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"])
    {
        
        RIButtonItem *movieItem = [RIButtonItem item];
        movieItem.label = @"Movie";
        movieItem.action = ^
        {
            [info setValue:@"feature-movie" forKey:@"mediaKind"];
            beginImportForFileWithCustomInfo(info);
        };
        
        RIButtonItem *tvItem = [RIButtonItem item];
        tvItem.label = @"TV Episode";
        tvItem.action = ^
        {
            [info setValue:@"tv-episode" forKey:@"mediaKind"];
            beginImportForFileWithCustomInfo(info);
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
        [info setValue:mediaKindForExtension(extension) forKey:@"mediaKind"];
        beginImportForFileWithCustomInfo(info);
    }
    return;
}
%end
