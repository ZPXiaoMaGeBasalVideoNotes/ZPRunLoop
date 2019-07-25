//
//  ZPSixViewController.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/7/17.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ZPSixViewController.h"
#import "ZPThread.h"

@interface ZPSixViewController ()

@property (nonatomic, strong) ZPThread *thread;
@property (nonatomic, assign) BOOL isStop;  //用来标记子线程是否停止

@end

@implementation ZPSixViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"SixViewController";
    
    self.isStop = NO;
    
    /**
     创建子线程：
     默认情况下，子线程里面的任务执行完了以后，该线程就会被系统自动销毁掉；
     下面方法中的initWithTarget:参数一般写为self，这样的话就会造成线程强引用着本视图控制器，而本视图控制器又强引用着线程，两者相互强引用着，到时候就会造成视图控制器无法释放的问题。为了避免上述问题的发生，就要用"initWithBlock:"方法来进行代替，这样的话视图控制器才能被释放。
     */
//   self.thread = [[ZPThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    self.thread = [[ZPThread alloc] initWithBlock:^{
        //这个block里面撰写的内容目的是让新建的子线程保活，不要因为子线程中的任务完成了以后就被销毁掉。
        
        NSLog(@"%@---begin---", [NSThread currentThread]);
        
        /**
         用RunLoop的方式使线程保活的最大优点就在于，当子线程如果没有接收到响应的话就会让这条子线程进行休眠，当有响应的时候让这条子线程进行响应，这就最大程度上的节省了系统的资源；
         创建RunLoop对象。因为如果Mode里面没有任何Source0/Source1/Timer/Observer的话，RunLoop就会立马退出，所以当创建完RunLoop后，就要向它里面添加Source0/Source1/Observer。下面方法中的addPort:就是向RunLoop里面添加Source1。
         */
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        
        /**
         如果调用run方法的话则意味着开启一个永不释放的子线程，子线程的任务会一直卡在这一行，任务不会结束，所以当视图控制器被销毁的时候，这个子线程无论如何都是不会被销毁的。
         */
//        [[NSRunLoop currentRunLoop] run];
        
        /**
         想要子线程拥有销毁的能力，就要按照如下的代码进行撰写：
         检测子线程是否已经停止了，如果没有停止（isStop == NO）的话就要开启子线程；
         当调用stop方法中的"CFRunLoopStop(CFRunLoopGetCurrent());"代码的时候会停止掉当前的RunLoop，当停止RunLoop的时候弱指针(weakSelf)会被销毁，销毁以后它就成为了nil，此时它的的时候布尔值是NO，所以在while后面的小括号里面应该填写"weakSelf && !weakSelf.isStop"，即当弱指针(weakSelf)有值并且weakSelf的布尔值为NO的时候才能执行大括号里面的代码。
         */
        __weak typeof(self) weakSelf = self;
        while (weakSelf && !weakSelf.isStop)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        NSLog(@"%@---end---", [NSThread currentThread]);
    }];
    
    [self.thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /**
     在指定的子线程中执行某个方法：
     下面方法中的waitUntilDone:参数如果写为YES的话则代表着系统需要等待子线程中的任务完了以后，主线程才能继续运行下面"NSLog(@"123");"代码，如果写为NO的话则代表着系统运行子线程中任务的同时，主线程不必等待，可以直接运行下面的"NSLog(@"123");"代码。
     */
    if (self.thread)
    {
        [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
    }else
    {
        return;  //当子线程不存在的时候直接返回
    }
    
    NSLog(@"123");
}

//这个方法是在子线程中执行的任务。
- (void)test
{
    NSLog(@"%s, %@", __func__, [NSThread currentThread]);
}

//这个方法用来停止子线程的RunLoop。
- (void)stop
{
    //标记停止子线程
    self.isStop = YES;
    
    /**
     停止RunLoop：
     当执行下面的代码的时候，会停掉当前的RunLoop，即会把上面的"viewDidLoad"方法中的"[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];"语句停止掉，然后再判断while括号里面的条件，因为此时NSLog的"!weakSelf.isStop"已经为NO了，所以不会再执行while大括号里面的语句了，继而执行"(@"%@---end---", [NSThread currentThread]);"语句了。
     */
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    NSLog(@"%s, %@", __func__, [NSThread currentThread]);
    
    //清空子线程
    self.thread = nil;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    /**
     在本视图控制器即将被销毁的时候也要销毁之前创建的常驻子线程；
     下面方法中的waitUntilDone:参数后面要写YES。因为如果写NO的话则代表着主线程不等待子线程中的任务执行完毕后再继续执行主线程中的代码，这就意味着子线程中的任务在执行的同时，主线程中的dealloc方法也在继续执行着，还没等子线程中的stop任务执行完毕，主线程中的dealloc方法就执行完毕了，也就意味着该视图控制器被销毁了，即self对象不存在了。当执行子线程中的stop任务的时候是用self对象来进行调用，而此时的self对象已经被销毁了，所以运行的时候会报“坏内存访问”的错误。如果写YES的话则代表着主线程会等待子线程中的任务执行完毕后再继续执行主线程中的代码，这就意味着子线程中的任务先执行，主线程这个时候会进行停顿来等待子线程中的任务执行，这个时候主线程中的dealloc方法不会再继续执行，该视图控制器没有被销毁，即self对象还存在着，self对象能够进行调用stop方法。
     */
    if (self.thread)
    {
        [self performSelector:@selector(stop) onThread:self.thread withObject:nil waitUntilDone:YES];
    }else
    {
        return;  //当子线程不存在的时候直接返回
    }
    
}

@end
