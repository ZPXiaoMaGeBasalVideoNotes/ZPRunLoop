//
//  ZPSixViewController.h
//  RunLoop
//
//  Created by 赵鹏 on 2019/7/17.
//  Copyright © 2019 赵鹏. All rights reserved.
//

//在程序运行的过程中，有些任务是需要在一条子线程中持续地执行着，为了避免程序频繁地创建和销毁子线程，就需要在程序运行的过程中创建一条常驻线程，用来持续地执行某个任务。本类主要介绍如何利用RunLoop来创建一个常驻线程以及如何销毁这个常驻线程。

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPSixViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
