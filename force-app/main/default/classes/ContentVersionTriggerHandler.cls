public without sharing class ContentVersionTriggerHandler {
    public void contentDocumentCheck(List<ContentVersion> cvList){
        System.debug('cvList '+ cvList.size());
        Set<Id> cvIds = new Set<Id>();
        for(ContentVersion cv : cvList){
            cvIds.add(cv.Id);
        }
        for(ContentVersion cv : [SELECT Id, Title, FileType, FileExtension, VersionData, ContentDocumentId, OwnerId FROM ContentVersion WHERE Id IN :cvIds]){
            if(cv.VersionData != null){
                System.enqueueJob(new ValidateFileQueueable(cv));
            }
        }
    }
}