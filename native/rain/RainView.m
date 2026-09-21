#import "RainView.h"
#import <CoreText/CoreText.h>

typedef struct {
    float head;
    float speed;
    int length;
    int seed;
} RainColumn;

@implementation RainView {
    RainColumn *_cols;
    int _colCount;
    int _rowCount;
    CGFloat _cellW;
    CGFloat _cellH;
    NSTimer *_timer;
    uint32_t _bg;
    uint32_t _accent;
    uint32_t _head;
    CTFontRef _font;
    NSArray<NSString *> *_glyphs;
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cellW = 14;
        _cellH = 18;
        _bg = 0x080C09;
        _accent = 0x3CBF5C;
        _head = 0xC5E6C6;
        _glyphs = @[
            @"ｱ",@"ｲ",@"ｳ",@"ｴ",@"ｵ",@"ｶ",@"ｷ",@"ｸ",@"ｹ",@"ｺ",
            @"ｻ",@"ｼ",@"ｽ",@"ｾ",@"ｿ",@"ﾀ",@"ﾁ",@"ﾂ",@"ﾃ",@"ﾄ",
            @"ﾅ",@"ﾆ",@"ﾇ",@"ﾈ",@"ﾉ",@"ﾊ",@"ﾋ",@"ﾌ",@"ﾍ",@"ﾎ",
            @"ﾏ",@"ﾐ",@"ﾑ",@"ﾒ",@"ﾓ",@"ﾔ",@"ﾕ",@"ﾖ",@"ﾗ",@"ﾘ",
            @"ﾙ",@"ﾚ",@"ﾛ",@"ﾜ",@"ﾝ",@"0",@"1",@"2",@"3",@"4",
            @"5",@"6",@"7",@"8",@"9",@"Z",@":",@".",@"=",@"*",
            @"+",@"-",@"<",@">"
        ];
        self.wantsLayer = YES;
        [self reloadPalette];
        [self rebuildGrid];
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    if (_cols) free(_cols);
    if (_font) CFRelease(_font);
}

- (void)setAutoplay:(BOOL)autoplay {
    _autoplay = autoplay;
    if (autoplay) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0
                                                      target:self
                                                    selector:@selector(tick)
                                                    userInfo:nil
                                                     repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }
    } else {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self rebuildGrid];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self rebuildGrid];
}

- (uint32_t)parseHex:(NSString *)hex fallback:(uint32_t)fallback {
    if (hex.length < 6) return fallback;
    NSString *clean = [[hex stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    if (clean.length < 6) return fallback;
    unsigned int value = 0;
    [[NSScanner scannerWithString:[clean substringToIndex:6]] scanHexInt:&value];
    return value;
}

- (void)reloadPalette {
    NSArray<NSString *> *paths = @[
        [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/mac-theme/rain.json"],
        [[NSBundle bundleForClass:[self class]] pathForResource:@"rain" ofType:@"json"] ?: @"",
        [NSHomeDirectory() stringByAppendingPathComponent:@"Projects/mac-theme/state/rain.json"]
    ];
    for (NSString *path in paths) {
        if (path.length == 0) continue;
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (!data) continue;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![json isKindOfClass:[NSDictionary class]]) continue;
        _bg = [self parseHex:json[@"background"] fallback:_bg];
        _accent = [self parseHex:json[@"accent"] fallback:_accent];
        _head = [self parseHex:json[@"head"] fallback:_head];
        break;
    }
    [self setNeedsDisplay:YES];
}

- (void)rebuildGrid {
    NSSize size = self.bounds.size;
    if (size.width < 8 || size.height < 8) return;
    if (self.preview) {
        _cellW = 8;
        _cellH = 10;
    } else {
        _cellW = 14;
        _cellH = 18;
    }
    int cols = MAX(1, (int)floor(size.width / _cellW));
    int rows = MAX(1, (int)floor(size.height / _cellH));
    if (cols == _colCount && rows == _rowCount && _cols) return;

    if (_cols) free(_cols);
    _colCount = cols;
    _rowCount = rows;
    _cols = calloc((size_t)cols, sizeof(RainColumn));
    for (int i = 0; i < cols; i++) {
        [self resetColumn:i randomizeHead:YES];
    }

    if (_font) CFRelease(_font);
    CTFontRef font = CTFontCreateWithName(CFSTR("Menlo-Bold"), _cellH * 0.86, NULL);
    if (!font) font = CTFontCreateUIFontForLanguage(kCTFontUIFontUserFixedPitch, _cellH * 0.86, NULL);
    _font = font;
}

- (void)resetColumn:(int)i randomizeHead:(BOOL)randomize {
    RainColumn *c = &_cols[i];
    c->speed = 0.18f + (float)(arc4random_uniform(220)) / 220.0f * 0.55f;
    c->length = 8 + (int)arc4random_uniform((uint32_t)MAX(4, _rowCount / 3));
    c->seed = (int)arc4random_uniform(100000);
    c->head = randomize ? (float)(arc4random_uniform((uint32_t)_rowCount)) : -((float)c->length);
}

- (void)tick {
    [self step];
    [self setNeedsDisplay:YES];
}

- (void)step {
    if (!_cols) return;
    for (int i = 0; i < _colCount; i++) {
        _cols[i].head += _cols[i].speed;
        if (_cols[i].head - _cols[i].length > _rowCount + 2) {
            [self resetColumn:i randomizeHead:NO];
        }
        if (arc4random_uniform(18) == 0) {
            _cols[i].seed += 1;
        }
    }
}

- (NSColor *)colorFromRGB:(uint32_t)rgb alpha:(CGFloat)alpha {
    return [NSColor colorWithCalibratedRed:((rgb >> 16) & 0xff) / 255.0
                                     green:((rgb >> 8) & 0xff) / 255.0
                                      blue:(rgb & 0xff) / 255.0
                                     alpha:alpha];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSRect bounds = self.bounds;
    [[self colorFromRGB:_bg alpha:1] setFill];
    NSRectFill(bounds);
    if (!_cols || !_font) return;

    CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);

    for (int x = 0; x < _colCount; x++) {
        RainColumn col = _cols[x];
        int headRow = (int)floorf(col.head);
        for (int d = 0; d < col.length; d++) {
            int y = headRow - d;
            if (y < 0 || y >= _rowCount) continue;
            float t = col.length <= 1 ? 1 : 1.0f - (float)d / (float)col.length;
            uint32_t rgb = (d == 0) ? _head : _accent;
            CGFloat alpha = (d == 0) ? 1.0 : (0.12 + t * 0.78);
            NSColor *color = [self colorFromRGB:rgb alpha:alpha];
            int glyphIndex = abs(col.seed * 131 + x * 17 + y * 29) % (int)_glyphs.count;
            NSString *ch = _glyphs[glyphIndex];
            CFAttributedStringRef attr = CFAttributedStringCreate(
                kCFAllocatorDefault,
                (__bridge CFStringRef)ch,
                (__bridge CFDictionaryRef)@{
                    (__bridge NSString *)kCTFontAttributeName: (__bridge id)_font,
                    (__bridge NSString *)kCTForegroundColorAttributeName: (id)color.CGColor
                });
            CTLineRef line = CTLineCreateWithAttributedString(attr);
            CGContextSetTextPosition(ctx, x * _cellW + 1, bounds.size.height - (y + 1) * _cellH + 2);
            CTLineDraw(line, ctx);
            CFRelease(line);
            CFRelease(attr);
        }
    }
}

- (BOOL)isOpaque {
    return YES;
}

@end
