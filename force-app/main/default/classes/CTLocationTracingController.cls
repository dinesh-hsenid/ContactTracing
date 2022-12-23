public with sharing class CTLocationTracingController {
   
    public static List<Location_Tracing__c> getVisitors(String locationId) {
        List<Location_Tracing__c> result = [SELECT Id, Name, Person__c, Location__c, Visit_Date__c,
                                            Person__r.Token__c, Person__r.Health_Status__c 
                                            FROM Location_Tracing__c
                                            WHERE Location__c = :locationId
                                            ORDER BY Visit_Date__c DESC NULLS LAST];
        return result;                                            
    }

    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds) {
        List<Location_Tracing__c> result = [SELECT Id, Name, Person__c, Location__c, Visit_Date__c,
                                            Person__r.Token__c, Person__r.Health_Status__c 
                                            FROM Location_Tracing__c
                                            WHERE Person__c IN :personIds
                                            AND Visit_Date__c = LAST_N_DAYS:10];
        return result;                                            
    }

    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds) {
        List<Location_Tracing__c> result = [SELECT Id, Name, Person__c, Location__c, Visit_Date__c,
                                            Person__r.Token__c, Person__r.Health_Status__c
                                            FROM Location_Tracing__c
                                            WHERE Location__c IN :locationIds AND
                                            Person__r.Health_Status__c = 'Green' AND
                                            Visit_Date__c = LAST_N_DAYS:10];
        return result;                                            
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces) {

        // 1. Get all Unique Location Ids and Person Ids from 'newLocationTraces'
        Set<Id> locationIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();

        for(Location_Tracing__c trace : newLocationTraces) {
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        // 2. Query the existing location tracing records using ids collected from Step 1
        List<Location_Tracing__c> existingLocationTraces = [SELECT Id, Name, Person__c, Location__c, Visit_Date__c
                                                            FROM Location_Tracing__c
                                                            WHERE Location__c IN :locationIds AND 
                                                            Person__c IN :personIds];

        // 3. Create a Map<LocationId, Set<PersonId>>, 
        // to find the duplicates for Persons related with Location easier.
        Map<Id, Set<Id>> duplicateCheckMap = new Map<Id, Set<Id>>();

        if(existingLocationTraces != null && existingLocationTraces.size() > 0) {
            for(Location_Tracing__c trace : existingLocationTraces) {
                if(!duplicateCheckMap.containsKey(trace.Location__c)) {
                    duplicateCheckMap.put(trace.Location__c, new Set<Id>());
                }
                duplicateCheckMap.get(trace.Location__c).add(trace.Person__c);
            }
        }

        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        // 4. Loop over new Location tracing records and check for duplicates in Map (created in Step 3)

        for(Location_Tracing__c trace : newLocationTraces) {
            if(duplicateCheckMap.containsKey(trace.Location__c) 
            && duplicateCheckMap.get(trace.Location__c).contains(trace.Person__c)) {
                duplicates.add(trace);
            }
        }

        // 5. Return duplicates list
        return duplicates;
    }
}
