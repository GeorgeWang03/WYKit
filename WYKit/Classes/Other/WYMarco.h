//
//  WYMarco.h
//  Pods
//
//  Created by yingwang on 2017/6/13.
//
//

#ifndef WYMarco_h
#define WYMarco_h

/**
 *  弱引用
 */
#define WEAK_SELF __weak typeof(self) weakSelf = self;

/**
 *  强引用
 */
#define STRONG_SELF __strong typeof(weakSelf) strongSelf = weakSelf;

#endif /* WYMarco_h */
