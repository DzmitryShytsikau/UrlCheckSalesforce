public class SystemLogHandler {
    public static void addLog(String logType, String logLevel, String logMessage){
        System_Log__c log = new System_Log__c(
            Log_Level__c = logLevel,
            Log_Type__c = logType,
            Log_Message__c = logMessage
        );
        insert log;
    }
}