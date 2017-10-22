//
//  splashController.m
//  loginApp
//
//  Created by Jibran on 9/23/17.
//  Copyright © 2017 Jibran. All rights reserved.
//

#import "splashController.h"
#import "phoneNumberController.h"


@implementation splashController
 NSMutableData *_responseData;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //---------- You can toggle this line to clear the awt from the standard user defaults for testing a scenario ------------------//
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Token"];
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSString *savedTokenValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"Token"];
    if(nil == savedTokenValue){
            [self performSegueWithIdentifier:@"splashToPhone" sender:nil];
     }else{
            [self validateToken:savedTokenValue];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) validateToken:(NSString *)token{
    NSString * jwtToken = token;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *compURLString = [NSString stringWithFormat:@"http://qa.noticeboard.tech/identity-service/session/validate/%@",jwtToken];
    
    NSLog(@"URL:%@",compURLString);
    
    [request setURL:[NSURL URLWithString:compURLString]];
    
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Basic U3lzdGVtflN5c3RlbTpTeXN0ZW0=" forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *task = [[self getURLSession] dataTaskWithRequest:request completionHandler:^( NSData *data, NSURLResponse *response, NSError *error )
                                  {
                                      dispatch_async( dispatch_get_main_queue(),
                                                     ^{
                                                         // parse returned data
                                                         NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                                         
                                                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                         NSInteger  code = [httpResponse statusCode];
                                                         NSLog(@"Code%ld",(long)code);
                                                         NSLog( @"%@", result);
                                                         
                                                         
                                                         if([self isAPISuccess:data] == 1){
                                                             [self performSegueWithIdentifier:@"SplashToHome" sender:nil];
                                                         }
                                                         else{
                                                             [self performSegueWithIdentifier:@"splashToPhone" sender:nil];
                                                         }
                                                         
                                                     } );
                                  }];
    
    [task resume];
}



- ( NSURLSession * )getURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken,
                  ^{
                      NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                      session = [NSURLSession sessionWithConfiguration:configuration];
                  } );
    
    return session;
}



// --------------------------------------------      UTILITY METHODS       ------------------------------------------------------------//



-(BOOL) isAPISuccess:(NSData*)data{
    NSMutableDictionary * innerJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSMutableDictionary *statusDictionary =[innerJson objectForKey:@"status"];
    
    NSString * successOrFailure = [statusDictionary objectForKey:@"type"];

    if([successOrFailure isEqualToString:@"SUCCESS"])
        return YES;
    else
        return NO;
}

@end
