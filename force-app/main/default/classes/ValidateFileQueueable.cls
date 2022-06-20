public class ValidateFileQueueable implements Queueable,Database.AllowsCallouts{
    private static final String STATE_URL_NAME = 'UrlCheckState';
    private static final String STATE_PARSER_NAME = 'UrlParser';
    public ContentVersion cv;
    private List<String> restrictedUrls;
    
    public ValidateFileQueueable(ContentVersion contentData){
        cv = contentData;
        restrictedUrls = new List<String>();
        for(Restricted_URLs__mdt mdt : [SELECT URL__c FROM Restricted_URLs__mdt]){
            restrictedUrls.add(mdt.URL__c);
        }
    }
    
    public void execute(QueueableContext qc){
        Map<String, String> meta = new Map<String, String>();
        for(Integration_Settings__mdt mdt : [SELECT Id, DeveloperName, Endpoint__c FROM Integration_Settings__mdt]){
            meta.put(mdt.DeveloperName, mdt.Endpoint__c);
        }
        try{
            HttpResponse stateResponce = ValidateFileQueueable.serverState(meta.get(STATE_URL_NAME));
            if(stateResponce.getStatusCode() == 200 && stateResponce.getStatus() == 'OK'){
                HttpResponse parseResponce = ValidateFileQueueable.urlParser(restrictedUrls, meta.get(STATE_PARSER_NAME), cv);
                if(parseResponce.getStatusCode() == 200){
                    Map<String, String> responce = (Map<String, String>)JSON.deserialize(parseResponce.getBody(), Map<String, String>.class);
                    if(responce.get('message') == 'One or more URLs are restricted!'){
                        ValidateFileQueueable.deleteFile(cv);
                    } else if(responce.get('status') == 'true'){
                        String logMessage = 'URLS: '+ responce.get('message');
                        String responceResult = responce.get('message');
                        User u = [SELECT Name FROM User WHERE Id = :cv.OwnerId LIMIT 1];
                        String fileName = cv.Title;
                        responceResult = 'Title: ' + fileName + '; User Name: ' + u.Name + '; DT: ' + DateTime.now() + responceResult;
                        SystemLogHandler.addLog('Success', 'Integration', responceResult);
                    } else if(responce.get('status') == 'false'){
                       	String logMessage = responce.get('message');
                    	SystemLogHandler.addLog('Integration Error', 'Integration', logMessage);
                    }
                } else {
                    String logMessage = 'Status Code: ' + parseResponce.getStatusCode()+ ', Status: ' + parseResponce.getStatus()+ ', Message:' + parseResponce.getBody();
                    SystemLogHandler.addLog('Integration Error', 'Integration', logMessage);
                }
            } else {
                String logMessage = 'Status Code: ' + stateResponce.getStatusCode() + ', Status: ' + stateResponce.getStatus() + ', Message:' + stateResponce.getBody();
                SystemLogHandler.addLog('Integration Error', 'Integration', logMessage);
            }
        } catch (Exception e){
             SystemLogHandler.addLog('Error', 'System', e.getMessage());
        }
    }
    
    private static HttpResponse serverState(String endpoint){
        Http h = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setHeader('Content-Type','application/json'); 
        httpReq.setEndpoint(endpoint);
        HttpResponse res = h.send(httpReq);
        return res;
    }
    
    private static HttpResponse urlParser(List<String> restrictedUrls, String endpoint, ContentVersion cv){
        System.debug('=== cv '+cv.VersionData.toString());
        System.debug('=== endpoint '+endpoint);
        Http h = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
    	httpReq.setHeader('Content-Type', 'application/json;charset=UTF-8');
        System.debug(cv.VersionData.toString());
        ValidateTextWrapper wrap = new ValidateTextWrapper(restrictedUrls, cv.VersionData.toString());
        httpReq.setBody(JSON.serialize(wrap));
		httpReq.setEndpoint(endpoint);
        HttpResponse res = h.send(httpReq);
        return res;
    }
    
    private static void deleteFile(ContentVersion cv){
        List<String> usersIds = new List<String>();
        List<String> userNames = new List<String>();
        for(ContentDocumentLink cdl : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = : cv.ContentDocumentId]){
            if(String.valueOf(cdl.LinkedEntityId).startsWith('005')){
                usersIds.add(cdl.LinkedEntityId);
            }
        }
        for(User u : [SELECT Name FROM User WHERE Id IN :usersIds]){
            userNames.add(u.Name);
        }
        String logMessage = cv.Title + 'file was deleted due to infected link for the following users: '+ userNames;
        SystemLogHandler.addLog('Integration Error', 'Integration', logMessage);
        ContentDocument docToDelete = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId LIMIT 1];
        delete docToDelete;
    }
    
    public class ValidateTextWrapper {
        public String[] restrictedUrls;
        public String uncheckedText;
        public ValidateTextWrapper(List<String> restictedValues, String textValue){
            uncheckedText = textValue;
            restrictedUrls = restictedValues;
        }
    }
}