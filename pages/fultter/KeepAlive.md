# KeepAlive

[源码](https://gitee.com/learnany/flutter/blob/master/lib/keep_alive_route.dart) [KeepAlive](https://book.flutterchina.club/chapter6/keepalive.html#_6-8-%E5%8F%AF%E6%BB%9A%E5%8A%A8%E7%BB%84%E4%BB%B6%E5%AD%90%E9%A1%B9%E7%BC%93%E5%AD%98) [AutomaticKeepAlive详解](https://juejin.cn/post/6979972557575782407)

1. 在列表项Widget的State中混入AutomaticKeepAliveClientMixin。
2. 覆写wantKeepAlive返回true。
3. 在build()内调用super.build(context)。