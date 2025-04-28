public with sharing class InterviewsNotificationScheduler {
    public static void scheduleUpcomingInterviewNotifications() {
        String jobName = 'Upcoming Interview Notification Job';
        String cron = '0 0 7 * * ?'; 
        
        if (Schema.sObjectType.CronTrigger.isAccessible()) { 
            List<CronTrigger> existingJobs = [ select Id from CronTrigger where CronJobDetail.Name = :jobName ];
        
            if (!existingJobs.isEmpty()) {
                System.abortJob(existingJobs[0].Id);
            }
        
            System.schedule(jobName, cron, new UpcomingInterviewSchedule());
        }
    }

    public class UpcomingInterviewSchedule implements Schedulable {
        public void execute (SchedulableContext sc) {
            InterviewsNotifications.upcomingInterviewNotifications();
        }
    }

    public static void setupNotifications() {
        scheduleUpcomingInterviewNotifications();
    }
}