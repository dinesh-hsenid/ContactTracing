public with sharing class CTPeopleTracingDataCleanupBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Contact_Date__c FROM People_Tracing__c WHERE Contact_Date__c < LAST_N_DAYS:10');
    }

    public void execute(Database.BatchableContext bc, List<People_Tracing__c> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Data Clean up Batch finished');
    }
}
