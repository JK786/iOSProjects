//
//  OTPController.m
//  loginApp
//
//  Created by Jibran on 9/23/17.
//  Copyright © 2017 Jibran. All rights reserved.
//

#import "OTPController.h"

@implementation OTPController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.OTPTextfield.delegate = self;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if([textField.text length]==4){
        [self verifyOTP:textField.text];
    }
    return YES;
}

-(void) verifyOTP:(NSString*)OneTimePwd{
    
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"pn"];
    NSString *OTP = OneTimePwd;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *temp = @"%2B";
    NSString *compURLString = [NSString stringWithFormat:@"http://qa.noticeboard.tech/identity-service/auth/otp/verify/?login=%@91%@&otp=%@",temp,phoneNumber,OTP];
    
    
    NSLog(@"URL:%@",compURLString);
    
    
    [request setURL:[NSURL URLWithString:compURLString]];
    
    [request setHTTPMethod:@"POST"];
    
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
                                                           [self parseResponseAndStoreJwt:data];
                                                           [self performSegueWithIdentifier:@"OTPtoHome" sender:nil];
                                                         }
                                                         else{
                                                             
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Invalid OTP"
                                                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                             [alert show];
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

-(void) parseResponseAndStoreJwt:(NSData *)data{
 
    NSMutableDictionary * innerJson = [NSJSONSerialization
                                       JSONObjectWithData:data options:kNilOptions error:nil
                                       ];

    [[NSUserDefaults standardUserDefaults] setObject:[innerJson objectForKey:@"token"] forKey:@"Token"];
}


-(BOOL) isAPISuccess:(NSData*)data{
    NSMutableDictionary * innerJson = [NSJSONSerialization
                                       JSONObjectWithData:data options:kNilOptions error:nil
                                       ];
    
    NSMutableDictionary *statusDictionary =[innerJson objectForKey:@"status"];
    
    NSString * successOrFailure = [statusDictionary objectForKey:@"type"];

    if([successOrFailure isEqualToString:@"SUCCESS"])
        return YES;
    else
        return NO;
}

@end
