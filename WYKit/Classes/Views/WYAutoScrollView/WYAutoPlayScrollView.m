//
//  WYAutoPlaySrollView.m
//  WYostApp
//
//  Created by yingwang on 2016/10/27.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYAutoPlayScrollView.h"

#define DEFAULT_UNSELECTED_ALPHA 0.5
#define DEFAULT_SELECTED_WIDTH 2

@interface WYRoundRectPageControl : UIView
{
    UIColor *_pageDotColor;
}

@property (nonatomic, strong) UIColor *pageDotColor;
@property (nonatomic, assign) CGFloat pageDotRadius;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) BOOL loop;

- (instancetype)initWithFrame:(CGRect)frame pageCount:(NSInteger)count radius:(CGFloat)radius;

@end

@implementation WYRoundRectPageControl

- (instancetype)initWithFrame:(CGRect)frame pageCount:(NSInteger)count radius:(CGFloat)radius {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _pageCount = count;
        _pageDotRadius = radius > 0 ? radius : 3;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (UIColor *)pageDotColor {
    if (_pageDotColor) {
        return _pageDotColor;
    } else {
        return [UIColor whiteColor];
    }
}

- (void)setPageCount:(NSInteger)pageCount {
    _selectedIndex = 0;
    _progress = 0.0;
    _pageCount = MAX(0, pageCount);
    [self setNeedsDisplay];
}
- (void)setPageDotRadius:(CGFloat)pageDotRadius {
    _pageDotRadius = pageDotRadius > 0 ? pageDotRadius : 3;
    [self setNeedsDisplay];
}
- (void)setPageDotColor:(UIColor *)pageDotColor {
    _pageDotColor = pageDotColor;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGPoint boundsCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat totalDotWidth = (2*_pageCount + DEFAULT_SELECTED_WIDTH - 1)*2*_pageDotRadius;
    CGFloat startX = boundsCenter.x - totalDotWidth/2;
    CGFloat startY = boundsCenter.y - _pageDotRadius;
    CGFloat currentDotWidth;
    CGFloat currentX = startX;
    CGFloat currentProgress;
    
    UIColor *fillColor;
    
    if (_pageCount <= 0) return;
    // progress 表示向下一个或者前一个点的偏移进度，大于0表示向右，小于0表示向左
    // shouldDrawTransitionDot 表示偏移的方向是否有下一个点可以绘制
    BOOL shouldDrawTransitionDot = (_progress>0 && _selectedIndex<_pageCount-1)
                                    || (_progress<0 && _selectedIndex > 0) || _loop;//当loop为YES的时候，表示可以循环滚动
    
    // transitionDotIndex 表示当前点偏移方向的下一个需要绘制的点的下标
    NSInteger transitionDotIndex = 0;
    if (shouldDrawTransitionDot) {
        transitionDotIndex = _progress > 0 ? _selectedIndex + 1 : _selectedIndex - 1;
        transitionDotIndex = (transitionDotIndex + _pageCount) % _pageCount;
    }
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, 0.01);
    for (NSInteger idx = 0; idx < _pageCount; ++idx) {
        
        // 绘制当前点
        if (idx == _selectedIndex) {
            currentProgress = 1-fabs(_progress);
            currentDotWidth = 2*_pageDotRadius+2*_pageDotRadius*(DEFAULT_SELECTED_WIDTH)*currentProgress;
            fillColor = [self.pageDotColor colorWithAlphaComponent:DEFAULT_UNSELECTED_ALPHA * (1 + currentProgress)];
            [fillColor set];
            
            CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(currentX, startY, currentDotWidth, 2*_pageDotRadius),
                                                         _pageDotRadius, _pageDotRadius, &CGAffineTransformIdentity);
            CGContextAddPath(currentContext, path);
            CGContextFillPath(currentContext);
            currentX = currentX + currentDotWidth + 2*_pageDotRadius;
            
            // 绘制偏移方向的下一个点
        } else if(shouldDrawTransitionDot && idx == transitionDotIndex) {
            currentProgress = fabs(_progress);
            currentDotWidth = 2*_pageDotRadius+2*_pageDotRadius*(DEFAULT_SELECTED_WIDTH)*currentProgress;
            fillColor = [self.pageDotColor colorWithAlphaComponent:DEFAULT_UNSELECTED_ALPHA * (1 + currentProgress)];
            [fillColor set];
            CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(currentX, startY, currentDotWidth, 2*_pageDotRadius),
                                                         _pageDotRadius, _pageDotRadius, &CGAffineTransformIdentity);
            CGContextAddPath(currentContext, path);
            CGContextFillPath(currentContext);
            currentX = currentX + currentDotWidth + 2*_pageDotRadius;
            
            // 绘制其他点
        } else {
            currentDotWidth = _pageDotRadius*2;
            fillColor = [self.pageDotColor colorWithAlphaComponent:DEFAULT_UNSELECTED_ALPHA];
            [fillColor set];
            CGContextAddEllipseInRect(currentContext, CGRectMake(currentX, startY, currentDotWidth, currentDotWidth));
            CGContextFillPath(currentContext);
            currentX += 2*currentDotWidth;
        }
    }
}

@end

@interface WYTimerProxy : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
- (void)handleTimerAction:(NSTimer *)timer;
@end

@implementation WYTimerProxy

- (void)handleTimerAction:(NSTimer *)timer {
    if (_target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_selector withObject:timer];
#pragma clang diagnostic pop
    }
}

@end

@interface WYAutoPlayScrollView () <UIScrollViewDelegate>
{
    NSDate *_currentFiredDate;
    int *index_ref;
    NSInteger _currentIndex;
    
    BOOL _isRespondToImageViewMethod;
}

@property (nonatomic, strong) WYRoundRectPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *privateScrollView;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) NSTimer *repeatTimer;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation WYAutoPlayScrollView

#pragma mark - Life Cycle

- (void)dealloc {
    free(index_ref);
}

#pragma mark - Setter

- (void)setLoop:(BOOL)loop {
    _loop = loop;
    _pageControl.loop = _loop;
    [self reloadData];
}

- (void)setPagesCount:(NSInteger)pagesCount {
    _pagesCount = MAX(0, pagesCount);
    [self reloadData];
}

- (void)setActivityIndicatorAnimating:(BOOL)activityIndicatorAnimating {
    _activityIndicatorAnimating = activityIndicatorAnimating;
    
    _activityIndicatorAnimating ? [self.indicator startAnimating] : [self.indicator stopAnimating];
}

- (void)setDelegate:(id<WYAutoPlayScrollViewDelegate>)delegate {
    _delegate = delegate;
    
    if ([delegate conformsToProtocol:@protocol(WYAutoPlayScrollViewDelegate)]
        && [delegate respondsToSelector:@selector(autoPlayScrollView:imageView:atIndex:)]) {
        _isRespondToImageViewMethod = YES;
    } else {
        _isRespondToImageViewMethod = NO;
    }
}

- (UIActivityIndicatorView *)indicator {
    
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [self addSubview:_indicator];
    }
    
    return _indicator;
}

#pragma mark - Interface

- (void)reloadData {
    [self layoutIfNeeded];
    [self setupContents];
    [self setupTimer];
}

#pragma mark - Index Manage

- (NSInteger)indexBeforeIndex:(NSInteger)index {
    
    if (_loop) {
        return (index - 1 + _pagesCount) % _pagesCount;
    } else {
        return index - 1;
    }
}

- (NSInteger)indexAfterIndex:(NSInteger)index {
    
    if (_loop) {
        return (index + 1) % _pagesCount;
    } else {
        return index + 1;
    }
}

#pragma mark - Scroll Logic

- (void)scrollRight {
    _currentIndex = [self indexAfterIndex:_currentIndex];
    
    UIImageView *imageView;
    
    imageView = _imageViews[0];
    index_ref[0] = (int)[self indexBeforeIndex:_currentIndex];
    _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:index_ref[0]] :nil;
    
    imageView = _imageViews[1];
    index_ref[1] = (int)_currentIndex;
    _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:_currentIndex] :nil;
    
    [_privateScrollView setContentOffset:CGPointMake(CGRectGetWidth(_privateScrollView.bounds), 0) animated:NO];
    
    imageView = _imageViews[2];
    index_ref[2] = (int)[self indexAfterIndex:_currentIndex];
    _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:index_ref[2]] :nil;
}

- (void)scrollLeft {
    _currentIndex = [self indexBeforeIndex:_currentIndex];
    
    UIImageView *imageView;
    
    imageView = _imageViews[2];
    index_ref[2] = (int)[self indexAfterIndex:_currentIndex];
    _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:index_ref[2]] :nil;
    
    imageView = _imageViews[1];
    index_ref[1] = (int)_currentIndex;
    _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:_currentIndex] :nil;
    
    [_privateScrollView setContentOffset:CGPointMake(CGRectGetWidth(_privateScrollView.bounds), 0) animated:NO];
    
    imageView = _imageViews[0];
    index_ref[0] = (int)[self indexBeforeIndex:_currentIndex];
    _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:index_ref[0]] :nil;
}

- (void)beginScroll:(UIScrollView *)scrollView {
    scrollView.scrollEnabled = NO;
}

- (void)finishScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = _privateScrollView.frame.size.width;
    NSInteger index = round(_privateScrollView.contentOffset.x/pageWidth);
    
    if (!_loop) {
        
        if (_pagesCount < 3) {
            _currentIndex = index;
            scrollView.scrollEnabled = YES;
            return;
        }
        
        if (index == 1) {
            if (_currentIndex == 0 || _currentIndex == _pagesCount-1) {
                _currentIndex = (_currentIndex == 0) ? 1 : _currentIndex-1;
                scrollView.scrollEnabled = YES;
                return;
            }
        }
        
        if (_currentIndex >= _pagesCount-2 && index == 2) {
            _currentIndex = _pagesCount-1;
            scrollView.scrollEnabled = YES;
            return;
        }
        
        if (_currentIndex <= 1 && index == 0) {
            _currentIndex = 0;
            scrollView.scrollEnabled = YES;
            return;
        }
    }
    
    if (index == 2) {
        [self scrollRight];
    }
    
    if (index == 0) {
        [self scrollLeft];
    }
    
    scrollView.scrollEnabled = YES;
}

#pragma mark - Setup

- (void)initializeSubviews {
    
    // setup scrollView
    
    _privateScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _privateScrollView.decelerationRate = 0.5;
    _privateScrollView.delegate = self;
    _privateScrollView.pagingEnabled = YES;
    _privateScrollView.showsHorizontalScrollIndicator = NO;
    _privateScrollView.showsVerticalScrollIndicator = NO;
    [self insertSubview:_privateScrollView atIndex:0];
    
    // setup imageViews
    
    UIImageView *imageView;
    _imageViews = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger idx = 0; idx < 3; ++ idx) {
        imageView = [[UIImageView alloc] init];
        [_imageViews addObject:imageView];
        
        [_privateScrollView addSubview:imageView];
    }
    
    // setup ref
    
    index_ref = malloc(3 * sizeof(int));
    
    // setup layout
    
    UIEdgeInsets padding;
    _privateScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:_privateScrollView
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:self
                                                 attribute:NSLayoutAttributeTop
                                                multiplier:1.0 constant:padding.top];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:_privateScrollView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0 constant:padding.left];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:_privateScrollView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0 constant:-padding.right];
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:_privateScrollView
                                                    attribute:NSLayoutAttributeBottom
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeBottom
                                                   multiplier:1.0 constant:-padding.bottom];
    [self addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintBottom]];
    
    UITapGestureRecognizer *reg = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:reg];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadData];
}

- (void)setupTimer {
//    return;
    
    if (_repeatTimer) {
        [_repeatTimer invalidate];
    }
    
    if (_autoPlayInterval <= 0 || _pagesCount < 2) {
        return;
    }
    
    WYTimerProxy *proxy = [[WYTimerProxy alloc] init];
    proxy.target = self;
    proxy.selector = @selector(handleTimerAction:);
    
    _repeatTimer = [NSTimer scheduledTimerWithTimeInterval:_autoPlayInterval
                                                    target:proxy
                                                  selector:@selector(handleTimerAction:)
                                                  userInfo:nil repeats:YES];
    _repeatTimer.tolerance = _autoPlayInterval * 0.02;
    _currentFiredDate = [NSDate dateWithTimeIntervalSinceNow:0];
}

- (void)setupContents {
    
    if (!_privateScrollView) {
        [self initializeSubviews];
    }
    
    if (!_pageControl) {
        
        _pageControl = [[WYRoundRectPageControl alloc] init];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.pageCount = _pagesCount;
        _pageControl.pageDotRadius = 3;
        _pageControl.loop = _loop;
        
        [self addSubview:_pageControl];
        
        UIEdgeInsets padding;
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        padding = UIEdgeInsetsMake(0, 0, 0, 0);
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:_pageControl
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0 constant:30.f];
        NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:_pageControl
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0 constant:padding.left];
        NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:_pageControl
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0 constant:-padding.right];
        NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:_pageControl
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-padding.bottom];
        [self addConstraints:@[constraintHeight, constraintLeft, constraintRight, constraintBottom]];
        
    } else {
        _pageControl.pageCount = _pagesCount;
    }
    
    NSInteger maxPage;
    
    if (_loop) {
        maxPage = _pagesCount ? 3 : 0;
    } else {
        maxPage = MIN(_pagesCount, 3);
    }
    
    _privateScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.privateScrollView.bounds)*maxPage,
                                                CGRectGetHeight(self.privateScrollView.bounds));
    if (_pagesCount == 0) return;
    
    if (_loop) [_privateScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.privateScrollView.bounds), 0) animated:NO];
    
    [self initializeImageViews];
}

- (void)initializeImageViews {
    
    _currentIndex = 0;
    _pageControl.selectedIndex = 0;
    _privateScrollView.scrollEnabled = YES;
    
    NSInteger idx = 0;
    for (UIImageView *imageView in _imageViews) {
        
        imageView.frame = CGRectMake(idx*CGRectGetWidth(_privateScrollView.bounds)+self.contentViewInset.left, self.contentViewInset.top,
                                     CGRectGetWidth(_privateScrollView.bounds)-(self.contentViewInset.left+self.contentViewInset.right),
                                     CGRectGetHeight(_privateScrollView.bounds)-(self.contentViewInset.top+self.contentViewInset.bottom));
        
        if (idx < _pagesCount || _loop) {
            
            NSInteger index = _loop ? (idx-1+_pagesCount)%_pagesCount : idx;
            index_ref[idx] = (int)index;
            _isRespondToImageViewMethod ? [_delegate autoPlayScrollView:self imageView:imageView atIndex:index]:nil;
        }
        
        ++idx;
    }
}

#pragma mark - Respond Method

- (void)handleTimerAction:(NSTimer *)timer {
    // if timer fire after a time 5% of _autoPlayInterval, duplicate it.
    if ([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:_currentFiredDate] > _autoPlayInterval * 1.05) {
        _currentFiredDate = [NSDate dateWithTimeIntervalSinceNow:0];
        return;
    }
    
    CGFloat pageWidth = _privateScrollView.frame.size.width;
    NSInteger index = round(_privateScrollView.contentOffset.x/pageWidth);
    if(index < 0) index = 0;
    if(index >= _pagesCount) index = _pagesCount;
    
    NSInteger destination = index + 1;
    if (!_loop && index == MIN(2, _pagesCount-1)) destination = 0;
    
    CGFloat offsetX = (destination)%(NSInteger)(_privateScrollView.contentSize.width/pageWidth) * pageWidth;
    BOOL animated = (_loop || index < MIN(2, _pagesCount-1));
    
    [self beginScroll:_privateScrollView];
    [_privateScrollView setContentOffset:CGPointMake(offsetX, _privateScrollView.contentOffset.y)
                                animated:animated];
    
    if (!_loop && destination == 0) [self initializeImageViews];
    
    _currentFiredDate = [NSDate dateWithTimeIntervalSinceNow:0];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    
    // to make sure scrollView was decelerating finish, otherwise tapp will get a wrong index
    if (_privateScrollView.decelerating) return;
    // if no page in scroll view, tap action should not be call
    if (_pagesCount == 0) return;
    
    // notify delegate
    if ([_delegate conformsToProtocol:@protocol(WYAutoPlayScrollViewDelegate)]
        && [_delegate respondsToSelector:@selector(autoPlayScrollView:didSelectedCellAtIndex:)]) {
        [_delegate autoPlayScrollView:self didSelectedCellAtIndex:_currentIndex];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self finishScroll:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self beginScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self finishScroll:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = _privateScrollView.frame.size.width;
    NSInteger index = round(_privateScrollView.contentOffset.x/pageWidth);
    
    NSInteger maxIndex = _loop? 2 : MIN(2, _pagesCount-1);
    
    if (index < 0 || index > maxIndex) {
        return;
    }
    
    CGFloat progress = (_privateScrollView.contentOffset.x - index*pageWidth) / pageWidth;
    _pageControl.selectedIndex = index_ref[index];
    _pageControl.progress = progress;
}

@end

