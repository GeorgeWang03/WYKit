//
//  WYPodDefine.h
//  Pods
//
//  Created by yingwang on 2017/6/13.
//
//

#ifndef WYPodDefine_h
#define WYPodDefine_h

#define WYBundleName @"WYKit"

#define WYPodBundlePath [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"Frameworks/WYKit.framework/WYKit.bundle"]
#define WYPodBundle [NSBundle bundleWithPath:WYPodBundlePath]

#define WYPodImageNamed(named) [UIImage imageNamed:named inBundle:WYPodBundle compatibleWithTraitCollection:nil]

#endif /* WYPodDefine_h */
