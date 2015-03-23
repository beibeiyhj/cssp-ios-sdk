# CSSP IOS SDK说明
<h2><span style="color:red">1.概述 </span></h2>  
&#160; &#160;&#160;&#160;此`IOS SDK`适用于`iOS 7以上`。通过该SDK，用户可以很容易的开发出利用CSSP存储的产品，实现数据的高速、安全的上传和下载。  
### 1.1	名词解释 ###

*	`Access Key ID`和`Access Key Secret`
	*	用户进行身份验证获取动态令牌的标识对，`CSSP`中一个用户可以生成多个标识对进行分发。`CSSP`用户通过`Access Key ID`和`Access Key Secret`对称加密的方式验证某个请求发送者身份。`Access Key ID`用于标示用户，`Access Key Secret`是用户用于加密签名字符串和`CSSP`用来验证签名字符串的密钥，其中 `Access Key Secret`必须保密，只有用户和`CSSP`知道。
*	`URL`
	*	租户对应的存储`URL`，每个`Container`对应的`URL`都不一样，用户可以从页面上获取相应的`URL`。
*	`Account`
	*	`Account`是`CSSP`提供给用户的独立虚拟空间，用户可以在此空间中创建多个属于自己的`Container`。`Account`作为隔离用户的独立命名空间，其名称在开启云存储服务时即需指定,服务开启后不可修改。
*	`Container`
	*	`Container`是开放存储平台中object存储的容器；`Container`名称在单个`Account`中具有全局唯一性，且不能修改。存储在`Account`中的每个`Object`必须都包含在某个`Container`中。 `Container`同时作为权限控制和计费度量等功能的管理单位。需要注意的是用户可根据需要在合肥，北京，广州总计创建4个`Container`，每个`Container`存放的`Object`的数量和大小没有限制。
*	`Object`
	*	`Object`是`CSSP`中用户操作的基本数据单元。`Object`包含`key`、`metadata`(元数据)和`data`三部分
		*	`key`是`Object`的名字
		*	`metadata`是用户对该`Object`的描述，由一系列`name-value`对组成
		*	`data`是`Object`的数据部分

### 1.2	安装使用 ###
&#160; &#160;&#160;&#160;iOS SDK可以集成在用户的项目中使用，也可以作为第三方库用在用户的项目中。iOS SDK支持以下版本的软件：  

* Xcode 5以上
* iOS 7以上

### 1.3 Frameworks ###
1. 从我们的官网上下载SDK，并解压.
2. 在Xcode中打开你的项目, 右键点击 **Frameworks**，选择**Add files to "\<project name\>"...**.
3. 在Finder中查找CSSPiOSSDK.framework，并单击选择，点击**Add**.
4. 按照以上步骤，添加以下第三方framework,这些第三方framework在目录third-party中.
	* `Bolts.framework`
    * `Mantle.framework`
    * `XMLDictionary.framework`	
5. 将目录service-definitions中的cssp-2015-02-09.json添加到你的项目中.

<h2><span style="color:red">2.使用iOS SDK </span></h2>  
###2.1 初始化
####2.1.1 在项目中`import cssp.h`  
    **Frameworks**
    
        #import <CSSPiOSSDK/CSSPiOSSDKAPI.h>

####2.1.2 配置用户认证信息以及Endpoint信息      
	
		CSSPStaticCredentialsProvider *credentialsProvider = [CSSPStaticCredentialsProvider credentialsWithAccessKey:@"accesskey_id" secretKey:@"accesskey_secret"];

	    CSSPEndpoint *endpoint = [CSSPEndpoint endpointWithURL:@"url"];
	    
	    CSSPServiceConfiguration *configuration = [CSSPServiceConfiguration configurationWithCredentialsProvider:credentialsProvider withEndpoint:endpoint];	
   

	* `url`  
		*	`Container`的接入`URL`，可以从页面上获取。初始化后，后续所有的操作都是针对该`Container`及其下属`Object`的。  
	* `accesskey_id && accesskey_secret`
		*	用户进行身份验证获取动态令牌的标识对，`CSSP`中一个用户可以生成多个标识对进行分发。
	* `CSSPStaticCredentialsProvider`
		* 身份认证接口，提供签名的能力
	* `CSSPEndpoint`	
		* 配置url，提供解析host等能力
	* `CSSPServiceConfiguration`
		* CSSP存储服务配置类 

####2.1.3 初始化CSSPClient
接口定义：   
 
	- (void)initWithConfiguration:(CSSPServiceConfiguration *)configuration;

示例  

	[[[CSSPClient initialize]] initWithConfiguration:configuration];

###2.2 Contaner存储服务   
####2.2.1 获取容器元数据
通过`HEAD`可以获取`Container`的详细信息。

接口定义：

	- (BFTask *) headContainer

*	`Parameters`
	*	`无`
*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空
	*	`result`,成功时，返回`CSSPHeadContainerOutput`实例
		*	`objectCount`: Container下object数量
		*	`bytesUsed`:Container下占用的存储空间字节数
		*	`grantRead`:Container的读权限
		*	`metadata`:Container元数据，是一组键值对  

示例   

    [[[[CSSP initialize] headContainer] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
		XCTAssertTrue([task.result isKindOfClass:[CSSPHeadContainerOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPHeadContainerOutput class]),[task.result description]);
        return nil;
    }]waitUntilFinished];


#### 2.2.2	获取`Object`列表 ####
`GET`操作获取`Container`下的`Object`列表。

接口定义：

	- (BFTask *) listObjects:(CSSPListObjectsRequest *)request;

*	`Parameters`：`CSSPListObjectsRequest`
	*	`marker`
		*	`marker query`
		*	比如`marker = 'object1'`，表示查询`object1`之后的`Object`列表
	*	`limit`
		*	`limit query`
		*	限制查询结果中`ObjectList`的长度，比如`limit=1`，只显示前1个`Object`，`limit`的值应该大于等于1且为整数。`limit`默认为`None`，表示不对列表长度进行限制，但是集群支持的`Object`列表最长为`10000`个。
	*	`prefix`
		*	`prefix query`
		*	前缀查询，比如`prefix='a'`，表示查询以`a`开头的`Object`
	*	`delimiter`
		*	以`delimiter`分割的object名，比如object名为'abc-def-123'，如果`delimiter`设置为`-`,则返回的object名为'abc def 123'
	*	`endMarker`
		*	`marker query`
		*	比如`endMarker='object2`，表示查询`object2`之前的`Object`列表

*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空
	*	`result`,成功时，返回`CSSPListObjectsOutput`实例
		*	`contents`: `object`接口类的数组
			* `object`接口
				* `etag`: object的MD5值
				* `name`: object名
				* `lastModified`:创建时间或者object 元数据最后一次修改改建
				* `size`:object大小
				* `contentType`:object类型
		*	`subdirs` : 通过prefix和delimiter联合检索返回的object名称组成的数组
		

示例    

	CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
    listObjectReq.limit = [NSNumber numberWithInt:1];
    listObjectReq.marker = @"eee";
    listObjectReq.prefix = @"animals/";
    listObjectReq.delimiter = @"/";
    
    [[[[CSSP initialize] listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
        CSSPListObjectsOutput *listObjectsOutput = task.result;
        
        for (CSSPObject *object in listObjectsOutput.contents) {
            XCTAssertTrue([object.lastModified isKindOfClass:[NSDate class]], @"listObject doesn't contain LastModified(NSDate)");
        }
        
		for (CSSPSubdir *subdir in listObjectsOutput.subdirs) {
			NSLog("subdir %@", subdir);
        }
        
        return nil;
    }] waitUntilFinished];



### 2.3	`Object`存储服务 ###

#### 2.3.1	获取`Object`元数据 ####
通过`HEAD`可以获取`Object`的详细信息。
接口定义：

	- (BFTask *) headObject:(CSSPHeadObjectRequest *)request;

*	`Parameters`：`CSSPHeadObjectRequest`
	*	`object`: object名  

*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空
	*	`result`,成功时，返回`CSSPHeadObjectOutput`实例
		*	`lastModified`: object创建时间或者object元数据最后一次修改的时间
		*   `contentLength`：object的大小
		*   `contentType`： object类型
		*   `ETag`:该object的MD5
		*   `metadata`：object元数据，是一组键值对 

#### 2.3.2 上传`object`数据####
通过`PUT`上传object到CSSP
接口定义： 
 
	- (BFTask *) putObject:(CSSPPutObjectRequest *)request;

*	`Parameters`：`CSSPPutObjectRequest`
	*	`body`: object数据  
	*	`contentLength`：body长度
	*	`contentMD5`：body的MD5值
	*	`contentType`:object类型
	*	`object`： object名
	*	`metadata`:object 元数据，是一组键值对

*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空
	*	`result`,成功时，返回`CSSPPutObjectOutput`实例
		*   `ETag`:该object的MD5


#### 2.3.3 下载`object`数据
通过`GET`下载object  
接口定义：  

	- (BFTask *) getObject:(CSSPGetObjectRequest *)request;

*	`Parameters`：`CSSPGetObjectRequest`
	*	`object`： object名

*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空
	*	`result`,成功时，返回`CSSPGetObjectOutput`实例
		*	`body`：object数据
		*	`contentLength`：body长度
		*	`contentType`:object类型
		*   `ETag`:该object的MD5
		*	`object`:object名
		*	`metadata`:object 元数据，是一组键值对


#### 2.3.4 删除`object`数据####
用过`DELETE`在CSSP上删除object    
接口定义:

	- (BFTask *) deleteObject:(CSSPDeleteObjectRequest *)request;

*	`Parameters`：`CSSPGetObjectRequest`
	*	`object`： object名

*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空

####2.3.5 Object拷贝####
从其他Contaner拷贝object到当前Container
接口定义:

	- (BFTask *) replicateObject:(CSSPReplicateObjectRequest *)request;

*	`Parameters`：`CSSPReplicateObjectRequest`
	*	`object`： object名
	*	`replicateSource`:其他Container下的Object路径，格式：/OtherContainer/Objecy
	*	`metadata`：Object元数据，为拷贝后的新的object设置metadata

*	`Returns`:`BFTask`  
	*	`error`,异常时，error不为空
	*	`result`,成功时，返回`CSSPGetObjectOutput`实例
		*   `ETag`:该object的MD5

####2.3.6 分块上传与终止
1. 创建分块上传，获取uploadID    
接口定义：

    	- (BFTask *)createMultipartUpload:(CSSPCreateMultipartUploadRequest *)request;

	*	`Parameters`：`CSSPCreateMultipartUploadRequest`
		*	`object`： object名
	
	*	`Returns`:`BFTask`  
		*	`error`,异常时，error不为空
		*	`result`,成功时，返回`CSSPCreateMultipartUploadOutput`实例
			* `uploadID`：为该次分块分配的唯一ID


- 分块上传   
接口定义：

		- (BFTask *) uploadPart:(CSSPUploadPartRequest *) request;
	*	`Parameters`：`CSSPUploadPartRequest`
		*	`body`:当前分块数据
		*	`contentLength`：当前分块的长度
		*	`contentMD5`：当前分块数据的MD5
		*	`object`： object名
		*	`partNumber`：分块号
		*	`uploadId`:createMultipartUpload创建的uploadID
	
	*	`Returns`:`BFTask`  
		*	`error`,异常时，error不为空
		*	`result`,成功时，返回`CSSPUploadPartOutput`实例
			* `ETag`：该分块的MD5值


- 完成分块上传
接口定义:  

		- (BFTask *)completeMultipartUpload:(CSSPCompleteMultipartUploadRequest *)request
	*	`Parameters`：`CSSPUploadPartRequest`
		*	`object`： object名
		*	`uploadId`:createMultipartUpload创建的uploadID
	
	*	`Returns`:`BFTask`  
		*	`error`,异常时，error不为空
		*	`result`,成功时，返回`CSSPUploadPartOutput`实例
			* `ETag`：该object的MD5值

  
- 终止分块上传，将已上传的分块从CSSP上删除  
接口定义：
  
		- (BFTask *)abortMultipartUpload:(CSSPAbortMultipartUploadRequest *)request; 
	*	`Parameters`：`CSSPUploadPartRequest`
		*	`object`： object名
		*	`uploadId`:createMultipartUpload创建的uploadID
	
	*	`Returns`:`BFTask`  
		*	`error`,异常时，error不为空


示例：
  
* PUT/HEAD/GET/DELETE object  
	
		NSString *testObjectStr = @"a test object string.";
	    NSString *keyName = @"ios-test-put-get-and-delete-obj";
	    NSData *testObjectData = [testObjectStr dataUsingEncoding:NSUTF8StringEncoding];
		
		CSSPPutObjectRequest *putObjectRequest = [CSSPPutObjectRequest new];
	    putObjectRequest.object = keyName;
	    putObjectRequest.body = testObjectData;
	    putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[testObjectData length]];
	    putObjectRequest.contentType = @"video/mpeg";
	    
	    //Add User Metadata
	    NSDictionary *userMetaData = @{@"User-Data-1": @"user-metadata-value1",
	                                   @"User-Data-2": @"user-metadata-value2"};
    
    
	    putObjectRequest.metadata = userMetaData;
	    
	    [[[[[[[[CSSP initialize] putObject:putObjectRequest] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPPutObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPPutObjectOutput class]), [task.result description]);
	        CSSPPutObjectOutput *putObjectOutput = task.result;
	        XCTAssertNotNil(putObjectOutput.ETag);
	        
	        CSSPHeadObjectRequest *headObjectRequest = [CSSPHeadObjectRequest new];
	        headObjectRequest.object = keyName;
	        
	        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:15]];
	        return [[CSSP initialize] headObject:headObjectRequest];
	    }] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPHeadObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPHeadObjectOutput class]), [task.result description]);
	        CSSPHeadObjectOutput *headObjectOutput = task.result;
	        XCTAssertTrue([headObjectOutput.contentLength intValue] > 0, @"Content Length is 0: [%@]", headObjectOutput.contentLength);
	        
	        XCTAssertEqualObjects(userMetaData, headObjectOutput.metadata, @"headObjectOutput doesn't contains the metadata we expected");
	        
	        CSSPGetObjectRequest *getObjectRequest = [CSSPGetObjectRequest new];
	        getObjectRequest.object = keyName;
	        
	        return [[CSSP initialize] getObject:getObjectRequest];
	    }] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPGetObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPGetObjectOutput class]),[task.result description]);
	        CSSPGetObjectOutput *getObjectOutput = task.result;
	        NSData *receivedBody = getObjectOutput.body;
	        XCTAssertEqualObjects(testObjectData,receivedBody, @"received object is different from sent object, expect:%@ but got:%@",[[NSString alloc] initWithData:testObjectData encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:receivedBody encoding:NSUTF8StringEncoding]);
	        
	        XCTAssertEqualObjects(userMetaData, getObjectOutput.metadata, @"getObjectOutput doesn't contains the metadata we expected");
	        
	        CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
	        deleteObjectRequest.object = keyName;
	        
	        return [[CSSP initialize] deleteObject:deleteObjectRequest];
	    }] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),[task.result description]);
	        return nil;
	    }] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"Error: [%@]", task.error);
	        return nil;
	    }] waitUntilFinished];


* 分块上传object  
* 
		NSString *keyName = @"testMultipartUploadKey";
	    NSMutableString *testString = [NSMutableString string];
	    for (int32_t i = 0; i < 3000000; i++) {
	        [testString appendFormat:@"%d", i];
	    }
	    
	    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
	    __block NSString *uploadId = @"";
	    __block NSString *resultETag = @"";
	    __block NSUInteger const transferManagerMinimumPartSize = 5 * 1024 * 1024;
	    
	    NSUInteger partCount = ceil((double)[testData length] / transferManagerMinimumPartSize);
	    
	    CSSPCreateMultipartUploadRequest *createReq = [CSSPCreateMultipartUploadRequest new];
	    createReq.object = keyName;
	    
	    [[[[[[CSSP initialize] createMultipartUpload:createReq] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        CSSPCreateMultipartUploadOutput *output = task.result;
	        XCTAssertTrue([task.result isKindOfClass:[CSSPCreateMultipartUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPCreateMultipartUploadOutput class]),[task.result description]);
	        uploadId = output.uploadId;
	        
	        NSMutableArray *partUploadTasks = [NSMutableArray arrayWithCapacity:partCount];
	        
	        for (int32_t i = 1; i < partCount + 1; i++) {
	            NSUInteger dataLength = i == partCount ? [testData length] - ((i - 1) * transferManagerMinimumPartSize) : transferManagerMinimumPartSize;
	            NSData *partData = [testData subdataWithRange:NSMakeRange((i - 1) * transferManagerMinimumPartSize, dataLength)];
	            
	            CSSPUploadPartRequest *uploadPartRequest = [CSSPUploadPartRequest new];
	            uploadPartRequest.object = keyName;
	            uploadPartRequest.partNumber = @(i);
	            uploadPartRequest.body = partData;
	            uploadPartRequest.contentLength = @(dataLength);
	            uploadPartRequest.uploadId = uploadId;
	            
	            [partUploadTasks addObject:[[cssp uploadPart:uploadPartRequest] continueWithSuccessBlock:^id(BFTask *task) {
	                XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	                XCTAssertTrue([task.result isKindOfClass:[CSSPUploadPartOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPUploadPartOutput class]),[task.result description]);
	                CSSPUploadPartOutput *partOuput = task.result;
	                XCTAssertNotNil(partOuput.ETag);
	                
	                return nil;
	            }]];
	        }
	        
	        return [BFTask taskForCompletionOfAllTasks:partUploadTasks];
	    }] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        
	        CSSPCompleteMultipartUploadRequest *compReq = [CSSPCompleteMultipartUploadRequest new];
	        compReq.object = keyName;
	        compReq.uploadId = uploadId;
	        
	        return [[CSSP initialize] completeMultipartUpload:compReq];
	    }] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        XCTAssertTrue([task.result isKindOfClass:[CSSPCompleteMultipartUploadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPCompleteMultipartUploadOutput class]),[task.result description]);
	        CSSPCompleteMultipartUploadOutput *compOutput = task.result;
	        resultETag = compOutput.ETag;
	 
	        XCTAssertNotNil(compOutput.ETag);
	        return nil;
	    }] waitUntilFinished];
	    
	    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:20]];
	    
	    
	    CSSPListObjectsRequest *listObjectReq = [CSSPListObjectsRequest new];
	    listObjectReq.prefix = [NSString stringWithFormat:@"%@/%@", keyName, uploadId];
	    
	    [[[[CSSP initialize] listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        XCTAssertTrue([task.result isKindOfClass:[CSSPListObjectsOutput class]],@"The response object is not a class of [%@]", NSStringFromClass([CSSPListObjectsOutput class]));
	        CSSPListObjectsOutput *listObjectsOutput = task.result;
	        
	        BOOL match = NO;
	        for (CSSPObject *object in listObjectsOutput.contents) {
	            if ([object.name isEqualToString:keyName] && [object.etag isEqualToString:resultETag]) {
	                match = YES;
	            }
	        }
	        	        
	        return nil;
	    }] waitUntilFinished];
	    
	    CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
	    deleteObjectRequest.object = keyName;
	    
	    [[[[CSSP initialize] deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),[task.result description]);
	        return nil;
	    }] waitUntilFinished];

####2.3.6 数据传输接口####
数据传输接口`CSSPTransferManager`基于上面的基础接口，实现数据上传进度、下载进度以及任务暂停、恢复与取消。

#####2.3.6.1 初始化#####
类似于基础接口的初始化,不再赘述。

####2.3.6.2 数据上传#####
对于数据上传，如果数据小于5MB，将采用PutObject方式上传数据，若数据大于5MB，则采用分块上传的方式。    

在数据上传前，通过传入CSSPNetworkingUploadProgressBlock，可以获取当前传输的进度。

示例如下：    
	
	CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
    uploadRequest.object = "TransferManagerUploadTestObject";
    uploadRequest.body = testDataURL;
    
    
    __block int64_t accumulatedUploadBytes = 0;
    __block int64_t totalUploadedBytes = 0;
    __block int64_t totalExpectedUploadBytes = 0;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        NSLog(@"Object:%@ bytesSent: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld",keyName,bytesSent,totalBytesSent,totalBytesExpectedToSend);
        accumulatedUploadBytes += bytesSent;
        totalUploadedBytes = totalBytesSent;
        totalExpectedUploadBytes = totalBytesExpectedToSend;
    };
    
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        return nil;
    }] waitUntilFinished];


#####2.3.6.3 数据下载 #####
在数据下载前，通过传入CSSPNetworkingDownloadProgressBlock，可以获取当前传输的进度。
示例如下：    

		CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
	    downloadRequest.object = "TransferManagerDownloadTestObject";
	    
	    NSString *downloadFileName = "LocalFileName"
	    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:downloadFileName]];
	    
	    __block int64_t accumulatedDownloadBytes = 0;
	    __block int64_t totalDownloadedBytes = 0;
	    __block int64_t totalExpectedDownloadBytes = 0;
	    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
	        accumulatedDownloadBytes += bytesWritten;
	        totalDownloadedBytes = totalBytesWritten;
	        totalExpectedDownloadBytes = totalBytesExpectedToWrite;
	        NSLog(@"keyName:%@ bytesWritten: %lld, totalBytesWritten: %lld, totalBytesExpectedtoWrite: %lld",NSStringFromSelector(_cmd), bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
	    };
	    
	    [[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
	        return nil;
	        
	    }] waitUntilFinished];


#####2.3.6.4 数据传输暂停与恢复 #####
`CSSPTransferManager`支持数据上传或下载的暂停与恢复。
在CSSP中，新上传的Object会替换之前同名的Object，所以上传任务暂停后恢复时，采用重新上传的策略；下载Object时，采用断点续传的方法，在任务恢复后，会从之前的断点处继续下载。

现在用实例来说明。  
上传Object

	CSSPTransferManagerUploadRequest *uploadRequest = [CSSPTransferManagerUploadRequest new];
	    uploadRequest.object = objectName;
	    uploadRequest.body = testDataURL;

	BFTask *uploadTaskSmall = [[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
		// 如果任务被暂停，task.error返回Canneled异常
		XCTAssertNotNil(task.error,@"Expect got 'Cancelled' Error, but got nil");
        XCTAssertEqualObjects(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
	        return nil;
	    }];

    //wait a few moment and pause the task
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    [[[uploadRequest pause] continueWithBlock:^id(BFTask *task) {
		///通知后台该请求暂停，如果成功，返回nil
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error); //should not return error if successfully paused.
        return nil;
    }] waitUntilFinished];
	
	///当暂停请求成功时，此时该请求的状态为Paused
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStatePaused);
    
	/// 等待以确保upload函数的回调已返回
    [uploadTaskSmall waitUntilFinished];
    
    //resume the upload
    [[[[CSSPTransferManager initialize] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerUploadOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([task.result class]));
        return nil;
    }] waitUntilFinished];
    
    /// 当上传任务完成时，此时该请求的状态为Completed
    XCTAssertEqual(uploadRequest.state, CSSPTransferManagerRequestStateCompleted);


下载Object
	
    CSSPTransferManagerDownloadRequest *downloadRequest = [CSSPTransferManagerDownloadRequest new];
    downloadRequest.object = objectName;
    
    NSString *downloadFileName = [NSString stringWithFormat:@"%@-downloaded-%@",NSStringFromSelector(_cmd),objectName];
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:downloadFileName]];

	/// 默认开始状态为NotStarted
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateNotStarted);
    
    BFTask *pausedTask = [[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
		/// Object下载暂停时，task.error返回Cancel异常，在请求暂停后触发
        XCTAssertNotNil(task.error,@"Expect got 'Cancelled' Error, but got nil");
        XCTAssertNil(task.result, @"task result should be nil since it has already been cancelled");
        XCTAssertEqualObjects(CSSPTransferManagerErrorDomain, task.error.domain);
        XCTAssertEqual(CSSPTransferManagerErrorPaused, task.error.code);
        return nil;
    }];
    
	// 下载任务开始后，状态为Running
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateRunning);
    
    //wait a few seconds and then pause it.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[[downloadRequest pause] continueWithBlock:^id(BFTask *task) {
		// 暂停Object请求成功时，task.error返回nil
        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error); 
        return nil;
    }] waitUntilFinished];
    
	// 任务暂停后，请求状态为Paused
    XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStatePaused);
	// 等待以确保download函数的回调已返回
	[pausedTask waitUntilFinished]; 
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
	
	// 恢复下载
	[[[[CSSPTransferManager initialize] download:downloadRequest] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        XCTAssertTrue([task.result isKindOfClass:[CSSPTransferManagerDownloadOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPTransferManagerDownloadOutput class]),NSStringFromClass([task.result class]));
	        CSSPTransferManagerDownloadOutput *output = task.result;
	        NSURL *receivedBodyURL = output.body;
	        XCTAssertTrue([receivedBodyURL isKindOfClass:[NSURL class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([NSURL class]),NSStringFromClass([receivedBodyURL class]));
	        
	        return nil;
	    }] waitUntilFinished];
	
	// 下载完成后，状态为Completed
	XCTAssertEqual(downloadRequest.state, CSSPTransferManagerRequestStateCompleted);