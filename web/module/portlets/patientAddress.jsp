<tbody id="addressContent${varStatus.index}">
    <tr>
        <td>
            <spring:message code="PersonAddress.address1"/>
        </td>
        <td>
            <spring:bind path="address1">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="PersonAddress.address2"/>
        </td>
        <td>
            <spring:bind path="address2">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="amrsregistration.address.neighborhoodCell" />
        </td>
        <td>
            <spring:bind path="neighborhoodCell">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <td>
            <spring:message code="PersonAddress.cityVillage"/>
        </td>
        <td>
            <spring:bind path="cityVillage">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="Location.township"/>/<spring:message code="Location.division"/>
        </td>
        <td>
            <spring:bind path="townshipDivision">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="Location.county"/>/<spring:message code="Location.district"/>
        </td>
        <td>
            <spring:bind path="countyDistrict">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <td>
            <spring:message code="amrsregistration.label.address.subregion" />
        </td>
        <td>
            <spring:bind path="subregion">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="Location.region"/>
        </td>
        <td>
            <spring:bind path="region">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <td>
            <spring:message code="PersonAddress.stateProvince"/>
        </td>
        <td>
            <spring:bind path="stateProvince">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="PersonAddress.country"/>
        </td>
        <td>
            <spring:bind path="country">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td align="right">
            <spring:message code="PersonAddress.postalCode"/>
        </td>
        <td>
            <spring:bind path="postalCode">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
    	<td>&nbsp;</td>
    </tr>
</tbody>