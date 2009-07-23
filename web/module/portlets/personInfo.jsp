<table id="patientHeaderGeneralInfo">
	<tr>
		<td id="patientHeaderPatientGender">
			<c:if test="${patient.gender == 'M'}"><img src="${pageContext.request.contextPath}/images/male.gif" alt='<spring:message code="Person.gender.male"/>' id="maleGenderIcon"/></c:if>
			<c:if test="${patient.gender == 'F'}"><img src="${pageContext.request.contextPath}/images/female.gif" alt='<spring:message code="Person.gender.female"/>' id="femaleGenderIcon"/></c:if>
		</td>
		<td id="patientHeaderPatientAge">
			<c:if test="${patient.age > 0}">${patient.age} <spring:message code="Person.age.years"/></c:if>
			<c:if test="${patient.age == 0}">< 1 <spring:message code="Person.age.year"/></c:if>
			<span id="patientHeaderPatientBirthdate"><c:if test="${not empty patient.birthdate}">(<c:if test="${patient.birthdateEstimated}">~</c:if><openmrs:formatDate date="${patient.birthdate}" type="medium" />)</c:if><c:if test="${empty patient.birthdate}"><spring:message code="Person.age.unknown"/></c:if></span>
		</td>
		<%-- Display selected person attributes from the manage person attributes page --%>
		<openmrs:forEachDisplayAttributeType personType="patient" displayType="header" var="attrType">
			<td class="patientHeaderPersonAttribute">
				<spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/>: 
				<b>${patient.attributeMap[attrType.name]}</b>
			</td>
		</openmrs:forEachDisplayAttributeType>
		<td style="width: 100%;">&nbsp;</td>
		<td id="patientHeaderOtherIdentifiers">
			<c:forEach var="identifier" items="${patient.activeIdentifiers}">
				<c:if test="${amrsIdType != identifier.identifierType.name}">
					<span class="patientHeaderPatientIdentifier">
						${identifier.identifierType.name}:
						${identifier.identifier}
					</span>
				</c:if>
			</c:forEach>
		</td>
	</tr>
</table>