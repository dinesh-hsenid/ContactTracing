({
    handleSelect : function(component, event, helper) {
        const selectedTabId = event.getParam("id");

        if(selectedTabId === "person") {
            component.set("v.headerTitle", "Person View");
            // console.log('Person view selected');
        }
        else {
            component.set("v.headerTitle", "Location View");
            // console.log('Location view selected');
        }
        component.set("v.scope", selectedTabId);

        const healthHeaderComp = component.find("health-header");
        healthHeaderComp.getStatusCount();
    }
})
