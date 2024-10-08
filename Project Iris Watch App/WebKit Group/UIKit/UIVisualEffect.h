#if (defined(USE_UIKIT_PUBLIC_HEADERS) && USE_UIKIT_PUBLIC_HEADERS) || !__has_include(<UIKitCore/UIVisualEffect.h>)
//
//  UIVisualEffect.h
//  UIKit
//
//  Copyright © 2016-2018 Apple Inc. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "UIKit/UIKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UIKIT_EXTERN API_AVAILABLE(ios(8.0)) NS_SWIFT_UI_ACTOR
@interface UIVisualEffect : NSObject <NSCopying, NSSecureCoding>

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#else
#import "UIKitCore/UIVisualEffect.h"
#endif
