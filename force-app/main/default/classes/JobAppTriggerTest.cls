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
}