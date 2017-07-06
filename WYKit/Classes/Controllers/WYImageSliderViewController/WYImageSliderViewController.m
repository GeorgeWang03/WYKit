//
//  WYImageSliderViewController.m
//  WYKit
//
//  Created by yingwang on 2016/11/21.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <objc/runtime.h>
#import "Masonry.h"
#import "UIImage+WYExtension.h"
#import "UIImageView+WebCache.h"
#import "WYImageSliderViewController.h"

@interface WYSingleImageScrollView : UIScrollView <UIScrollViewDelegate>
{
    CGFloat _currentScale;
    UIGestureRecognizer *_onceTapGestureRecognizer;
}

@property (nonatomic) CGFloat maxScale;
@property (nonatomic) NSUInteger index;
@property (nonatomic, weak) WYImageSliderViewController *parentViewController;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *placeholderImage;

- (void)resetImageViewFrame;

@end

@interface WYImageSliderViewController () <UIScrollViewDelegate>
{
    NSUInteger _currentImageIndex;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSMutableArray *imageViewsArray;
@property (nonatomic, strong) UIImageView *backgroundImageView;
// bottom bar
@property (nonatomic, strong) UILabel *pageIndicator;
@property (nonatomic, strong) UIButton *downloadButton;

// title view
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *titleView;

- (void)configureViewComponentAtIndex:(NSInteger)index;
- (void)toggleFullScreenAnimation:(BOOL)animation;

@end

@implementation WYSingleImageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        [self setupSubview];
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    __weak typeof(self) weakSelf = self;
    [_imageView setShowActivityIndicatorView:YES];
    [_imageView setIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_imageView sd_setImageWithURL:_imageURL
                  placeholderImage:self.placeholderImage
                           options:SDWebImageTransformAnimatedImage
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             [strongSelf.imageView setShowActivityIndicatorView:NO];
                             
                             strongSelf.maxScale = CGRectGetHeight(strongSelf.bounds) / (CGRectGetWidth(strongSelf.bounds) * image.size.height/image.size.width);
                             strongSelf.maximumZoomScale = strongSelf.maxScale;
                             
                             strongSelf.imageView.alpha = 0;
                             [UIView animateWithDuration:0.4 animations:^{
                                 strongSelf.imageView.alpha = 1;
                             }];
                             
                             // 如果背景图还未初始化，那么进行图片设置，此操作每个实例只执行一次
                             if (strongSelf.index == 0 && !strongSelf.parentViewController.backgroundImageView.image) {
                                 [strongSelf.parentViewController configureViewComponentAtIndex:0];
                             }
                         }];
}

- (void)setupSubview {
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 10.0;
    
    _imageView = [self createImageView];
    _imageView.frame = self.bounds;
    [self addSubview:_imageView];
}

- (UIImageView *)createImageView {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *onceTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleOnceTapGestureRecognizer:)];
    onceTap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:onceTap];
    
    UITapGestureRecognizer *twiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleTwiceTapGestureRecognizer:)];
    twiceTap.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:twiceTap];
    
    [onceTap requireGestureRecognizerToFail:twiceTap];
    
    return imageView;
}

- (void)resetImageViewFrame {
    _imageView.transform = CGAffineTransformIdentity;
    [self updateContentWithScrollingToCenter:YES];
}

// scrollCenter : 是否滑动到中心位置
- (void)updateContentWithScrollingToCenter:(BOOL)scrollCenter {
    
    CGFloat contentWidth = CGRectGetWidth(_imageView.frame);
    self.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(self.bounds));
    _imageView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    if (scrollCenter) {
        self.contentOffset = CGPointMake((CGRectGetWidth(_imageView.frame) - CGRectGetWidth(self.bounds))/2, self.contentOffset.y);
    }
}

#pragma mark - action handler

- (void)handleOnceTapGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    
    [self.parentViewController toggleFullScreenAnimation:YES];
}

- (void)handleTwiceTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    
    UIImageView *imageView = (UIImageView *)recognizer.view;
    
    if (!CGAffineTransformEqualToTransform(imageView.transform, CGAffineTransformIdentity)) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             imageView.transform = CGAffineTransformIdentity;
                             [self updateContentWithScrollingToCenter:YES];
                         }];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             imageView.transform = CGAffineTransformMakeScale(_maxScale, _maxScale);
                             [self updateContentWithScrollingToCenter:YES];
                         }];
    }
    
    return;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height/2-CGRectGetHeight(self.bounds)/2);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

@end


@implementation WYImageSliderViewController

- (void)setImageURLs:(NSArray *)imageURLs {
    _imageURLs = imageURLs;
    [self setupImageViews];
}

- (void)loadView {
    
    _currentImageIndex = -1;
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (!_mainScrollView) {
        [self setupSubviews];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //by wukerui for还原状态栏样式
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent) {
        self.view.tag = 101;
    }
    
    [self configNavigationBarForShowing];
    
    [self setupImageViews];
    [self scrollImageToIndex:self.initialImageIndex];
    [self configureViewComponentAtIndex:_currentImageIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configNavigationBarForShowing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self configNavigationBarForDismissing];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self configNavigationBarForDismissing];
    
    //by wukerui for还原状态栏样式
    if (self.view.tag == 101) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

#pragma mark - view logic

// 滑动到某张图片
// 由于存在重用机制，过程比较复杂
- (void)scrollImageToIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.imageURLs.count || index == _currentImageIndex)
        return;
    
    // 是否在现有的可用图片中，也就是在当前的imageViewsArray里面
    BOOL inRangeOfCurrentImageViews = (index >= [[self.imageViewsArray firstObject] index])
    && (index <= [[self.imageViewsArray lastObject] index]);
    
    // 如果是的话，调整一下位置，然后滑动scrollView
    if (inRangeOfCurrentImageViews) {
        
        // 重用调整
        [self updateImageViewToIndex:index];
        
    } else {
        // 如果不是，那么就要移动 现有的imageView的位置，到达目标图片的位置
        // 并滑动scrollView
        // 值得注意的是，在imageURLs.cout小于等于5的时候，这种情况不会出现
        void(^changeImageViewBlock)(WYSingleImageScrollView *, NSUInteger) = ^(WYSingleImageScrollView *imageView, NSUInteger idx) {
            CGFloat x = idx * CGRectGetWidth([UIScreen mainScreen].bounds);
            CGRect frame = CGRectMake(x, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
            imageView.frame = frame;
            imageView.index = idx;
            imageView.imageURL = [NSURL URLWithString:self.imageURLs[idx]];
            imageView.placeholderImage = self.placeholderImage;
        };
        
        // 开始重置的位置
        // 默认是目标图片的前两个
        NSInteger startIndex = index-2;
        // 如果目标图片是第一或第二张图片
        // 那么从0开始调整
        if (index < 2) startIndex = 0;
        // 如果目标图片是倒数第一或第二张图片
        // 那么从倒数第5开始调整
        if (index >= self.imageURLs.count-5) startIndex = self.imageURLs.count-5;
        
        for (NSInteger i=0; i < 5; ++i) {
            changeImageViewBlock(self.imageViewsArray[i], startIndex+i);
        }
    }
    
    // 最后滑动scrollView到目标位置
    [self.mainScrollView setContentOffset:CGPointMake(index*CGRectGetWidth([UIScreen mainScreen].bounds), 0)];
    //重新设定当前位置
    [self configureViewComponentAtIndex:index];
    _currentImageIndex = index;
}

- (void)configureViewComponentAtIndex:(NSInteger)index {
    
    _backgroundImageView.image = [self getImageViewAtIndex:index].imageView.image ?: [UIImage wy_imageFromColor:[UIColor blackColor]];
    
    // 设置标题及位置
    NSString *title = (index >= 0 && _titles.count > index) ? _titles[index] : nil;
    // 如果标题为空或者长度为0，隐藏标题,
    _titleView.hidden = !(title && title.length > 0);
    _titleLabel.text = title;
    [_titleView layoutIfNeeded];
    // 当查看器全屏时，更新标题位移的距离
    if (!(CGAffineTransformEqualToTransform(_titleView.transform, CGAffineTransformIdentity))) {
        _titleView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_titleView.frame));
    }
    
    // 设置页码及样式
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu/%lu", index+1, _imageURLs.count]];
    NSRange range = [string.string rangeOfString:@"/"];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:18.f] range:NSMakeRange(0, range.location)];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:13.f] range:NSMakeRange(range.location, string.string.length-range.location)];
    _pageIndicator.attributedText = string;
}

- (void)toggleFullScreenAnimation:(BOOL)animation {
    
    CGAffineTransform titleTransform;
    CGAffineTransform navigationBarTransform;
    CGFloat navigationBarAlpha;
    BOOL statusBarHidden;
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        statusBarHidden = NO;
        titleTransform = CGAffineTransformIdentity;
        navigationBarTransform = CGAffineTransformIdentity;
        navigationBarAlpha = 1.0;
    } else {
        statusBarHidden = YES;
        titleTransform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_titleView.frame));
        navigationBarTransform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.navigationController.navigationBar.frame)-10);
        navigationBarAlpha = 0;
    }
    
    if (!statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden
                                                withAnimation:UIStatusBarAnimationNone];
    }
    if (animation) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             _titleView.transform = titleTransform;
                             self.navigationController.navigationBar.alpha = navigationBarAlpha;
                         } completion:^(BOOL finished) {
                             if (statusBarHidden) {
                                 [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden
                                                                         withAnimation:UIStatusBarAnimationNone];
                                 self.navigationController.navigationBar.alpha = navigationBarAlpha;
                             }
                         }];
    } else {
        _titleView.transform = titleTransform;
        self.navigationController.navigationBar.alpha = navigationBarAlpha;
    }
}

#pragma mark - setup view

- (void)setupSubviews {
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupBlurEffectImageView];
    [self setupScrollView];
    [self setupTitleLabel];
    [self setupBottomBar];
}

- (void)setupScrollView {
    
    _mainScrollView = [[UIScrollView alloc] init];
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.alwaysBounceHorizontal = YES;
    _mainScrollView.alwaysBounceVertical = NO;
    _mainScrollView.scrollsToTop = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainScrollView];
    
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [_mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.height.equalTo(@([UIScreen mainScreen].bounds.size.height));
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
    }];
}

- (WYSingleImageScrollView *)getImageViewAtIndex:(NSUInteger)index {
    
    if (index >= _imageURLs.count) {
        return nil;
    }
    
    NSUInteger reuseIndex = 2;
    if (_imageURLs.count <= 5 || index < 2) {
        reuseIndex = index;
    } else if (index >= _imageURLs.count-2) {
        reuseIndex = 2 + index - (_imageURLs.count-3);
    }
    
    return reuseIndex < _imageViewsArray.count ? _imageViewsArray[reuseIndex] : nil;
}

- (void)updateImageViewToIndex:(NSUInteger)index {
    
    // DDLogDebug(@"update index %lu", index);
    // 位置没有变化，不调整
    if (index == _currentImageIndex) return;
    
    // 恢复隐藏图片的大小及位置
    WYSingleImageScrollView *imageScrollView = [self getImageViewAtIndex:index-1];
    [imageScrollView resetImageViewFrame];
    imageScrollView = [self getImageViewAtIndex:index+1];
    [imageScrollView resetImageViewFrame];
    
    // 重用逻辑 👇
    
    // 图片数量和视图重用个数相同，不调整
    if (_imageURLs.count <= 5) return;
    // 重用循环到边界的时候，不再调整位置
    if (index < 2 || index >= _imageURLs.count - 2) return;
    
    BOOL scrollLeft = _currentImageIndex > index;
    BOOL scrollRight = _currentImageIndex < index;
    // 重用循环到边界的时候，不再调整位置
    if ((index == 2 && scrollRight) || (index == _imageURLs.count-3 && scrollLeft))
        return;
    
    void(^changeImageViewBlock)(WYSingleImageScrollView *, NSUInteger) = ^(WYSingleImageScrollView *imageView, NSUInteger idx) {
        CGFloat x = idx * CGRectGetWidth([UIScreen mainScreen].bounds);
        CGRect frame = CGRectMake(x, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        imageView.frame = frame;
        imageView.index = idx;
        imageView.imageURL = [NSURL URLWithString:self.imageURLs[idx]];
        imageView.placeholderImage = self.placeholderImage;
    };
    
    // 重用的核心 👇
    WYSingleImageScrollView *imageView;
    if (scrollLeft) {
        imageView = [_imageViewsArray lastObject];
        [_imageViewsArray removeLastObject];
        [_imageViewsArray insertObject:imageView atIndex:0];
        changeImageViewBlock(imageView, index-2);
    }
    
    if (scrollRight) {
        imageView = [_imageViewsArray firstObject];
        [_imageViewsArray removeObjectAtIndex:0];
        [_imageViewsArray addObject:imageView];
        changeImageViewBlock(imageView, index+2);
    }
}

- (void)setupImageViews {
    
    [self.view layoutIfNeeded];
    
    CGFloat boundWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat boundHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    [self.imageViewsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 设置 contentSize
    _mainScrollView.contentSize = CGSizeMake(_imageURLs.count*boundWidth, boundHeight);
    
    if (!_imageURLs || !_imageURLs.count) {
        [self configureViewComponentAtIndex:_currentImageIndex];
        return;
    }
    
    _imageViewsArray = [NSMutableArray array];
    
    // 初始化下标
//    _currentImageIndex = 0;
    WYSingleImageScrollView *imageScrollView;
    for (NSUInteger idx = 0; idx < _imageURLs.count && idx < 5; ++idx) {
        
        CGFloat x = idx * boundWidth;
        CGRect frame = CGRectMake(x, 0, boundWidth, boundHeight);
        imageScrollView = [[WYSingleImageScrollView alloc] initWithFrame:frame];
        imageScrollView.parentViewController = self;
        imageScrollView.index = idx;
        [_imageViewsArray addObject:imageScrollView];
        
        NSString *urlString = _imageURLs[idx];
        NSURL *url = [NSURL URLWithString:urlString];
        imageScrollView.placeholderImage = self.placeholderImage;
        imageScrollView.imageURL = url;
        
        [self.mainScrollView addSubview:imageScrollView];
    }
}

- (void)setupBlurEffectImageView {
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.layer.masksToBounds = YES;
        [self.view addSubview:_backgroundImageView];
        
        __weak typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(60, 0, 0, 0);
        [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.height.equalTo(@(CGRectGetHeight([UIScreen mainScreen].bounds)));
            make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
            make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
            make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        }];
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [_backgroundImageView addSubview:effectView];
        
        padding = UIEdgeInsetsMake(0, 0, 0, 0);
        [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            make.top.equalTo(strongSelf.backgroundImageView.mas_top).with.offset(padding.top);
            make.left.equalTo(strongSelf.backgroundImageView.mas_left).with.offset(padding.left);
            make.bottom.equalTo(strongSelf.backgroundImageView.mas_bottom).with.offset(-padding.bottom);
            make.right.equalTo(strongSelf.backgroundImageView.mas_right).with.offset(-padding.right);
        }];
    }
}

- (void)setupBottomBar {
    
    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomBar];
    
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(60, 0, 0, 0);
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.height.equalTo(@40);
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
    }];
    
    _pageIndicator = [[UILabel alloc] init];
    _pageIndicator.textColor = [UIColor grayColor];
    [bottomBar addSubview:_pageIndicator];
    
    padding = UIEdgeInsetsMake(0, 10, 0, 0);
    [_pageIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomBar.mas_top).with.offset(padding.top);
        make.left.equalTo(bottomBar.mas_left).with.offset(padding.left);
        make.bottom.equalTo(bottomBar.mas_bottom).with.offset(-padding.bottom);
    }];
    
    _downloadButton = [[UIButton alloc] init];
    [_downloadButton addTarget:self
                        action:@selector(handleDowloadButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton setImage:[[UIImage imageNamed:@"app_ic_home_add@3x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateNormal];
    [bottomBar addSubview:_downloadButton];
    
    padding = UIEdgeInsetsMake(10, 0, 10, 20);
    [_downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.top.equalTo(bottomBar.mas_top).with.offset(padding.top);
        make.width.equalTo(strongSelf.downloadButton.mas_height).multipliedBy(1.f);
        make.bottom.equalTo(bottomBar.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(bottomBar.mas_right).with.offset(-padding.right);
    }];
    
    UIView *seperator = [[UIView alloc] init];
    seperator.backgroundColor = [UIColor darkGrayColor];
    [bottomBar addSubview:seperator];
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [seperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomBar.mas_top).with.offset(padding.top);
        make.left.equalTo(bottomBar.mas_left).with.offset(padding.left);
        make.right.equalTo(bottomBar.mas_right).with.offset(-padding.right);
        make.height.equalTo(@.6);
    }];
}

- (void)setupTitleLabel {
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textColor = [UIColor whiteColor];
    
    UIView *backgroundView = [[UIView alloc] init];
    _titleView = backgroundView;
    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:backgroundView];
    [backgroundView addSubview:_titleLabel];
    
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(60, 0, 40, 0);
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
    }];
    
    padding = UIEdgeInsetsMake(10, 10, 10, 10);
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backgroundView.mas_top).with.offset(padding.top);
        make.left.equalTo(backgroundView.mas_left).with.offset(padding.left);
        make.bottom.equalTo(backgroundView.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(backgroundView.mas_right).with.offset(-padding.right);
    }];
}


- (void)configNavigationBarForShowing {
    
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    UIView *subview;
    UIView *targetView;
    for (subview in self.navigationController.navigationBar.subviews) {
        if ([subview isKindOfClass:objc_getClass("_UIBarBackground")]) {
            [subview setHidden:YES];
        }
        if (subview.tag == 1101) {
            targetView = subview;
        }
    }
    
    if (!targetView) {
        CGRect frame = self.navigationController.navigationBar.frame;
        frame.size.height += 60;
        frame.origin.y = -20;
        CGPoint startPoint = CGPointZero;
        CGPoint endPoint = CGPointMake(0, CGRectGetHeight(frame));
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.tag = 1101; // 标记用于后面定位，不能更改
        imageView.image = [UIImage wy_gradientImageFromColors:@[[UIColor blackColor], [UIColor colorWithWhite:0 alpha:0]]
                                                        frame:imageView.bounds
                                                   startPoint:startPoint
                                                     endPoint:endPoint];
        [self.navigationController.navigationBar insertSubview:imageView atIndex:0];
    }
    //    [subview setHidden:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)configNavigationBarForDismissing {
    
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    UIView *subview;
    UIView *targetView;
    for (subview in self.navigationController.navigationBar.subviews) {
        if ([subview isKindOfClass:objc_getClass("_UIBarBackground")]) {
            [subview setHidden:NO];
        }
        if (subview.tag == 1101) {
            targetView = subview;
        }
    }
    
    [targetView removeFromSuperview];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
#pragma mark - UIScrollView delegate
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    WYSingleImageScrollView *slider = [self getImageViewAtIndex:_currentImageIndex];
//    return slider.imageView;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    
    NSUInteger index = roundf(scrollView.contentOffset.x / CGRectGetWidth(self.mainScrollView.frame));
    // 重用调整
    [self updateImageViewToIndex:index];
    //重新设定当前位置
    _currentImageIndex = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self configureViewComponentAtIndex:_currentImageIndex];
}

#pragma mark - bussiness logic

- (void)handleDowloadButtonAction:(UIButton *)sender {
    
    WYSingleImageScrollView *slider =   [self getImageViewAtIndex:_currentImageIndex];
    UIImageWriteToSavedPhotosAlbum(slider.imageView.image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo: (void *) contextInfo; {

}

@end
