public with sharing class CTLocationStatusUpdateBatch implements Database.Batchable<SObject> {
    
    public Date today = Date.today();
    public Date fourteenDaysBackDate = today - 14;
    public List<String> statuses = new List<String>{'Red', 'Yellow', 'Orange'};

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Status_Update_Date__c, Status__c FROM Location__c WHERE (Status_Update_Date__c =: fourteenDaysBackDate AND Status__c IN: statuses)');
    }

    public void execute(Database.BatchableContext bc, List<Location__c> scope) {
        for(Location__c location : scope) {
            location.Status__c = 'Green';
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Location Health Update Batch finished');
    }
}
