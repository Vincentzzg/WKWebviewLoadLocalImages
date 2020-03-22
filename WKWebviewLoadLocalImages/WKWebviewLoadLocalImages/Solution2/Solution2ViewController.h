//
//  Solution2ViewController.h
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/21.
//  Copyright © 2020 周中广. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 方案2：
/// 使用 setURLSchemeHandler:forURLScheme: 方法设置自定义的scheme
/// 这种方式图片数据是原生读取，所以对文件所在的沙盒目录没有要求，都可以正常加载
@interface Solution2ViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
