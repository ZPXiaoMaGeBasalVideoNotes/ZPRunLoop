# ZPRunLoop
本Demo主要介绍了：

1、RunLoop的概念、作用、与线程的关系；

2、RunLoop的两套API，分别为OC语言中的Foundation框架下的NSRunLoop类和C语言中的Core Foundation框架中下的CFRunLoopRef类；

3、RunLoop的相关源码以及源码中比较重要的部分；

4、RunLoop的处理逻辑；

5、定时器的六种使用方式以及如何彻底地释放定时器对象；

6、视图控制器中定时器对象工作的同时，如果拖动UIScrollView控件的时候造成定时器对象停止工作的原因以及解决办法（定时器工作的同时，拖动UIScrollView控件，定时器对象也能继续工作）；

7、RunLoop的三大应用；

8、程序中延迟执行的六种方式；

9、如何利用RunLoop来创建一个常驻线程以及如何销毁这个常驻线程。

本Demo综合了“逻辑教育”和“小马哥视频2015年（没加密版）”以及“2018年9月iOS底层原理班（加密版）”中的“下（OC对象、关联对象、多线程、内存管理、性能优化）”的相关视频中的内容以及网上的相关资料，自己总结而成的，基本涵盖了RunLoop的所有内容和应用，并且把基于RunLoop的各种相关应用都进行了对比分析，较全面地阐述了RunLoop。

视频路径：逻辑教育——>付费课——>iOS进阶到项目实战——>正式视频——>20190227-进阶班-底层原理-第二讲-Runloop底层原理；

小马哥——>小马哥视频2015年（没加密版）——>05-多线程——>0710SDWebImage/RunLoop——>视频——>04-runloop01-简介.mp4.flv.mkv、05-runloop02-线程和runloop.mp4.flv.mkv、06-runloop03-cfrunloopmoderef.mp4.flv.mkv、07-runloop04-cfrunlooptimerref.mp4.flv.mkv；

小马哥——>小马哥视频2015年（没加密版）——>05-多线程——>0712RunLoop（加密）——>视频——>01-runloop01-nstimer_.mkv、02-runloop02-source_.mkv、03-runloop03-observer_.mkv、04-runloop04-整体处理逻辑_.mkv、04-runloop04-observer补充_.mkv、05-runloop实践01_.mkv、06-runloop实践02_.mkv、07-runloop实践03_.mkv、08-gcd定时器_.mkv；

小马哥——>小马哥视频2015年（没加密版）——>06-网络——>0713JSON/XML/解压缩——>视频——>16-runloop补充.mp4.flv.mkv。

小马哥——>2018年9月iOS底层原理班（加密版）——>下（OC对象、关联对象、多线程、内存管理、性能优化）——>2.底层下-原理——>day17——>138-Runloop01-基本认识.ev4、139-Runloop02-获取RunLoop对象.ev4、140-Runloop03-CFRunLoopModeRef.ev4、141-Runloop04-CFRunLoopModeRef的成员.ev4、142-Runloop05-CFRunLoopObserverRef.ev4、143-Runloop06-答疑.ev4；

小马哥——>2018年9月iOS底层原理班（加密版）——>下（OC对象、关联对象、多线程、内存管理、性能优化）——>2.底层下-原理——>day18——>144-Runloop07-执行流程图.ev4、145-Runloop08-源码分析.ev4、146-Runloop09-调用细节.ev4、147-Runloop10-休眠的细节.ev4、148-Runloop11-NSTimer失效.ev4、149-Runloop12-线程保活01.ev4、150-Runloop13-线程保活02_.ev4、151-Runloop14-线程保活03.ev4、152-Runloop15-线程保活04.ev4、153-Runloop16-答疑.ev4；

小马哥——>2018年9月iOS底层原理班（加密版）——>下（OC对象、关联对象、多线程、内存管理、性能优化）——>2.底层下-原理——>day19——>154-Runloop17-线程保活05.ev4、155-Runloop18-线程保活06.ev4、158-Runloop21-线程的封装03-C语言方式实现.ev4、159-Runloop22-答疑.ev4。
