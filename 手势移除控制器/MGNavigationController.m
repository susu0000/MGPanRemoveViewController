//
//  MGNavigationController.m
//  66-手势移除控制器
//
//  Created by 穆良 on 16/6/30.
//  Copyright © 2016年 穆良. All rights reserved.
//

#import "MGNavigationController.h"
#import "LxDBAnything.h"

@interface MGNavigationController ()

/** 存放每一个控制器的全屏截图 */
@property (nonatomic, strong) NSMutableArray *images;

/** 上一个控制器的view */
@property (nonatomic, strong) UIImageView *lastVcView;

/** 后面的遮盖 */
@property (nonatomic, strong) UIView *cover;
@end

@implementation MGNavigationController

- (UIImageView *)lastVcView
{
    if (!_lastVcView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIImageView *lastVcView = [[UIImageView alloc] init];
        _lastVcView = lastVcView;
        lastVcView.frame = window.bounds;
    }
    return _lastVcView;
}

- (UIView *)cover
{
    if (!_cover) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *cover = [[UIView alloc] init];
        cover.frame = window.bounds;
        cover.backgroundColor = [UIColor blackColor];
        cover.alpha = 0.4;
        self.cover = cover;
    }
    return _cover;
}


- (NSMutableArray *)images
{
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}



// 也可在awakeFromNib
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 拖拽手势
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [self.view addGestureRecognizer:recognizer];
}

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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 先截图，保存上一张
//    [self createScreenShot];
    
    [super pushViewController:viewController animated:animated];
    
    [self createScreenShot];
    LxDBAnyVar(self.images.count);
}

#pragma mark - 截图
// 截第一张图
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 导航控制器viewWillAppear只调用一次，以后一值存在，不同于它的子控制器
//    if (self.childViewControllers.count > 1) return;
    LxDBAnyVar(self.childViewControllers.count);
    
    [self createScreenShot];
}

- (void)createScreenShot
{
    // 开启图形上下文
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0);
    // 调用截图方法
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    // 获得图形上下文的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 压缩保存- test
//        [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"/Users/MG/Desktop/%zd.png", self.childViewControllers.count] atomically:YES];
    [self.images addObject:image];
}

@end