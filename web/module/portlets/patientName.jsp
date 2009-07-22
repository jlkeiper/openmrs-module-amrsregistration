<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/registration.form" />

<b class="boxHeader"><spring:message code="amrsregistration.edit.name"/> </b>
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
    <tbody id="nameContent">
    <tr>
        <spring:bind path="personNameId">
            <input type="hidden" id="${status.expression}" name="${status.expression}" value="${status.value}"/>
        </spring:bind>
        <td align="left" valign="top">
            <spring:bind path="preferred">
				<input type="hidden" name="_${status.expression}">
                <input type="checkbox" id="${status.expression}" name="${status.expression}" value="true" alt="patientName" onclick="if (preferredBoxClick) preferredBoxClick(this)" <c:if test="${status.value == 'true'}">checked</c:if>/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="prefix">
                <input type="text" id="${status.expression}" name="${status.expression}" size="3" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="givenName">
                <input type="text" id="${status.expression}" name="${status.expression}" size="16" value="${status.value}"
                       onkeyup="timeOutSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="middleName">
                <input type="text" id="${status.expression}" name="${status.expression}" size="12" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td>&nbsp;</td>
        <td align="left" valign="top">
            <spring:bind path="familyNamePrefix">
                <input type="text" id="${status.expression}" name="${status.expression}" size="3" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyName">
                <input type="text" id="${status.expression}" name="${status.expression}" size="16" value="${status.value}"
                       onkeyup="timeOutSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyName2">
                <input type="text" id="${status.expression}" name="${status.expression}" size="16" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyNameSuffix">
                <input type="text" id="${status.expression}" name="${status.expression}" size="3" value="${status.value}"
                       onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="degree">
                <input type="text" id="${status.expression}" name="${status.expression}" size="4" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
    </tbody>
</table>
