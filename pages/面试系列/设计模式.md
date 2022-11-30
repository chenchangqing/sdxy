# 设计模式

1) 状态模式

在状态模式（State Pattern）中，类的行为是基于它的状态改变的。这种类型的设计模式属于行为型模式。

```java
public class StatePatternDemo {
   public static void main(String[] args) {
      Context context = new Context();
 
      StartState startState = new StartState();
      startState.doAction(context);
 
      System.out.println(context.getState().toString());
 
      StopState stopState = new StopState();
      stopState.doAction(context);
 
      System.out.println(context.getState().toString());
   }
}
```

>## 参考链接
 
[菜鸟·设计模式](https://www.runoob.com/design-pattern/design-pattern-tutorial.html)  
[[译] 使用 Swift 的 iOS 设计模式（第一部分）](https://zhuanlan.zhihu.com/p/51502187)  
[MVC，MVP 和 MVVM 的图示](https://www.ruanyifeng.com/blog/2015/02/mvcmvp_mvvm.html)