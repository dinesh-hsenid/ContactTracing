({
    fetchRecentHealthChanges : function(component, event, helper) {
        const scope = component.get("v.scope");
        const action = scope === 'person' ? component.get("c.getRecentPersonHealthChanges") : component.get("c.getRecentLocationHealthChanges");

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === 'SUCCESS') {
                component.set("v.data", response.getReturnValue());
                component.set("v.initialData", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },

    getSearchRecords : function(component, queryTerm) {
        const scope = component.get("v.scope");
        const action = scope === 'person' ? component.get("c.searchPeople") : component.get("c.searchLocations");

        action.setParams({
            searchTerm : queryTerm
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state === 'SUCCESS') {
                const data = response.getReturnValue();

                if(data && data.length > 0) {
                    component.set("v.data", data);
                }
                component.set("v.issearching", false);
            }
        });

        $A.enqueueAction(action);
    }
})
