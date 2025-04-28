public with sharing class JobsListController {
    @AuraEnabled(cacheable=true)    
    public static List<Job_Application__c> getAllJobs() {
        List<Job_Application__c> allJobs = new List<Job_Application__c>();

        try {
            if (Schema.sObjectType.Job_Application__c.isAccessible()) {
                allJobs = [select Id, Company_Name__c, Position__c, Salary__c, Status__c, Application_Date__c, Interview_Date__c, URL__c from Job_Application__c order by Application_Date__c desc];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return allJobs;
    }
}