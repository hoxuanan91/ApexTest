public with sharing class SubscriptionTriggerHandler {

        private static final CONFORMITE_PUB = 'Conformité Pub';
    	public static void onAfterInsert (List<SBQQ__Subscription__c> newSubscriptions) {
            updateContractEndate(newSubscriptions);
        }

        public static void onAfterUpdate (map<Id, SBQQ__Subscription__c> mapNewSubscriptions, map<Id, SBQQ__Subscription__c> mapOldSubscriptions) {
            updateContractEndate(mapNewSubscriptions.values());
        }

        public static void onBeforeInsert (List<SBQQ__Subscription__c> newSubscriptions) {
        }

       

        private static void verifyNewComplianceProcess( List<SBQQ__Subscription__c> newSubscriptions){
            for(SBQQ__Subscription__c sub : newSubscriptions){
                if(sub.ComplianceProcess__c == CONFORMITE_PUB){
                    if( sub.EffectiveEndDate__c !=  null && sub.EffectiveEndDate__c > Date.today()){
                        sub.Souscription_Conforme__c = true; 
                    } else {
                        sub.Souscription_Conforme__c = false; 
                        sub.MissingInformations__c = CONFORMITE_PUB;
                    }
                }
            }
        }

        private static void updateContractEndate(List<SBQQ__Subscription__c> subscriptionUpserts){
            
            Boolean isTerminate;
            Date terminatedDate;
            Date endDate;
            Savepoint sp = Database.setSavepoint();

            Set<Id> cons = new Set<Id>();
            for (SBQQ__Subscription__c sub :subscriptionUpserts) {
                if(sub.SBQQ__Contract__c !=null)
                    cons.add(sub.SBQQ__Contract__c);
            }
            try {
                if(!cons.isEmpty()){
                    List<Contract> conts = new List<Contract>();
                    for (Contract con : [SELECT Id, EndDate, (SELECT Id, SBQQ__EndDate__c, SBQQ__TerminatedDate__c, SBQQ__Contract__c 
                                                        FROM SBQQ__Subscriptions__r) FROM Contract WHERE Id IN :cons]) {
                        isTerminate = true;
                        terminatedDate = con.EndDate;
                        endDate = con.EndDate;
                        
                        for (SBQQ__Subscription__c sub : con.SBQQ__Subscriptions__r) {
                            if (sub.SBQQ__TerminatedDate__c == null) {
                                isTerminate = false;
                            } else if (terminatedDate < sub.SBQQ__TerminatedDate__c) {
                                terminatedDate = sub.SBQQ__TerminatedDate__c;
                            }
                            if (sub.SBQQ__EndDate__c != null && endDate < sub.SBQQ__EndDate__c) {
                                endDate = sub.SBQQ__EndDate__c;
                            }
                        }
                        
                        if (isTerminate) {
                            con.EndDate = terminatedDate;
                        } else {
                            con.EndDate = endDate;
                        }        
                        conts.add(con);
                    }
                    
                    if(!conts.isEmpty())  UPDATE conts;
                }
            } catch(Exception e) {
                Database.rollback(sp);
                Logs.error('ContractEndDateAdapterTrigger','SBQQ__Subscription__c Trigger insert & update', e);
            }
        }

}