public with sharing class JobAppTriggerHandler extends TriggerHandler {
    private List<Job_Application__c> newJobApp;
    private List<Job_Application__c> oldJobApp;
    private Map<Id, Job_Application__c> newJobAppMap;
    private Map<Id, Job_Application__c> oldJobAppMap;

    JobAppHelper jobAppHelper = new JobAppHelper();

    public JobAppTriggerHandler() {
        this.oldJobApp = (List<Job_Application__c>) Trigger.old;
        this.newJobApp = (List<Job_Application__c>) Trigger.new;
        this.newJobAppMap = (Map<Id, Job_Application__c>) Trigger.newMap;
        this.oldJobAppMap = (Map<Id, Job_Application__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        /*
         * When a job application is inserted, create a task related to the job application
         */
        jobAppHelper.createTask(newJobApp);
    }

    public override void beforeInsert() {
        jobAppHelper.setDefaultStatus(newJobApp);
    }

    public override void afterUpdate() {
        /*
         * When a job application has been updated, create the interview event related to the job application
         */
        jobAppHelper.createEvent(newJobApp);
    }
}