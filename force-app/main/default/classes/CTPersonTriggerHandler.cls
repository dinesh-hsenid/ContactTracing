public with sharing class CTPersonTriggerHandler {
    
    public static void beforeInsert(List<Person__c> newRecords) {
        for(Person__c person : newRecords) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap) {
        for(Person__c person : newRecords) {
            if(person.Health_Status__c != oldRecordsMap.get(person.id).Health_Status__c) {
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap) {

        Set<Id> statusChanges = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();

        for(Person__c person : newRecords) {
            if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c) {
                statusChanges.add(person.Id);
            }

            if(person.Health_Status__c == 'Red' && oldRecordsMap.get(person.Id).Health_Status__c != 'Red') {
                redStatus.add(person.Id);
            }
        }

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        // Adding all cohabitants to Orange status
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));

        // Adding all primary contacts to Orange status
        Set<Id> primaryContactIds = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContactIds);

        // Adding all Neighbour to Yellow status
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));

        // Adding all secondary contacts to Yellow status
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContactIds, alreadyProcessed));

        List<Person__c> personToUpdate = new List<Person__c>();

        for(Id pid : orangeStatus) {
            personToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Orange'));
        }

        for(Id pid : yellowStatus) {
            personToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Yellow'));
        }

        if(personToUpdate.size() > 0) {
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChanges);

        if(locationTraces != null && locationTraces.size() > 0) {
            Set<Id> locationIds = new Set<Id>();

            for(Location_Tracing__c trace : locationTraces) {
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }
    }
}
