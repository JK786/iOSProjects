//
//  homeController.m
//  loginApp
//
//  Created by Jibran on 9/24/17.
//  Copyright © 2017 Jibran. All rights reserved.
//

#import "homeController.h"

@implementation homeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.jwtTokenLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Token"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
