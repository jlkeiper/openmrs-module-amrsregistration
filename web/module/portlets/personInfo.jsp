<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/registration.form" />

<b class="boxHeader">Patient Data</b>
<div class="box">
	<table>
		<tr>
			<th>Name:</th>
	    	<c:forEach items="${patient.names}" var="name" varStatus="varStatus">
					<td>&nbsp</td>
	    			<td colspan="2">
	    				<!-- One object of name goes here -->
	    				${name.prefix}&nbsp;
	    				${name.givenName}&nbsp;
	    				${name.middleName}&nbsp;
	    				${name.familyNamePrefix}&nbsp;
	    				${name.familyName}&nbsp;
	    				${name.familyName2}&nbsp;
	    				${name.familyNameSuffix}&nbsp;
	    				${name.degree}
	    			</td>
	    		</tr>
	    		<tr>
	    			<th>&nbsp</th>
	    	</c:forEach>
			<td>&nbsp</td>
			<td>&nbsp</td>
			<td>&nbsp</td>
		</tr>
		<tr>
			<th>Birthdate</th>
			<td>&nbsp</td>
			<td colspan="2">
				<openmrs:formatDate date="${patient.birthdate}" />
                <c:if test="${patient.birthdateEstimated}"> [Estimated] </c:if>
            </td>
		</tr>
		<tr>
			<th>Gender</th>
			<td>&nbsp</td>
			<td colspan="2">${patient.gender}</td>
		</tr>
		<tr>
			<th>Address</th>
	    	<c:forEach items="${patient.addresses}" var="address" varStatus="varStatus">
					<td>&nbsp</td>
					<td colspan="2">
	    				<!-- One object of address goes here -->
	    				${address.address1}&nbsp;
	    				${address.address2}&nbsp;
	    				${address.neighborhoodCell}&nbsp;
	    				<br />
	    				${address.cityVillage} &nbsp;
	    				${address.townshipDivision} &nbsp;
	    				${address.countyDistrict} &nbsp;
	    				<br />
	    				${address.region}&nbsp;
	    				${address.subregion}&nbsp;
	    				<br />
	    				${address.stateProvince}&nbsp;
	    				${address.country}&nbsp;
	    				${address.postalCode}&nbsp;
	    			</td>
	    		</tr>
	    		<tr>
	    			<th>&nbsp</th>
	    	</c:forEach>
			<td>&nbsp</td>
			<td>&nbsp</td>
			<td>&nbsp</td>
		</tr>
		<openmrs:forEachDisplayAttributeType personType="" displayType="all" var="attrType">
			<tr>
				<th>
					<spring:message text="${attrType.name}"/>
				</th>
				<td>&nbsp</td>
				<td colspan="2">
					<spring:message text="${patient.attributeMap[attrType.name].hydratedObject}" />
				</td>
			</tr>
	    </openmrs:forEachDisplayAttributeType>
	</table>
</div>