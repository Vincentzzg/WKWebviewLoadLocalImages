//
//  NSURL+chageScheme.m
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/22.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "NSURL+chageScheme.h"

@implementation NSURL (chageScheme)

- (NSURL *)changeURLScheme:(NSString *)newScheme {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    components.scheme = newScheme;
    return components.URL;
}

@end
