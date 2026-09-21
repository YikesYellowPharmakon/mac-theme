#import <ScreenSaver/ScreenSaver.h>
#import "RainView.h"

@interface MacThemeRainView : ScreenSaverView
@property (nonatomic, strong) RainView *rain;
@end

@implementation MacThemeRainView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1.0 / 30.0];
        self.rain = [[RainView alloc] initWithFrame:self.bounds];
        self.rain.preview = isPreview;
        self.rain.autoplay = NO;
        self.rain.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:self.rain];
    }
    return self;
}

- (void)startAnimation {
    [super startAnimation];
    [self.rain reloadPalette];
}

- (void)animateOneFrame {
    [self.rain step];
    [self.rain setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet {
    return NO;
}

@end
