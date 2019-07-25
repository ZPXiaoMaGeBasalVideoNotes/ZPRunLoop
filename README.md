# ZPRunLoop
本Demo主要介绍了：  1、RunLoop的概念、作用、与线程的关系；  2、RunLoop的两套API，分别为OC语言中的Foundation框架下的NSRunLoop类和C语言中的Core Foundation框架中下的CFRunLoopRef类；  3、RunLoop的相关源码以及源码中比较重要的部分；  4、RunLoop的处理逻辑；  5、定时器的六种使用方式以及如何彻底地释放定时器对象；  6、视图控制器中定时器对象工作的同时，如果拖动UIScrollView控件的时候造成定时器对象停止工作的原因以及解决办法（定时器工作的同时，拖动UIScrollView控件，定时器对象也能继续工作）；  7、RunLoop的三大应用；  8、程序中延迟执行的六种方式；  9、如何利用RunLoop来创建一个常驻线程以及如何销毁这个常驻线程。
