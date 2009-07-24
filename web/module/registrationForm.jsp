<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form" />

<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/common.js" />

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<script type="text/javascript">

    function focusOnTextBox() {
        var idCardInput = document.getElementById("idCardInput");
        idCardInput.focus();
    }
</script>

<div id="amrsTitle">
	<h2><spring:message code="amrsregistration.start.title"/></h2>
</div>

<style>

	input[type='text'] {
		font-size: 3em;
		text-align: right;
	}
	
	input[type='submit'] {
		font-size: 2em;
		padding: 5px;
		font-weight: bold;
		vertical-align:super;
	}
	
	#amrsForm {
		text-align: center;
	}
	
	#centeredForm {
		position: absolute;
		height: 200px;
		margin-top: -100px;
		top: 50%;
		width: 100%;
	}
	
</style>

<div id="amrsContent">
	<span><spring:message code="amrsregistration.start.details"/></span>
	<div id="amrsForm">
		<div id="centeredForm">
			<spring:hasBindErrors name="patient">	
				<c:forEach items="${errors.allErrors}" var="error">
					<span class="error"><spring:message code="${error.code}"/></span>
				</c:forEach>
			</spring:hasBindErrors>
			<form id="identifierForm" method="post">
		        <input type="hidden" id="scannedPatientId" name="scannedPatientId" />
		        <input type="text" id="idCardInput" size="20" name="idCardInput" style="margin-top: 15px;" />
				<input type="submit" name="_target1" value="  <spring:message code="amrsregistration.button.go"/>  " />
			</form>
			<form id="newIdentifierForm" method="post">
					<input type="submit" name="_target1" value="No Id Card" />
			</form>
		</div>
	</div>
	<br/>
	<script type="text/javascript">
	    focusOnTextBox();
	</script>
</div>
<%@ include file="/WEB-INF/template/footer.jsp"%>
