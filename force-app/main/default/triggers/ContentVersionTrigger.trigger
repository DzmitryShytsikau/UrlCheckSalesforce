trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        ContentVersionTriggerHandler cv = new ContentVersionTriggerHandler();
        cv.contentDocumentCheck(Trigger.new);
    }
}