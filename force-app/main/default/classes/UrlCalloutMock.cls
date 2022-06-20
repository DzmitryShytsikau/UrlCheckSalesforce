@isTest
public class UrlCalloutMock implements HttpCalloutMock{
	public static String callautType;
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if(request.getMethod() == 'GET' && callautType != 'no responce'){
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{status : true, message : OK!}');
            response.setStatusCode(200);
            response.setStatus('OK');
        } else if (request.getMethod() == 'GET' && callautType == 'no responce'){
            response.setStatusCode(404);
            response.setStatus('Server error');
        } else if (request.getMethod() == 'POST'){
            if(callautType == 'success'){
                Map<String, String> responceMessage = new Map<String, String>();
                responceMessage.put('status', 'true');
                responceMessage.put('message', 'www.someUrl.com, www.someUrl2.com');
                response.setHeader('Content-Type', 'application/json');
                response.setBody(JSON.serialize(responceMessage));
                response.setStatusCode(200);
                response.setStatus('OK');
            } else if(callautType == 'infected'){
                Map<String, String> responceMessage = new Map<String, String>();
                responceMessage.put('status', 'true');
                responceMessage.put('message', 'One or more URLs are restricted!');
                response.setHeader('Content-Type', 'application/json');
                response.setBody(JSON.serialize(responceMessage));
                response.setStatusCode(200);
                response.setStatus('OK');
            } else if(callautType == 'missing text'){
                Map<String, String> responceMessage = new Map<String, String>();
                responceMessage.put('status', 'false');
                responceMessage.put('message', 'Text is empty!');
                response.setHeader('Content-Type', 'application/json');
                response.setBody(JSON.serialize(responceMessage));
                response.setStatusCode(200);
                response.setStatus('OK');
            } else if(callautType == 'no responce 2'){
                response.setStatusCode(404);
            	response.setStatus('Server error');
            }
        }
        return response; 
    }
}