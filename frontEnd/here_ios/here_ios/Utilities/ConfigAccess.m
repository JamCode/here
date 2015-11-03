//
//  ConfigAccess.m
//  here_ios
//
//  Created by wang jam on 11/3/15.
//  Copyright © 2015 jam wang. All rights reserved.
//

#import "ConfigAccess.h"

@implementation ConfigAccess

+ (NSDictionary*)readConfig
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"geojson"];
    
    NSData *data=[NSData dataWithContentsOfFile:strPath];
    
    
    NSError* error;
    
    NSDictionary* parsejson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    
    
    return parsejson;
}


+ (NSString*)serverDomain
{
    NSDictionary* parseJason = [ConfigAccess readConfig];
    
#ifdef DEBUG
    return [[parseJason objectForKey:@"dev"] objectForKey:@"ServerDomain"];
#else
    return [[parseJason objectForKey:@"pro"] objectForKey:@"ServerDomain"];
#endif
    
}

+ (NSString*)socketIP
{
    NSDictionary* parseJason = [ConfigAccess readConfig];
    
#ifdef DEBUG
    return [[parseJason objectForKey:@"dev"] objectForKey:@"SocketIP"];
#else
    return [[parseJason objectForKey:@"pro"] objectForKey:@"SocketIP"];
#endif
}

+ (NSInteger)socketPort
{
    NSDictionary* parseJason = [ConfigAccess readConfig];
    
#ifdef DEBUG
    return [[[parseJason objectForKey:@"dev"] objectForKey:@"SocketPort"] integerValue];
#else
    return [[[parseJason objectForKey:@"pro"] objectForKey:@"SocketPort"] integerValue];
#endif
}


@end
