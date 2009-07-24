<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<script type="text/javascript">
	
	function parseDate(d) {
		var str = '';
		if (d != null) {
			
			// get the month, day, year values
			var month = "";
			var day = "";
			var year = "";
			var date = d.getDate();
			
			if (date < 10)
				day += "0";
			day += date;
			var m = d.getMonth() + 1;
			if (m < 10)
				month += "0";
			month += m;
			if (d.getYear() < 1900)
				year = (d.getYear() + 1900);
			else
				year = d.getYear();
		
			var datePattern = '<openmrs:datePattern />';
			var sep = datePattern.substr(2,1);
			var datePatternStart = datePattern.substr(0,1).toLowerCase();
			
			if (datePatternStart == 'm') /* M-D-Y */
				str = month + sep + day + sep + year
			else if (datePatternStart == 'y') /* Y-M-D */
				str = year + sep + month + sep + day
			else /* (datePatternStart == 'd') D-M-Y */
				str = day + sep + month + sep + year
			
		}
		return str;
	}
</script>

<h2><spring:message code="amrsregistration.start.title"/></h2>
<span><spring:message code="amrsregistration.start.review"/></span>
<br/><br/>

<form id="identifierForm" method="post">
	<div id="patientHeader" class="boxHeader">
	<div id="patientHeaderPatientName">${patient.personName}</div>
	<div id="patientHeaderPreferredIdentifier">
		<c:if test="${fn:length(patient.activeIdentifiers) > 0}">
			<c:forEach var="identifier" items="${patient.activeIdentifiers}">
				<c:if test="${amrsIdType == identifier.identifierType.name}">
					<span class="patientHeaderPatientIdentifier">
						<span id="patientHeaderPatientIdentifierType">
							${identifier.identifierType.name}:
						</span>
						${identifier.identifier}
					</span>
				</c:if>
			</c:forEach>
		</c:if>
	</div>
	<%@ include file="portlets/personInfo.jsp" %>
	</div>
	<br />
	
	<div class="boxHeader"><spring:message code="Patient.title"/></div>
	<div class="box">
		<table class="personName">
			<thead>
				<tr>
					<th><spring:message code="Person.names"/></th>
					<openmrs:forEachDisplayAttributeType personType="patient" displayType="viewing" var="attrType">
						<th><spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/></th>
					</openmrs:forEachDisplayAttributeType>
				</tr>
			</thead>
			<tbody>
				<tr>
					<openmrs:forEachDisplayAttributeType personType="patient" displayType="viewing" var="attrType">
						<td valign="top">${patient.attributeMap[attrType.name]}</td>
					</openmrs:forEachDisplayAttributeType>
				</tr>
			</tbody>
		</table>
	</div>
	
	<br/>
	
	<div class="boxHeader"><spring:message code="Person.addresses"/></div>
	<div class="box">
		<table class="personAddress">
			<thead>
				<openmrs:portlet url="addressLayout" id="addressPortlet" size="columnHeaders" parameters="layoutShowTable=false|layoutShowExtended=true" />
			</thead>
			<tbody>
				<c:forEach var="address" items="${patient.addresses}" varStatus="varStatus">
					<c:if test="${!address.voided}">
						<spring:nestedPath path="patient.addresses[${varStatus.index}]">
							<openmrs:portlet url="addressLayout" id="addressPortlet" size="inOneRow" parameters="layoutMode=view|layoutShowTable=false|layoutShowExtended=true" />
						</spring:nestedPath>
					</c:if>
				</c:forEach>
			</tbody>
		</table>
	</div>
	<br />
	&nbsp;
	<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
	&nbsp; &nbsp;
	<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
	&nbsp; &nbsp;
	<input type="submit" name="_finish" value="<spring:message code='amrsregistration.button.register'/>">
</form>
<br/>
<br />
<%@ include file="/WEB-INF/template/footer.jsp" %>
