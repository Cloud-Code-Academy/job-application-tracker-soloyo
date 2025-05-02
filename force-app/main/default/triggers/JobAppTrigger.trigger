trigger JobAppTrigger on Job_Application__c (after insert, after update, before insert, after delete) {
    new JobAppTriggerHandler().run();
}