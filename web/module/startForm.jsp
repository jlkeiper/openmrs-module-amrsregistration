<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/admin/amrsregistration/start.form" />

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
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

<spring:hasBindErrors name="patient">
	<c:forEach items="${errors.allErrors}" var="error">
		<span class="error"><spring:message code="${error.code}"/></span>
	</c:forEach>
</spring:hasBindErrors>
<b class="boxHeader"><spring:message code="amrsregistration.start"/> </b>
<form id="identifierForm" method="post" class="box">
    <table name="initialMrn" border="0" cellspacing="2" cellpadding="2" align="center">
        <tr id="initMrn" name="initMrn">
            <td align="center" valign="top">
                <input type="hidden" id="scannedPatientId" name="scannedPatientId"/>
                <input type="text" id="idCardInput" size="20" name="idCardInput"/>
            </td>
			<td align="center" valign="top">
				<input type="submit" name="_target1" value="<spring:message code="amrsregistration.button.go"/>">
			</td>
        </tr>
</form>
<form id="newIdentifierForm" method="post" class="box">
		<tr>
			<td align="center" valign="top">
				<input type="submit" name="_target1" value="<spring:message code="amrsregistration.button.nocard"/>">
			</td>
		</tr>
	</table>
</form>
<br/>
<script type="text/javascript">
    focusOnTextBox();
</script>
<%@ include file="/WEB-INF/template/footer.jsp"%>
