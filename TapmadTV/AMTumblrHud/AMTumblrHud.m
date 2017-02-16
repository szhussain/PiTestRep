//
// Created by Mustafin Askar on 22/05/2014.
// Copyright (c) 2014 Asich. All rights reserved.
//

#import "AMTumblrHud.h"

#define kShowHideAnimateDuration 0.2


@implementation AMTumblrHud {
    NSMutableArray *hudRects;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
        self.userInteractionEnabled = NO;
        self.alpha = 0;
    }
    return self;
}

#pragma mark - config UI

- (void)configUI {
    self.backgroundColor = [UIColor clearColor];
    
    UIView *rect1 = [self drawRectAtPosition:CGPointMake((self.frame.size.width/2)-31, (self.frame.size.height/2)-10)];
    UIView *rect2 = [self drawRectAtPosition:CGPointMake((self.frame.size.width/2)-9, (self.frame.size.height/2)-10)];
    UIView *rect3 = [self drawRectAtPosition:CGPointMake((self.frame.size.width/2)+13, (self.frame.size.height/2)-10)];
    
    [self addSubview:rect1];
    [self addSubview:rect2];
    [self addSubview:rect3];
    
    [self doAnimateCycleWithRects:@[rect1, rect2, rect3]];
}

#pragma mark - animation

- (void)doAnimateCycleWithRects:(NSArray *)rects {
    __weak typeof(self) wSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.25 * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf animateRect:rects[0] withDuration:0.25];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.25 * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wSelf animateRect:rects[1] withDuration:0.2];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf animateRect:rects[2] withDuration:0.15];
            });
        });
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf doAnimateCycleWithRects:rects];
    });
}

- (void)animateRect:(UIView *)rect withDuration:(NSTimeInterval)duration {
    [rect setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         rect.alpha = 1;
                         rect.transform = CGAffineTransformMakeScale(1, 1.3);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              rect.alpha = 0.5;
                                              rect.transform = CGAffineTransformMakeScale(1, 1);
                                          } completion:^(BOOL f) {
                                          }];
                     }];
}

#pragma mark - drawing

- (UIView *)drawRectAtPosition:(CGPoint)positionPoint {
    UIView *rect = [[UIView alloc] init];
    CGRect rectFrame;
    rectFrame.size.width = 18;
    rectFrame.size.height = 20;
    rectFrame.origin.x = positionPoint.x;
    rectFrame.origin.y = positionPoint.y;
    rect.frame = rectFrame;
    rect.alpha = 0.6;
    rect.layer.cornerRadius = 3;
    
    if (hudRects == nil) {
        hudRects = [[NSMutableArray alloc] init];
    }
    [hudRects addObject:rect];
    
    return rect;
}

#pragma mark - Setters

- (void)setHudColor:(UIColor *)hudColor {
    for (UIView *rect in hudRects) {
        rect.backgroundColor = hudColor;
    }
}

#pragma mark -
#pragma mark - show / hide

- (void)hide {
    [UIView animateWithDuration:kShowHideAnimateDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kShowHideAnimateDuration animations:^{
            self.alpha = 1;
        }];
    } else {
        self.alpha = 1;
    }
}

- (void)dealloc {
    hudRects = nil;
}

@end
