#import <Cocoa/Cocoa.h>

@interface BibleReaderApp : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSPopUpButton *fileSelector;
    NSPopUpButton *bookSelector;
    NSTextView *verseDisplay;
    NSString *bibleDirPath;
    NSMutableDictionary *currentBookMap;
    NSMutableArray *bookOrder; // Added to track insertion order
}
@end

@implementation BibleReaderApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    currentBookMap = [NSMutableDictionary dictionary];
    bookOrder = [NSMutableArray array]; // Initialize the order tracker
    
    NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];
    bibleDirPath = [cwd stringByAppendingPathComponent:@"bibles"];

    NSRect frame = NSMakeRect(0, 0, 800, 600);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | 
                           NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;
    
    window = [[NSWindow alloc] initWithContentRect:frame 
                                         styleMask:styleMask 
                                           backing:NSBackingStoreBuffered 
                                             defer:NO];
    [window setTitle:@"Cocoa VPL Bible Reader"];
    [window center];

    NSView *contentView = [window contentView];

    NSStackView *topPanel = [NSStackView stackViewWithViews:@[]];
    topPanel.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    topPanel.alignment = NSLayoutAttributeCenterY;
    topPanel.spacing = 10;
    topPanel.edgeInsets = NSEdgeInsetsMake(10, 10, 10, 10);
    [topPanel setTranslatesAutoresizingMaskIntoConstraints:NO];

    [topPanel addView:[NSTextField labelWithString:@"Version:"] inGravity:NSStackViewGravityLeading];
    fileSelector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 150, 25) pullsDown:NO];
    [fileSelector setTarget:self];
    [fileSelector setAction:@selector(fileChanged:)];
    [topPanel addView:fileSelector inGravity:NSStackViewGravityLeading];

    [topPanel addView:[NSTextField labelWithString:@"Book:"] inGravity:NSStackViewGravityLeading];
    bookSelector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 25) pullsDown:NO];
    [bookSelector setTarget:self];
    [bookSelector setAction:@selector(bookChanged:)];
    [topPanel addView:bookSelector inGravity:NSStackViewGravityLeading];

    NSScrollView *scrollPane = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [scrollPane setHasVerticalScroller:YES];
    [scrollPane setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollPane setBorderType:NSBezelBorder];

    verseDisplay = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
    [verseDisplay setEditable:NO];
    [verseDisplay setVerticallyResizable:YES];
    [verseDisplay setHorizontallyResizable:NO];
    [verseDisplay setFont:[NSFont fontWithName:@"Times" size:16]];
    [verseDisplay setTextContainerInset:NSMakeSize(10, 10)];
    [scrollPane setDocumentView:verseDisplay];

    [contentView addSubview:topPanel];
    [contentView addSubview:scrollPane];

    NSDictionary *views = NSDictionaryOfVariableBindings(topPanel, scrollPane);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topPanel]|" options:0 metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollPane]|" options:0 metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPanel(50)][scrollPane]|" options:0 metrics:nil views:views]];

    [self loadVplFiles];
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)loadVplFiles {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bibleDirPath error:nil];
    [fileSelector removeAllItems];
    for (NSString *file in files) {
        if ([[file lowercaseString] hasSuffix:@".txt"]) [fileSelector addItemWithTitle:file];
    }
    if ([fileSelector numberOfItems] > 0) [self parseVplFile:[fileSelector titleOfSelectedItem]];
}

- (void)fileChanged:(id)sender {
    [self parseVplFile:[sender titleOfSelectedItem]];
}

- (void)parseVplFile:(NSString *)fileName {
    [currentBookMap removeAllObjects];
    [bookOrder removeAllObjects]; // Clear the order tracker
    [bookSelector removeAllItems];
    
    NSString *path = [bibleDirPath stringByAppendingPathComponent:fileName];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!content) return;

    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        if (line.length < 4) continue;
        NSString *bookId = [[line substringToIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (!currentBookMap[bookId]) {
            currentBookMap[bookId] = [NSMutableArray array];
            [bookOrder addObject:bookId]; // Record the order we found the book in
        }
        [currentBookMap[bookId] addObject:line];
    }

    // Add items to selector in the order they were discovered
    [bookSelector addItemsWithTitles:bookOrder];
    
    if ([bookSelector numberOfItems] > 0) [self bookChanged:bookSelector];
}

- (void)bookChanged:(id)sender {
    NSString *key = [sender titleOfSelectedItem];
    if (key && currentBookMap[key]) {
        [verseDisplay setString:[currentBookMap[key] componentsJoinedByString:@"\n"]];
        [verseDisplay scrollRangeToVisible:NSMakeRange(0, 0)];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication { return YES; }

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        BibleReaderApp *delegate = [[BibleReaderApp alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}