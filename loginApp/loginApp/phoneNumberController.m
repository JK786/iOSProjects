//
//  phoneNumberController.m
//  loginApp
//
//  Created by Jibran on 9/23/17.
//  Copyright © 2017 Jibran. All rights reserved.
//

#import "phoneNumberController.h"

@implementation phoneNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.phoneNumberTextfield.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString * text = textField.text;

    // --- Only if Phone number is valid we store it in the app wide shared memory (standard user default) and then generate OTP. Else do nothing ---//
    
   if([self validatePhoneNumber:text] == 1){
       [[NSUserDefaults standardUserDefaults]  setObject:text forKey:@"pn"];
       [self generateOTP];
    }
    return YES;
}


-(void) generateOTP{
    
    NSDictionary *phoneNumber = @{@"phone": [NSMutableString stringWithFormat:@"+91%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"pn"]]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:phoneNumber options:0 error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    // insert whatever URL you would like to connect to
    [request setURL:[NSURL URLWithString:@"http://qa.noticeboard.tech/identity-service/auth/otp"]];
    
    [request setHTTPMethod:@"POST"];
    NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Basic U3lzdGVtflN5c3RlbTpTeXN0ZW0=" forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:requestData];
    
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
                                                           [self performSegueWithIdentifier:@"PhoneToOTP" sender:nil];
                                                         }else {
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                                 message:@"Some Error Occurred" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (BOOL) validatePhoneNumber:(NSString *)phoneNumber{
         if([phoneNumber length] == 10){
             if([[phoneNumber substringToIndex:1] isEqualToString:@"7"]||[[phoneNumber substringToIndex:1] isEqualToString:@"8"]||[[phoneNumber substringToIndex:1] isEqualToString:@"9"]){
                 return YES;
             }
         }
    return NO;
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
