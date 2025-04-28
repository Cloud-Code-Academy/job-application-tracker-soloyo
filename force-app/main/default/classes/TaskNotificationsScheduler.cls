public with sharing class TaskNotificationsScheduler {

    // schedule upcoming tasks notifications
    public static void scheduleUpcomingTasksNotifications() {
        String jobName = 'Upcoming Task Notification Job';
        String cron = '0 0 7 * * ?'; 
        
        if (Schema.sObjectType.CronTrigger.isAccessible()) { 
            List<CronTrigger> existingJobs = [ select Id from CronTrigger where CronJobDetail.Name = :jobName ];
        
            if (!existingJobs.isEmpty()) {
                System.abortJob(existingJobs[0].Id);
            }
        
            System.schedule(jobName, cron, new UpcomingTaskSchedule());
        }
    }

    // schedule overdue tasks notifications
    public static void scheduleOverdueTasksNotifications() {
        String jobName = 'Overdue Task Notification Job';
        String cron = '0 0 8 * * ?'; 
        
        if (Schema.sObjectType.CronTrigger.isAccessible()) {
            List<CronTrigger> existingJobs = [ select Id from CronTrigger where CronJobDetail.Name = :jobName ];
            
            if (!existingJobs.isEmpty()) {
                System.abortJob(existingJobs[0].Id);
            }
        
            System.schedule(jobName, cron, new OverdueTaskSchedule());
        }
    }

    public class OverdueTaskSchedule implements Schedulable {
        public void execute (SchedulableContext sc) {
            TasksNotifications.overdueTasksNotifications();
        }
    }

    public class UpcomingTaskSchedule implements Schedulable {
        public void execute (SchedulableContext sc) {
            TasksNotifications.upcomingTasksNotifications();
        }
    }

    public static void setupNotifications() {
        scheduleUpcomingTasksNotifications();
        scheduleOverdueTasksNotifications();
    }
}