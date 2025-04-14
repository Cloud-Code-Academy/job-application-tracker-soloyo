import { LightningElement, wire, track } from 'lwc';
import getApplicationStats from '@salesforce/apex/DashboardController.getApplicationStats';
import getUpcomingInterviews from '@salesforce/apex/DashboardController.getUpcomingInterviews';
import getPendingTasks from '@salesforce/apex/DashboardController.getPendingTasks';
import completedTask from '@salesforce/apex/DashboardController.completedTask';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Dashboard extends LightningElement {
    @track appliedCount = 0;
    @track interviewCount = 0;
    @track offerCount = 0;
    @track totalCount = 0;
    @track upcomingInterviews = [];
    @track pendingTasks = [];

    @wire(getApplicationStats)
    wiredStats({ error, data }) {
        if (data) {
            this.appliedCount = data.appliedCount || this.appliedCount;
            this.interviewCount = data.interviewCount || this.interviewCount;
            this.offerCount = data.offerCount || this.offerCount;
            this.totalCount = data.totalCount || this.totalCount;
            this.upcomingInterviews = data.upcomingInterviews || this.upcomingInterviews;
            this.pendingTasks = data.pendingTasks || this.pendingTasks;
        } else if (error) {
            console.error('Error fetching application stats:', error);
        }
    }

    @wire(getUpcomingInterviews)
    wiredInterviews({ error, data }) {
        this.interviewResults = data;
        if (data) {
            this.upcomingInterviews = data.map(interview => {
                const startDate = new Date(interview.startDate);

                return {
                    ...interview,
                    formattedDate: startDate.toLocaleDateString(),
                    formattedTime: startDate.toLocateTimeString([], { hour: '2-digit', minute: '2-digit' })
                };
            });
        } else if (error) {
            console.error('Error fetching upcoming interviews:', error);
        }
    }

    @wire(getPendingTasks)
    wiredTasks({ error, data }) {
        this.tasksResults = data;
        if (data) {
            this.pendingTasks = data.map(task => {
                const dueDate = task.ActivityDate ? new Date(task.ActivityDate) : null;

                return {
                    ...task,
                    formattedDueDate: dueDate ? dueDate.toLocaleDateString() : 'No due date'
                };
            });
        }
        else if (error) {
            console.error('Error fetching pending tasks:', error);
        }
    }

    handleTaskCompletion(event) {
        const taskId = event.target.dataset.id;
        const isCompleted = event.target.checked;
        
        if (isCompleted) {
            completedTask({ taskId })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Task marked as completed',
                            variant: 'success'
                        })
                    );

                    return refreshApex(this.wiredTasksResult);
                })
                .catch(error => {
                    console.error('Error completing task:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while completing the task',
                            variant: 'error'
                        })
                    );
                });
        }
    }
}