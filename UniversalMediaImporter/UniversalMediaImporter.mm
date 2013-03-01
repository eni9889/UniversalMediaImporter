#line 1 "/Users/egjoka/Documents/Projects/UniversalMediaImporter/UniversalMediaImporter/UniversalMediaImporter.xm"



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

#include <logos/logos.h>
#include <substrate.h>
@class EditingFileInfoViewController; 
static void (*_logos_orig$_ungrouped$EditingFileInfoViewController$viewDidLoad)(EditingFileInfoViewController*, SEL); static void _logos_method$_ungrouped$EditingFileInfoViewController$viewDidLoad(EditingFileInfoViewController*, SEL); static void _logos_method$_ungrouped$EditingFileInfoViewController$beginImportForFile$withMediaKind$(EditingFileInfoViewController*, SEL, id, NSString *); static NSString * _logos_method$_ungrouped$EditingFileInfoViewController$mediaKindForExtension$(EditingFileInfoViewController*, SEL, NSString *); static void _logos_method$_ungrouped$EditingFileInfoViewController$buttonClicked$(EditingFileInfoViewController*, SEL, id); 

#line 66 "/Users/egjoka/Documents/Projects/UniversalMediaImporter/UniversalMediaImporter/UniversalMediaImporter.xm"


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
            header = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,50)];
            [(UITableView *)[self tableView] setTableHeaderView:header];
        }
        
        BButton *btn = [[BButton alloc] initWithFrame:CGRectMake((300.0f-112.0)/2.0f, 5.0, 112.0, 40.0)];
        [btn setTitle:@"Add To iPod" forState:UIControlStateNormal]; 
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.color = [UIColor colorWithRed:0.32f green:0.64f blue:0.32f alpha:1.00f]; 
        [header addSubview:btn];
        [btn release];
    }
    return;
}



static void _logos_method$_ungrouped$EditingFileInfoViewController$beginImportForFile$withMediaKind$(EditingFileInfoViewController* self, SEL _cmd, id file, NSString * kind) {
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



static NSString * _logos_method$_ungrouped$EditingFileInfoViewController$mediaKindForExtension$(EditingFileInfoViewController* self, SEL _cmd, NSString * extension) {
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



static void _logos_method$_ungrouped$EditingFileInfoViewController$buttonClicked$(EditingFileInfoViewController* self, SEL _cmd, id sender) {
    NSLog(@"-[<EditingFileInfoViewController: %p> buttonClicked:%@]", self, sender);
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


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$EditingFileInfoViewController = objc_getClass("EditingFileInfoViewController"); MSHookMessageEx(_logos_class$_ungrouped$EditingFileInfoViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$EditingFileInfoViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$EditingFileInfoViewController$viewDidLoad);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$EditingFileInfoViewController, @selector(beginImportForFile:withMediaKind:), (IMP)&_logos_method$_ungrouped$EditingFileInfoViewController$beginImportForFile$withMediaKind$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$EditingFileInfoViewController, @selector(mediaKindForExtension:), (IMP)&_logos_method$_ungrouped$EditingFileInfoViewController$mediaKindForExtension$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$EditingFileInfoViewController, @selector(buttonClicked:), (IMP)&_logos_method$_ungrouped$EditingFileInfoViewController$buttonClicked$, _typeEncoding); }} }
#line 176 "/Users/egjoka/Documents/Projects/UniversalMediaImporter/UniversalMediaImporter/UniversalMediaImporter.xm"
