public with sharing class CTStatusUpdateSchedule implements Schedulable {
    
    public static final String CRON_EXP = '0 0 3 * * ?';

    public void execute(SchedulableContext sc) {
        CTPersonHealthUpdateBatch personBatch = new CTPersonHealthUpdateBatch();
        Database.executeBatch(personBatch, 2000);

        CTLocationStatusUpdateBatch locationBatch = new CTLocationStatusUpdateBatch();
        Database.executeBatch(locationBatch, 2000);
    }
}
