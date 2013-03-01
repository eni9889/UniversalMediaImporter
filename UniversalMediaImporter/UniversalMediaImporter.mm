#line 1 "/Users/egjoka/Documents/Projects/UniversalMediaImporter/UniversalMediaImporter/UniversalMediaImporter.xm"



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
}


#include <logos/logos.h>
#include <substrate.h>
@class EditingFileInfoViewController; @class FileViewController; 
static void (*_logos_orig$_ungrouped$EditingFileInfoViewController$viewDidLoad)(EditingFileInfoViewController*, SEL); static void _logos_method$_ungrouped$EditingFileInfoViewController$viewDidLoad(EditingFileInfoViewController*, SEL); static void _logos_method$_ungrouped$EditingFileInfoViewController$importMediaButtonClicked$(EditingFileInfoViewController*, SEL, id); static void (*_logos_orig$_ungrouped$FileViewController$viewDidLoad)(FileViewController*, SEL); static void _logos_method$_ungrouped$FileViewController$viewDidLoad(FileViewController*, SEL); static void _logos_method$_ungrouped$FileViewController$importMediaButtonClicked$(FileViewController*, SEL, id); 

#line 99 "/Users/egjoka/Documents/Projects/UniversalMediaImporter/UniversalMediaImporter/UniversalMediaImporter.xm"


static void _logos_method$_ungrouped$EditingFileInfoViewController$viewDidLoad(EditingFileInfoViewController* self, SEL _cmd) {
    NSLog(@"-[<EditingFileInfoViewController: %p> viewDidLoad]", self);
    _logos_orig$_ungrouped$EditingFileInfoViewController$viewDidLoad(self, _cmd); 
    
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
        [btn setTitle:@"Add To iPod" forState:UIControlStateNormal]; 
        [btn addTarget:self action:@selector(importMediaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.color = [UIColor colorWithRed:0.32f green:0.64f blue:0.32f alpha:1.00f]; 
        [header addSubview:btn];
        [btn release];
    }
    return;
}



static void _logos_method$_ungrouped$EditingFileInfoViewController$importMediaButtonClicked$(EditingFileInfoViewController* self, SEL _cmd, id sender) {
    NSLog(@"-[<EditingFileInfoViewController: %p> importMediaButtonClicked:%@]", self, sender);
    __unsafe_unretained NSObject *file = [self valueForKeyPath:@"_file"];
    NSString *filePath  = [file valueForKeyPath:@"_path"];
    NSString *extension = [file valueForKeyPath:@"_extension"];
    
    __block NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:filePath forKey:@"path"];
    
    
    if([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"])
    {
        __unsafe_unretained EditingFileInfoViewController *blockSafeSelf = self;
        
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
    
}






static void _logos_method$_ungrouped$FileViewController$viewDidLoad(FileViewController* self, SEL _cmd) {
    NSLog(@"-[<FileViewController: %p> viewDidLoad]", self);
    _logos_orig$_ungrouped$FileViewController$viewDidLoad(self, _cmd); 
    
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
        [btn setTitle:@"Add To iPod" forState:UIControlStateNormal]; 
        [btn addTarget:self action:@selector(importMediaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.color = [UIColor colorWithRed:0.32f green:0.64f blue:0.32f alpha:1.00f]; 
        [header addSubview:btn];
        [btn release];
    }
    return;
}



static void _logos_method$_ungrouped$FileViewController$importMediaButtonClicked$(FileViewController* self, SEL _cmd, id sender) {
    NSLog(@"-[<FileViewController: %p> importMediaButtonClicked:%@]", self, sender);
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
    
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$EditingFileInfoViewController = objc_getClass("EditingFileInfoViewController"); MSHookMessageEx(_logos_class$_ungrouped$EditingFileInfoViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$EditingFileInfoViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$EditingFileInfoViewController$viewDidLoad);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$EditingFileInfoViewController, @selector(importMediaButtonClicked:), (IMP)&_logos_method$_ungrouped$EditingFileInfoViewController$importMediaButtonClicked$, _typeEncoding); }Class _logos_class$_ungrouped$FileViewController = objc_getClass("FileViewController"); MSHookMessageEx(_logos_class$_ungrouped$FileViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$FileViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$FileViewController$viewDidLoad);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$FileViewController, @selector(importMediaButtonClicked:), (IMP)&_logos_method$_ungrouped$FileViewController$importMediaButtonClicked$, _typeEncoding); }} }
#line 261 "/Users/egjoka/Documents/Projects/UniversalMediaImporter/UniversalMediaImporter/UniversalMediaImporter.xm"
