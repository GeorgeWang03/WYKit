//
//  WYKVOObserver.h
//  WYKit
//
//  Created by yingwang on 2017/7/22.
//

#import <Foundation/Foundation.h>

typedef void (^ WYKVOObserverActionBlock)(id target, id observer, NSDictionary<NSKeyValueChangeKey,id> *change, void *context);

@interface WYKVOObserver : NSObject

- (void)wy_observe:(NSObject * _Nonnull)target
           keyPath:(NSString * _Nonnull)keyPath
           options:(NSKeyValueObservingOptions)options
           context:(nullable void *)context
            action:( WYKVOObserverActionBlock _Nonnull)action;

@end


@interface NSObject(WYKVOObserver)

@property (nonatomic, readonly) WYKVOObserver *kvoObserver;

@end
