//
//  ViewController.h
//  WKWebviewLoadLocalImages
//
//  Created by 周中广 on 2020/3/20.
//  Copyright © 2020 周中广. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 方案1：
/// loadHTMLString:baseURL方法加载html文本(html中有沙盒文件路径)
/// 图片需要存储到沙盒tmp目录下，baseURL中设置本地文件路径的url，或者设置“file://”
/// 猜测，待验证：wkwebview中为了防止跨域访问问题，H5页面只能读取本地tmp文件夹中的文件
@interface Solution1ViewController : UIViewController


@end

