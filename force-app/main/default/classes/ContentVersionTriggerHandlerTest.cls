@isTest
public class ContentVersionTriggerHandlerTest {
	@testSetup
    public static void initData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(
            firstname = 'TestFirst',
            lastName = 'TestLast',
            email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert tuser;
        Case testCase = new Case(Origin = 'Web',
                                Status = 'New',
                                OwnerId = tuser.Id);
        insert testCase;
    }
    
    @isTest
    public static void testInsertContentVersionSuccess(){
        Test.setMock(HttpCalloutMock.class, new UrlCalloutMock());
        List<System_Log__c> logs = new List<System_Log__c>();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        UrlCalloutMock.callautType = 'success';
        ContentVersion content=new ContentVersion(); 
        content.Title='TextHeader'; 
        content.PathOnClient='/' + content.Title + '.txt'; 
        Blob bodyBlob=Blob.valueOf('Test text sample. www.someUrl.com The end of text sample. www.someUrl2.com'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        Test.stopTest();
        logs = [SELECT Id, Log_Type__c, Log_Level__c, Log_Message__c, CreatedDate FROM System_Log__c];
        System.assertEquals(1, logs.size(), 'System log record should be created');
        System.assertEquals('Success', logs.get(0).Log_Type__c, 'Log type should be equal Success value');
        System.assertEquals('Integration', logs.get(0).Log_Level__c, 'Log level should be equal Integration value');
        System.assertEquals(true, logs.get(0).Log_Message__c.contains('www.someUrl.com'), 'Log message should contain www.someUrl.com value');
    }
    
    @isTest
    public static void testInsertContentVersionInfected(){
        Test.setMock(HttpCalloutMock.class, new UrlCalloutMock());
        List<System_Log__c> logs = new List<System_Log__c>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        UrlCalloutMock.callautType = 'infected';
        ContentVersion content=new ContentVersion(); 
        content.Title='TextHeader'; 
        content.PathOnClient='/' + content.Title + '.txt'; 
        Blob bodyBlob=Blob.valueOf('Test text sample. www.someUrl.com The end of text sample. www.someUrl2.com'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        Test.stopTest();
        cvList = [SELECT Id FROM ContentVersion];
        System.assertEquals(0, cvList.size(), 'ContentVersion record should be deleted!');
        logs = [SELECT Id, Log_Type__c, Log_Level__c, Log_Message__c, CreatedDate FROM System_Log__c];
        System.assertEquals(1, logs.size(), 'System log record should be created');
        System.assertEquals('Integration Error', logs.get(0).Log_Type__c, 'Log type should be equal Success value');
        System.assertEquals('Integration', logs.get(0).Log_Level__c, 'Log level should be equal Integration value');
        System.assertEquals(true, logs.get(0).Log_Message__c.contains('file was deleted due to infected link for the following users'), 'Content version delete message should be added to the log message.');
    }
    
    @isTest
    public static void testInsertContentVersionMissingText(){
        Test.setMock(HttpCalloutMock.class, new UrlCalloutMock());
        List<System_Log__c> logs = new List<System_Log__c>();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        UrlCalloutMock.callautType = 'missing text';
        ContentVersion content=new ContentVersion(); 
        content.Title='TextHeader'; 
        content.PathOnClient='/' + content.Title + '.txt'; 
        Blob bodyBlob=Blob.valueOf('Test text sample. www.someUrl.com The end of text sample. www.someUrl2.com'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        Test.stopTest();
        logs = [SELECT Id, Log_Type__c, Log_Level__c, Log_Message__c, CreatedDate FROM System_Log__c];
        System.assertEquals(1, logs.size(), 'System log record should be created');
        System.assertEquals('Integration Error', logs.get(0).Log_Type__c, 'Log type should be equal Success value');
        System.assertEquals('Integration', logs.get(0).Log_Level__c, 'Log level should be equal Integration value');
        System.assertEquals(true, logs.get(0).Log_Message__c.contains('Text is empty!'), 'Text is empty! message should be added to the log message.');
    }
    
    @isTest
    public static void testServerError(){
        Test.setMock(HttpCalloutMock.class, new UrlCalloutMock());
        List<System_Log__c> logs = new List<System_Log__c>();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        UrlCalloutMock.callautType = 'no responce';
        ContentVersion content=new ContentVersion(); 
        content.Title='TextHeader'; 
        content.PathOnClient='/' + content.Title + '.txt'; 
        Blob bodyBlob=Blob.valueOf('Test text sample. www.someUrl.com The end of text sample. www.someUrl2.com'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        Test.stopTest();
        logs = [SELECT Id, Log_Type__c, Log_Level__c, Log_Message__c, CreatedDate FROM System_Log__c];
        System.assertEquals(1, logs.size(), 'System log record should be created');
        System.assertEquals('Integration Error', logs.get(0).Log_Type__c, 'Log type should be equal Success value');
        System.assertEquals('Integration', logs.get(0).Log_Level__c, 'Log level should be equal Integration value');
        System.assertEquals(true, logs.get(0).Log_Message__c.contains('Server error'), 'Server error message should be added to the log message.');
    }
    
    @isTest
    public static void testServerError2(){
        Test.setMock(HttpCalloutMock.class, new UrlCalloutMock());
        List<System_Log__c> logs = new List<System_Log__c>();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        UrlCalloutMock.callautType = 'no responce 2';
        ContentVersion content=new ContentVersion(); 
        content.Title='TextHeader'; 
        content.PathOnClient='/' + content.Title + '.txt'; 
        Blob bodyBlob=Blob.valueOf('Test text sample. www.someUrl.com The end of text sample. www.someUrl2.com'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        Test.stopTest();
        logs = [SELECT Id, Log_Type__c, Log_Level__c, Log_Message__c, CreatedDate FROM System_Log__c];
        System.assertEquals(1, logs.size(), 'System log record should be created');
        System.assertEquals('Integration Error', logs.get(0).Log_Type__c, 'Log type should be equal Success value');
        System.assertEquals('Integration', logs.get(0).Log_Level__c, 'Log level should be equal Integration value');
        System.assertEquals(true, logs.get(0).Log_Message__c.contains('Server error'), 'Server error message should be added to the log message.');
    }
}