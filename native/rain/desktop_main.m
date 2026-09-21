#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <signal.h>
#import "RainView.h"

@interface RainApp : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSMutableArray<NSWindow *> *windows;
@end

@implementation RainApp

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    self.windows = [NSMutableArray array];
    [self rebuildWindows];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rebuildWindows)
                                                 name:NSApplicationDidChangeScreenParametersNotification
                                               object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(rebuildWindows)
                                                               name:NSWorkspaceActiveSpaceDidChangeNotification
                                                             object:nil];
    signal(SIGUSR1, SIG_IGN);
    dispatch_source_t src = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGUSR1, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(src, ^{ [self reloadAll]; });
    dispatch_resume(src);
}

- (void)reloadAll {
    for (NSWindow *window in self.windows) {
        RainView *view = (RainView *)window.contentView;
        if ([view isKindOfClass:[RainView class]]) {
            [view reloadPalette];
        }
    }
}

- (void)rebuildWindows {
    for (NSWindow *window in self.windows) {
        [window orderOut:nil];
    }
    [self.windows removeAllObjects];

    NSArray<NSScreen *> *screens = [NSScreen screens];
    for (NSScreen *screen in screens) {
        NSRect frame = screen.frame;
        NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                      styleMask:NSWindowStyleMaskBorderless
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO
                                                         screen:screen];
        window.level = kCGDesktopWindowLevel;
        window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces
            | NSWindowCollectionBehaviorStationary
            | NSWindowCollectionBehaviorIgnoresCycle
            | NSWindowCollectionBehaviorFullScreenAuxiliary;
        window.opaque = YES;
        window.hasShadow = NO;
        window.ignoresMouseEvents = YES;
        window.backgroundColor = [NSColor blackColor];
        window.hidesOnDeactivate = NO;
        window.animationBehavior = NSWindowAnimationBehaviorNone;
        RainView *view = [[RainView alloc] initWithFrame:window.contentView.bounds];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        view.autoplay = YES;
        window.contentView = view;
        [window setFrame:frame display:YES];
        [window orderBack:nil];
        [self.windows addObject:window];
    }
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        RainApp *app = [RainApp new];
        NSApp.delegate = app;
        [NSApp run];
    }
    return 0;
}
