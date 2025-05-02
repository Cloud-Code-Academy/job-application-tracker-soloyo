@isTest
private class JobAppTriggerTest {

    @isTest
    static void testCreateTask() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 5; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Applied',
                Application_Date__c = Date.today().addDays(-i),
                Interview_Date__c = Date.today().addDays(i),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;
        
        List<Task> tasks = [select Id, Subject from Task where Subject LIKE '%Job Application%'];

        System.assertEquals(5, tasks.size(), 'Five tasks should have been created.');
    }

    @isTest
    static void testCreateEvent() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 1; i < 6; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Applied',
                Application_Date__c = Date.today(),
                Interview_Date__c = Date.today().addDays(i),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;
        
        List<Event> events = [select Id, Subject from Event where Subject LIKE '%Interview%'];

        System.assertEquals(5, events.size(), 'Five events should have been created.');
    }

    @isTest
    static void testCreateEvent_AfterUpdate() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 1; i < 6; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Applied',
                Application_Date__c = Date.today(),
                Interview_Date__c = Date.today().addDays(i),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;

        for (Job_Application__c app : testApplications) {
            app.Interview_Date__c = Date.today().addDays(10);
        }
        
        update testApplications;
        
        List<Event> events = [select Id, Subject from Event where Subject LIKE '%Interview%'];

        System.assertEquals(5, events.size(), 'Five events should have been created.');
    }
}