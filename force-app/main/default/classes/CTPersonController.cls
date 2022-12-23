public with sharing class CTPersonController {
    
    public static String getToken(String mobileNo) {
        Blob targetBlob = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        return EncodingUtil.base64Encode(hash);
    }

    public static List<Person__c> getRecentHealthChanges() {
        List<Person__c> result = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                                  FROM Person__c
                                  ORDER BY Status_Update_Date__c DESC
                                  NULLS LAST LIMIT 100];
        return result;                          
    }

    public static List<Person__c> searchPeople(String searchTerm) {
        String searchValue =  searchTerm + '%';

        List<Person__c> result = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                                  FROM Person__c
                                  WHERE Name LIKE :searchValue OR 
                                  Mobile__c LIKE :searchValue OR
                                  Token__c LIKE :searchValue
                                  ORDER BY Status_Update_Date__c DESC
                                  NULLS LAST];
        return result;
    }

    public static Person__c getPersonById(String personId) {
        List<Person__c> result = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                            FROM Person__c
                            WHERE Id = :personId];

        if(result != null && result.size() > 0) {
            return result[0];
        }                            
        return null;                            
    }

    public static Map<String, Integer> getHealthStatusCount() {
        List<AggregateResult> statusCounts = [SELECT Health_Status__c, COUNT(Id) total FROM Person__c 
                                              GROUP BY Health_Status__c];

        Map<String,Integer> result = new Map<String,Integer>();
        
        if(statusCounts != null && statusCounts.size() > 0) {
            for(AggregateResult ar : statusCounts) {
                String healthStatus = String.valueOf(ar.get('Health_Status__c'));
                Integer total = Integer.valueOf(ar.get('total'));
    
                result.put(healthStatus, total);
            }
            return result;
        }
        return null;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> statuses = new List<String> {'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Cohabitant'
                                                AND (Person_1__r.Health_Status__c IN :statuses OR Person_2__r.Health_Status__c IN :statuses)];
                                                
        Set<Id> cohabitants = new Set<Id>();
        
        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)) {
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)) {
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Neighbour'
                                                AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        Set<Id> neighbours = new Set<Id>();

        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)) {
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)) {
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed) {
        List<String> statuses = new List<String> {'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN :statuses OR Person_2__r.Health_Status__c IN :statuses)];
        
        Set<Id> primaryContacts = new Set<Id>();
        
        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)) {
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)) {
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }                                       
        return primaryContacts;         
    } 

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed) {
        List<String> statuses = new List<String> {'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                                WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds)
                                                AND Contact_Type__c = 'Other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN :statuses OR Person_2__r.Health_Status__c IN :statuses)];
        
        Set<Id> secondaryContacts = new Set<Id>();

        for(People_Tracing__c pt : peopleTraces) {
            if(!alreadyProcessed.contains(pt.Person_1__c)) {
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }

            if(!alreadyProcessed.contains(pt.Person_2__c)) {
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }
}
