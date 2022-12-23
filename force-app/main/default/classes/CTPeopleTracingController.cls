public with sharing class CTPeopleTracingController {
    
    public static List<People_Tracing__c> getTraces(String recordId) {
        List<People_Tracing__c> result = [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, 
                                          Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c,
                                          Person_2__r.Health_Status__c, Person_2__r.Token__c
                                          FROM People_Tracing__c
                                          WHERE (Person_1__c = :recordId OR
                                          Person_2__c = :recordId) AND
                                          Contact_Date__c = LAST_N_DAYS:30
                                          ORDER BY Contact_Date__c DESC NULLS LAST];

        return result;                                          
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces) {

        Set<Id> uniquePersonIds = new Set<Id>();

        for(People_Tracing__c trace : peopleTraces) {
            uniquePersonIds.add(trace.Person_1__c);
            uniquePersonIds.add(trace.Person_2__c);
        }

        List<People_Tracing__c> existingPeopleTraces = [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c 
                                                        FROM People_Tracing__c
                                                        WHERE Person_1__c IN: uniquePersonIds OR
                                                        Person_2__c IN: uniquePersonIds];

        
        Map<Id, Set<Id>> existingPeopleMap = new Map<Id, Set<Id>>();
        
        if(existingPeopleTraces != null && existingPeopleTraces.size() > 0) {
            for(People_Tracing__c trace : existingPeopleTraces) {
                if(!existingPeopleMap.containsKey(trace.Person_1__c)) {
                    existingPeopleMap.put(trace.Person_1__c, new Set<Id>());
                }
                existingPeopleMap.get(trace.Person_1__c).add(trace.Person_2__c);

                if(!existingPeopleMap.containsKey(trace.Person_2__c)) {
                    existingPeopleMap.put(trace.Person_2__c, new Set<Id>());
                }
                existingPeopleMap.get(trace.Person_2__c).add(trace.Person_1__c);
            }
        }

        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        for(People_Tracing__c trace : peopleTraces) {
            if(
                (existingPeopleMap.containsKey(trace.Person_1__c) &&
                existingPeopleMap.get(trace.Person_1__c).contains(trace.Person_2__c)) || 
                (existingPeopleMap.containsKey(trace.Person_2__c) &&
                existingPeopleMap.get(trace.Person_2__c).contains(trace.Person_1__c))
            ) {
                duplicates.add(trace);
            }
        }

        return duplicates;
    }
}
