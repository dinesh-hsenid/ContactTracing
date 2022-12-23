({
    updateStatus : function(component, event, helper) {
        const action = component.get("c.updateHealthStatus");
        const recordId = component.get("v.recordId");

        action.setParams({
            personId : recordId 
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === 'SUCCESS') {
                this.showToast("Success", "Person Health Status Updated", "success");
            }
            else {
                this.showToast("Error", "There is a problem in Health Status update", "error");
            }
        });

        $A.enqueueAction(action);
    },

    showToast : function(titleValue, messageValue, typeValue) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": titleValue,
            "message": messageValue,
            "type" : typeValue
        });
        toastEvent.fire();
    }
})
