<table width="100%">
	<tr>
		<td class="headingElement" style="padding: 0px;">
			<c:if test="${patient.gender == 'M'}"><img src="${pageContext.request.contextPath}/images/male.gif" alt='<spring:message code="Person.gender.male"/>' id="maleGenderIcon"/></c:if>
			<c:if test="${patient.gender == 'F'}"><img src="${pageContext.request.contextPath}/images/female.gif" alt='<spring:message code="Person.gender.female"/>' id="femaleGenderIcon"/></c:if>
		</td>
		<td class="headingElement">
			<c:if test="${patient.age > 0}">${patient.age} <spring:message code="Person.age.years"/></c:if>
			<c:if test="${patient.age == 0}">< 1 <spring:message code="Person.age.year"/></c:if>
			<span><c:if test="${not empty patient.birthdate}">(<c:if test="${patient.birthdateEstimated}">~</c:if><openmrs:formatDate date="${patient.birthdate}" type="medium" />)</c:if><c:if test="${empty patient.birthdate}"><spring:message code="Person.age.unknown"/></c:if></span>
		</td>
		<td width="100%">&nbsp;</td>
		<td class="headingElement" style="padding: 0px;">
			<table width="100%">
			<c:forEach var="identifier" items="${patient.activeIdentifiers}">
				<c:if test="${amrsIdType != identifier.identifierType.name && fn:length(identifier.identifier) > 0}">
					<tr>
						<td>
							<span>
								${identifier.identifierType.name}:
								${identifier.identifier}
							</span>
						</td>
					</tr>
				</c:if>
			</c:forEach>
			</table>
		</td>
	</tr>
</table>