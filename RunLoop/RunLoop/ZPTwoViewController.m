//
//  ZPTwoViewController.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/3.
//  Copyright © 2019 赵鹏. All rights reserved.
//

//参考文献：https://www.jianshu.com/p/608ef4a6262e

#import "ZPTwoViewController.h"
#import "ZPThread.h"
#import "NSTimer+ZPTimer.h"

@interface ZPTwoViewController ()

@property (nonatomic, strong) NSTimer *timer;  //NSTimer类型的属性使用"strong"关键字来修饰

@end

@implementation ZPTwoViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"TwoViewController";
    
    /**
     NSTimer有六种使用方式，分为撰写如下：
     */
    
    //NSTimer的使用方式1
//    [self useNSTimerMethod1];
    
    //NSTimer的使用方式2
//    [self useNSTimerMethod2];
    
    //NSTimer的使用方式3
//    [self useNSTimerMethod3];
    
    //NSTimer的使用方式4
//    [self useNSTimerMethod4];
    
    //NSTimer的使用方式5
//    [self useNSTimerMethod5];
    
    //NSTimer的使用方式6
    [self useNSTimerMethod6];
}

#pragma mark ————— NSTimer的使用方式1 —————
- (void)useNSTimerMethod1
{
    /**
    这种NSTimer的使用方式是系统把定时器创建出来以后，然后系统会把它自动添加到当前的RunLoop运行循环中，并且设置它的NSRunLoopMode为NSDefaultRunLoopMode，在设定的时间后启动定时器（调用相关的方法）。
     */
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    
    //因为在调用上述方法的时候把target的参数设为了self，所以为了能够彻底释放定时器对象，就要调用下面的NSTimer分类里面的方法。
    self.timer = [NSTimer repeatWithInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"TwoViewController中的定时器");
    }];
}

#pragma mark ————— NSTimer的使用方式2 —————
- (void)useNSTimerMethod2
{
    /**
     这种NSTimer的使用方式与方式1中的相同，系统把定时器创建出来以后，然后系统会把它自动添加到当前的RunLoop运行循环中，并且设置它的NSRunLoopMode为NSDefaultRunLoopMode，在设定的时间后启动定时器（调用相关的方法）。
     */
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"TwoViewController中的定时器");
    }];
    
    //备注：因为在调用上述方法的时候并没有把target参数设为self，所以定时器对象可以正常地被释放掉，故而可以不用调用NSTimer分类里面的方法了。
}

#pragma mark ————— NSTimer的使用方式3 —————
- (void)useNSTimerMethod3
{
    /**
     NSInvocation：用来包装方法和对应的对象，它可以存储方法的名称、对应的对象、对应的参数等，它的参数没有限制。在IOS4.0之后，它大多被block结构所取代，只有在很老的兼容性系统中才会使用。
     */
    
    //初始化一个NSInvocation类的对象
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(init)]];
//    [invocation setTarget:self];
//    [invocation setSelector:@selector(timerRun)];
    
    /**
     这种NSTimer的使用方式和上述的两种相同的是系统把定时器创建出来以后，然后系统会把它自动添加到当前的RunLoop运行循环中，并且设置它的NSRunLoopMode为NSDefaultRunLoopMode，在设定的时间后启动定时器（调用相关的方法）。不同的是使用这种方式创建出来的定时器对象需要手动调用"fire"方法才能使定时器开始运行了。
     */
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:invocation repeats:YES];
//    [self.timer fire];
    
    //因为在调用上述方法的时候已经把NSInvocation对象的target设为了self，所以为了能够彻底释放NSTimer对象，就要调用下面的NSTimer分类里面的方法了。
    self.timer = [NSTimer repeatWithInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"TwoViewController中的定时器");
    }];
}

#pragma mark ————— NSTimer的使用方式4 —————
- (void)useNSTimerMethod4
{
    /**
     这种NSTimer的使用方式与前三种不同的是系统把定时器创建出来以后，系统不会把它自动添加到当前的RunLoop运行循环中，而是需要手动把它添加到当前的RunLoop运行循环中，并且手动设置它的NSRunLoopMode为NSRunLoopCommonModes，在设定的时间后启动定时器（调用相关的方法）。
     */
    self.timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"TwoViewController中的定时器");
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    //备注：因为上述的方法中没有把定时器的target参数设置为self，所以定时器对象可以正常地被释放掉，故而不用调用NSTimer分类里面的方法了。
}

#pragma mark ————— NSTimer的使用方式5 —————
- (void)useNSTimerMethod5
{
    /**
     这种NSTimer的使用方式与上述的方式4中的一样，系统把定时器创建出来以后，不会把它自动添加到当前的RunLoop运行循环中，而是需要手动把它添加到当前的RunLoop运行循环中，并且设置它的NSRunLoopMode为NSRunLoopCommonModes，在设定的时间后启动定时器（调用相关的方法）。
     */
//    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];

//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    //因为上述的方法中定时器对象把target参数设置为了self，所以为了能够彻底释放定时器对象，就要调用下面的NSTimer分类里面的方法了。
    self.timer = [NSTimer repeatWithInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"TwoViewController中的定时器");
    }];
}

#pragma mark ————— NSTimer的使用方式6 —————
- (void)useNSTimerMethod6
{
    //初始化一个NSInvocation类的对象
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(init)]];
//    [invocation setTarget:self];
//    [invocation setSelector:@selector(timerRun)];
    
//    self.timer = [NSTimer timerWithTimeInterval:1.0 invocation:invocation repeats:YES];
    
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    //因为在上述的方法中把NSInvocation对象的target设置为了self，所以为了能够彻底释放定时器对象，就要调用下面的NSTimer分类里面的方法了。
    self.timer = [NSTimer repeatWithInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"TwoViewController中的定时器");
    }];
}

#pragma mark ————— 给RunLoop添加定时器的底层实现 —————
//上面调用"addTimer: forMode: "方法的RunLoop的底层实现。
- (void)addTimerBottomedRealize
{
    //1、创建一个内容上下文：
    CFRunLoopTimerContext context = {
        0,
        ((__bridge void *)self),
        NULL,
        NULL,
        NULL
    };
    
    //2、获得当前的RunLoop对象：
    CFRunLoopRef rlp = CFRunLoopGetCurrent();
    
    /**
     3、初始化一个NSTimer对象：
     参数一：用于分配对象的内存；
     参数二：在什么时候触发 (距离现在)；
     参数三：每隔多长时间触发一次（单位为秒）；
     参数四：未来参数；
     参数五：当在Runloop同一运行阶段中有多个CFRunLoopObserver时，这个参数用来确定CFRunLoopObserver的优先级，一般情况下这个参数填0；
     参数六：回调函数；
     参数七：上下文记录信息。
     */
    CFRunLoopTimerRef timerRef = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, 1, 0, 0, ZPRunLoopTimerCallBack, &context);
    
    //4、把NSTimer对象(timerRef)依赖于某种模式(kCFRunLoopDefaultMode)加入到RunLoop对象(rlp)中：
    CFRunLoopAddTimer(rlp, timerRef, kCFRunLoopDefaultMode);
}

#pragma mark ————— 回调函数 —————
void ZPRunLoopTimerCallBack(CFRunLoopTimerRef timer, void *info){
    NSLog(@"%@---%@",timer,info);
}

- (void)timerRun
{
    NSLog(@"TwoViewController中的定时器");
}

#pragma mark ————— 点击“暂停定时器”按钮 —————
- (IBAction)pauseTimer:(id)sender
{
    [self.timer setFireDate:[NSDate distantFuture]];
    
    NSLog(@"暂停TwoViewController中的定时器");
}

#pragma mark ————— 点击“启动定时器”按钮 —————
- (IBAction)startTimer:(id)sender
{
    [self.timer setFireDate:[NSDate distantPast]];
    
    NSLog(@"启动TwoViewController中的定时器");
}

#pragma mark ————— 点击“关闭定时器”按钮 —————
/**
 调用这个方法会永久地关闭定时器；
 因为在官方文档中有"run loops maintain strong references to their timers"的相关阐述，所以说定时器不释放的原因在于Runloop运行循环对它的强引用；
 "invalidate"方法是唯一将定时器对象从Runloop运行循环池中移除的方法，移除之后定时器将被彻底地释放。
 */
- (IBAction)closeTimer:(id)sender
{
    [self.timer invalidate];
    
    NSLog(@"关闭TwoViewController中的定时器");
}

/**
 定时器对象的释放：
 1、在视图控制器中的"viewWillDisappear"方法中调用"invalidate"方法来释放定时器对象：这种方式的弊端在于，原本程序从A视图控制器push到B视图控制器中的时候，A中的定时器会照常工作，如果在A中的"viewWillDisappear"方法中调用"invalidate"来释放定时器的话，那样当程序push到B中的时候定时器也不能工作了，这样的话就有可能会有违项目的初衷（项目的初衷可能是需要在A中释放定时器，进入B中的时候不释放定时器，定时器照常工作）；
 2、在视图控制器中的"dealloc"方法中调用"invalidate"方法来释放定时器对象：这种方式的弊端在于，如果定时器对象当初把target设为视图控制器本身(self)的话，则意味着定时器对象有一个强指针指着这个视图控制器（即使传入weakSelf也是不行的），所以现在的情形就是视图控制器有一个强指针指着定时器对象，而定时器对象又有一个强指针指着这个视图控制器，所以这个视图控制器用强指针指着别人的时候，自己也被强指针指着，就造成了循环引用，故而这个视图控制器不能被销毁，系统也就无法调用"dealloc"方法了；
 3、创建一个NSTimer类的分类：把NSTimer的target设为NSTimer分类本身，这就代替了视图控制器对象被强指针指着了，这样的话视图控制器对象只有一个强指针指着定时器对象，而它本身没有被强指针指着，所以这个视图控制器对象就可以被销毁了，系统也就可以调用"dealloc"方法了，再在"dealloc"方法中调用定时器的"invalidate"方法，并且把它置为nil，从而把定时器彻底地释放掉。推荐使用这种方法。
 */
- (void)dealloc
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
        
        NSLog(@"TwoViewController中的定时器对象被释放了！");
    }
}

@end
