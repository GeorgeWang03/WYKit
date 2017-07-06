//
//  WYSegmentScrollView.h
//  WYKit
//
//  Created by yingwang on 2017/1/4.
//  Copyright © 2017年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYSegmentScrollView;

@protocol WYSegmentScrollViewDelegate <NSObject>
@optional
- (CGFloat)segmentScrollView:(WYSegmentScrollView *)segmentScrollView widthForSegmentorAtIndex:(NSInteger)index;
- (void)segmentScrollView:(WYSegmentScrollView *)segmentScrollView didScrollToPageAtIndex:(NSInteger)index;

@end

@protocol WYSegmentScrollViewDataSource <NSObject>
@required
- (NSInteger)numberOfItemInSegmentScrollView:(WYSegmentScrollView *)segmentScrollView;
- (UIView *)segmentScrollView:(WYSegmentScrollView *)segmentScrollView viewForSegmentorAtIndex:(NSInteger)index;
- (NSString *)segmentScrollView:(WYSegmentScrollView *)segmentScrollView titleForSegmentorAtIndex:(NSInteger)index;

@end

@interface WYSegmentScrollView : UIView

@property (nonatomic) CGFloat segmentorHeight;
@property (nonatomic) BOOL segmentable;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, readonly) NSInteger currentViewIndex;

@property (nonatomic, weak) id<WYSegmentScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<WYSegmentScrollViewDelegate> delegate;

- (instancetype)init __attribute__((unavailable("use initWithFrame: instead")));

- (void)reloadData;

@end
