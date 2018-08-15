//
//  H5ViewController.m
//  H5Demo
//
//  Created by kane on 2018/8/6.
//  Copyright © 2018年 JQX. All rights reserved.
//

#import "H5ViewController.h"
#import <WebKit/WebKit.h>
#import "UIView+Toast.h"

@interface H5ViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
// 进度条
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, assign) double startTime;

@property (nonatomic, strong) NSMutableArray *logArr;
@property (nonatomic, strong) UILabel *logLabel;
@property (nonatomic, strong) UIButton *logBtn;

@end

@implementation H5ViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    // 取消监听
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logArr = [NSMutableArray array];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navigation_bar_return"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick)];

    [self configUI];
 
    self.startTime = CACurrentMediaTime();
    [self.logArr addObject:[NSString stringWithFormat:@"开始加载%f",[[NSDate date] timeIntervalSince1970]]];
    [self showWKLog];
    
    [self loadWebviewDatas];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10.f];
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentRight;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.bounds.size.width-44, 0, 44, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:10.f];
    btn.titleLabel.numberOfLines = 2;
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, -10, -35);
    [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.logLabel = label;
    self.logBtn = btn;
    self.logLabel.hidden = self.isShowLog?NO:YES;
    self.logBtn.hidden = self.isShowLog?NO:YES;
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.progressView removeFromSuperview];
}

- (BOOL)navigationShouldPopOnBackButton
{
    if ([self.wkWebView canGoBack]) {
        // 如果有则返回
        [self.wkWebView goBack];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        return NO;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        return YES;
    }
}


#pragma mark - init

- (void)configUI {
    
    self.navigationItem.titleView = self.titleView;
//    _isShowCloseItem = NO;
    
    // 进度条
    CGFloat progressBarHeight = .7f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect progressViewFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:progressViewFrame];
    _progressView.transform = CGAffineTransformMakeScale(1.0f,.7f);
    _progressView.tintColor = [UIColor blueColor];
    _progressView.trackTintColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:_progressView];
    
    //webview
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _wkWebView.backgroundColor = [UIColor whiteColor];
    [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.view addSubview:_wkWebView];
    [self.view setNeedsLayout];
}

- (void)loadWebviewDatas
{
    [_wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
}


#pragma mark - getter

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/4*3, 44)];
        _titleView.backgroundColor = [UIColor clearColor];
        [self.titleView addSubview:self.titleLb];
    }
    
    return _titleView;
}

- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/4*3, 44)];
        _titleLb.font = [UIFont boldSystemFontOfSize:17.0];
        _titleLb.text = @"默认标题";
        _titleLb.numberOfLines = 0;
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.textColor = [UIColor blackColor];
    }
    
    return _titleLb;
}

#pragma mark - WKUIDelegate

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"信息" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"信息" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
}


#pragma mark - WKNavigationDelegate

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //    NSHTTPURLResponse *response = nil;
    //    [NSURLConnection sendSynchronousRequest:navigationAction.request returningResponse:&response error:nil];
    
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if(webView != _wkWebView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    //重定向 Kane 01.26
    //    WKNavigationActionPolicy isAllow = WKNavigationActionPolicyCancel;
    //    if (response.statusCode == 200 ||
    //        response.statusCode == 302 ||
    //        response.statusCode == 304 ||
    //        response.statusCode == 307) {
    //        isAllow = WKNavigationActionPolicyAllow;
    //    } else {
    //       self.webEmptyView.hidden = NO;
    //    }
    
    //    decisionHandler(isAllow);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// WKWebView开始重定向处理
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    // 类似UIWebView的 -webViewDidStartLoad:
}

// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
}

// WKWebView开始加载时出错处理
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.logArr addObject:[NSString stringWithFormat:@"加载出错 %.3fms %@ %ld",(CACurrentMediaTime() - self.startTime) * 1000,error.domain,(long)error.code]];
    [self showWKLog];
    
    if (error) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"加载出错 用时%.3fms",(CACurrentMediaTime() - self.startTime) * 1000] message:[NSString stringWithFormat:@"URL: %@ \n 错误信息:%@ %ld \n 请检查输入信息 并反馈给开发人员。",self.urlStr,error.domain,(long)error.code] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    if([error code] == NSURLErrorCancelled) {
        return;
    }
    
//    [WeLoopTools showBottomTip:kLStr(@"S2917")];
}

// WKWebView加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    self.webEmptyView.hidden = YES;
    [self.logArr addObject:[NSString stringWithFormat:@"加载完成 %.3fms",(CACurrentMediaTime() - self.startTime) * 1000]];
    [self showWKLog];
}

// WKWebView加载失败调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.logArr addObject:[NSString stringWithFormat:@"加载失败 %.3fms",(CACurrentMediaTime() - self.startTime) * 1000]];
    [self showWKLog];
}


#pragma mark - 计算wkWebView进度条

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loading"]) {
        
        [self.logArr addObject:[NSString stringWithFormat:@"longing 回调 %.3fms",(CACurrentMediaTime() - self.startTime) * 1000]];
        [self showWKLog];
        
    } else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.wkWebView) {
//            if (!_titleStr) {
                _titleStr = self.wkWebView.title;
//            }
            self.titleLb.text = _titleStr;
            [self.logArr addObject:[NSString stringWithFormat:@"title 回调 %.3fms",(CACurrentMediaTime() - self.startTime) * 1000]];
            [self showWKLog];
        }
        
    } else if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        [self.progressView setProgress:newprogress animated:NO];
        if (newprogress == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
        } else {
            self.progressView.hidden = NO;
        }
        
        self.logLabel.text = [NSString stringWithFormat:@"%.3fms \n %.0f%%",(CACurrentMediaTime() - self.startTime) * 1000,newprogress*100];
        CGFloat width = [self returnStringWidth:[UIFont systemFontOfSize:12.0f] str:self.logLabel.text];
        self.logLabel.frame = CGRectMake(self.view.bounds.size.width-width, 0, width, 44);
        self.logBtn.frame = CGRectMake(self.view.bounds.size.width-width, 0, width, 44);
        [self.logBtn setTitle:self.logLabel.text forState:UIControlStateNormal];
        
        [self.logArr addObject:[NSString stringWithFormat:@"progress %.0f%% 回调 %.3fms",newprogress*100,(CACurrentMediaTime() - self.startTime) * 1000]];
        [self showWKLog];

    }
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
//    if (!self.navigationController.navigationBar.underlinelay.hidden) {
//        self.navigationController.navigationBar.underlinelay.hidden = YES;//还原
//    }
}

//显示log
- (void)showWKLog {
    if (self.logArr.count > 0 && self.isShowLog) {
        NSString *str = [self.logArr componentsJoinedByString:@"\n"];
        [self.view makeToast:str];
    }
}

- (CGFloat)returnStringWidth:(UIFont*)font str:(NSString*)str
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.width;
}


@end
