public with sharing class CTDataCleanupSchedule implements Schedulable {
    
    public static final String CRON_EXP = '0 0 2 * * ?';

    public void execute(SchedulableContext sc) {
        CTPeopleTracingDataCleanupBatch peopleBatch = new CTPeopleTracingDataCleanupBatch();

        Database.executeBatch(peopleBatch, 2000);

        CTLocationTracingDataCleanupBatch locationBatch = new CTLocationTracingDataCleanupBatch();

        Database.executeBatch(locationBatch, 2000);
    }
}
