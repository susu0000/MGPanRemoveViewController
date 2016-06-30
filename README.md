# 手势移除控制器

- 添加滑动手势
 - 自定义导航控制器，监听push事件
 - 截图Quart2D
 - 手势拖动时，把图片摆到后面去
 - 手松开的那一刻，解决pop还是还原。

![](/Screenshot/snip01.gif)


- 拖拽方法

```objc
- (void)dragging:(UIPanGestureRecognizer *)recognizer
{
    // 只有根控制器,停止拖拽
    if (self.childViewControllers.count <= 1) return;

    // 在x方向上挪动的距离
    CGFloat tx = [recognizer translationInView:self.view].x;
    if (tx < 0) return; // 禁止左滑动

    // 手指抬起来 或 结束拖拽
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {

        // 决定pop还是还原
        CGFloat x = self.view.frame.origin.x; // view的位置
        if (x >= self.view.frame.size.width * 0.5) {
            [UIView animateWithDuration:0.25 animations:^{

                self.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
            } completion:^(BOOL finished) {

                [self popViewControllerAnimated:NO];
                [self.lastVcView removeFromSuperview];
                [self.cover removeFromSuperview];
                self.view.transform = CGAffineTransformIdentity;

                [self.images removeLastObject];
            }];
        } else { // 还原
            self.view.transform = CGAffineTransformIdentity;
        }
    } else {
        // 移动view,以后只能右滑，push或pop
        // 用一个新的值，覆盖原来的值，不会每次累加,一次性
        self.view.transform = CGAffineTransformMakeTranslation(tx, 0);

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        // 添加截图到后面
        self.lastVcView.image = self.images[self.images.count -2];
        [window insertSubview:self.lastVcView atIndex:0];
        [window insertSubview:self.cover aboveSubview:self.lastVcView];
    }
}

```

- 截图
```objc
// 开启图形上下文
UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0);
// 调用截图方法
[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
// 获得图形上下文的图片
UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
[self.images addObject:image];
```

- 参考：
[]()
