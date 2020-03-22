//
//  NSURL+chageScheme.h
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/22.
//  Copyright © 2020 周中广. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (chageScheme)

- (NSURL *)changeURLScheme:(NSString *)newScheme;

@end

NS_ASSUME_NONNULL_END
