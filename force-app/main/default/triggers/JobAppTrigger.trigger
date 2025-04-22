trigger JobAppTrigger on Job_Application__c (after insert, after update) {
    new JobAppTriggerHandler().run();
}