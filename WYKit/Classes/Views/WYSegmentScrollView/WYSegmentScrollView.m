//
//  WYSegmentScrollView.m
//  WYKit
//
//  Created by yingwang on 2017/1/4.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import "WYSegmentScrollView.h"

#define DEFAULT_SEGMENTOR_WIDTH 80.0

@interface WYSegmentScrollView () <UIScrollViewDelegate>
{
    NSInteger _currrentIndex;
}

@property (nonatomic, strong) UIScrollView *segmentScrollView;
@property (nonatomic, strong) UIScrollView *itemScrollView;
@property (nonatomic, strong) UIView *decoratedLine;

@property (nonatomic, strong) NSMutableArray *segmentors;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation WYSegmentScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _segmentable = YES;
        _segmentorHeight = 44;
        _currrentIndex = 0;
        _titleFont = [UIFont systemFontOfSize:14];
        _highlightedColor = [UIColor cyanColor];
        _normalColor = [UIColor darkGrayColor];
    }
    
    return self;
}

- (UIView *)decoratedLine {
    if (!_decoratedLine) {
        _decoratedLine = [[UIView alloc] init];
    }
    
    return _decoratedLine;
}

- (UIScrollView *)segmentScrollView {
    if (!_segmentScrollView) {
        _segmentScrollView = [[UIScrollView alloc] init];
        _segmentScrollView.backgroundColor = [UIColor whiteColor];
        _segmentScrollView.showsVerticalScrollIndicator = NO;
        _segmentScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_segmentScrollView];
    }
    
    _segmentScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _segmentorHeight);
    return _segmentScrollView;
}

- (UIScrollView *)itemScrollView {
    if (!_itemScrollView) {
        _itemScrollView = [[UIScrollView alloc] init];
        _itemScrollView.delegate = self;
        _itemScrollView.pagingEnabled = YES;
        _itemScrollView.showsVerticalScrollIndicator = NO;
        _itemScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_itemScrollView];
    }
    
    _itemScrollView.frame = CGRectMake(0, _segmentorHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) -  _segmentorHeight);
    return _itemScrollView;
}

- (NSMutableArray *)segmentors {
    if (!_segmentors) {
        _segmentors = [NSMutableArray array];
    }
    
    return _segmentors;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    return _items;
}

- (NSInteger)currentViewIndex {
    return _currrentIndex;
}

- (void)setSegmentable:(BOOL)segmentable {
    _segmentable = segmentable;
    
    self.itemScrollView.scrollEnabled = _segmentable;
    self.segmentScrollView.scrollEnabled = _segmentable;
}

- (void)reloadData {
    
    _currrentIndex = 0;
    [self setupSegmentors];
    [self setupItems];
}

- (void)setupSegmentors {
    
    NSAssert([_dataSource respondsToSelector:@selector(numberOfItemInSegmentScrollView:)], @"WYSegmentScrollView : DataSource should respond to method numberOfItemInSegmentScrollView:");
    NSAssert([_dataSource respondsToSelector:@selector(segmentScrollView:titleForSegmentorAtIndex:)], @"WYSegmentScrollView : DataSource should respond to method segmentScrollView:titleForSegmentorAtIndex:");
    
    CGFloat contentWidth = 0;
    CGFloat segmentorWidth;
    CGFloat segmentorHeight = _segmentorHeight;
    NSInteger numberOfSegmentors;
    UIButton *segmentor;
    NSString *title;
    
    numberOfSegmentors = [_dataSource numberOfItemInSegmentScrollView:self];
    
    [self.segmentors makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger idx = 0; idx < numberOfSegmentors; ++ idx) {
        
        if (self.segmentors.count > idx) {
            segmentor = self.segmentors[idx];
        } else {
            segmentor = [[UIButton alloc] init];
            [segmentor addTarget:self action:@selector(handleSegmentorButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
            [self.segmentors addObject:segmentor];
        }
        
        if ([_delegate respondsToSelector:@selector(segmentScrollView:widthForSegmentorAtIndex:)]) {
            segmentorWidth = [_delegate segmentScrollView:self widthForSegmentorAtIndex:idx];
        } else {
            segmentorWidth = DEFAULT_SEGMENTOR_WIDTH;
        }
        
        // button highlighted initialize
        segmentor.highlighted = !idx;
        
        // decoratorLine
        if (idx == 0) {
            self.decoratedLine.frame = CGRectMake(0, segmentorHeight-2, segmentorWidth, 2);
            self.decoratedLine.backgroundColor = _highlightedColor;
            [self.segmentScrollView addSubview:self.decoratedLine];
        }
        
        title = [_dataSource segmentScrollView:self titleForSegmentorAtIndex:idx];
        [segmentor setTitle:title forState:UIControlStateNormal];
        [segmentor setTitleColor:_normalColor forState:UIControlStateNormal];
        [segmentor setTitleColor:_highlightedColor forState:UIControlStateHighlighted];
        segmentor.titleLabel.font = _titleFont;
        
        segmentor.tag = idx; // set idx by tag, should not change it cause it will be used later
        
        segmentor.frame = CGRectMake(contentWidth, 0, segmentorWidth, segmentorHeight);
        [self.segmentScrollView addSubview:segmentor];
        
        contentWidth += segmentorWidth;
    }
    
    [self.segmentScrollView setContentSize:CGSizeMake(contentWidth, _segmentorHeight)];
}

- (void)setupItems {
    
    NSAssert([_dataSource respondsToSelector:@selector(numberOfItemInSegmentScrollView:)], @"WYSegmentScrollView : DataSource should respond to method numberOfItemInSegmentScrollView:");
    
    NSInteger numberOfSegmentors;
    CGFloat contentWidth;
    UIView *view;
    
    numberOfSegmentors = [_dataSource numberOfItemInSegmentScrollView:self];
    contentWidth = numberOfSegmentors * CGRectGetWidth(self.itemScrollView.bounds);
    
    [self.itemScrollView setContentSize:CGSizeMake(contentWidth, CGRectGetHeight(self.itemScrollView.bounds))];
    
    [self.itemScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger idx = 0; idx < numberOfSegmentors; ++ idx) {
        view = [_dataSource segmentScrollView:self viewForSegmentorAtIndex:idx];
        view.frame = CGRectMake(idx*CGRectGetWidth(self.itemScrollView.bounds), 0, CGRectGetWidth(self.itemScrollView.bounds), CGRectGetHeight(self.itemScrollView.bounds));
        [self.itemScrollView addSubview:view];
    }
}

- (void)changeSegmentBarAppearenceForItemScrollViewContentOffetX:(CGFloat)x {
    
    CGFloat coX = x;
    CGFloat width = CGRectGetWidth(_itemScrollView.bounds);
    
    CGFloat firstWidth = 0;
    CGFloat secondWidth = 0;
    
    NSInteger firstIndex = (coX / width);
    NSInteger secondIndex = firstIndex+1;
    
    //DDLogDebug(@"first index = %lu", firstIndex);
    
    firstWidth = ( firstIndex >= 0 ) ? (CGRectGetWidth([self.segmentors[firstIndex] bounds])) : 0;
    secondWidth = ( secondIndex < self.segmentors.count ) ? (CGRectGetWidth([self.segmentors[secondIndex] bounds])) : 0;
    
    CGFloat coeF = ((firstIndex + 1) * width - coX) / width;
    CGFloat coeS = (coX+width - (firstIndex + 1) * width) / width;
    //DDLogDebug(@"coeF = %.2f", coeF);
    CGRect rect = _decoratedLine.frame;
    rect.size.width = coeF * firstWidth + coeS * secondWidth;
    rect.origin.x = ( firstIndex >= 0 ) ? ( CGRectGetMinX([self.segmentors[firstIndex] frame]) + firstWidth*(1-coeF) ) : 0;
    //DDLogDebug(@"rect.x = %.2f", rect.origin.x);
    _decoratedLine.frame = rect;
    
    // button appearence
    NSInteger index = round(x/width);
    
    if (index == _currrentIndex) return;
    
    UIButton *primaryButton = self.segmentors[_currrentIndex];
    UIButton *currentButton = self.segmentors[index];
    
    primaryButton.highlighted = NO;
    currentButton.highlighted = YES;
    
    CGFloat segmentBarWidth = CGRectGetWidth(self.segmentScrollView.bounds);
    CGFloat currentButtonMaxX = CGRectGetMaxX(currentButton.frame);
    CGFloat currentButtonMinX = CGRectGetMinX(currentButton.frame);
    CGFloat segmentScrollViewOffsetX = self.segmentScrollView.contentOffset.x;
    
    if (segmentScrollViewOffsetX + segmentBarWidth < currentButtonMaxX) {
        [self.segmentScrollView setContentOffset:CGPointMake(currentButtonMaxX-segmentBarWidth, self.segmentScrollView.contentOffset.y) animated:YES];
    } else if (segmentScrollViewOffsetX > currentButtonMinX) {
        [self.segmentScrollView setContentOffset:CGPointMake(currentButtonMinX, self.segmentScrollView.contentOffset.y) animated:YES];
    }
    
    _currrentIndex = index;
    
    if ([_delegate respondsToSelector:@selector(segmentScrollView:didScrollToPageAtIndex:)]) {
        [_delegate segmentScrollView:self didScrollToPageAtIndex:_currrentIndex];
    }
}

- (void)handleSegmentorButtonAction:(UIButton *)sender {
    
    if (!_segmentable) return;
    
    NSInteger index = sender.tag;
    
    if (_currrentIndex == index) {
        // 延迟执行button.status设置才有效
        // 应该是button target->selector 之后，会重置button.status
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.highlighted = YES;
        });
        return;
    }
    
    [self.itemScrollView setContentOffset:CGPointMake(index*CGRectGetWidth(self.itemScrollView.bounds), self.itemScrollView.contentOffset.y) animated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _itemScrollView) {
        //DDLogDebug(@"offset x = %.2f", scrollView.contentOffset.x);
        [self changeSegmentBarAppearenceForItemScrollViewContentOffetX:scrollView.contentOffset.x];
    }
}

@end
