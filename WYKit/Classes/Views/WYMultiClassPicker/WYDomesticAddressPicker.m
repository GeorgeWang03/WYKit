//
//  WYDomesticAddressPicker.m
//  WYKit
//
//  Created by yingwang on 2016/12/1.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYMultiClassPickerView.h"
#import "WYDomesticAddressPicker.h"

@implementation WYDomesticAddressModel

@end

@interface WYDomesticAddressPicker () <WYMultiClassPickerViewDelegate>

@property (nonatomic, strong) WYMultiClassPickerView *pickerView;
@property (nonatomic, strong) NSMutableDictionary *addressInfo;

@end

NSString * const WYDomesticAddressPickerProvinceCodeKey = @"WYDomesticAddressPickerProvinceCodeKey";
NSString * const WYDomesticAddressPickerCityCodeKey = @"WYDomesticAddressPickerCityCodeKey";
NSString * const WYDomesticAddressPickerAreaCodeKey = @"WYDomesticAddressPickerAreaCodeKey";

NSString * const WYDomesticAddressPickerProvinceNameKey = @"WYDomesticAddressPickerProvinceNameKey";
NSString * const WYDomesticAddressPickerCityNameKey = @"WYDomesticAddressPickerCityNameKey";
NSString * const WYDomesticAddressPickerAreaNameKey = @"WYDomesticAddressPickerAreaNameKey";

static NSString *WYDomesticAddressPickerUpdateDateKey = @"WYDomesticAddressPickerUpdateDateKey";

static NSString *WYDomesticAddressCurrentUpdatedDateKey = @"WYDomesticAddressCurrentUpdatedDateKey";

NSString * const WYDomesticAddressUpdatedSuccessedNotificationName = @"WYDomesticAddressUpdatedSuccessedNotificationName";
NSString * const WYDomesticAddressUpdatedFailedNotificationName = @"WYDomesticAddressUpdatedFailedNotificationName";
NSString * const WYDomesticAddressUpdatedFailedErrorKey = @"WYDomesticAddressUpdatedFailedErrorKey";

@implementation WYDomesticAddressPicker

+ (instancetype)sharePicker {
    static WYDomesticAddressPicker *picker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!picker) {
            picker = [[self alloc] init];
        }
    });
    return picker;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _addressInfo = [NSMutableDictionary dictionary];
        [self initializeViews];
        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            [self checkForUpdattingWithCompleteBlock:nil];
//        });
    }
    return self;
}

- (NSArray *)getAddressModelsWithAddressClassIndex:(NSInteger)index {
    
    NSArray *keys = @[WYDomesticAddressPickerProvinceCodeKey, WYDomesticAddressPickerCityCodeKey, WYDomesticAddressPickerAreaCodeKey];
    
    return _addressInfo[keys[index]];
}

- (void)initializeViews {
    
    _pickerView = [[WYMultiClassPickerView alloc] init];
    _pickerView.delegate = self;
    _pickerView.asynchronous = YES;
    _pickerView.dismiassWhenSelectLastClass = YES;
    _pickerView.title = @"地址选择";
    _pickerView.designatedTitle = @"当前城市 ：";
    _pickerView.designatedText = @"广东 东莞";
    _pickerView.highlightedColor = [UIColor blackColor];
}

+ (void)showPickerWithDismissBlock:(void (^)(WYDomesticAddressPicker *, NSDictionary *))dismissBlock {
    WYDomesticAddressPicker *picker = [WYDomesticAddressPicker sharePicker];
    [picker showPickerWithDismissBlock:dismissBlock];
}

- (void)showPickerWithDismissBlock:(void (^)(WYDomesticAddressPicker *, NSDictionary *))dismissBlock {
    
    self.dismissBlock = dismissBlock;
    [self show];
}

- (void)show {
    
    [_pickerView show];
}
#pragma mark - WYMultiClassPickerView Delegate

- (NSInteger)maxNumberClassInPickerView:(WYMultiClassPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(WYMultiClassPickerView *)pickerView numberOfRowInClassIndex:(NSInteger)classIndex {
    NSArray *modelArray = [self getAddressModelsWithAddressClassIndex:classIndex];
    return modelArray.count;
}

- (NSString *)pickerView:(WYMultiClassPickerView *)pickerView textAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *modelArray = [self getAddressModelsWithAddressClassIndex:indexPath.section];
    WYDomesticAddressModel *model = modelArray[indexPath.row];
    return model.distName;
}

- (BOOL)pickerItemHasSubClassAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSArray *modelArray = [self getAddressModelsWithAddressClassIndex:indexPath.section];
//    WYDomesticAddressModel *model = modelArray[indexPath.row];
    return indexPath.section != 2;
}

//- (void)pickerViewWillLoadInitialClass:(WYMultiClassPickerView *)pickerView {
//    
//}

- (void)pickerView:(WYMultiClassPickerView *)pickerView willLoadSubClassFromIndexPath:(NSIndexPath *)indexPath{
    
    WYDomesticAddressModel *model = [self getAddressModelsWithAddressClassIndex:indexPath.section][indexPath.row];
    
    if ([model.distType integerValue] == 2 && indexPath.section == 0) {
        // 如果是直辖市，section0，1都显示直辖市名
        self.addressInfo[WYDomesticAddressPickerCityCodeKey] = @[model];
        [self.pickerView finishLoadDataAtClassIndex:indexPath.section+1 success:YES error:nil];
        
    } else if ([model.distDegree integerValue] == 2 && [model.isTerminal integerValue] == 1) {
        // 如果是没有县级的地市，如东莞 、中山
        self.addressInfo[WYDomesticAddressPickerAreaCodeKey] = @[model];
        [self.pickerView finishLoadDataAtClassIndex:indexPath.section+1 success:YES error:nil];
        
    } else  if (![model.distDegree isEqualToString:@"3"]) {
       
    }
}

- (void)pickerViewWillDismiss:(WYMultiClassPickerView *)pickerView {
    if (_dismissBlock) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (NSIndexPath *indexPath in _pickerView.selectedIndexPaths) {
            WYDomesticAddressModel *model = [self getAddressModelsWithAddressClassIndex:indexPath.section][indexPath.row];
            switch (indexPath.section) {
                case 0:
                    dictionary[WYDomesticAddressPickerProvinceCodeKey] = model.distCode;
                    dictionary[WYDomesticAddressPickerProvinceNameKey] = model.distName;
                    break;
                case 1:
                    dictionary[WYDomesticAddressPickerCityCodeKey] = model.distCode;
                    dictionary[WYDomesticAddressPickerCityNameKey] = model.distName;
                    break;
                case 2:
                    dictionary[WYDomesticAddressPickerAreaCodeKey] = model.distCode;
                    dictionary[WYDomesticAddressPickerAreaNameKey] = model.distName;
                    break;
                default:
                    break;
            }
        }
        _dismissBlock(self, dictionary);
    }
}

@end
