//
//  AFNetworkingWrapper.h
//  Clippet
//
//  Created by Ammad on 11/4/13.
//  Copyright (c) 2013 Apppli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

// Protocol for the importer to communicate with its delegate.
@protocol AFNetworkingWrapperDelegate <NSObject>

//asynchronous request finished
//- (void)requestFinished:(id)response;
- (void)requestFinished:(id)response tag:(int) callTag;

//asynchronous request failed
- (void)requestFailed:(NSError *)error;

////get upload progress to display on home screen for upload items
//-(void)uploadProgress:(float)progress;

@end


@interface AFNetworkingWrapper : NSObject
{
    __weak id <AFNetworkingWrapperDelegate> delegate;
    
    AFHTTPSessionManager *manager;
    
    NSString *requestURL;
    NSDictionary *postParams;
    NSData *postData;
    NSString *fileName;
    
    int tag;
}

@property (nonatomic, weak) id <AFNetworkingWrapperDelegate> delegate;

@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic, strong) NSDictionary *postParams;
@property (nonatomic, strong) NSData *postData;
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, readwrite) int tag;

//-(id)initWithURL:(NSString *)url andPostParams:(NSMutableDictionary *)params;
-(id)initWithURL:(NSString *)url andPostParams:(NSDictionary *)params tag:(int) tag;
-(id)initWithURL:(NSString *)url andPostParams:(NSDictionary *)params postData:(NSData *)data dataName:(NSString *)name;

-(void)startAsynchronousGet;

-(void)startAsynchronousPost;

-(void)startAsynchronousPostWithData;

//-(void)uploadImageWithProgress;

-(void)cancelRequest;

@end
