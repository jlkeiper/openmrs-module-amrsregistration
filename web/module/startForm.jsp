<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/admin/amrsregistration/start.form" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>
<script type="text/javascript">
    function focusOnTextBox() {
        var idCardInput = document.getElementById("idCardInput");
        idCardInput.focus();
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
                <input type="text" id="idCardInput" size="16" name="idCardInput"/>
            </td>
            <td>
                &nbsp;<label><spring:message code="amrsregistration.start.barcode"/></label><br/>
            </td>
			<td align="center" valign="top">
				<input type="submit" name="_target1" value="<spring:message code="amrsregistration.start.go"/>">
			</td>
        </tr>
</form>
<form id="newIdentifierForm" method="post" class="box">
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
