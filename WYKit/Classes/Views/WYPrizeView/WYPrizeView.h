//
//  IPPrizeView.h
//  Pods
//
//  Created by yingwang on 2017/11/3.
//

#import <UIKit/UIKit.h>

@class WYPrizeView;
@protocol WYPrizeViewDelegate<NSObject>
@required

/**
 Must be odd numbers and greater or equal to 3.
 */
- (NSUInteger)numberOfRowInPrizeView:(WYPrizeView *)prizeView;
/**
 Must be odd numbers and greater or equal to 3.
 */
- (NSUInteger)numberOfColumnInPrizeView:(WYPrizeView *)prizeView;

@optional
- (void)prizeViewDidStartedRolling:(WYPrizeView *)prizeView;
- (void)prizeViewDidEndedRolling:(WYPrizeView *)prizeView;

/**
 Return a indexPath which indicate row and column of prize result.
 If no realize the method or return nil, the result of prize will be random.
 */
- (NSIndexPath *)indexPathOfPrizeItemInPrizeView:(WYPrizeView *)prizeView;

/**
 Return title string for item at indexPath, if no realize this method,
 then prizeView:configureTitleLabel:indexPath: will be call
 */
- (NSString *)prizeView:(WYPrizeView *)prizeView titleOfItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Realize this method to configure font and textColor of title
 */
- (void)prizeView:(WYPrizeView *)prizeView configureTitleLabel:(UILabel *)titleLabel indexPath:(NSIndexPath *)indexPath;

/**
 Return a prize image for item at indexPath, if no realize this method,
 then prizeView:configureImageView:indexPath: will be call
 */
- (UIImage *)prizeView:(WYPrizeView *)prizeView imageOfItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Realize this method for loading image asynchrous, such as [imageView sd_imageForURL:] in SDWebImage Framework.
 */
- (void)prizeView:(WYPrizeView *)prizeView configureImageView:(UIImageView *)imageView indexPath:(NSIndexPath *)indexPath;

@end

typedef NS_ENUM(NSUInteger, WYPrizeRollingMode) {
    
    kWYPrizeRollingClockwise,
    kWYPrizeRollingAntiClockwise,
    kWYPrizeRollingRandom
};

typedef NS_ENUM(NSUInteger, WYPrizeRollingSpeedStyle) {
    
    kWYPrizeRollingDeceleration,
    kWYPrizeRollingUniformSpeed
};

@interface WYPrizeStrategy : NSObject

@property (nonatomic) WYPrizeRollingMode rollingModel;

@property (nonatomic) WYPrizeRollingSpeedStyle rollSpeedStyle;

@property (nonatomic, strong) NSIndexPath *targetItemIndexPath;

@end

@interface WYPrizeView : UIView

@property (nonatomic, weak) id<WYPrizeViewDelegate> delegate;

@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) CGFloat itemSpacing;

@property (nonatomic, strong) UIImage *normalBackgroundImageForItems;
@property (nonatomic, strong) UIImage *highlightedBackgroundImageForItems;

@property (nonatomic, strong) UIImage *imageForStartButton;
@property (nonatomic, strong) NSString *titleForStartButton;
@property (nonatomic, strong) NSAttributedString *attributeTitleForStartButton;

@property (nonatomic, readonly) BOOL isRolling;

@property (nonatomic, readonly) WYPrizeStrategy *strategy;

/**
 Default is NO, if equal to YES, prize view will not rolling after delegate method 'prizeViewDidStartedRolling:' was called unless call 'startRolling' manually.
 */
@property (nonatomic) BOOL async;

- (void)reloadData;

- (void)startRolling;

/**
 Can just cancel rolling action which was waitting to roll
 */
- (void)cancelRolling;

@end
