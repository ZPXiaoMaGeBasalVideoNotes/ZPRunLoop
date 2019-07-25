//
//  ZPThread.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/1.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ZPThread.h"

@implementation ZPThread

- (void)dealloc
{
    NSLog(@"%s 线程被销毁了。", __func__);
}

@end
