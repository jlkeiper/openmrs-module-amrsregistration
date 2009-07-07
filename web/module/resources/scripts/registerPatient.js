$(document).ready(function() {
    $("#deathInformation").hide();
    $("#i18n").datepicker($.extend({},
        $.datepicker.regional[''], {
            showStatus: true,
            showOn: "both",
            buttonImage: "/openmrs/moduleResources/amrsregistration/images/calendar.gif",
            buttonImageOnly: true
        }));
    $("#deathPicker").datepicker($.extend({},
        $.datepicker.regional[''], {
            showStatus: true,
            showOn: "both",
            buttonImage: "/openmrs/moduleResources/amrsregistration/images/calendar.gif",
            buttonImageOnly: true
        }));
    $("#age").html(calculateAge());
    if(($("#loadedID").html())==null || ($("#loadedID").html())=="" ){
        $("#saveButton").attr("disabled","true");
    }
});

function personDeadClicked(){
    if( $("#personDead").attr('checked')==true)
        $("#deathInformation").show();
    else
        $("#deathInformation").hide();
}

function changeAge(){
    $("#age").html(calculateAge());
}

function calculateAge(){
    var currentDate = new Date();
    ms = currentDate.valueOf() - new Date($("#i18n").attr('value')).valueOf();
    var minutes = ms / 1000 / 60;
    var hours = minutes / 60;
    var days = hours / 24;
    var years = days/365;
    if(Math.floor(years) == 0)
        return '< 1';
    else
        return Math.floor(years);
}