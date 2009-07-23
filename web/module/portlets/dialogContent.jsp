<script type="text/javascript">

function renderPatientData(patient) {
	var gender = '<img src="${pageContext.request.contextPath}/images/male.gif" alt="<spring:message code='Person.gender.male'/>" id="maleGenderIcon"/>';
	if (patient.gender == 'F')
		gender = '<img src="${pageContext.request.contextPath}/images/female.gif" alt="<spring:message code='Person.gender.female'/>" id="femaleGenderIcon"/>';

	var age = "";
	if (patient.age > 0)
		age = patient.age + '<spring:message code="Person.age.years"/>';
	
	if (patient.age == 0)
		age = '< 1 <spring:message code="Person.age.year"/>';
		
	age = age + '<span id="patientHeaderPatientBirthdate">';
	
	if (age.length > 0) {
		age = age + '(';
		if (patient.birthdateEstimated)
			age = age + '~'
		age = age + parseDate(patient.birthdate);
	} else {
		age = age + '<spring:message code="Person.age.unknown"/>';
	}
	
	age = age + '</span>';
	
	var identifier = "";
	var identifiers = patient.identifiers;
	for (i = 0; i < identifiers.length; i ++) {
		if (identifiers[i].identifierType.name != '${amrsIdType}') {
			identifier = identifier + identifiers[i].identifierType.name + ': ' + identifiers[i].identifier;
		}
	}
	
	var name = "";
	var names = patient.names;
	for (i = 0; i < names.length; i ++) {
		if (!names[i].voided) {
			if (names[i].preferred)
				name = name + '*';
			if (names[i].givenName.length > 0)
				name = name + names[i].givenName + ' ';
			if (names[i].middleName.length > 0)
				name = name + names[i].middleName + ' ';
			if (names[i].familyName.length > 0)
				name = name + names[i].familyName;
			name = name + '<br />';
		}
	}
	
	var address = "";
	var addresses = patient.addresses;
	for (i = 0; i < addresses.length; i ++) {
		if (!addresses[i].voided) {
			address = address + "<tr>";
			if (addresses[i].preferred)
				address = address + '<td>*';
			else
				address = address + '<td>';
			address = address +  replaceNull(addresses[i].address1) + '</td><td>' + replaceNull(addresses[i].address2) + '</td><td>' + replaceNull(addresses[i].neighborhoodCell) + '</td><td>';
	    	address = address + replaceNull(addresses[i].cityVillage) + '</td><td>' + replaceNull(addresses[i].townshipDivision) + '</td><td>' + replaceNull(addresses[i].countyDistrict) + '</td><td>';
	    	address = address + replaceNull(addresses[i].region) + '</td><td>' + replaceNull(addresses[i].subregion) + '</td><td>';
	    	address = address + replaceNull(addresses[i].stateProvince) + '</td><td>' + replaceNull(addresses[i].country) + '</td><td>' + replaceNull(addresses[i].postalCode) + '</td></tr>';
		}
	}
	
	var preferedName = patient.personName;
	var personName = "";
	if (preferedName.givenName.length > 0)
		personName = personName + preferedName.givenName + ' ';
	if (preferedName.middleName.length > 0)
		personName = personName + preferedName.middleName + ' ';
	if (preferedName.familyName.length > 0)
		personName = personName + preferedName.familyName;
	
	var content = 
	'<div id="patientHeader" class="boxHeader">' + 
		'<div id="patientHeaderPatientName" style="font-size: 12px;">' + personName + '</div>' +
		'<div id="patientHeaderPreferredIdentifier">' +
			'<span class="patientHeaderPatientIdentifier" style="font-size: 12px;">' +
					'${amrsIdType}: 12345-RG6' +
			'</span>' +
		'</div>' +
		'<table id="patientHeaderGeneralInfo">' +
			'<tr>' +
				'<td id="patientHeaderPatientGender">' + gender +
				'</td>' +
				'<td id="patientHeaderPatientAge">' + age +
				'</td>' +
				'<td style="width: 30%;">&nbsp;</td>' +
				'<td id="patientHeaderOtherIdentifiers">' + identifier +
				'</td>' +
			'</tr>' +
		'</table>' +
	'</div>' +
	'<br />' +
	'<div class="boxHeader"><spring:message code="Patient.title"/></div>' +
	'<div class="box">' +
		'<table class="personName">' +
			'<thead>' +
				'<tr>' +
					'<th><spring:message code="Person.names"/></th>' +
					<openmrs:forEachDisplayAttributeType personType="patient" displayType="viewing" var="attrType">
						<th><spring:message text="${attrType.name}"/></th>
					</openmrs:forEachDisplayAttributeType>
				'</tr>' +
			'</thead>' +
			'<tbody>' +
				'<tr>' +
					'<td valign="top">' + name +
					'</td>' +
					<openmrs:forEachDisplayAttributeType personType="patient" displayType="viewing" var="attrType">
						'<td valign="top">' + patient.attributeMap[${attrType.name}] + '</td>' +
					</openmrs:forEachDisplayAttributeType>
				'</tr>' +
			'</tbody>' +
		'</table>' +
	'</div>' +
	'<br/>' +
	'<div class="boxHeader"><spring:message code="Person.addresses"/></div>' +
	'<div class="box">' +
		'<table class="personAddress">' +
			'<tbody>' + address +
			'</tbody>' +
		'</table>' +
	'</div>';
    	
	document.getElementById("personContent").innerHTML = content;
	
	blankSpan = document.createElement("span");
	blankSpan.innerHTML = "&nbsp;";
	
	textNode = document.createTextNode("Is this the correct patient?");
    document.getElementById("personContent").appendChild(textNode);
    
    document.getElementById("personContent").appendChild(blankSpan);
	
    // create anchor tag to update the data
    var anchor = document.createElement("a");
    anchor.innerHTML="Yes";
	anchor.href="javascript:updateData('" + patient.identifiers[0].identifier + "')";
    document.getElementById("personContent").appendChild(anchor);
    
    document.getElementById("personContent").appendChild(blankSpan);
    
    var cancel = document.createElement("a");
    cancel.innerHTML="No";
	cancel.href="javascript:cancel()";
    document.getElementById("personContent").appendChild(cancel );
	
	animatePatientData();
}
</script>
