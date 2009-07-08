<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/admin/amrsregistration/start.form" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>
<script type="text/javascript">
    function focusOnTextBox() {
        var idCardInput = document.getElementById("idCardInput");
        idCardInput.focus();
    }

    function handlePatientResult(result) {
        var scannedPatientId = document.getElementById("scannedPatientId");
        if (result.length != 1) {
            scannedPatientId.value = "";
        } else {
            scannedPatientId.value = result[0].patientId;
        }
    }

    function patientSearch(thing) {
        var identifier = document.getElementById("idCardInput");
        //var identifier = {
        //    identifier:idCardInput.value
        //}
        //DWRAmrsRegistrationService.getPatients(name, null, null, null, null, null, function(str) {alert(str[0].personName);});
        //DWRAmrsRegistrationService.getPatients(null, null, null, null, null, null, handlePatientResult);
        DWRPatientService.findPatients(identifier, false, handlePatientResult);
    }


</script>

<h2><spring:message code="amrsregistration.start.title"/></h2>
<span><spring:message code="amrsregistration.start.details"/></span>
<br/><br/>
<b class="boxHeader"><spring:message code="amrsregistration.start"/> </b>
<form id="identifierForm" method="post" class="box">
    <table name="initialMrn" border="0" cellspacing="2" cellpadding="2" align="center">
        <tr id="initMrn" name="initMrn">
            <td align="center" valign="top">
                <input type="hidden" id="scannedPatientId" name="scannedPatientId"/>
                <input type="text" id="idCardInput" size="16" name="idCardInput" onchange="patientSearch(this.value)"/>
            </td>
            <td>
                &nbsp;<label><spring:message code="amrsregistration.start.barcode"/></label><br/>
            </td>
        </tr>
		<tr>
			<td align="center" valign="top">
				<input type="submit" name="_target1" value="<spring:message code="amrsregistration.start.nocard"/>">
			</td>
		</tr>
	</table>
</form>
<br/>
<script type="text/javascript">
    focusOnTextBox();
</script>
<%@ include file="/WEB-INF/template/footer.jsp"%>
