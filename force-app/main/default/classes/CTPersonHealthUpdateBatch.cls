public with sharing class CTPersonHealthUpdateBatch implements Database.Batchable<SObject> {

    public Date today = Date.today();
    public Date fourteenBackDate = today - 14;
    public List<String> healthStatuses = new List<String>{'Red', 'Yellow', 'Orange'};

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Health_Status__c, Status_Update_Date__c FROM Person__c WHERE (Status_Update_Date__c = :fourteenBackDate AND Health_Status__c IN:healthStatuses)');
    }

    public void execute(Database.BatchableContext bc, List<Person__c> scope) {
        for(Person__c person : scope) {
            person.Health_Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Person Health Update Batch finished');
    }
}
