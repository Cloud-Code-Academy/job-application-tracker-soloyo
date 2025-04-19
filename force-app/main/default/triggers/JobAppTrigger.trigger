trigger JobAppTrigger on Job_Application__c (after insert) {
    new JobAppTriggerHandler().run();
}