<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>

<h2><spring:message code="amrsregistration.start.title"/></h2>
<span><spring:message code="amrsregistration.start.review"/></span>
<br/><br/>

<script type="text/javascript">
    function changeNameHeaderHack() {
        var headers = document.getElementsByTagName("th");
        for (var i=0; i<headers.length; i++) {
            if (headers[i].innerHTML == "Given") {
                headers[i].innerHTML = "First Name";
            } else if (headers[i].innerHTML == "Middle") {
                headers[i].innerHTML = "Middle Name";
            }
        }
    }
</script>

<form id="identifierForm" method="post">
	<spring:hasBindErrors name="patient">	
		<c:forEach items="${errors.allErrors}" var="error">
			<span class="error"><spring:message code="${error.code}" /></span>
		</c:forEach>
	</spring:hasBindErrors>
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

    <c:forEach var="name" items="${patient.names}" varStatus="varStatus">
       <c:if test="${varStatus.index == 1 && name != personName}">
           <div class="summaryInfo">
               <div class="infoHeading">Other Name(s)</div>
               <table>
                   <tr>
                       <td>
                           <c:forEach var="name" items="${patient.names}" varStatus="varStatus">
                               <c:if test="${!name.voided && name != patient.personName}">
                                   <spring:nestedPath path="patient.names[${varStatus.index}]">
                                       <openmrs:portlet url="nameLayout" id="namePortlet" size="quickView" parameters="layoutShowExtended=true" />
                                   </spring:nestedPath>
                               </c:if>
                           </c:forEach>
                       </td>
                   </tr>
               </table>
           </div>
       </c:if>
    </c:forEach>

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
    
	<c:if test="${displayAttributes}">
    <div class="summaryInfo">
        <div class="infoHeading">Attributes</div>
        <table>
            <openmrs:forEachDisplayAttributeType personType="" displayType="viewing" var="attrType">
                <tr>
                    <td><spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/> :</td>
                    <td>${patient.attributeMap[attrType.name].hydratedObject}</td>
                </tr>
            </openmrs:forEachDisplayAttributeType>
        </table>
    </div>
	</c:if>
	
	<br />
	<input type="hidden" name="_page3" value="true" />
	&nbsp;
	<input type="submit" name="_finish" value="<spring:message code='amrsregistration.button.register'/>">
	&nbsp; &nbsp;
	<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
	&nbsp; &nbsp;
	<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
</form>
<br/>
<br />
<script type="text/javascript">
    changeNameHeaderHack();
</script>
<%@ include file="/WEB-INF/template/footer.jsp" %>
