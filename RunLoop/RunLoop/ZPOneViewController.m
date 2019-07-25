//
//  ZPOneViewController.m
//  RunLoop
//
//  Created by 赵鹏 on 2019/3/3.
//  Copyright © 2019 赵鹏. All rights reserved.
//

/**
 RunLoop的概念：
 1、RunLoop从字面意思上讲叫做运行循环，也可以理解为“跑圈”。其实它的内部就是一个"do-while"无限循环，系统在这个循环内部不断地处理各种任务（Source、Timer、Observer等）；
 2、RunLoop不仅仅是一个运行循环，还是一个对象，也是一个消息处理机制。例如，当用户在屏幕上点击一个按钮或者在程序中设置一个定时器对象时，系统都会把这些事件放到RunLoop中进行处理；
 3、RunLoop会给主程序提供一个入口函数，当主程序进入到这个入口函数后也就意味着进入到了一个"do...while"无限循环中，所以RunLoop会保证当前的应用程序不被退出；
 4、定时器（Timer）、PerformSelector、GCD Async Main Queue、事件响应、手势识别、界面刷新、网络请求、AutoreleasePool这些技术的底层都是基于RunLoop来实现的。
 
 RunLoop的作用：
 1、保持程序的持续运行；
 2、处理程序中的各种事件（触摸事件、定时器事件、performSelector等）；
 3、节省CPU的资源，提高程序的性能。RunLoop是一个运行循环，在循环的过程中系统会不断地检测当前的线程中是否有需要处理的事件，如果有的话，RunLoop就会让当前的线程从原来的休息状态切换到现在的工作状态来处理这些事件，等事件处理完以后再把当前的线程由工作状态切换到休息状态，如此往复，让程序该做事的时候做事，该休息的时候休息，以达到提高程序性能的目的。
 
 RunLoop与线程的关系：
 1、在项目中的main.m文件中的第14行代码，UIApplicationMain函数就相当于上述的RunLoop提供的入口函数，在这个函数的内部启动了一个RunLoop，从而保证了程序的持续运行。这个默认启动的RunLoop跟程序的主线程是一一对应的，主要处理主线程中的事件；
 2、RunLoop也分主RunLoop和子RunLoop，线程与RunLoop是一一对应的关系，主线程对应着主RunLoop，子线程对应着各自的子RunLoop。RunLoop保存在一个全局的Dictionary里，线程作为Key，RunLoop作为value；
 3、主线程对应的RunLoop在程序一开始运行的时候系统就自动创建好了并已经开始运行了，子线程对应的RunLoop需要手动创建并调用"run"方法使其运行；
 4、可以利用RunLoop开启一个常驻的子线程，让这个子线程不进入消亡状态，等待系统给这个常驻线程分配任务；
 5、当线程被销毁的时候，与这条线程对应的那个RunLoop也会被销毁。
 
 RunLoop的API：
 1、iOS中有两套API来访问和使用RunLoop，他们分别是Foundation框架（OC语言）中的NSRunLoop类以及Core Foundation框架(C语言)中的CFRunLoopRef类。NSRunLoop类是基于CFRunLoopRef类上面的一层OC包装，所以想要了解RunLoop的内部结构就需要多研究CFRunLoopRef类的API；
 2、关于RunLoop内容的苹果官方文档的地址："https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html"。
 
 RunLoop在Core Foundation框架中的源码：
 struct __CFRunLoop {
     CFRuntimeBase _base;
     pthread_mutex_t _lock;
     __CFPort _wakeUpPort;            // used for CFRunLoopWakeUp
     Boolean _unused;
     volatile _per_run_data *_perRunData;              // reset for runs of the run loop
     pthread_t _pthread;
     uint32_t _winthread;
     CFMutableSetRef _commonModes;
     CFMutableSetRef _commonModeItems;
     CFRunLoopModeRef _currentMode;
     CFMutableSetRef _modes;
     struct _block_item *_blocks_head;
     struct _block_item *_blocks_tail;
     CFAbsoluteTime _runTime;
     CFAbsoluteTime _sleepTime;
     CFTypeRef _counterpart;
 };
 
 struct __CFRunLoopMode {
     CFRuntimeBase _base;
     pthread_mutex_t _lock;
     CFStringRef _name;
     Boolean _stopped;
     char _padding[3];
     CFMutableSetRef _sources0;
     CFMutableSetRef _sources1;
     CFMutableArrayRef _observers;
     CFMutableArrayRef _timers;
     CFMutableDictionaryRef _portToV1SourceMap;
     __CFPortSet _portSet;
     CFIndex _observerMask;
     #if USE_DISPATCH_SOURCE_FOR_TIMERS
     dispatch_source_t _timerSource;
     dispatch_queue_t _queue;
     Boolean _timerFired; // set to true by the source when a timer has fired
     Boolean _dispatchTimerArmed;
     #endif
     #if USE_MK_TIMER_TOO
     mach_port_t _timerPort;
     Boolean _mkTimerArmed;
     #endif
     #if DEPLOYMENT_TARGET_WINDOWS
     DWORD _msgQMask;
     void (*_msgPump)(void);
     #endif
     uint64_t _timerSoftDeadline;
     uint64_t _timerHardDeadline;
 };
 由上面的源码可以看出Core Foundation框架中的CFRunLoopRef是__CFRunLoop类的一个对象，通过查看源码可以知道__CFRunLoop类是一个结构体，该结构体中的"CFMutableSetRef _modes"是一个数组，这个数组里面的每个元素都是一个__CFRunLoopMode对象。__CFRunLoopMode又是一个结构体，里面包含_sources0、_sources1、_timers和_observers各自所组成的四个数组，所以就有如下的关系：线程与CFRunLoop类是一一对应的关系，而CFRunLoop类与CFRunLoopMode类是一对多的关系，CFRunLoopMode类分别与CFRunLoopSourceRef类、CFRunLoopTimerRef类、CFRunLoopObserverRef类是一对多的关系。
 
 Core Foundation框架中关于RunLoop的5个类：
 1、CFRunLoopRef；
 2、CFRunLoopModeRef；
 3、CFRunLoopSourceRef；
 4、CFRunLoopTimerRef；
 5、CFRunLoopObserverRef。
 
 RunLoop的Mode：
 1、RunLoop的Mode包含三个构成要素，分别是Source、Observer和Timer。RunLoop在循环的过程中会利用Mode里面的Source和Timer来时刻监听外界有没有事件需要处理，如果有的话系统会把当前的线程由休息状态切换为工作状态来处理事件，事件处理完以后再切换回休息状态；
 2、可以把Source看成是外界需要处理的事件，把Timer看成是程序里面定义的定时器对象，把Observer看成是用来监听RunLoop状态改变的要素；
 3、RunLoop只允许在一种Mode下运行，这个Mode被称作CurrentMode，如果想要切换Mode，只能退出当前的RunLoop，重新指定一个新的Mode后再进入一个新的RunLoop。这样做主要是为了分隔开不同组的Source、Timer和Observer，让其互不影响；
 4、如果当前RunLoop的Mode中没有任何Source（外部事件）、Timer和Observer，那么系统就会直接退出该RunLoop；
 5、Foundation框架中的NSRunLoop下的NSRunLoopMode有如下的几种类型：
 （1）NSDefaultRunLoopMode：程序的默认Mode，通常主线程就是在这个Mode下运行的；
 （2）UITrackingRunLoopMode：界面跟踪Mode，用于ScrollView追踪触摸滑动，保证界面滑动时不受其他Mode的影响；
 （3）UIInitializationRunLoopMode：刚启动程序时进入的第一个Mode，启动完成后就不再使用了；
 （4）GSEventReceiveRunLoopMode：接收系统事件的内部Mode，通常用不到；
 （5）NSRunLoopCommonModes：占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode。
 6、Core Foundation框架中的CFRunLoopRef下的CFRunLoopModeRef：
 （1）CFRunLoopModeRef代表RunLoop的运行模式；
 （2）一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer；
 （3）RunLoop启动时只能选择其中一个Mode，作为currentMode；
 （4）如果需要切换Mode，只能退出当前的Loop，再重新选择一个Mode进入。
 CFRunLoopModeRef有如下的几种类型：
 （1）kCFRunLoopDefaultMode：程序的默认Mode，通常主线程是在这个Mode下运行的；
 （2）UITrackingRunLoopMode：界面跟踪Mode，用于ScrollView追踪触摸滑动，保证界面滑动时不受其他Mode的影响；
 （3）UIInitializationRunLoopMode：刚启动程序时进入的第一个Mode，启动完成后就不再使用了；
 （4）GSEventReceiveRunLoopMode：接收系统事件的内部Mode，通常用不到；
 （5）kCFRunLoopCommonModes：占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode。

 RunLoop的Source：
 1、可以把Source看成是事件源（输入源），程序中的触摸事件或者其他事件都是由它来进行触发的；
 2、有Source的时候RunLoop会停止休息对Source进行响应，当没有Source的时候RunLoop会进入休息状态，在休息之前会释放自动释放池；
 3、CFRunLoopSourceRef按照概念可以分为如下几类：
 （1）Port-Based Sources：是由其他线程或者手机的内核发过来的消息；
 （2）Custom Input Sources：自定义输入源；
 （3）Cocoa Perform Selector Sources：处理代码中的"performSelector"的事件。
 4、CFRunLoopSourceRef按照实践（函数调用栈）可以分为如下几类：
 （1）Source0：非基于Port的，用来处理按钮的点击事件等；
 （2）Source1：基于Port的，通过内核和其他线程通信，接收、分发系统的事件。例如：当用户点击屏幕上的一个按钮，用户首先摸到的是屏幕这个硬件，然后系统会把这个事件包装成一个Event事件，Event事件会先到Source1，Source1再把这个Event事件分发到Source0，最后由Source0来处理这个Event事件，所以Source1事件最终会分配给Source0来做。
 
 RunLoop的Timer：
 1、CFRunLoopTimerRef是一个基于时间的触发器，所以这个就等同于NSTimer定时器；
 2、可以让定时器在RunLoop特定的Mode下执行；
 
 RunLoop的Observer：
 1、CFRunLoopObserverRef是观察者，用来监听RunLoop状态的改变；
 2、Observer可以监听RunLoop如下的几个时间节点：
 （1）kCFRunLoopEntry：即将进入RunLoop；
 （2）kCFRunLoopBeforeTimers：即将处理Timer；
 （3）kCFRunLoopBeforeSources：即将处理Source；
 （4）kCFRunLoopBeforeWaiting：即将进入休眠；
 （5）kCFRunLoopAfterWaiting：刚从休眠中唤醒；
 （6）kCFRunLoopExit：即将退出RunLoop；
 （7）kCFRunLoopAllActivities：监听RunLoop所有状态的改变。
 3、当Observer监听到RunLoop即将进入休眠状态(kCFRunLoopBeforeWaiting)，就释放自动释放池；
 4、可以给RunLoop添加Observer对象，用来监听RunLoop状态的改变，例如本类中的"addObserver"方法。
 
 当程序使用下面的相关内容时系统就会调用当前RunLoop的底层：
 1、block应用：__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__；
 2、调用timer：__CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__；
 3、响应source0：__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__；
 4、响应source1：__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__；
 5、GCD主队列：__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__；
 6、observer源：__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__。
 
 RunLoop的处理逻辑：
 当线程运行的时候：1、系统首先会通知Observer，线程即将进入RunLoop；2、通知Observer，将要处理Timer；3、通知Observer，将要处理Source0（点击事件）；4、处理Source0（点击事件）；5、判断有没有Source1（其他线程发过来的消息或者操作系统内核发过来的消息），如果有的话就直接执行第9步了，如果没有的话就继续执行第6步；6、通知Observer，线程即将休眠；7、线程休眠，等待被唤醒。在线程休眠的过程中如果外界有Source0、Timer或者外部手动事件的话，就会继续执行第8步；8、通知Observer，线程刚被唤醒；9、处理唤醒时收到的消息，然后跳回到第2步（Source1接收的事件最终会交给Source0来处理）；10、在发生意外的情况下（超时或者程序被杀死），系统会通知Observer，线程即将退出RunLoop。
 */

#import "ZPOneViewController.h"
#import "ZPThread.h"

@interface ZPOneViewController ()

@property (nonatomic, assign) BOOL isStopping;

@end

@implementation ZPOneViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"OneViewController";
    
    //在Foundation框架中获取当前线程对应的RunLoop
//    NSRunLoop * currentNSRunLoop = [NSRunLoop currentRunLoop];
//    NSLog(@"currentNSRunLoop = %@", currentNSRunLoop);
    
    //在Foundation框架中获取主线程对应的RunLoop
//    NSRunLoop *mainNSRunloop = [NSRunLoop mainRunLoop];
//    NSLog(@"mainNSRunloop = %@", mainNSRunloop);
    
    //在Core Foundation框架中获取当前线程对应的RunLoop
//    CFRunLoopRef currentCFRunLoopRef = CFRunLoopGetCurrent();
//    NSLog(@"currentCFRunLoopRef = %@", currentCFRunLoopRef);
    
    //在Core Foundation框架中获取主线程对应的RunLoop
//    CFRunLoopRef mainCFRunLoopRef = CFRunLoopGetMain();
//    NSLog(@"mainCFRunLoopRef = %@", mainCFRunLoopRef);
    
    /**
     下面方法的底层通讯都依赖于当前的RunLoop。
     */
    
//    [self test];
    
//    [self test1];
    
//    [self test2];
    
//    [self test3];
    
    //创建子线程
    [self creatChildThread];
    
    //给RunLoop添加观察者
//    [self addObserver];
    
    //给RunLoop添加观察者的底层实现
//    [self addObserverBottomedRealize];
}

#pragma mark ————— 使用NSTimer类 —————
- (void)test
{
    //__CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"使用NSTimer类时会依赖于当前的RunLoop");
    }];
}

#pragma mark ————— 调用"performSelector: withObject: afterDelay: "方法 —————
- (void)test1
{
    [self performSelector:@selector(output) withObject:nil afterDelay:1.0];
}

- (void)output
{
    //__CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
    NSLog(@"调用performSelector方法时会依赖于当前的RunLoop");
}

#pragma mark ————— 使用主队列 —————
- (void)test2
{
    //__CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"使用主队列时会依赖于当前的RunLoop");
    });
}

#pragma mark ————— 使用block函数 —————
- (void)test3
{
    void (^block)(void) = ^{
        NSLog(@"使用block函数时会依赖于当前的RunLoop");
    };
    
    block();
}

#pragma mark ————— 创建子线程 —————
- (void)creatChildThread
{
    ZPThread *thread = [[ZPThread alloc] initWithBlock:^{
        NSLog(@"currentThread = %@", [NSThread currentThread]);
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            NSLog(@"OneViewController中的子线程的定时器");
            
            if (self.isStopping)
            {
                //把当前的子线程销毁，同时之前在子线程中创建的NSTimer类的对象也一并被销毁了。
                [ZPThread exit];
            }
        }];
        
        //与主线程不同的是，子线程默认不自动开启RunLoop，如果想要让子线程正常运转的话就要手动创建一个这个子线程对应的子RunLoop并调用"run"方法使其运行。
        [[NSRunLoop  currentRunLoop] run];
    }];
    
    thread.name = @"子线程";
    [thread start];
}

#pragma mark ————— 点击“关闭定时器”按钮 —————
- (IBAction)stop:(id)sender
{
    self.isStopping = YES;
}

#pragma mark ————— 给RunLoop添加观察者 —————
//Obsever是用来监听当前RunLoop的状态的，RunLoop的状态一旦改变了就会有相应的回调信息。
- (void)addObserver
{
    /**
     创建observer对象：
     下面方法中的第二个参数需要传入的是需要监听的RunLoop的状态的名称，如果这个参数填写为kCFRunLoopAllActivities，则代表需要监听RunLoop的所有状态的改变；
     
     RunLoop状态的类型：
     typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
         kCFRunLoopEntry = (1UL << 0),
         kCFRunLoopBeforeTimers = (1UL << 1),
         kCFRunLoopBeforeSources = (1UL << 2),
         kCFRunLoopBeforeWaiting = (1UL << 5),
         kCFRunLoopAfterWaiting = (1UL << 6),
         kCFRunLoopExit = (1UL << 7),
         kCFRunLoopAllActivities = 0x0FFFFFFFU
     };
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop的状态发生了改变，状态的名称为：%lu", activity);
    });
    
    //添加observer对象：
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    /**
     在ARC的环境下OC对象可以不用手动释放，但是在Core Foundation框架下（C语言）使用带有"create"、"copy"、"retain"等字眼的函数时是需要手动释放的。因为上面创建observer对象的C语言函数中含有"create"字眼，所以需要在下面进行释放。
     */
    CFRelease(observer);
}

#pragma mark ————— 给RunLoop添加观察者的底层实现 —————
//上面方法的RunLoop的底层实现。
- (void)addObserverBottomedRealize
{
    //1、创建上下文信息：
    CFRunLoopObserverContext context = {
        0,
        ((__bridge void *)self),
        NULL,
        NULL,
        NULL
    };
    
    //2、获取当前的RunLoop对象：
    CFRunLoopRef rlp = CFRunLoopGetCurrent();
    
    /**
     3、初始化一个CFRunLoopObserverRef对象：
     参数一：用于分配对象的内存；
     参数二：你关注的事件；
     参数三：CFRunLoopObserver是否循环调用；
     参数四：当在Runloop同一运行阶段中有多个CFRunLoopObserver时，这个参数用来确定CFRunLoopObserver的优先级，一般情况下这个参数填0；
     参数五：回调函数，监听到Runloop状态改变以后的回调函数；
     参数六：上下文记录信息。
     */
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ZPRunLoopObserverCallBack, &context);
    
    //4、添加observer对象：
    CFRunLoopAddObserver(rlp, observerRef, kCFRunLoopDefaultMode);
}

#pragma mark ————— 回调函数 —————
void ZPRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    NSLog(@"%lu-%@",activity,info);
}

@end
