//
//  NetWork.m
//  CarSocial
//
//  Created by wang jam on 8/27/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "NetWork.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>
#import "macro.h"
#import "Constant.h"
#import <MBProgressHUD.h>
#import "Tools.h"
#import "AppDelegate.h"
#import "NetworkAPI.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


@implementation NetWork


- (void)message:(NSDictionary*)message images:(NSMutableDictionary*)images feedbackcall:(NSDictionary*)feedbackcall complete:(messageComplete)complete callObject:(id)callObject
{
    
    
    if (images == nil) {
        [NetworkAPI callApiWithParam:message childpath:[message objectForKey:@"childpath"] successed:^(NSDictionary *response) {
            
            SEL outSelector = nil;
            if(feedbackcall != nil){
                [[feedbackcall objectForKey:[response objectForKey:@"code"]] getValue:&outSelector];
                if(outSelector == nil){
                    NSLog(@"outSelect is nil");
                    [self msgError:response path:[message objectForKey:@"childpath"]];
                }else{
                    [callObject performSelector:outSelector withObject:response];
                }
            }

            
            if (complete!=nil) {
                complete();
            }

            
            
        } failed:^(NSError *error) {
            
            [self msgException:error path:[message objectForKey:@"childpath"]];
            if (complete!=nil) {
                complete();
            }
            
        }];
        
        
    }else{
        
        [NetworkAPI callApiWithParamForImage:message imageDatas:images childpath:[message objectForKey:@"childpath"] successed:^(NSDictionary *response) {
            SEL outSelector = nil;
            if(feedbackcall != nil){
                [[feedbackcall objectForKey:[response objectForKey:@"code"]] getValue:&outSelector];
                if(outSelector == nil){
                    NSLog(@"outSelect is nil");
                    [self msgError:response path:[message objectForKey:@"childpath"]];
                }else{
                    [callObject performSelector:outSelector withObject:response];
                }
            }
            
            
            if (complete!=nil) {
                complete();
            }
            
        } failed:^(NSError *error) {
            
            [self msgException:error path:[message objectForKey:@"childpath"]];
            if (complete!=nil) {
                complete();
            }
        }];
        
    }
}

- (void)msgException:(id)sender path:(NSString*)path
{
    //alertMsg(@"msg exception");
    
    NSError* netError = (NSError*)sender;
    [Tools AlertMsg:[[NSString alloc] initWithFormat:@"%@:%@", netError.domain, path]];
    
}

- (void)msgError:(id)sender path:(NSString*)path
{
    //alertMsg(@"msg error");
    NSDictionary* feedback = (NSDictionary*)sender;
    [Tools AlertMsg:[[NSString alloc] initWithFormat:@"error code:%@:%@", [feedback objectForKey:@"code"], path]];
}


- (NSError*)sendImageAndMessageSyn:(NSURL*)url message:(NSDictionary*)message feedbackMessage:(NSMutableDictionary**)feedback images:(NSMutableDictionary*)images
{
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    //[request setValidatesSecureCertificate:NO];//请求https的时候，就要设置这个属性
    
    [request setRequestMethod:@"POST"];
    for (NSString* key in message) {
        [request setPostValue:[message objectForKey:key] forKey:key];
    }
    
    for (NSString* key in images) {
        UIImage* image = [images objectForKey:key];
        NSData* imageData = UIImageJPEGRepresentation(image, 0.7);
        
        [request setPostValue:key forKey:key];
        [request addData:imageData withFileName:key andContentType:@"image/jpeg" forKey:key];
    }
    
    
    
    [request startSynchronous];
    NSError* error = [request error];
    if (!error) {
        NSData *response = [request responseData];
        
        NSLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
        
        *feedback = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    }
    return error;
}

- (NSError*)sendMessageSyn:(NSURL*)url message:(NSDictionary*)message feedbackMessage:(NSMutableDictionary**)feedback
{
    //ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    //[request setValidatesSecureCertificate:NO];//请求https的时候，就要设置这个属性
    
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&error];
    
    NSLog(@"%@", [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    [request setPostBody:[NSMutableData dataWithData:jsonData]];
    
    [request startSynchronous];
    error = [request error];
    NSLog(@"%@", error.domain);
    NSLog(@"%ld", error.code);
    
    if (!error) {
        NSData *response = [request responseData];
        NSString* responseStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseStr);
        *feedback = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    }
    return error;
}


@end
