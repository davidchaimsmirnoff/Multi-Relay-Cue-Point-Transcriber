#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface BorderView : NSView
@property BOOL active;
@end

@implementation BorderView
- (void)drawRect:(NSRect)dirtyRect {
    if (!self.active) return;
    [[NSColor greenColor] set];
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:NSInsetRect(self.bounds, 9, 9)];
    border.lineWidth = 18;
    CGFloat dash[] = {10, 6};
    [border setLineDash:dash count:2 phase:0];
    [border stroke];
}
@end

@interface DotView : NSView
@property CGFloat dotX;
@property CGFloat dotY;
@property BOOL flash;
@end

@implementation DotView
- (void)drawRect:(NSRect)dirtyRect {
    [self.flash ? [NSColor greenColor] : [NSColor redColor] set];
    NSBezierPath *dot = [NSBezierPath bezierPathWithOvalInRect:
                         NSMakeRect(self.dotX - 7, self.dotY - 7, 14, 14)];
    [dot fill];
}
@end

static BorderView *gBorderView = nil;
static DotView    *gDotView    = nil;
static BOOL        gActive     = NO;
static CGFloat     gSavedMouseX = 0;
static CGFloat     gSavedMouseY = 0;
static CGFloat     gDotParkX   = 0;
static CGFloat     gDotParkY   = 0;
static NSTimer    *gTimer      = nil;
static BOOL        gClickInProgress = NO;

static CGPoint nsToCG(CGFloat x, CGFloat y) {
    CGFloat h = [[NSScreen mainScreen] frame].size.height;
    return CGPointMake(x, h - y);
}

static void postLeftArrow() {
    CGEventRef kd = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)123, true);
    CGEventRef ku = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)123, false);
    CGEventSetFlags(kd, 0);
    CGEventSetFlags(ku, 0);
    CGEventPost(kCGHIDEventTap, kd);
    CGEventPost(kCGHIDEventTap, ku);
    CFRelease(kd);
    CFRelease(ku);
}

static void postRightArrow() {
    CGEventRef kd = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)124, true);
    CGEventRef ku = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)124, false);
    CGEventSetFlags(kd, 0);
    CGEventSetFlags(ku, 0);
    CGEventPost(kCGHIDEventTap, kd);
    CGEventPost(kCGHIDEventTap, ku);
    CFRelease(kd);
    CFRelease(ku);
}

void performClick() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gClickInProgress) return;
        gClickInProgress = YES;

        CGPoint dotPos = nsToCG(gDotView.dotX, gDotView.dotY);
        NSPoint ns = [NSEvent mouseLocation];
        CGPoint realPos = nsToCG(ns.x, ns.y);

        gDotView.flash = YES;
        [gDotView setNeedsDisplay:YES];

        CGEventRef moveIn = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, dotPos, kCGMouseButtonLeft);
        CGEventSetFlags(moveIn, 0);
        CGEventPost(kCGHIDEventTap, moveIn);
        CFRelease(moveIn);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{

            CGEventRef down = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, dotPos, kCGMouseButtonLeft);
            CGEventRef up   = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp,   dotPos, kCGMouseButtonLeft);
            CGEventSetFlags(down, 0);
            CGEventSetFlags(up,   0);
            CGEventSetIntegerValueField(down, kCGMouseEventClickState, 1);
            CGEventSetIntegerValueField(up,   kCGMouseEventClickState, 1);
            CGEventPost(kCGHIDEventTap, down);
            CGEventPost(kCGHIDEventTap, up);
            CFRelease(down);
            CFRelease(up);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{

                CGEventRef moveOut = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, realPos, kCGMouseButtonLeft);
                CGEventSetFlags(moveOut, 0);
                CGEventPost(kCGHIDEventTap, moveOut);
                CFRelease(moveOut);

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    gDotView.flash = NO;
                    [gDotView setNeedsDisplay:YES];
                    gClickInProgress = NO;
                });
            });
        });
    });
}

void performClickAndRewind() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gClickInProgress) return;
        gClickInProgress = YES;

        CGPoint dotPos = nsToCG(gDotView.dotX, gDotView.dotY);
        NSPoint ns = [NSEvent mouseLocation];
        CGPoint realPos = nsToCG(ns.x, ns.y);

        gDotView.flash = YES;
        [gDotView setNeedsDisplay:YES];

        CGEventRef moveIn = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, dotPos, kCGMouseButtonLeft);
        CGEventSetFlags(moveIn, 0);
        CGEventPost(kCGHIDEventTap, moveIn);
        CFRelease(moveIn);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{

            CGEventRef down = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, dotPos, kCGMouseButtonLeft);
            CGEventRef up   = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp,   dotPos, kCGMouseButtonLeft);
            CGEventSetFlags(down, 0);
            CGEventSetFlags(up,   0);
            CGEventSetIntegerValueField(down, kCGMouseEventClickState, 1);
            CGEventSetIntegerValueField(up,   kCGMouseEventClickState, 1);
            CGEventPost(kCGHIDEventTap, down);
            CGEventPost(kCGHIDEventTap, up);
            CFRelease(down);
            CFRelease(up);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{

                postLeftArrow();

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{

                    CGEventRef moveOut = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, realPos, kCGMouseButtonLeft);
                    CGEventSetFlags(moveOut, 0);
                    CGEventPost(kCGHIDEventTap, moveOut);
                    CFRelease(moveOut);

                    NSLog(@"Click+rewind  returned to: %.0f,%.0f", realPos.x, realPos.y);

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                        gDotView.flash = NO;
                        [gDotView setNeedsDisplay:YES];
                        gClickInProgress = NO;
                    });
                });
            });
        });
    });
}

void performClickAndFastForward() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gClickInProgress) return;
        gClickInProgress = YES;

        CGPoint dotPos = nsToCG(gDotView.dotX, gDotView.dotY);
        NSPoint ns = [NSEvent mouseLocation];
        CGPoint realPos = nsToCG(ns.x, ns.y);

        gDotView.flash = YES;
        [gDotView setNeedsDisplay:YES];

        CGEventRef moveIn = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, dotPos, kCGMouseButtonLeft);
        CGEventSetFlags(moveIn, 0);
        CGEventPost(kCGHIDEventTap, moveIn);
        CFRelease(moveIn);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{

            CGEventRef down = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, dotPos, kCGMouseButtonLeft);
            CGEventRef up   = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp,   dotPos, kCGMouseButtonLeft);
            CGEventSetFlags(down, 0);
            CGEventSetFlags(up,   0);
            CGEventSetIntegerValueField(down, kCGMouseEventClickState, 1);
            CGEventSetIntegerValueField(up,   kCGMouseEventClickState, 1);
            CGEventPost(kCGHIDEventTap, down);
            CGEventPost(kCGHIDEventTap, up);
            CFRelease(down);
            CFRelease(up);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{

                postRightArrow();

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{

                    CGEventRef moveOut = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, realPos, kCGMouseButtonLeft);
                    CGEventSetFlags(moveOut, 0);
                    CGEventPost(kCGHIDEventTap, moveOut);
                    CFRelease(moveOut);

                    NSLog(@"Click+fastforward  returned to: %.0f,%.0f", realPos.x, realPos.y);

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                        gDotView.flash = NO;
                        [gDotView setNeedsDisplay:YES];
                        gClickInProgress = NO;
                    });
                });
            });
        });
    });
}

void toggleBorder() {
    dispatch_async(dispatch_get_main_queue(), ^{
        gActive = !gActive;
        gBorderView.active = gActive;
        [gBorderView setNeedsDisplay:YES];

        if (gActive) {
            NSPoint m = [NSEvent mouseLocation];
            gSavedMouseX = m.x;
            gSavedMouseY = m.y;
            [NSCursor hide];
            CGWarpMouseCursorPosition(nsToCG(gDotParkX, gDotParkY));
            gTimer = [NSTimer scheduledTimerWithTimeInterval:0.016
                repeats:YES block:^(NSTimer *t) {
                    NSPoint m = [NSEvent mouseLocation];
                    gDotView.dotX = m.x;
                    gDotView.dotY = m.y;
                    [gDotView setNeedsDisplay:YES];
                }];
        } else {
            [gTimer invalidate];
            gTimer = nil;
            gDotParkX = gDotView.dotX;
            gDotParkY = gDotView.dotY;
            [NSCursor unhide];
            CGWarpMouseCursorPosition(nsToCG(gSavedMouseX, gSavedMouseY));
        }

        NSLog(@"Border: %@", gActive ? @"ON" : @"OFF");
    });
}

static CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type,
                                CGEventRef event, void *refcon) {
    CGEventFlags flags = CGEventGetFlags(event);
    BOOL ctrl = (flags & kCGEventFlagMaskControl)   != 0;
    BOOL opt  = (flags & kCGEventFlagMaskAlternate) != 0;
    BOOL cmd  = (flags & kCGEventFlagMaskCommand)   != 0;
    CGKeyCode key = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);

    if (ctrl && opt && cmd && key == 5) { toggleBorder();              return NULL; } // G
    if (ctrl && opt && cmd && key == 4) { performClick();              return NULL; } // H
    if (ctrl && opt && cmd && key == 3) { performClickAndRewind();     return NULL; } // F
    if (ctrl && opt && cmd && key == 38) { performClickAndFastForward(); return NULL; } // J

    return event;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        NSRect screen = [[NSScreen mainScreen] frame];

        NSWindow *borderWin = [[NSWindow alloc]
            initWithContentRect:screen
            styleMask:NSWindowStyleMaskBorderless
            backing:NSBackingStoreBuffered
            defer:NO];
        borderWin.opaque = NO;
        borderWin.backgroundColor = [NSColor clearColor];
        borderWin.level = NSScreenSaverWindowLevel;
        borderWin.ignoresMouseEvents = YES;
        borderWin.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
        gBorderView = [[BorderView alloc] initWithFrame:screen];
        gBorderView.active = NO;
        borderWin.contentView = gBorderView;
        [borderWin makeKeyAndOrderFront:nil];

        NSWindow *dotWin = [[NSWindow alloc]
            initWithContentRect:screen
            styleMask:NSWindowStyleMaskBorderless
            backing:NSBackingStoreBuffered
            defer:NO];
        dotWin.opaque = NO;
        dotWin.backgroundColor = [NSColor clearColor];
        dotWin.level = NSScreenSaverWindowLevel + 1;
        dotWin.ignoresMouseEvents = YES;
        dotWin.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
        gDotView = [[DotView alloc] initWithFrame:screen];
        gDotParkX = screen.size.width  / 2;
        gDotParkY = screen.size.height / 2;
        gDotView.dotX = gDotParkX;
        gDotView.dotY = gDotParkY;
        gDotView.flash = NO;
        dotWin.contentView = gDotView;
        [dotWin makeKeyAndOrderFront:nil];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            char c;
            while (read(STDIN_FILENO, &c, 1) == 1) {
                if (c == 'b' || c == 'B') toggleBorder();
                if (c == 'h' || c == 'H') performClick();
                if (c == 'f' || c == 'F') performClickAndRewind();
                if (c == 'j' || c == 'J') performClickAndFastForward();
            }
        });

        CGEventMask mask = CGEventMaskBit(kCGEventKeyDown);
        CFMachPortRef tap = CGEventTapCreate(
            kCGSessionEventTap, kCGHeadInsertEventTap,
            kCGEventTapOptionDefault, mask, eventCallback, NULL);
        if (tap) {
            CFRunLoopSourceRef src = CFMachPortCreateRunLoopSource(NULL, tap, 0);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), src, kCFRunLoopCommonModes);
            CGEventTapEnable(tap, true);
            NSLog(@"Shortcuts: ctrl+opt+cmd+G=border  H=click  F=click+rewind  J=click+fastforward");
        } else {
            NSLog(@"Event tap failed - use b/h/f/j + Enter instead");
        }

        [app run];
    }
    return 0;
}
