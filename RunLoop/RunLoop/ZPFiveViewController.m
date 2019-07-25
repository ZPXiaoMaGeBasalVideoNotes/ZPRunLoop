//
//  ZPFiveViewController.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/8.
//  Copyright © 2019 赵鹏. All rights reserved.
//

/**
 * 因为NSTimer会受到RunLoop的Mode的影响，所以有时候不准确，而GCD的定时器不会受到RunLoop的Mode的影响，所以一般比NSTimer更准确一些。
 */
#import "ZPFiveViewController.h"

@interface ZPFiveViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_source_t timer1;
@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation ZPFiveViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"FiveViewController";
    
    /**
     延迟执行有如下的几种方式：
     */
    
    //1、调用"performSelector: withObject: afterDelay: "方法实现延迟执行
//    [self delayedExecute];
    
    //2、利用定时器实现延迟执行
//    [self delayedExecute1];
    
    //3、利用子线程的"sleepForTimeInterval: "方法实现延迟执行
//    [self delayedExecute2];
    
    //4、利用GCD函数实现延迟执行
//    [self delayedExecute3];
    
    //5、利用GCD函数实现任务的循环往复执行（每隔一段时间执行一遍任务，和定时器作用相同）
//    [self delayedExecute4];
    
    //6、利用CADisplayLink类实现任务的循环往复执行
    [self delayedExecute5];
}

#pragma mark ————— 方式1：调用"performSelector: withObject: afterDelay: "方法实现延迟执行 —————
//该方法是一种非阻塞执行方式，不会影响其他进程。该方法必须在主线程中执行。
- (void)delayedExecute
{
    NSLog(@"%s", __func__);
    
    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
}

- (void)run
{
    NSLog(@"调用performSelector: withObject: afterDelay: 方法实现延迟执行");
}

#pragma mark ————— 方式2：利用定时器实现延迟执行 —————
- (void)delayedExecute1
{
    NSLog(@"%s", __func__);
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"利用定时器实现延迟执行");
    }];
}

#pragma mark ————— 点击“关闭定时器”按钮 —————
- (IBAction)closeTimer:(id)sender
{
    if (self.timer)
    {
        [self.timer invalidate];
        
        NSLog(@"关闭FiveViewController中的定时器");
    }else if (self.link)
    {
        [self.link invalidate];
        self.link = nil;
        
        NSLog(@"关闭FiveViewController中的CADisplayLink对象");
    }
}

#pragma mark ————— 方式3：利用子线程的"sleepForTimeInterval: "方法实现延迟执行 —————
- (void)delayedExecute2
{
    NSLog(@"%s", __func__);
    
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        //此方法是一种阻塞执行方式，建议放在子线程中执行，否则会卡住界面。
        [NSThread sleepForTimeInterval:2.0];
        
        NSLog(@"利用子线程的sleepForTimeInterval: 方法实现延迟执行");
    }];
    
    thread.name = @"子线程";
    [thread start];
}

#pragma mark ————— 方式4：利用GCD函数实现延迟执行 —————
- (void)delayedExecute3
{
    NSLog(@"%s", __func__);
    
    //函数中的第三个参数代表指定任务在哪个线程中执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"利用GCD函数实现延迟执行");
    });
}

#pragma mark ————— 方式5：利用GCD函数实现任务的循环往复执行（每隔一段时间执行一遍任务，和定时器作用相同） —————
//这种方式会在子线程中执行定时器。
- (void)delayedExecute4
{
    NSLog(@"%s", __func__);
    
    //获得全局的并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    /**
     创建定时器：
     因为dispatch_source_t的本质就是一个OC对象类，而且创建出来的timer对象是一个局部变量，如果不加处理的话则这个对象刚创建出来就会被系统收回内存空间，这个对象就会被杀死，所以必须要由一个强指着这个对象才行；
     在哪个线程中执行定时器，下面函数中的最后一个参数就写哪个队列（如果在主线程中执行就写主队列，如果在子线程中执行就写全局的并发队列）。
     */
    self.timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    /**
     设置定时器的各种属性：
     dispatch_source_set_timer函数的第一个参数写定时器对象；
     函数的第二个参数代表从什么时候开始执行定时器，"DISPATCH_TIME_NOW"表示的是从现在时刻就开始执行定时器，如果想在当前时刻之后的一段时间再执行定时器就要用设置一个dispatch_time变量；
     函数的第三个参数代表间隔多长时间执行下一次，单位是纳秒（1秒等于十的九次方纳秒），"NSEC_PER_SEC"表示的是十的九次方；
     函数的第四个参数一般写0就可以了。
     */
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_time_t interval = 2.0 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.timer1, start, interval, 0);
    
    __block int count = 0;
    
    //设置回调函数
    dispatch_source_set_event_handler(self.timer1, ^{
        NSLog(@"利用GCD函数实现任务的循环往复执行");
        
        NSLog(@"currentThread = %@", [NSThread currentThread]);
        
        count++;
        if (count == 4)
        {
            //可以利用下面的方法取消定时器
            dispatch_cancel(self.timer1);
            
            //再把定时器置空
            self.timer1 = nil;
        }
    });
    
    //因为GCD定时器默认是关闭的，所以要手动启动定时器
    dispatch_resume(self.timer1);
}

#pragma mark ————— 方式6：利用CADisplayLink类实现任务的循环往复执行 —————
- (void)delayedExecute5
{
    /**
     用CADisplayLink类来作为定时器使用的时候，该定时器在屏幕每次刷新的时候都会被调用，屏幕刷新的频率是60HZ，即每秒刷新60次，故而该定时器一秒会被调用60次，该定时器每次调用的时间间隔就是1/60秒，大概16.7毫秒；
     CADisplayLink正常情况下会在屏幕每次刷新结束的时候被调用，精确度相当高。但是NSTimer的精度就相对显得低了点，比如NSTimer触发时间到的时候，RunLoop如果在阻塞状态，触发时间就会推迟到下一个RunLoop周期；
     CADisplayLink的使用场合相对专一，适合做UI的不停重绘，比如自定义动画引擎或者视频播放的渲染。NSTimer的使用范围就要广泛的多，各种需要单次或者循环定时处理的任务都可以使用。
     */
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(run1)];
    
    //把CADisplayLink类的对象添加到当前的运行循环中：
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)run1
{
    NSLog(@"利用CADisplayLink类实现任务的循环往复执行");
}

- (void)dealloc
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
        
        NSLog(@"FiveViewController中的定时器被释放了！");
    }
}

@end
