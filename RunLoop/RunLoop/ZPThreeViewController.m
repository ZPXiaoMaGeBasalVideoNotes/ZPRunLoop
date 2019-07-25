//
//  ZPThreeViewController.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/3.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ZPThreeViewController.h"
#import "ZPThread.h"

@interface ZPThreeViewController ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ZPThreeViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"ThreeViewController";
    
//    [self test];
    
    [self test1];
    
//    [self test2];
}

- (void)test
{
    /**
     这句代码在底层所做的工作是系统先创建一个定时器对象，然后把它添加到NSDefaultRunLoopMode中，接着RunLoop再启动这个NSDefaultRunLoopMode，随后取出NSDefaultRunLoopMode中的定时器对象来用；
     这种方式创建的定时器对象不需要手动添加到当前的RunLoop中。
     */
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"ThreeViewController中的定时器");
    }];
}

- (void)test1
{
    /**
     这句代码的意思只是系统会创建一个定时器对象；
     这种方式创建的定时器对象需要手动添加到当前的RunLoop中。
     */
    self.timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"ThreeViewController中的定时器");
    }];
    
    /**
     这句代码的意思是把定时器对象添加到当前的RunLoop中，并且设置它的NSRunLoopMode为NSDefaultRunLoopMode。因为把定时器对象设置为了NSDefaultRunLoopMode，所以该定时器对象只能在该Mode中运行，在其他的Mode中是不能运行的。又因为在同一时刻RunLoop只能在一个Mode中运行，所以在该视图控制器中，当不拖动UITextView控件时，RunLoop在NSDefaultRunLoopMode中运行，此时定时器对象能够正常运行，当拖动UITextView控件时，此时RunLoop就不在NSDefaultRunLoopMode中运行了，而是切换到UITrackingRunLoopMode中运行，所以此时UITextView控件能够拖动，但是定时器对象就不能继续运行了。
     */
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    /**
     NSRunLoopCommonModes是一个占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode。Core Foundation框架中的kCFRunLoopDefaultMode就是Foundation框架中的NSDefaultRunLoopMode，两者其实是一种Mode；
     如果想在拖动UITextView控件的同时定时器对象也能够正常运行的话就需要设置定时器对象的NSRunLoopMode为NSRunLoopCommonModes，即定时器对象在kCFRunLoopDefaultMode和UITrackingRunLoopMode中都能正常运行。
     */
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)test2
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"ThreeViewController中的定时器");
    }];
    
    /**
     上述的方法中系统会自动设置定时器对象的NSRunLoopMode为NSDefaultRunLoopMode，但是可以通过下面的代码进行修改。
     */
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timerRun
{
    NSLog(@"ThreeViewController中的定时器");
}

#pragma mark ————— 点击“关闭定时器”按钮 —————
- (IBAction)closeTimer:(id)sender
{
    [self.timer invalidate];
    
    NSLog(@"关闭ThreeViewController中的定时器");
}

- (void)dealloc
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
        
        NSLog(@"ThreeViewController中的定时器对象被释放了！");
    }
}

@end
