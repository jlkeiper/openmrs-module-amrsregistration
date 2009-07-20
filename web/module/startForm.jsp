<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/start.form" />

<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		var allInput = $(":input");
		allInput.css("font-size", "150%");
	});
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
<div class="box">
	<form id="identifierForm" method="post">
	    <table name="initialMrn" align="center">
	        <tr id="initMrn" name="initMrn">
	            <td align="center" valign="top">
	                <input type="hidden" id="scannedPatientId" name="scannedPatientId"/>
	                <input type="text" id="idCardInput" size="20" name="idCardInput"/>
	            </td>
				<td align="center" valign="top">
					<input type="submit" name="_target1" value="<spring:message code="amrsregistration.button.go"/>">
				</td>
	        </tr>
		</table>
	</form>
	<form id="newIdentifierForm" method="post">
	    <table name="newMrn" align="center">
			<tr>
				<td align="center" valign="top">
					<input type="submit" name="_target1" value="<spring:message code="amrsregistration.button.nocard"/>">
				</td>
			</tr>
		</table>
	</form>
</div>
<br/>
<script type="text/javascript">
    focusOnTextBox();
</script>
<%@ include file="/WEB-INF/template/footer.jsp"%>
