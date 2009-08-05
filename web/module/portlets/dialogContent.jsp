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
		age = age + parseDate(patient.birthdate, '<openmrs:datePattern />');
		age = age + ')';
	} else {
		age = age + '<spring:message code="Person.age.unknown"/>';
		age = age + ')';
	}
	
	age = age + '</span>';
	
	var amrsIdentifier = '-';
	var identifier = '';
	var identifiers = patient.identifiers;
	for (i = 0; i < identifiers.length; i ++) {
		// alert(identifiers[i].identifierType.name + ": " + identifiers[i].identifier + ", voided: " + identifiers[i].voided);
		if (identifiers[i].identifierType.name != '${amrsIdType}') {
			if (identifier != '') {
				identifier = identifier + '<br />';
			}
			identifier = identifier + identifiers[i].identifierType.name + ': ' + identifiers[i].identifier;
		} else {
			if (!identifiers[i].voided)
				amrsIdentifier = identifiers[i].identifier;
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
	'<div id="summaryHeading" style="width: 100%; padding: 2px; margin: 2px;">' + 
		'<div id="headingName" style="font-size: 1.5em">' + personName + '</div>' +
		'<div id="headingPreferredIdentifier" style="font-size: 1em">' +
			'<span>' + amrsIdentifier + '</span>' +
		'</div>' +
		'<table width="100%">' +
			'<tr>' +
				'<td class="headingElement" style="padding: 0px;">' + gender +
				'</td>' +
				'<td class="headingElement">' + age +
				'</td>' +
				'<td style="width: 40%;">&nbsp;</td>' +
				'<td class="headingElement">' + identifier +
				'</td>' +
			'</tr>' +
		'</table>' +
	'</div>' +
	'<div class="summaryInfo" style="width: 100%; padding: 2px; margin: 2px;">' +
		'<div class="infoHeading">Name(s)</div>' +
		'<table>' +
			'<tr>' +
				'<td valign="top">' + name + '</td>' +
			'</tr>' +
		'</table>' +
	'</div>' +
	'<div class="summaryInfo" style="width: 100%; padding: 2px; margin: 2px;">' +
		'<div class="infoHeading">Address(es)</div>' +
		'<table>' + address + '</table>' +
	'</div>';
    	
	document.getElementById("personContent").innerHTML = content;
	
	blankSpan = document.createElement("span");
	blankSpan.innerHTML = "&nbsp;";
	
	textNode = document.createTextNode("Is this the correct patient?");
    document.getElementById("personContent").appendChild(textNode);
    
    document.getElementById("personContent").appendChild(blankSpan);
    document.getElementById("personContent").appendChild(blankSpan);
	
    // create button tag to update the data
    var yesButton = document.createElement("input");
    yesButton.type = "button";
    yesButton.value="Yes";
	$j(yesButton).bind('click', function() {
		updateData(patient.patientId);
	});
    document.getElementById("personContent").appendChild(yesButton);
    
    document.getElementById("personContent").appendChild(blankSpan);
    document.getElementById("personContent").appendChild(blankSpan);
    
    var noButton = document.createElement("input");
    noButton.type = "button";
    noButton.value="No";
	$j(noButton).bind('click', function() {
		cancel();
	});
    document.getElementById("personContent").appendChild(noButton);
    
	yesButton.focus();
	
	animatePatientData();
}
</script>
