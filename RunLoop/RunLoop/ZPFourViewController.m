//
//  ZPFourViewController.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/8.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ZPFourViewController.h"
#import "ZPThread.h"

@interface ZPFourViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) ZPThread *thread;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ZPFourViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"FourViewController";
    
    /**
     RunLoop有如下的应用：
     */
    
    //1、利用RunLoop加载图片
//    [self loadImage];
    
    //2、利用RunLoop创建常驻线程
//    [self permanentThread];
    
    //3、利用RunLoop在子线程中添加定时器
//    [self addTimerInChildThread];
    
    //4、利用RunLoop在子线程中添加定时器1
    [self addTimerInChildThread1];
}

#pragma mark ————— RunLoop应用1：利用RunLoop加载图片 —————
- (void)loadImage
{
    /**
     有时需要显示在UIScrollView控件上的图片会比较大，而且图片的数量也会比较多，但是网络下载的比较慢，所以当用户拖动控件的时候感觉会比较卡顿。想要解决这一问题，可以在用户拖动UIScrollView控件完以后统一显示控件上面的所有图片；
     遵循上面的思路，让图片只在NSDefaultRunLoopMode状态下显示，在用户拖动控件的时候(UITrackingRunLoopMode)不显示。
     */
    [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"placeholder"] afterDelay:3.0 inModes:@[NSDefaultRunLoopMode]];
}

#pragma mark ————— RunLoop应用2：利用RunLoop创建常驻线程 —————
- (void)permanentThread
{
    self.thread = [[ZPThread alloc] initWithTarget:self selector:@selector(childThreadRun) object:nil];
    [self.thread start];
}

/**
 有时候希望线程永远不死，因为有时候可能会经常去做一些耗时的操作，所以希望后台永远有一个线程等着系统分配任务让它去做。但是用GCD方式创建的线程，只要线程中的任务做完了系统就会自动关闭该线程，不能达到线程常驻的目的；
 在视图控制器中用strong关键字来修饰线程属性也不能达到线程常驻的目的，只有通过这个方法中的做法才能达到线程常驻的目的。
 */
- (void)childThreadRun
{
    @autoreleasepool {
        NSLog(@"currentThread = %@", [NSThread currentThread]);
        
        /**
         只有在RunLoop中加入port才能保证RunLoop不断转圈而不消失，这样的话这个RunLoop才能在不断地转圈中时刻接收系统发给子线程的任务，然后子线程进行处理，这样才能真正地做到线程常驻。
         */
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //给常驻的子线程发送任务，让它来进行处理。
    [self performSelector:@selector(childThreadRun1) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)childThreadRun1
{
    NSLog(@"currentThread = %@", [NSThread currentThread]);
}

#pragma mark ————— RunLoop应用3：利用RunLoop在子线程中添加定时器 —————
- (void)addTimerInChildThread
{
    self.thread = [[ZPThread alloc] initWithTarget:self selector:@selector(childThreadRun2) object:nil];
    [self.thread start];
}

/**
 因为这个方法中的定时器是在子线程中的NSDefaultRunLoopMode下运行的，而用户是在主线程中的UITrackingRunLoopMode下拖动UIScrollView控件的，虽然同一时刻RunLoop只能执行一个Mode，但是上述的两者是在不同的线程中执行的，所以他们互不干扰，即拖动UIScrollView控件的同时，定时器照常工作。
 */
- (void)childThreadRun2
{
    @autoreleasepool {
        self.timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"FourViewController中的定时器");
        }];
        
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        
    //与主线程不同的是，子线程默认不自动开启RunLoop，如果想要让子线程正常运转的话就要手动创建一个这个子线程对应的子RunLoop并调用"run"方法使其运行。
        [[NSRunLoop currentRunLoop] run];
    }
}

#pragma mark ————— RunLoop应用4：利用RunLoop在子线程中添加定时器1 —————
- (void)addTimerInChildThread1
{
    self.thread = [[ZPThread alloc] initWithTarget:self selector:@selector(childThreadRun3) object:nil];
    [self.thread start];
}

- (void)childThreadRun3
{
    @autoreleasepool {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"FourViewController中的定时器");
        }];
        
        [[NSRunLoop currentRunLoop] run];
    }
}

#pragma mark ————— 点击“关闭定时器”按钮 —————
- (IBAction)closeTimer:(id)sender
{
    [self.timer invalidate];
    
    NSLog(@"关闭FourViewController中的定时器");
}

- (void)dealloc
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
        
        NSLog(@"FourViewController中的定时器对象被释放了！");
    }
}

@end
