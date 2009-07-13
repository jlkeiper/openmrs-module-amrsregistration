<table class="box" border="0" cellspacing="2" cellpadding="2">
    <b class="boxHeader"><spring:message code="amrsregistration.edit.address"/></b>
    <tr>
        <th>
            Preferred
        </th>
        <td align="left" valign="top">
            <spring:bind path="personAddressId">
                <input type="hidden" id="personAddressId" value="${status.value}"/>
            </spring:bind>
            <spring:bind path="preferred">
                <input type="checkbox"
                	id="personAddress.preferred_${varStatus.index}"
                	name="personAddress.preferred_${varStatus.index}"
                    value="${status.value}"
                    <c:if test="${status.value == 'true'}">checked</c:if>/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <th>
            <spring:message code="PersonAddress.address1"/>
        </th>
        <td>
            <spring:bind path="address1">
                <input type="text" id="address1_${varStatus.index}" name="address1_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="PersonAddress.address2"/>
        </th>
        <td>
            <spring:bind path="address2">
                <input type="text" id="address2_${varStatus.index}" name="address2_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            Neighborhood Cell <!-- spring:message code="PersonAddress.neighborhoodCell"/ -->
        </th>
        <td>
            <spring:bind path="neighborhoodCell">
                <input type="text" id="neighborhoodCell_${varStatus.index}" name="neighborhoodCell_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <th>
            <spring:message code="PersonAddress.cityVillage"/>
        </th>
        <td>
            <spring:bind path="cityVillage">
                <input type="text" id="cityVillage_${varStatus.index}" name="cityVillage_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="Location.township"/>/<spring:message code="Location.division"/>
        </th>
        <td>
            <spring:bind path="townshipDivision">
                <input type="text" id="townshipDivision_${varStatus.index}" name="townshipDivision_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="Location.county"/>/<spring:message code="Location.district"/>
        </th>
        <td>
            <spring:bind path="countyDistrict">
                <input type="text" id="countyDistrict_${varStatus.index}" name="countyDistrict_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <th>
            Sub-Region<!-- spring:message code="PersonAddress.subregion"/ -->
        </th>
        <td>
            <spring:bind path="subregion">
                <input type="text" id="subregion_${varStatus.index}" name="subregion_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="Location.region"/>
        </th>
        <td>
            <spring:bind path="region">
                <input type="text" id="region_${varStatus.index}" name="region_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
    <tr>
        <th>
            <spring:message code="PersonAddress.stateProvince"/>
        </th>
        <td>
            <spring:bind path="stateProvince">
                <input type="text" id="stateProvince_${varStatus.index}" name="stateProvince_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="PersonAddress.country"/>
        </th>
        <td>
            <spring:bind path="country">
                <input type="text" id="country_${varStatus.index}" name="country_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
        <th align="right">
            <spring:message code="PersonAddress.postalCode"/>
        </th>
        <td>
            <spring:bind path="postalCode">
                <input type="text" id="postalCode_${varStatus.index}" name="postalCode_${varStatus.index}" value="${status.value}" onkeyup="patientSearch(this.value)"/>
            </spring:bind>
        </td>
    </tr>
</table>
