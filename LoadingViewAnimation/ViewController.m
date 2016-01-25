//
//  ViewController.m
//  LoadingViewAnimation
//
//  Created by 宋千 on 16/1/20.
//  Copyright © 2016年 宋千. All rights reserved.
//

#import "ViewController.h"
#import "SQLDAnimationView.h"

@interface ViewController ()

@property (nonatomic) SQLDAnimationView *loadingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.loadingView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loading:(id)sender {
    
    [self.loadingView loading];
    
}

- (IBAction)success:(id)sender {
    
    [self.loadingView loadingSuccessedCompletedBlock:^{
        nil;
    }];
}

- (IBAction)fail:(id)sender {
    [self.loadingView loadingFailedCompletedBlock:^{
        nil;
    }];
}


- (IBAction)reloading:(id)sender {
    
    [self.loadingView stop];
    
}

#pragma mark - getter

- (SQLDAnimationView *)loadingView {
    
    if (!_loadingView) {
        _loadingView = [[SQLDAnimationView alloc]
                        initWithFrame:CGRectMake(15, 30, 300, 300)];
        _loadingView.backgroundColor = [UIColor yellowColor];
        _loadingView.selfBackgroundColor = [UIColor yellowColor];
    }
    
    return _loadingView;
    
}

@end
