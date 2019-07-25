//
//  NSTimer+ZPTimer.h
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/3.
//  Copyright © 2019 赵鹏. All rights reserved.
//

//NSTimer类的分类，专门用于释放NSTimer类的对象。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (ZPTimer)

+ (instancetype)repeatWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
