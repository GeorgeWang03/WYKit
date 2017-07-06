//
//  WYAutoPlaySrollView.h
//  WYostApp
//
//  Created by yingwang on 2016/10/27.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYAutoPlayScrollView;
@protocol WYAutoPlayScrollViewDelegate <NSObject>

- (void)autoPlayScrollView:(WYAutoPlayScrollView *)scrollView imageView:(UIImageView *)imageView atIndex:(NSInteger)index;
- (void)autoPlayScrollView:(WYAutoPlayScrollView *)scrollView didSelectedCellAtIndex:(NSInteger)index;
@end

@interface WYAutoPlayScrollView : UIView

@property (nonatomic, weak) id<WYAutoPlayScrollViewDelegate> delegate;

@property (nonatomic, assign) IBInspectable BOOL loop;
@property (nonatomic, assign) IBInspectable NSInteger pagesCount;

// The interval for auto scrolling next image, if equal 0.0, it does not auto scrolling.
@property (nonatomic, assign) IBInspectable CGFloat autoPlayInterval;

@property (nonatomic, assign) BOOL activityIndicatorAnimating;

- (void)reloadData;

@end
