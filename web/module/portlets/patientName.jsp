<b class="boxHeader"><spring:message code="amrsregistration.edit"/> </b>
<table class="box" border="0" cellspacing="2" cellpadding="2">
    <tr>
        <th align="left" valign="top">
            Preferred
        </th>
        <th align="left" valign="top">
            Prefix
        </th>
        <th align="left" valign="top">
            <spring:message code="PersonName.givenName"/>
        </th>
        <th>
            <spring:message code="PersonName.middleName"/>
        </th>
        <th>&nbsp;</th>
        <th>
            Prefix
        </th>
        <th>
            <spring:message code="PersonName.familyName"/>
        </th>
        <th>
            <spring:message code="PersonName.familyName2"/>
        </th>
        <th>
            Suffix
        </th>
        <th>
            <spring:message code="PersonName.degree"/>
        </th>
    </tr>
    <tr>
        <spring:bind path="personNameId">
            <input type="hidden" id="personNameId" value="${status.value}"/>
        </spring:bind>
        <td align="left" valign="top">
            <spring:bind path="preferred">
                <input type="checkbox" id="personName.preferred" value="${status.value}" <c:if
                    test="${status.value == 'true'}">checked</c:if>/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="prefix">
                <input type="text" id="prefix" size="3" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="givenName">
                <input type="text" id="givenName" size="16" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="middleName">
                <input type="text" id="middleName" size="12" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td>&nbsp;</td>
        <td align="left" valign="top">
            <spring:bind path="familyNamePrefix">
                <input type="text" id="familyNamePrefix" size="3" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyName">
                <input type="text" name="familyName" id="familyName" size="16" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyName2">
                <input type="text" id="familyName2" size="16" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyNameSuffix">
                <input type="text" id="familyNameSuffix" size="3" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="degree">
                <input type="text" id="degree" size="4" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
</table>
