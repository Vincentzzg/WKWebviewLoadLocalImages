//
//  ViewController.m
//  WKWebviewLoadLocalImages
//
//  Created by 周中广 on 2020/3/20.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>

@interface ViewController () <WKUIDelegate, WKNavigationDelegate, WKURLSchemeHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
    [self.webView loadRequest:request];
    // Do any additional setup after loading the view.
}

#pragma mark - WKURLSchemeHandler

/*! @abstract Notifies your app to start loading the data for a particular resource
 represented by the URL scheme handler task.
 @param webView The web view invoking the method.
 @param urlSchemeTask The task that your app should start loading data for.
 */
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)) {
    NSURL *requestURL = urlSchemeTask.request.URL;
    NSString *filter = [NSString stringWithFormat:@"localImages"];

    if (![requestURL.absoluteString containsString:filter]) {
        return;
    }

    NSURL *fileURL = [self changeURLScheme:requestURL toScheme:@"file"];//file是本地文件协议
    NSURLRequest *fileUrlRequest = [[NSURLRequest alloc] initWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:.1];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:fileUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       NSURLResponse *response2 = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];
       if(error){
           [urlSchemeTask didFailWithError:error];
       }
       [urlSchemeTask didReceiveResponse:response2];
       [urlSchemeTask didReceiveData:data];
       [urlSchemeTask didFinish];
    }];

    [dataTask resume];
}

/*! @abstract Notifies your app to stop handling a URL scheme handler task.
 @param webView The web view invoking the method.
 @param urlSchemeTask The task that your app should stop handling.
 @discussion After your app is told to stop loading data for a URL scheme handler task
 it must not perform any callbacks for that task.
 An exception will be thrown if any callbacks are made on the URL scheme handler task
 after your app has been told to stop loading for it.
 */
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)) {
    NSLog(@"DUNNO WHAT TO DO HERE");
}

#pragma mark -- WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 接受响应之后的页面跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%@",webView);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error) {
        
    }
}

// 页面加载出错时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

// 防止出现白屏
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

#pragma mark - private method

- (NSURL *)changeURLScheme:(NSURL *)url toScheme:(NSString *)newScheme {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    components.scheme = newScheme;
    return components.URL;
}

#pragma mark - setter and getter

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        if (@available(iOS 11.0, *)) {
            [configuration setURLSchemeHandler:self forURLScheme:@"localImages"];
        } else {
            // Fallback on earlier versions
        }
        configuration.allowsInlineMediaPlayback = YES;
        configuration.processPool = [[WKProcessPool alloc] init];
        [configuration.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"];
        WKUserContentController *userController = [WKUserContentController new];
        configuration.userContentController = userController;
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
            configuration.dataDetectorTypes = WKDataDetectorTypeAll;
        }
        
        _webView = [[WKWebView alloc] initWithFrame:[self.view frame] configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
//        _webView.backgroundColor = [UIColor whiteColor];
//        _webView.scrollView.backgroundColor = [UIColor whiteColor];
//        _webView.opaque = NO;
    }
    
    return _webView;
}

@end
