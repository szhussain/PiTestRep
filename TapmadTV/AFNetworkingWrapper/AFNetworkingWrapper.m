//
//  AFNetworkingWrapper.m
//  Clippet
//
//  Created by Ammad on 11/4/13.
//  Copyright (c) 2013 Apppli. All rights reserved.
//

#import "AFNetworkingWrapper.h"
#import "AFHTTPSessionManager.h"


@implementation AFNetworkingWrapper
@synthesize delegate, postData, postParams, requestURL, fileName;


-(id)initWithURL:(NSString *)url andPostParams:(NSDictionary *)params tag:(int) callTag
{
    if (self = [super init])
	{
		self.requestURL = url;
        self.tag = callTag;
		self.postParams = params;
	}
	return self;
}

-(id)initWithURL:(NSString *)url andPostParams:(NSDictionary *)params postData:(NSData *)data dataName:(NSString *)name
{
    if (self = [super init])
	{
		self.requestURL = url;
		self.postParams = params;
        self.postData = data;
        self.fileName = name;
	}
	return self;
}

-(void)startAsynchronousGet
{    
//    AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
//    [manager1 GET:self.requestURL parameters:self.postParams progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//        [self.delegate requestFinished:responseObject tag:self.tag];
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        [self.delegate requestFailed:self.tag];
//    }];
    
    AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
    [manager1 GET:self.requestURL parameters:self.postParams progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        [self.delegate requestFinished:responseObject tag:self.tag];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
        [self.delegate requestFailed:error];
    }];
}

-(void)startAsynchronousPost
{
//    AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
//    [manager1 POST:self.requestURL parameters:self.postParams progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//        [self.delegate requestFinished:responseObject tag:self.tag];
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        [self.delegate requestFailed:self.tag];
//    }];
    
}
-(void)startAsynchronousPostWithData
{
//    AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
//    [manager1 POST:self.requestURL parameters:self.postParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
//        [formData appendPartWithFormData:self.postData name:self.fileName];
//    } progress:^(NSProgress  * _Nonnull progress){
//    
//    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject){
//        NSLog(@"Success: %@", responseObject);
//        [self.delegate requestFinished:responseObject tag:self.tag];
//    
//    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError* _Nullable error){
//        NSLog(@"Error: %@", error);
//        [self.delegate requestFailed:self.tag];
//    }];
}

////thid method will only work with ios7
//-(void)uploadImageWithProgress
//{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
//    
//    NSProgress *progress;
//    NSURLSessionUploadTask *uploadTask = [sessionManager uploadTaskWithRequest:request fromFile:filePath progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Success: %@ %@", response, responseObject);
//        }
//    }];
//    [uploadTask resume];
//    
//    // Observe fractionCompleted using KVO
//    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
//    
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    
//    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
//        NSProgress *progress = (NSProgress *)object;
//        NSLog(@"Progress is %f", progress.fractionCompleted);
//        
//        [self.delegate uploadProgress:progress.fractionCompleted];
//    }
//}

//-(void)downloadFileWithProgress
//{
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURL]];
//    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.fileName];//fileName must contain extension as well.
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
//    
//    
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        
//        NSLog(@"progress = %f", (float)totalBytesRead / totalBytesExpectedToRead);
//        [self.delegate uploadProgress:(float)totalBytesRead / totalBytesExpectedToRead];
//        
//    }];
//    
//    [operation setCompletionBlock:^{
//        NSLog(@"downloadComplete!");
//        
//        [self.delegate requestFinished:@"" tag:self.tag];
//        
//    }];
//    [operation start];
//}



//-(void)uploadDataWithProgress
//{
//    UIProgressView *progressView = nil;
//    NSArray *fileNames = nil;
//    NSString *numberOfPhotosAsString = @"10";
//    
//    
//    NSString *fileBase = @"file0_";
//    NSString *fileNameBase = @"SourceName_";
//    NSURL *url = [NSURL URLWithString:@"http://www.mywebsite.com"];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"PU", @"type",
//                                   nil];
//    for (int i= 0; i < 10; i++)
//    {
//        [params setObject:[fileNames objectAtIndex:i] forKey:[fileNameBase stringByAppendingFormat:@"%i", i]];
//    }
//    
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/ReceivePhoto.aspx" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        
//        for (int i = 0; i < numberOfPhotos; i++)
//        {
//            // may want to experiment with the compression quality (0.5 currently)
//            NSData *imageData = UIImageJPEGRepresentation([images objectAtIndex:i], 0.5);
//            [formData appendPartWithFileData:imageData name:[fileBase stringByAppendingFormat:@"%i", i] fileName:[fileNames objectAtIndex:i] mimeType:@"image/jpeg"];
//        }
//    }];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//        float progress = totalBytesWritten / totalBytesExpectedToWrite;
//        [progressView setProgress: progress];
//    }];
//    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [self.delegate requestFinished:responseObject tag:self.tag];
//        
//        
//    } 
//    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"error: %@",  operation.responseString);
//    }
//     ];
//}


-(void)cancelRequest
{
    [manager.operationQueue cancelAllOperations];
    
//    NSLog(@"request cancelled.");
}

@end
