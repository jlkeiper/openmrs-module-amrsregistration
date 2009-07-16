<table class="box" border="0" cellspacing="2" cellpadding="2">
    <b class="boxHeader"><spring:message code="amrsregistration.edit.identifier"/></b>
    <tr>
        <th align="left" valign="top">
            <spring:message code="general.preferred"/>?
        </th>
        <td align="left" valign="top">
            <spring:bind path="preferred">
                <input type="checkbox" id="identifier.preferred_${varStatus.index}" name="identifier.preferred_${varStatus.index}" value="${status.value}" <c:if
                    test="${status.value == 'true'}">checked</c:if>/>
            </spring:bind>
        </td>
        <th align="left" valign="top">
            Identifier
        </th>
        <td>
            <spring:bind path="identifier">
                <input type="text" id="identifier_${varStatus.index}" name="identifier_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="PatientIdentifier.identifierType"/>
        </th>
        <td>
            <spring:bind path="identifierType">
                <select id="identifierType_${varStatus.index}" name="identifierType_${varStatus.index}">
                    <openmrs:forEachRecord name="patientIdentifierType">
                        <option value="${record.patientIdentifierTypeId}"
                        <c:if test="${status.value == record.name}">selected</c:if> >
                        ${record.name}
                        </option>
                    </openmrs:forEachRecord>
                </select>
            </spring:bind>
        </td>
    </tr>
</table>
