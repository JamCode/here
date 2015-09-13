//
//  SynthesizeSingleton.h
//  miniWeChat
//
//  Created by wang jam on 5/5/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#ifndef SynthesizeSingleton_h
#define SynthesizeSingleton_h


#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname* shared##classname = nil; \
\
+ (classname*) shared##classname \
{ \
    @synchronized(self) \
    { \
        if(shared##classname == nil){ \
            shared##classname = [[self alloc] init]; \
        } \
    } \
    return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone*) zone \
{\
    @synchronized(self)\
    {\
        if(shared##classname == nil){\
            shared##classname = [super allocWithZone:zone];\
            return shared##classname;\
        }\
    }\
    return nil;\
}\
\
- (id)copyWithZone:(NSZone*) zone \
{ \
    return self; \
} \

#endif
