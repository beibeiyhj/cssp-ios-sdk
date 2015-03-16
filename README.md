<<<<<<< HEAD
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
    
        #import <CSSPiOSSDK/CSSP.h>

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

####2.1.3 初始化CSSP
接口定义：   
 
	- (instancetype)initWithConfiguration:(CSSPServiceConfiguration *)configuration;

示例  

	CSSP *cssp = [[CSSP alloc] initWithConfiguration:configuration];

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

    [[[cssp headContainer] continueWithBlock:^id(BFTask *task) {
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
	*	`end_marker`
		*	`marker query`
		*	比如`end_marker='object2`，表示查询`object2`之前的`Object`列表

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
    
    [[[cssp listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
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
	*	`result`,成功时，返回`CSSPGetObjectOutput`实例


####2.3.5 分块上传与终止
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
	    
	    [[[[[[[cssp putObject:putObjectRequest] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPPutObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPPutObjectOutput class]), [task.result description]);
	        CSSPPutObjectOutput *putObjectOutput = task.result;
	        XCTAssertNotNil(putObjectOutput.ETag);
	        
	        CSSPHeadObjectRequest *headObjectRequest = [CSSPHeadObjectRequest new];
	        headObjectRequest.object = keyName;
	        
	        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:15]];
	        return [cssp headObject:headObjectRequest];
	    }] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPHeadObjectOutput class]], @"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPHeadObjectOutput class]), [task.result description]);
	        CSSPHeadObjectOutput *headObjectOutput = task.result;
	        XCTAssertTrue([headObjectOutput.contentLength intValue] > 0, @"Content Length is 0: [%@]", headObjectOutput.contentLength);
	        
	        XCTAssertEqualObjects(userMetaData, headObjectOutput.metadata, @"headObjectOutput doesn't contains the metadata we expected");
	        
	        CSSPGetObjectRequest *getObjectRequest = [CSSPGetObjectRequest new];
	        getObjectRequest.object = keyName;
	        
	        return [cssp getObject:getObjectRequest];
	    }] continueWithSuccessBlock:^id(BFTask *task) {
	        XCTAssertTrue([task.result isKindOfClass:[CSSPGetObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPGetObjectOutput class]),[task.result description]);
	        CSSPGetObjectOutput *getObjectOutput = task.result;
	        NSData *receivedBody = getObjectOutput.body;
	        XCTAssertEqualObjects(testObjectData,receivedBody, @"received object is different from sent object, expect:%@ but got:%@",[[NSString alloc] initWithData:testObjectData encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:receivedBody encoding:NSUTF8StringEncoding]);
	        
	        XCTAssertEqualObjects(userMetaData, getObjectOutput.metadata, @"getObjectOutput doesn't contains the metadata we expected");
	        
	        CSSPDeleteObjectRequest *deleteObjectRequest = [CSSPDeleteObjectRequest new];
	        deleteObjectRequest.object = keyName;
	        
	        return [cssp deleteObject:deleteObjectRequest];
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
	    
	    [[[[[cssp createMultipartUpload:createReq] continueWithBlock:^id(BFTask *task) {
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
	        
	        return [cssp completeMultipartUpload:compReq];
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
	    
	    [[[cssp listObjects:listObjectReq] continueWithBlock:^id(BFTask *task) {
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
	    
	    [[[cssp deleteObject:deleteObjectRequest] continueWithBlock:^id(BFTask *task) {
	        XCTAssertNil(task.error, @"The request failed. error: [%@]", task.error);
	        XCTAssertTrue([task.result isKindOfClass:[CSSPDeleteObjectOutput class]],@"The response object is not a class of [%@], got: %@", NSStringFromClass([CSSPDeleteObjectOutput class]),[task.result description]);
	        return nil;
	    }] waitUntilFinished];
=======
一级标题（标题下面加：===）
==========================================
二级标题（标题下面加：---）
-------------------------------------
***
#一级标题（#）
##二级标题（##）
###三级标题（####）
####四级标题（####）
#####五级标题（#####）
######六级标题（######）
***
*斜体*（ \*内容\* 后必须空两格以上，才能换行）   

**粗体**（\**内容\** 后必须空两格以上，才能换行）   

***
用反引号`标记一小段行内代码`（\'内容\'）

> this is a block;(不能用)

***** 
无序（必须空一行才能正确显式列表）

* It fetures:
 * code management
 * HDFS Browser for hadoop

-------  
有序（必须空一行才能正确显式列表）

1. It fetures:
 1. code management
 2. HDFS Browser for hadoop

***
（引用址址：\[名字\]\(网址\)）   
[baidu](http://www.baidu.com) 

***
（引用图片:\!\[内容\]\(网址\)）  
![史努比](http://pic5.nipic.com/20100108/3838282_120913082385_2.jpg)

***
(代码块，用一个制表符或四个空格)

	if not path:
        try:
            git_operation(team_group, project, request.user, None, None)  #just may pull code
        except GitCommandError:
            messages.error(request, 'this repo haven been inited,\nplease push your existed repo!',
                           fail_silently=True)
            url = reverse('project_init_tip',
                          args=(team_group_name, project_name))
>>>>>>> maple/master
