function tableGFX_Init(){
    $(".searchTBody tr").not('[id=pageRow]').mouseover(function() {
        $(this).addClass("over");
        $(this).css("cursor", "pointer")
    })
    .mouseout(function(){
        $(this).removeClass("over");
    })
    .click(function(){
        var patientIdentifier = trim($(".dashboardLink",this).html());
        window.location.href = "/openmrs/module/amrsregistration/registrationSummary.list?patientIdentifier="+patientIdentifier;
    });
}

function trim(str)
{
    while(str.charAt(0) == (" ")){
        str = str.substring(1);
    }
    while(str.charAt(str.length-1) == " " ) {
        str = str.substring(0,str.length-1);
    }
    return str;
}