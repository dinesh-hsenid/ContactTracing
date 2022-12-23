public with sharing class CTLocationController {
   
    public static List<Location__c> getRecentStatusChanges() {
        List<Location__c> result = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                    FROM Location__c
                                    ORDER BY Status_Update_Date__c DESC
                                    NULLS LAST LIMIT 100];
        return result;
    }

    public static List<Location__c> searchLocations(String searchTerm) {
        String searchValue = searchTerm + '%';

        List<Location__c> result = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                    FROM Location__c
                                    WHERE Name LIKE :searchValue OR
                                    Pincode__c LIKE :searchValue OR
                                    Address__c LIKE :searchValue
                                    ORDER BY Status_Update_Date__c DESC
                                    NULLS LAST];
        return result;                                    
    }

    public static Location__c getLocationById(String locationId) {
        List<Location__c> result = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                              FROM Location__c
                              WHERE Id = :locationId];

        if(result != null && result.size() > 0) {
            return result[0];                              
        }                              
        return null;
    }

    public static Map<String,Integer> getStatusCount() {
        List<AggregateResult> statusCount = [SELECT Status__c, COUNT(Id) total
                                             FROM Location__c
                                             GROUP BY Status__c];
        
        Map<String,Integer> result = new Map<String,Integer>();
        
        for(AggregateResult ar : statusCount) {
            String status = String.valueOf(ar.get('Status__c'));
            Integer count = Integer.valueOf(ar.get('total'));

            result.put(status, count);
        }

        return result;
    }

    public static void updateRedScore(Set<Id> locationIds) {
        List<Location__c> locationToUpdate = new List<Location__c>();
        List<AggregateResult> redPeoplePerLocation = [SELECT Location__c, Count(Id) total FROM Location_Tracing__c
                                                      WHERE Person__r.Health_Status__c = 'Red'
                                                      AND Visit_Date__c = LAST_N_DAYS:10
                                                      AND Location__c IN :locationIds
                                                      GROUP BY Location__c];
        
        for(AggregateResult ar : redPeoplePerLocation) {
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getStatus(redScore);

            locationToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScore, Status__c = status));
        }                                                        

        if(locationToUpdate != null && locationToUpdate.size() > 0) {
            update locationToUpdate;
        }
    }

    public static String getStatus(Integer redScore) {
        if(redScore == 0) {
            return 'Green';
        }
        else if(redScore <= 5) {
            return 'Yellow';
        }
        else if(redScore <= 10) {
            return 'Orange';
        }
        else {
            return 'Red';
        }
    }
}
