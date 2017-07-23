//
//  WYKVOObserver.m
//  WYKit
//
//  Created by yingwang on 2017/7/22.
//

#import <objc/runtime.h>
#import "WYKVOObserver.h"

@interface WYKVOObserver()

@end

char const *kWYKVOObserverKeyPathActionIdentifier = "kWYKVOObserverKeyPathActionIdentifier";

@implementation WYKVOObserver

- (void)wy_observe:(NSObject * _Nonnull)target keyPath:(NSString * _Nonnull)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context action:( WYKVOObserverActionBlock _Nonnull)action {
    
    NSMutableDictionary *keyPathActionDictionary = objc_getAssociatedObject(target, kWYKVOObserverKeyPathActionIdentifier);
    if (!keyPathActionDictionary) {
        keyPathActionDictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(target, kWYKVOObserverKeyPathActionIdentifier, keyPathActionDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    keyPathActionDictionary[keyPath] = [action copy];
    
    [target addObserver:self
             forKeyPath:keyPath
                options:options
                context:context];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSMutableDictionary *keyPathActionDictionary = objc_getAssociatedObject(object, kWYKVOObserverKeyPathActionIdentifier);
    WYKVOObserverActionBlock action = keyPathActionDictionary[keyPath];
    if (action) {
        action(object, self, change, context);
    }
}

@end

char const *kNSObjectWYKVOObserverIdentifier = "kNSObjectWYKVOObserverIdentifier";

@implementation NSObject(WYKVOObserver)
- (WYKVOObserver *)kvoObserver {
    WYKVOObserver *observer = objc_getAssociatedObject(self, kNSObjectWYKVOObserverIdentifier);
    if (!observer) {
        observer = [[WYKVOObserver alloc] init];
        objc_setAssociatedObject(self, kNSObjectWYKVOObserverIdentifier, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

@end
