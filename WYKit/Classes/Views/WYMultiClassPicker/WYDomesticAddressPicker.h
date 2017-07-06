//
//  WYDomesticAddressPicker.h
//  WYKit
//
//  Created by yingwang on 2016/12/1.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const WYDomesticAddressPickerProvinceCodeKey;
FOUNDATION_EXTERN NSString * const WYDomesticAddressPickerCityCodeKey;
FOUNDATION_EXTERN NSString * const WYDomesticAddressPickerAreaCodeKey;
FOUNDATION_EXTERN NSString * const WYDomesticAddressPickerProvinceNameKey;
FOUNDATION_EXTERN NSString * const WYDomesticAddressPickerCityNameKey;
FOUNDATION_EXTERN NSString * const WYDomesticAddressPickerAreaNameKey;

FOUNDATION_EXTERN NSString * const WYDomesticAddressUpdatedSuccessedNotificationName;
FOUNDATION_EXTERN NSString * const WYDomesticAddressUpdatedFailedNotificationName;

FOUNDATION_EXTERN NSString * const WYDomesticAddressUpdatedFailedErrorKey;

@interface WYDomesticAddressModel : NSObject

@property (nonatomic, strong) NSString *provCode;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSString *distCode;
@property (nonatomic, strong) NSString *distName;
@property (nonatomic, strong) NSString *distDegree;
@property (nonatomic, strong) NSString *isTerminal;
@property (nonatomic, strong) NSString *distType;
@property (nonatomic, strong) NSString *distStuts;
@property (nonatomic, strong) NSString *updateTime;

+ (WYDomesticAddressModel *)queryAddressByDistCode:(NSString *)distCode;

@end

@interface WYDomesticAddressPicker : NSObject

@property (nonatomic, copy) void (^dismissBlock)(WYDomesticAddressPicker *picker, NSDictionary *info);

- (void)show;
- (void)showPickerWithDismissBlock:(void(^)(WYDomesticAddressPicker *picker, NSDictionary *info))dismissBlock;

+ (instancetype)sharePicker;
+ (void)showPickerWithDismissBlock:(void(^)(WYDomesticAddressPicker *picker, NSDictionary *info))dismissBlock;

@end
