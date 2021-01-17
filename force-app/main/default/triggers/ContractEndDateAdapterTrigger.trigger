trigger ContractEndDateAdapterTrigger on SBQQ__Subscription__c (after insert, after update,before insert, before update) {
     if (Trigger.After) {
         if (Trigger.isInsert){
             SubscriptionTriggerHandler.onAfterInsert(Trigger.New);
         }
         if(Trigger.isUpdate){
             SubscriptionTriggerHandler.onAfterInsert(Trigger.newMap,Trigger.oldMap);
         }
     }
     if (Trigger.Before) {
         if (Trigger.isInsert){
             SubscriptionTriggerHandler.onBeforeInsert(Trigger.New);
         }
         
     }
   
}