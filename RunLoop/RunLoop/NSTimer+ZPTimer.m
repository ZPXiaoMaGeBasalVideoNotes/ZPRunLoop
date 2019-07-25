//
//  NSTimer+ZPTimer.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/3.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "NSTimer+ZPTimer.h"

@implementation NSTimer (ZPTimer)

+ (instancetype)repeatWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(NSTimer *timer))block
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(trigger:) userInfo:[block copy] repeats:repeats];
    
    return timer;
}

+ (void)trigger:(NSTimer *)timer
{
    void(^block)(NSTimer *timer) = [timer userInfo];
    
    if (block)
    {
        block(timer);
    }
}

@end
