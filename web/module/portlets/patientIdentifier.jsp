<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/registration.form" />

<table class="box" border="0" cellspacing="2" cellpadding="2">
    <b class="boxHeader"><spring:message code="amrsregistration.edit.identifier"/></b>
    <tr>
        <th align="left" valign="top">
            <spring:message code="general.preferred"/>?
        </th>
        <td align="left" valign="top">
            <spring:bind path="preferred">
				<input type="hidden" name="_${status.expression}">
				<input type="checkbox" name="${status.expression}" value="true" alt="patientIdentifier" onclick="if (preferredBoxClick) preferredBoxClick(this)" <c:if test="${status.value == true}">checked</c:if> />
            </spring:bind>
        </td>
        <th align="right" valign="top">
            Identifier
        </th>
        <td>
            <spring:bind path="identifier">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="PatientIdentifier.identifierType"/>
        </th>
        <td>
            <spring:bind path="identifierType">
                <select id="${status.expression}" name="${status.expression}">
                    <openmrs:forEachRecord name="patientIdentifierType">
                    	<c:if test="${amrsIdType != record.name}">
	                        <option value="${record.patientIdentifierTypeId}"
	                        <c:if test="${record.patientIdentifierTypeId == status.value}">selected</c:if> >
	                        	${record.name}
	                        </option>
                        </c:if>
                    </openmrs:forEachRecord>
                </select>
            </spring:bind>
        </td>
		<th align="right"><spring:message code="PatientIdentifier.location"/></th>
		<td>
			<spring:bind path="location">
				<select id="${status.expression}" name="${status.expression}">
					<openmrs:forEachRecord name="location">
						<option value="${record.locationId}" <c:if test="${record.locationId == status.value}">selected</c:if>>
							${record.name}
						</option>
					</openmrs:forEachRecord>
				</select>
				<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
			</spring:bind>
		</td>
	</tr>
</table>
