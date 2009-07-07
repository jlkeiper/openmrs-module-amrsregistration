<table class="box" border="0" cellspacing="2" cellpadding="2">
    <b class="boxHeader"><spring:message code="amrsregistration.edit.address"/></b>
    <c:forEach items="${patient.identifiers}" var="identifier" varStatus="varStatus">
            <spring:nestedPath path="patient.identifiers[${varStatus.index}]">
                <tr id="identifier${varStatus.index}Data" >
                    <th align="left" valign="top">
                        <spring:message code="general.preferred"/>?
                    </th>
                    <td align="left" valign="top">
                        <spring:bind path="preferred">
                            <input type="checkbox" id="identifier.preferred_${varStatus.index}" value="${status.value}" <c:if test="${status.value == 'true'}">checked</c:if>/>
                        </spring:bind>
                    </td>
                    <td>
                        <spring:bind path="identifier">
                            <input type="text" id="identifier_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
                        </spring:bind>
                    </td>
                    <th align="right">
                        <spring:message code="PatientIdentifier.identifierType"/>
                    </th>
                    <td>
                        <spring:bind path="identifierType">
                            <select name="identifierType" id="identifierType_${varStatus.index}">
                                <openmrs:forEachRecord name="patientIdentifierType">
                                    <option value="${record.patientIdentifierTypeId}" <c:if test="${status.value == record.name}">selected</c:if> >
                                        ${record.name}
                                    </option>
                                </openmrs:forEachRecord>
                            </select>
                        </spring:bind>
                    </td>
                </tr>
            </spring:nestedPath>
    </c:forEach>
</table>
