$(document).ready(function() {
    var options = {
        target:        '#uploadMessage',   // target element(s) to be updated with server response
        beforeSubmit:  showRequest,  // pre-submit callback
        success:       showResponse,  // post-submit callback
        clearForm:     true
    };
    $('#uploadForm').ajaxForm(options);
});
function showRequest(formData, jqForm, options) {
}

// post-submit callback
function showResponse(responseText, statusText){
    $("#availableCount").hide();
    $("#usedCount").hide();
}