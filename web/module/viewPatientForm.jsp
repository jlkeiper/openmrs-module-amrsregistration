<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>

<h2><spring:message code="amrsregistration.start.title"/></h2>
<span><spring:message code="amrsregistration.start.review"/></span>
<br/><br/>

<form id="identifierForm" method="post">
	<div id="summaryHeading">
		<div id="headingName">${patient.personName}</div>
		<div id="headingPreferredIdentifier">
			<c:if test="${fn:length(patient.activeIdentifiers) > 0}">
				<c:forEach var="identifier" items="${patient.activeIdentifiers}">
					<c:if test="${amrsIdType == identifier.identifierType.name}">
						<span>
							${identifier.identifier}
						</span>
					</c:if>
				</c:forEach>
			</c:if>
		</div>
		<%@ include file="portlets/personInfo.jsp" %>
	</div>

	<div class="summaryInfo">
		<div class="infoHeading">Name</div>
		<table>
			<tr>
				<td>
					<c:forEach var="name" items="${patient.names}" varStatus="varStatus">
						<c:if test="${!name.voided}">
							<spring:nestedPath path="patient.names[${varStatus.index}]">
								<openmrs:portlet url="nameLayout" id="namePortlet" size="quickView" parameters="layoutShowExtended=true" />
							</spring:nestedPath>
						</c:if>
					</c:forEach>
				</td>
			</tr>
		</table>
	</div>
	
	<div class="summaryInfo">
		<div class="infoHeading"><spring:message code="Person.addresses"/></div>
		<table>
			<tr>
				<td>
					<c:forEach var="address" items="${patient.addresses}" varStatus="varStatus">
						<c:if test="${!address.voided}">
							<spring:nestedPath path="patient.addresses[${varStatus.index}]">
								<openmrs:portlet url="addressLayout" id="addressPortlet" size="inOneRow" parameters="layoutMode=view|layoutShowTable=false|layoutShowExtended=false" />
							</spring:nestedPath>
						</c:if>
					</c:forEach>
				</td>
			</tr>
		</table>
	</div>
		
	<br />
	<input type="hidden" name="_page3" value="true" />
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
