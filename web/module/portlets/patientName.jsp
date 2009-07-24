    <tr id="nameContent${varStatus.index}">
        <spring:bind path="personNameId">
            <input type="hidden" id="${status.expression}" name="${status.expression}" value="${status.value}" />
        </spring:bind>
        <td align="left" valign="top">
            <spring:bind path="preferred">
				<input type="hidden" name="_${status.expression}">
                <input type="checkbox" id="${status.expression}" name="${status.expression}" value="true" alt="patientName" onclick="preferredBoxClick(this)" <c:if test="${status.value == 'true'}">checked</c:if> />
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
                       onkeyup="timeOutSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="familyName">
                <input type="text" id="${status.expression}" name="${status.expression}" size="16" value="${status.value}"
                       onkeyup="timeOutSearch(this.value)"/>
            </spring:bind>
        </td>
        <td align="left" valign="top">
            <spring:bind path="degree">
                <input type="text" id="${status.expression}" name="${status.expression}" size="4" value="${status.value}" onkeyup="timeOutSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
