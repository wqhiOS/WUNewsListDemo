//
//  WUHomeViewController.m
//  WUNewsListDemo
//
//  Created by wuqh on 2017/4/5.
//  Copyright © 2017年 吴启晗. All rights reserved.
//

#import "WUHomeViewController.h"
#import "WUContentViewController.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
static const CGFloat TITLE_BOTTOM_LINE_HEIGHT = 3.f;
static const CGFloat TITLE_VIEW_HEIGHT = 44.f;
static const CGFloat TITLE_ITEM_WIDTH = 100.f;
static const NSUInteger BUTTON_TAG = 1000;


@interface WUHomeViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) UIView *titleBottomLine;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *controllers;

@end

@implementation WUHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.titleScrollView];
    [self.view addSubview:self.contentScrollView];
    
    //初始显示第一个contentView
    [self showContentView:self.contentScrollView];
}

#pragma mark - Action
- (void)itemClick:(UIButton *)button {
    NSInteger idx = button.tag - BUTTON_TAG;
    
    [self.contentScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*idx, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self showContentView:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self showContentView:scrollView];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x / scrollView.contentSize.width *self.titleScrollView.contentSize.width;
    CGRect bottomLineFrame = CGRectMake(offsetX, TITLE_VIEW_HEIGHT-TITLE_BOTTOM_LINE_HEIGHT, TITLE_ITEM_WIDTH, TITLE_BOTTOM_LINE_HEIGHT);
    self.titleBottomLine.frame = bottomLineFrame;
}

#pragma mark - Private
- (void)showContentView:(UIScrollView *)scrollView {
    //索引
    NSUInteger idx = scrollView.contentOffset.x / SCREEN_WIDTH;
    
    //titleScrollView button 相关
    UIButton *currentButton = [self.titleScrollView viewWithTag:BUTTON_TAG +idx];
    [currentButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    for (UIView *subView in self.titleScrollView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            if (button != currentButton) {
                 [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }

        }
    }
    
    //titleScrollView相关
    CGFloat titleScrollViewOffsetX = currentButton.center.x-SCREEN_WIDTH*0.5;
    if (titleScrollViewOffsetX < 0) titleScrollViewOffsetX = 0;
    if (titleScrollViewOffsetX > self.titleScrollView.contentSize.width - SCREEN_WIDTH) titleScrollViewOffsetX = self.titleScrollView.contentSize.width - SCREEN_WIDTH;
    [self.titleScrollView setContentOffset:CGPointMake(titleScrollViewOffsetX, 0) animated:YES];


    //添加contentView
    if (![self.childViewControllers[idx] isViewLoaded]) {
        UIView *contentView = self.childViewControllers[idx].view;
        contentView.frame = self.contentScrollView.bounds;
        [self.contentScrollView addSubview:contentView];
    }
}

#pragma mark - Getter
- (UIScrollView *)titleScrollView {
    if (!_titleScrollView) {
        _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, TITLE_VIEW_HEIGHT)];
        _titleScrollView.backgroundColor = [UIColor greenColor];
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        _titleScrollView.contentSize = CGSizeMake(TITLE_ITEM_WIDTH*self.titles.count, 0);
        [_titleScrollView addSubview:self.titleBottomLine];
        [self.titles enumerateObjectsUsingBlock:^(NSString*  _Nonnull text, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx * TITLE_ITEM_WIDTH, 0, TITLE_ITEM_WIDTH, TITLE_VIEW_HEIGHT);
            [button setTitle:text forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = BUTTON_TAG + idx;
            [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.titleScrollView addSubview:button];
        }];
        
    }
    return _titleScrollView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64+TITLE_VIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-64-TITLE_VIEW_HEIGHT)];
        _contentScrollView.backgroundColor = [UIColor lightGrayColor];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.delegate = self;
        _contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.titles.count, 0);
        _contentScrollView.showsHorizontalScrollIndicator = NO;

        [self.controllers enumerateObjectsUsingBlock:^(NSString*  _Nonnull vcClassStr, NSUInteger idx, BOOL * _Nonnull stop) {
            Class cls = NSClassFromString(vcClassStr);
            UIViewController *vc = [[cls alloc ] init];
            vc.title = self.titles[idx];
            [self addChildViewController:vc];
        }];
       
    }
    return _contentScrollView;
}

- (UIView *)titleBottomLine {
    if (!_titleBottomLine) {
        _titleBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, TITLE_VIEW_HEIGHT-TITLE_BOTTOM_LINE_HEIGHT, TITLE_ITEM_WIDTH, TITLE_BOTTOM_LINE_HEIGHT)];
        _titleBottomLine.backgroundColor = [UIColor orangeColor];
    }
    return _titleBottomLine;
}

// titles 与 controllers 是一一对应的
- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"湖人",@"火箭",@"凯尔特人",@"马刺",@"雷霆",@"公牛",@"步行者"];
    }
    return _titles;
}

- (NSArray *)controllers {
    if (!_controllers) {
        //这里应该是使用7个不同的控制器，我这里懒省事儿，就用一个了。。
        _controllers = @[@"WUContentViewController"
                         ,@"WUContentViewController"
                         ,@"WUContentViewController"
                         ,@"WUContentViewController"
                         ,@"WUContentViewController"
                         ,@"WUContentViewController"
                         ,@"WUContentViewController"];
    }
    return _controllers;
}


@end
