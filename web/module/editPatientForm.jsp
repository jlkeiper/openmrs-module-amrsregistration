<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRAmrsRegistrationService.js" />
<openmrs:htmlInclude file="/dwr/engine.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/common.js" />

<%@ include file="portlets/dialogContent.jsp" %>
<script type="text/javascript">

    // Number of objects stored.  Needed for 'add new' purposes.
    // starts at -1 due to the extra 'blank' data div in the *Boxes dib
    var numObjs = new Array();
    numObjs["identifier"] = ${fn:length(patient.identifiers)};
    numObjs["name"] = ${fn:length(patient.names)};
    numObjs["address"] = ${fn:length(patient.addresses)};
    	
	nonRequiredIdType = 0;
    <c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
        <c:if test="${amrsIdType != identifier.identifierType.name}">
        	nonRequiredIdType ++;
        </c:if>
    </c:forEach>
    
	searchTimeout = null;
	searchDelay = 1000;
    
    var attributes = null;
    
    $j(document).ready(function() {
		
		$j('.match').click(function(){
			var tr = $j(this).parent();
			var input = $j(tr + ':first-child');
			alert($(input).html());
			getPatientByIdentifier($(input).html());
		});
		
		$j('.match').hover(
			function() {
				var parent = $j(this).parent();
				$j(parent).addClass("searchHighlight");
			},
			function() {
				var parent = $j(this).parent();
				$j(parent).removeClass("searchHighlight");
			}
		);
    });
    
    function getPatientByIdentifier(identifier) {
    	DWRAmrsRegistrationService.getPatientByIdentifier(identifier, renderPatientData);
    }
    
    function hidDiv() {
    	$j('#floating').hide();
    }
	
	function cancel() {
		$j('#mask').hide();
		$j('.window').hide();
	}
    
    function updateData(identifier) {
    	$j(document.forms[0].reset());
    	
    	var hiddenInput = $j(document.createElement("input"));
    	$j(hiddenInput).attr("type", "hidden");
    	$j(hiddenInput).attr("name", "idCardInput");
    	$j(hiddenInput).attr("id", "idCardInput");
    	$j(hiddenInput).attr("value", identifier);
    	$j('#boxes').append($j(hiddenInput));
    	
    	$j(document.forms[0].submit());
    }
		
	function createPreferred(preferred, type, position, hidden) {
		var container = $j('#' + type + 'Content' + position);
		var element = null;
			
		var input = $j(document.createElement('input'));
		$j(input).attr('type', 'radio');
		$j(input).attr('name', type + 'Preferred');
		$j(input).attr('value', position);
		if(preferred)
			$j(input).attr('checked', 'checked');
			
		if (type == 'address') {
			// for address, element is a row
			element = $j(document.createElement('tr'));
			
			td = $j(document.createElement('td'));
			$j(td).attr('colspan', '2');
			
			$j(element).append(td);
			
			$j(td).append(input);
			
			var label = $j(document.createTextNode('Preferred'));
			$j(td).append(label);
			
			$j(container).prepend(element);
		} else {
			// for identifier and name, the element is a cell
			element = $j(document.createElement('td'));
			
			$j(element).append(input);
			
			$j(container).append(element);
		}
		
		if (hidden)
			$j(element).hide();
	}

    function addNew(type) {
        $j('#' + type + 'Error').empty();
        
    	var idSufix = numObjs[type] - 1;
    	
    	var allowCreate = false;
    	
    	if (numObjs[type] == 0) {
    		allowCreate = true;
    	} else {
    		if (nonRequiredIdType == 0 && type == 'identifier')
    			allowCreate = true;
    		else {
	    		var allInputType = $j('#' + type + 'Content' + idSufix + ' input[type=text]');
	    		
		    	for (i = 0; i < allInputType.length; i ++) {
		    		var o = allInputType[i];
		    		str = jQuery.trim(o.value);
		    		if (str.length > 0) {
		    			// allow creating new object when a non blank element is found
		    			allowCreate = true;
		    			break;
		    		}
		    	}
		    }
		}
    	
        var typeHolder = $j('#' + type + 'Content');
        if ($j(typeHolder) != null && allowCreate) {
            var cloneHolder = $j(typeHolder).clone(true);
            $j(cloneHolder).attr('id', type + 'Content' + numObjs[type]);
            $j('#' + type + 'Position').append($j(cloneHolder));
            
            if (numObjs[type] == 1) {
            	$j('#' + type + 'PreferredLabel').show();
            	$j('input:radio[name=' + type + 'Preferred]').parent().show();
            }
            createPreferred(false, type, numObjs[type]);
            
            // focus to the first element
            ele = $j('#' + type + 'Content' + numObjs[type] + ' input[type=text]:eq(0)');
            ele.focus();
            
            numObjs[type] = numObjs[type] + 1;
            if (type == 'identifier') {
            	nonRequiredIdType ++;
            }
        }
        
        if (!allowCreate){
        	$j('#' + type + 'Error').html('Adding new row not permitted when the current ' + type + ' is blank');
        }
    }
	
	function removeBlankData() {
		// remove name, id and address template
		var obj = document.getElementById("identifierContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("nameContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("addressContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		
		for (key in numObjs)
			deleteRow(key, false);
	}
	
	function deleteLastRow (type) {
		deleteRow(type, true);
	}
	
	function deleteRow(type, showMessage) {
		
		// remove blank name, id and address that is added but never get filled
		// the check only for the last element because we're not allowing adding
		// new one when the previous one still blank (see addNew)
		
		var idSufix = numObjs[type] - 1;
		message = "";
			
		if (idSufix > 0) {
			var allInputType = $j('#' + type + 'Content' + idSufix + ' input[type=text]');
	    	var deleteInputs = true;
	    	for (i = 0; i < allInputType.length; i ++) {
	    		var o = allInputType[i];
	    		str = jQuery.trim(o.value);
	    		if (str.length > 0) {
	    			// don't delete if there's a single element with a value
	    			deleteInputs = false;
	    			break;
	    		}
	    	}
	    	if (deleteInputs) {
	    		$j('#' + type + "Content" + idSufix).remove();
	    		numObjs[type] = idSufix;
	    		// remove radio button when there's only one row left
	    		// assume the last one a preferred one
	    		if (numObjs[type] == 1) {
	    			$j('#' + type + 'PreferredLabel').hide();
	    			$j('input:radio[name=' + type + 'Preferred]').parent().hide();
	    		}
	    	} else {
	    		message = "Removing " + type + " not permitted because deleted element is not empty";
	    	}
    	} else {
    		message = "Removing " + type + " not permitted because there is only one row left";
    	}
    	
    	if (message.length > 0 && showMessage)
	    	$j('#' + type + 'Error').html(message);
	}
	
	function createCell(content, row) {
		var column = $j(document.createElement('td'));
		var data = $j(document.createTextNode(content));
		$j(column).append($j(data));
		$j(row).append($j(column));
	}
    
    function handlePatientResult(result) {
		clearTimeout(searchTimeout);
		
    	if (result.length > 0) {
    		
    		var tbody = $j('#resultTable');
    		$j(tbody).empty();
    		
    		for(i = 0; i < result.length; i ++) {
    			var tr = $j(document.createElement('tr'));
    			
    			if (i % 2 == 0)
    				$j(tr).addClass("evenRow");
    			else
    				$j(tr).addClass("oddRow");
    			
    			var value = result[i].identifiers[0].identifier;
    			
    			$j(tr).hover(
    				function() {
						$j(this).addClass("searchHighlight");
    				},
    				function() {
						$j(this).removeClass("searchHighlight");
    				}
    			);
    			
    			$j(tr).click(function() {
    				getPatientByIdentifier(value);
    			});
    			
    			createCell(result[i].identifiers[0].identifier, tr);
    			createCell(result[i].personName.givenName, tr);
    			createCell(result[i].personName.familyName, tr);
    			
    			var td = $j(document.createElement('td'));
    			$j(td).css('text-align', 'center');
    			var data = $j(document.createElement('img'));
    			if (result[i].gender == 'F')
    				$j(data).attr('src', "${pageContext.request.contextPath}/images/female.gif");
    			else
    				$j(data).attr('src', "${pageContext.request.contextPath}/images/male.gif");
    			$j(td).append($j(data));
    			$j(tr).append($j(td));
    			
    			createCell(parseDate(result[i].birthdate, '<openmrs:datePattern />'), tr);
    			
    			$j(tbody).append($j(tr));
    		}
    		
    		$j('#floating').show();
    		
    	} else {
    		$j('#floating').hide();
    	}
    }
	
	// age function borrowed from http://anotherdan.com/2006/02/simple-javascript-age-function/
	function getAge(d) {
		var age = -1;
		now = new Date();
		while (now >= d) {
			age++;
			d.setFullYear(d.getFullYear() + 1);
		}
		return age;
	}
    
    function isAlphaNumericCharacter(key) {
		 return (key >= 48 && key <= 90) ||
				(key >= 96 && key <= 105);
	}
	
	function isDashCharacter(key) {
		return key == 189 || key == 109;
	}
	
	function isBackspaceDelete(key) {
		return key == 46 || key == 8;
	}
	
	function timeOutSearch(e) {
		c = e.keyCode;
		
		if (isAlphaNumericCharacter(c) || isDashCharacter(c) || isBackspaceDelete(c)) {
			clearTimeout(searchTimeout);
			searchTimeout = setTimeout("patientSearch()", searchDelay);
		}
	}

    function patientSearch() {
    	
        var gName = document.getElementById("names[0].givenName");
        var mName = document.getElementById("names[0].middleName");
        var fName = document.getElementById("names[0].familyName");
        var deg = document.getElementById("names[0].degree");

        var personName = {
        	givenName: gName.value,
        	middleName: mName.value,
        	familyName: fName.value,
        	degree: deg.value
        }
        // alert(DWRUtil.toDescriptiveString(personName, 2));
        
        var add1 = document.getElementById("addresses[0].address1");
        var add2 = document.getElementById("addresses[0].address2");
        var cell = document.getElementById("addresses[0].neighborhoodCell");
        var city = document.getElementById("addresses[0].cityVillage");
        var township = document.getElementById("addresses[0].townshipDivision");
        var county = document.getElementById("addresses[0].countyDistrict");
        var state = document.getElementById("addresses[0].stateProvince");
        var reg = document.getElementById("addresses[0].region");
        var subreg = document.getElementById("addresses[0].subregion");
        var cntry = document.getElementById("addresses[0].country");
        var postCode = document.getElementById("addresses[0].postalCode");
        
        var personAddress = {
        	address1: add1.value,
        	address2: add2.value,
        	cityVillage: city.value,
        	neighborhoodCell: cell.value,
        	countyDistrict: county.value,
        	townshipDivision: township.value,
        	region: reg.value,
        	subregion: subreg.value,
        	stateProvince: state.value,
        	country: cntry.value,
        	postalCode: postCode.value
        }
        // alert(DWRUtil.toDescriptiveString(personAddress, 2));
        
        var id = document.getElementById("identifiers[0].identifier");
        var idType = document.getElementById("identifiers[0].identifierType");
        
        var patientIdentifier = {
        	identifier: id.value,
        	identifierType: idType.value
        }
        
        if (attributes == null) {
        	prepareAttributes();
        }
        
        for(i=0; i<attributes.length; i++) {
            if (attributes[i].value == null || attributes[i].value == "") {
                continue;
            }
        	else {
                attributes[i].value = DWRUtil.getValue(attributes[i].attributeType.personAttributeTypeId).toString();
            }
        }
        // alert("Attributes: " + DWRUtil.toDescriptiveString(attributes, 2));
        
        var birthStr = $j('input:text[name=birthdate]').attr('value');
        var birthdate = null;
        if (birthStr && birthStr.length > 0)
        	birthdate = new Date(Date.parse(birthStr));
        	
        var gender = $j('input:radio[name=gender]:checked').attr('value');
        if (!gender)
        	gender = null;
        	
        var age = $j('input:text[name=age]').attr('value');
        if (!age && birthStr) {
			var age = getAge(birthStr);
        	if (!age)
        		age = null;
        } else
        	age = null;
        
        DWRAmrsRegistrationService.getPatients(personName, personAddress, attributes, gender, birthdate, age, handlePatientResult);
    }
    
    function prepareAttributes() {
    	attributes = new Array();
        
        <openmrs:forEachDisplayAttributeType personType="" displayType="all" var="attrType">
        	type = new Object();
        	type.personAttributeTypeId = "${attrType.personAttributeTypeId}";
        	type.name = "${attrType.name}";
        	type.format = "${attrType.format}";
        	
        	attr = new Object();
        	attr.attributeType = type;
        	attributes[${varStatus.index}] = attr;
		</openmrs:forEachDisplayAttributeType>
    }
    
	function preferredBoxClick(obj) {
		var inputs = $j('input:checkbox');
		if (obj.checked == true) {
			for (var i=0; i<inputs.length; i++) {
				var input = inputs[i];
				if (input.type == "checkbox")
					if (input.alt == obj.alt && input != obj)
						input.checked = false;
			}
		}
	}
</script>

<style>
	.header {
		border-top:1px solid lightgray;
		vertical-align: top;
		text-align: left;
	}
	
	.input{
		border-top:1px solid lightgray;
	}
	
	.footer {
		border-bottom:1px solid lightgray;
	}
	
	.spacing {
		padding-right: 2em;
	}
	
	#centeredContent {
	}
</style>

<div>
	<h2><spring:message code="amrsregistration.edit.start"/></h2>
</div>

<div id="mask"></div>
<div id="amrsContent">
	<span>Fill in the patient information and press continue to proceed</span>
	<form id="patientForm" method="post" onSubmit="removeBlankData()">
	<div id="boxes"> 
		<div id="dialog" class="window">
			<div id="personContent"></div>
		</div>
	</div>
	
	<c:choose>
		<c:when test="${fn:length(potentialMatches) > 0}">
			<div id="floating" style="display: block;">
		</c:when>
		<c:otherwise>
			<div id="floating" style="display: none;">
		</c:otherwise>
	</c:choose>
    <table class="box">
        <tr>
        	<td><spring:message code="amrsregistration.labels.ID" /></td>
        	<td><spring:message code="amrsregistration.labels.givenNameLabel" /></td>
        	<td><spring:message code="amrsregistration.labels.familyNameLabel" /></td>
        	<td><spring:message code="amrsregistration.labels.gender" /></td>
        	<td><spring:message code="amrsregistration.labels.birthdate" /></td>
        </tr>
        <tbody id="resultTable">
    		<c:forEach items="${potentialMatches}" var="person" varStatus="varStatus">
    			<c:choose>
    				<c:when test="${varStatus.index % 2 == 0}">
    					<tr class="evenRow">
    				</c:when>
    				<c:otherwise>
    					<tr class="oddRow">
    				</c:otherwise>
    			</c:choose>
    				<c:forEach items="${person.identifiers}" var="identifier" varStatus="varStatus">
    					<c:if test="${varStatus.index == 0}">
		    				<td class="match">
		    					<c:out value="${identifier.identifier}" />
		    				</td>
        				</c:if>
    				</c:forEach>
    				<td class="match">
    					<c:out value="${person.personName.givenName}" />
    				</td>
    				<td class="match">
    					<c:out value="${person.personName.familyName}" />
    				</td>
    				<td class="match">
    					<c:out value="${person.gender}" />
    				</td>
    				<td class="match">
    					<openmrs:formatDate date="${person.birthdate}" />
    				</td>
    			</tr>
    		</c:forEach>
        </tbody>
        <tr>
        	<td>
        		<span class="close"><a href="javascript:;" onclick="hidDiv()">close</a></span>
        	</td>
        </tr>
    </table>
	</div>

	<spring:hasBindErrors name="patient">
		<c:forEach items="${errors.allErrors}" var="error">
			<br />
			<span class="error"><spring:message code="${error.code}"/></span>
		</c:forEach>
	</spring:hasBindErrors>
	
	<table id="centeredContent">
		<tr>
			<th class="header">Names</th>
			<td class="input">

<!-- Patient Names Section -->
		<table>
			<tr>
				<td>
				    <spring:message code="PersonName.givenName"/>
				</td>
				<td>
				    <spring:message code="PersonName.middleName"/>
				</td>
				<td>
				    <spring:message code="PersonName.familyName"/>
				</td>
				<td>
				    <spring:message code="PersonName.degree"/>
				</td>
				<td>
				    <span id="namePreferredLabel" style="display: none"><spring:message code="general.preferred"/></span>
				</td>
			</tr>
	        <c:forEach var="name" items="${patient.names}" varStatus="varStatus">
	            <spring:nestedPath path="patient.names[${varStatus.index}]">
	            	<%@ include file="portlets/patientName.jsp" %>
	            </spring:nestedPath>
				<script type="text/javascript">
					var hidden = true;
					<c:if test="${fn:length(patient.names) > 1}">
						hidden = false;
					</c:if>
					var preferred = false;
					<c:if test="${name.preferred}">
						preferred = true;
					</c:if>
					createPreferred(preferred, 'name', ${varStatus.index}, hidden);
	            </script>
	        </c:forEach>
	    	<tbody id="namePosition">
		</table>
		<spring:nestedPath path="emptyName">
			<table style="display: none;">
				<%@ include file="portlets/patientName.jsp" %>
			</table>
		</spring:nestedPath>
		<div class="tabBar" id="nameTabBar">
			<span id="nameError" class="newError"></span>
			<input type="button" onClick="return deleteLastRow('name');" class="addNew" id="name" value="Remove"/>
			<input type="button" onClick="return addNew('name');" class="addNew" id="name" value="Add New Name"/>
		</div>
<!-- End of Patient Names Section -->
	
			</td>
		</tr>
		<tr>
			<th class="header">Demographics</th>
			<td class="input">
    
<!-- Gender and Birthdate Section -->
    	<table>
    		<tr>
				<td><spring:message code="Person.gender"/></td>
				<td>
					<spring:message code="Person.birthdate"/>
					<i style="font-weight: normal; font-size: .8em;">(<spring:message code="general.format"/>: <openmrs:datePattern />)</i>
				</td>
    		</tr>
			<spring:nestedPath path="patient">
				<tr>
				<c:if test="${empty INCLUDE_PERSON_GENDER || (INCLUDE_PERSON_GENDER == 'true')}">
						<td style="padding-right: 3.6em;">
							<spring:bind path="patient.gender">
								<openmrs:forEachRecord name="gender">
									<input type="radio" name="gender" id="${record.key}" value="${record.key}" <c:if test="${record.key == status.value}">checked</c:if> onclick="timeOutSearch(event)" />
										<label for="${record.key}"> <spring:message code="Person.gender.${record.value}"/> </label>
								</openmrs:forEachRecord>
							</spring:bind>
						</td>
				</c:if>
				<c:choose>
					<c:when test="${patient.birthdate == null}">
							<td style="padding-right: 4em;">
								<input type="text" name="birthdate" id="birthdate" size="11" value="" readonly="readonly" onclick="showCalendar(this)" onkeyup="timeOutSearch(event)"/>
								<spring:message code="Person.age.or"/>
								<input type="text" name="age" id="age" size="5" value="" onkeyup="timeOutSearch(event)" />
							</td>
					</c:when>
					<c:otherwise>
							<td style="padding-right: 4em;">
								<script type="text/javascript">
									function updateEstimated(txtbox) {
										var input = document.getElementById("birthdateEstimatedInput");
										if (input) {
											input.checked = false;
											input.parentNode.className = "";
										}
										else if (txtbox)
											txtbox.parentNode.className = "listItemChecked";
									}
									
									function updateAge() {
										var birthdateBox = document.getElementById('birthdate');
										var ageBox = document.getElementById('age');
										try {
											var birthdate = parseSimpleDate(birthdateBox.value, '<openmrs:datePattern />');
											var age = getAge(birthdate);
											if (age > 0)
												ageBox.innerHTML = "(" + age + ' <spring:message code="Person.age.years"/>)';
											else if (age == 1)
												ageBox.innerHTML = '(1 <spring:message code="Person.age.year"/>)';
											else if (age == 0)
												ageBox.innerHTML = '( < 1 <spring:message code="Person.age.year"/>)';
											else
												ageBox.innerHTML = '( ? )';
											ageBox.style.display = "";
										} catch (err) {
											ageBox.innerHTML = "";
											ageBox.style.display = "none";
										}
									}
								</script>
								<spring:bind path="birthdate">			
									<input type="text" 
											name="birthdate" size="10" id="birthdate"
											value="${status.value}"
											readonly="readonly"
											onchange="updateAge(); updateEstimated(this);"
											onclick="showCalendar(this)" onkeyup="timeOutSearch(event)" />
									<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if> 
								</spring:bind>
								
								<span id="age"></span> &nbsp; 
								
								<span id="birthdateEstimatedCheckbox" class="listItemChecked" style="padding: 5px;">
									<spring:bind path="birthdateEstimated">
										<label for="birthdateEstimatedInput"><spring:message code="Person.birthdateEstimated"/></label>
										<input type="hidden" name="_birthdateEstimated">
										<input type="checkbox" name="birthdateEstimated" value="true" 
											   <c:if test="${status.value == true}">checked</c:if> 
											   id="birthdateEstimatedInput" 
											   onclick="if (!this.checked) updateEstimated()" />
										<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
									</spring:bind>
								</span>
								
								<script type="text/javascript">
									if (document.getElementById("birthdateEstimatedInput").checked == false)
										updateEstimated();
									updateAge();
								</script>
							</td>
					</c:otherwise>
				</c:choose>
				</tr>
			</spring:nestedPath>
		</table>
<!-- End of Gender and Birthdate Section -->
	
			</td>
		</tr>
		<tr>
			<th class="header">Identifiers</th>
			<td class="input">

<!-- Patient Identifier Section -->
		<table>
			<tr>
			    <td>
			        <spring:message code="amrsregistration.labels.ID"/>
			    </td>
			    <td>
			        <spring:message code="PatientIdentifier.identifierType"/>
			    </td>
				<td>
					<spring:message code="PatientIdentifier.location"/>
				</td>
				<td>
				    <span id="identifierPreferredLabel" style="display: none"><spring:message code="general.preferred"/></span>
				</td>
			</tr>
	        <c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
	            <spring:nestedPath path="patient.identifiers[${varStatus.index}]">
	            	<c:if test="${amrsIdType != identifier.identifierType.name}">
	            		<%@ include file="portlets/patientIdentifier.jsp" %>
	            	</c:if>
	    			<tbody id="identifierPosition">
	            </spring:nestedPath>
	        </c:forEach>
      	</table>
        <spring:nestedPath path="emptyIdentifier">
			<table style="display: none;">
            	<%@ include file="portlets/patientIdentifier.jsp" %>
            </table>
        </spring:nestedPath>
        <div class="tabBar" id="identifierTabBar">
			<span id="identifierError" class="newError"></span>
            <input type="button" onClick="return deleteLastRow('identifier');" class="addNew" id="identifier" value="Remove"/>
            <input type="button" onClick="return addNew('identifier');" class="addNew" id="identifier" value="Add New Identifier"/>
        </div>
<!-- End of Patient Identifier Section -->
	
			</td>
		</tr>
		<tr>
			<th class="header">Addresses</th>
			<td class="input">

<!-- Patient Address Section -->
		<table id="addressPosition">
	        <c:forEach var="address" items="${patient.addresses}" varStatus="varStatus">
	            <spring:nestedPath path="patient.addresses[${varStatus.index}]">
	                <%@ include file="portlets/patientAddress.jsp" %>
	            </spring:nestedPath>
	        </c:forEach>
		</table>
		<spring:nestedPath path="emptyAddress">
			<table style="display: none;">
	        	<%@ include file="portlets/patientAddress.jsp" %>
			</table>
		</spring:nestedPath>
	    <div class="tabBar" id="addressTabBar">
			<span id="addressError" class="newError"></span>
	        <input type="button" onClick="return deleteLastRow('address');" class="addNew" id="address" value="Remove"/>
	        <input type="button" onClick="return addNew('address');" class="addNew" id="address" value="Add New Address"/>
	    </div>
<!-- End of Patient Address Section -->
	
			</td>
		</tr>
		<tr>
			<th class="header footer">Attributes</th>
			<td class="input footer">
    
<!-- Patient Attributes Section -->
    	<table>
			<spring:nestedPath path="patient">
				<openmrs:forEachDisplayAttributeType personType="" displayType="all" var="attrType">
					<tr>
						<td><spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/></td>
						<td>
							<spring:bind path="attributeMap">
								<openmrs:fieldGen 
									type="${attrType.format}" 
									formFieldName="${attrType.personAttributeTypeId}" 
									val="${status.value[attrType.name].hydratedObject}" 
									parameters="optionHeader=[blank]|showAnswers=${attrType.foreignKey}" />
							</spring:bind>
						</td>
					</tr>
				</openmrs:forEachDisplayAttributeType>
			</spring:nestedPath>
		</table>
<!-- End of Patient Attributes Section -->
	
			</td>
		</tr>
	</table>
	<input type="hidden" name="_page1" value="true" />
	&nbsp;
	<input type="submit" name="_target2" value="<spring:message code='amrsregistration.button.continue'/>">
	&nbsp; &nbsp;
	<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
	<br/>
	<br/>
	</form>
</div>

<%@ include file="/WEB-INF/template/footer.jsp" %>
