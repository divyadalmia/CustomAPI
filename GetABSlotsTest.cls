@isTest
public with sharing class GetABSlotsTest {
    private static final String GET_SLOT_URL = '/services/apexrest/GetABSlots';
    
    @isTest static void doPostTestWithSANumber() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
            
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.ERROR_MESSAGE);
    }
    
    @isTest static void doPostTestWithNoSAFound() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = 'TestSA';
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
            
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.NO_SERVICE_APPOINTMENT_FOUND);
    }
    
    @isTest static void doPostTestWithNoPolicy() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            //WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
            
        }
        
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.NOT_SCHEDULED_UNSCHEDULED);
    }
    
    @isTest static void doPostTestWithInvalidStatus() {
        system.runAs(HSTestFactory.UserCreate()) {
            
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Dispatched');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
            
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.NOT_SCHEDULED_UNSCHEDULED);
    }
    
    @isTest static void doPostTestWithNoTerritory() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.createSA(testWO,'Open',datetime.newInstance(2022, 7, 05, 13, 00, 0),datetime.newInstance(2022, 7, 30, 14, 00, 0),new ServiceTerritory());
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];		    
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.NO_SERVICETERRITORY); 
    }
    
    @isTest static void doPostTestWithNoSlots() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            HSTestFactory.createSchedulingPolicy();
            HSTestFactory.createOperatingHour();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.NO_SLOTAVAILABLE); 
    }
    
    @isTest static void doPostTestWithSlots() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            HSTestFactory.createSchedulingPolicy();
            HSTestFactory.createOperatingHour();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            OperatingHours operatingHourObj = HSTestFactory.creatOperatingHours('Eastern Operating Hours Test', 'America/New_York');
            TimeSlot timeSlotObj = HSTestFactory.creatTimeSlot(operatingHourObj, Time.newInstance(8,0,0,0), Time.newInstance(20,30,0,0));
            ServiceTerritory serviceTerritoryObj = HSTestFactory.creatServiceTerritory('Maryland',operatingHourObj,true);
            ServiceAppointment testSA = HSTestFactory.createSA(testWO,'Open', DateTime.now().addDays(1),DateTime.now().addDays(10),serviceTerritoryObj);
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            FSL__Scheduling_Policy__c policy = MyABUtil.fetchSchedulingPolicy();
            
            Test.startTest();
            GetABSlots.generateTimeSlots(requestWrap, true);
            Test.stopTest();
        }
    }

    /*
    @isTest static void doPostTestWithDefaultOH() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.MISSING_PARAMETER); 
    }
    
    @isTest static void doPostTestWithDefaultSP() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            
            HSTestFactory.createOperatingHour();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper requestWrap = new ABWrapper.requestWrapper();
            requestWrap.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(GET_SLOT_URL,requestWrap);
            
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
        }
        System.AssertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode, MyABUtil.MISSING_PARAMETER); 
    } */

    @isTest static void catchBlock() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            HSTestFactory.createPostRequest(GET_SLOT_URL,null);
            Test.startTest();
            GetABSlots.doPost();
            Test.stopTest();
        }
    }
}