public with sharing class CTLocationTracingDataCleanupBatch implements Database.Batchable<SObject> {
   
    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Visit_Date__c FROM Location_Tracing__c WHERE Visit_Date__c < LAST_N_DAYS:3');
    }

    public void execute(Database.BatchableContext bc, List<Location_Tracing__c> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Data Clean up Location Batch was finished');
    }
}
