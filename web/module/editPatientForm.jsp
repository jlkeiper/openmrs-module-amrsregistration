<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRAmrsRegistrationService.js" />
<openmrs:htmlInclude file="/dwr/engine.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />
<openmrs:htmlInclude file="/moduleResources/amrsregistration/scripts/common.js" />

<%@ include file="portlets/dialogContent.jsp" %>
<script type="text/javascript">

    // Number of objects stored.  Needed for 'add new' purposes.
    // starts at -1 due to the extra 'blank' data div in the *Boxes dib
    var numObjs = new Array();
    numObjs["identifier"] = ${fn:length(patient.identifiers)};
    numObjs["name"] = ${fn:length(patient.names)};
    numObjs["address"] = ${fn:length(patient.addresses)};
    
    var baseObjs = new Array();
    baseObjs["identifier"] = ${fn:length(patient.identifiers)};
    baseObjs["name"] = ${fn:length(patient.names)};
    baseObjs["address"] = ${fn:length(patient.addresses)};
    	
	requiredIdType = 0;
    <c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
        <c:if test="${amrsIdType == identifier.identifierType.name}">
        	requiredIdType ++;
        </c:if>
    </c:forEach>
    
	searchTimeout = null;
	searchDelay = 1000;
    
    var attributes = null;
    
    $j(document).ready(function() {
		
		$j('.match').click(function(){
			var tr = $j(this).parent();
			var children = $j(tr).children(':input');
			var id = $j(children).attr('value');
			getPatientByIdentifier(jQuery.trim(id));
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
		
		$j('a[name=extendedToggle]').click(function(e) {
			e.preventDefault();
			$j('.resultTableExtended').toggle();
			if ($j('.resultTableExtended').is(':hidden')) {
				$j(this).html('more >>');
			} else {
				$j(this).html('<< less');
			}
		});
		
		$j('th').css('font', '1em verdana');
		
		<c:if test="${fn:length(potentialMatches) > 0}">$j('#resultTableHeader').show();</c:if>
		
    });
    
    function getPatientByIdentifier(identifier) {
    	DWRAmrsRegistrationService.getPatientByIdentifier(identifier, renderPatientData);
    }
	
	function cancel() {
		$j('#mask').hide();
		$j('.window').hide();
	}
    
    function updateData(identifier) {
    	$j(document.forms[0].reset());
    	
    	var hiddenInput = $j(document.createElement("input"));
    	$j(hiddenInput).attr("type", "hidden");
    	$j(hiddenInput).attr("name", "patientIdInput");
    	$j(hiddenInput).attr("id", "patientIdInput");
    	$j(hiddenInput).attr("value", identifier);
    	$j('#boxes').append($j(hiddenInput));
    	
    	$j(document.forms[0].submit());
    }
		
	function createPreferred(preferred, type, id, container, hidden) {
		// this will be <tr> for id and name
		// and <table> for address
		var element = null;
			
		var input = $j(document.createElement('input'));
		$j(input).attr('type', 'radio');
		$j(input).attr('name', type + 'Preferred');
		$j(input).attr('value', id);
		if(preferred) {
			$j(input).attr('checked', 'checked');
		}
			
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
	
	function getTemplateType(type) {
		if (type == 'name')
			return $j('#nameContent').find('tr');
		if (type == 'address')
			return $j('#addressContent').find('table');
		if (type == 'identifier')
			return $j('#identifierContent');
	}
	
	function duplicateElement(type, id) {
		var templateClone = getTemplateType(type).clone(true);
		createPreferred(false, type, id, templateClone, false);
		
		// custom mods for address
		if (type == 'address') {
			var td = $j(document.createElement('td'));
			td.append(templateClone);
			var tr = $j(document.createElement('tr'));
			tr.append(td);
			return tr;
		}
		
		return templateClone;
	}
	
	function createElement(type, id) {
		var element = duplicateElement(type, id);
		$j(element).attr('id', type + 'Content' + id);
		return element;
	}

    function addNew(type) {
        $j('#' + type + 'Error').empty();
        
    	var prevIdSuffix = numObjs[type] - 1;
    	if (type == 'identifier')
    		prevIdSuffix = prevIdSuffix - requiredIdType;
    		
    	var allowCreate = false;
    	
    	// alert('id: ' + prevIdSuffix);
    	// alert('numObjs['+type+']: ' + numObjs[type]);

    	if (prevIdSuffix < 0) {
    		allowCreate = true;
    	} else {
    		var allInputType = $j('#' + type + 'Content' + prevIdSuffix + ' input[type=text]');
    		
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
    	
        if (allowCreate) {
            var newElement = createElement(type, (prevIdSuffix + 1));
            
            $j('#' + type + 'Position').append(newElement);
            
            if (prevIdSuffix == 0) {
            	// alert('show flag');
            	$j('#' + type + 'PreferredLabel').show();
            	var parent = $j('input:radio[name=' + type + 'Preferred]').parent();
            	if (type != 'address')
            		parent.show();
            	else
            		parent.parent().show();
            }
            // focus to the first element
            ele = $j('#' + type + 'Content' + numObjs[type] + ' input[type=text]:eq(0)');
            ele.focus();
            
            numObjs[type] = numObjs[type] + 1;
        }
        
        if (!allowCreate){
        	$j('#' + type + 'Error').html('Adding new row not permitted when the current ' + type + ' is blank');
        }
    }
	
	function removeTemplate() {
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
		
		var prevIdSuffix = numObjs[type] - 1;
		if (type == 'identifier')
			prevIdSuffix = prevIdSuffix - requiredIdType;
		message = "";
    		
		if (prevIdSuffix > 0) {
			var allInputType = $j('#' + type + 'Content' + prevIdSuffix + ' input[type=text]');
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
    			// alert('id: ' + prevIdSuffix);
    			// alert('type: ' + requiredIdType);
	    		var success = $j('#' + type + "Content" + prevIdSuffix).remove();
	    		numObjs[type] = numObjs[type] - 1;
	    		prevIdSuffix = prevIdSuffix - 1;
	    		// remove radio button when there's only one row left
	    		// assume the last one a preferred one
	    		if (prevIdSuffix == 0) {
	    			$j('#' + type + 'PreferredLabel').hide();
	            	parent = $j('input:radio[name=' + type + 'Preferred]').parent();
	            	if (type != 'address')
	            		$j(parent).hide();
	            	else
	            		$j(parent).parent().hide();
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
    		
		var tbody = $j('#resultTable');
		$j(tbody).empty();
    		
		if (result.length > 3)
			$j('#extendedToggle').show();
		else
			$j('#extendedToggle').hide();
		
    	if (result.length > 0) {
    		
    		for(i = 0; i < result.length; i ++) {
    			var tr = $j(document.createElement('tr'));
    			
    			if (i % 2 == 0)
    				$j(tr).addClass("evenRow");
    			else
    				$j(tr).addClass("oddRow");
    				
    			if (i > 3) {
    				$j(tr).addClass('resultTableExtended');
    			}
    			
    			$j(tr).hover(
    				function() {
						$j(this).addClass("searchHighlight");
    				},
    				function() {
						$j(this).removeClass("searchHighlight");
    				}
    			);
    			
    			$j(tr).click(function() {
					var children = $j(this).children(':input');
					var id = $j(children).attr('value');
					getPatientByIdentifier(jQuery.trim(id));
    			});
    			
    			createCell(result[i].identifiers[0].identifier, tr);
    			createCell(result[i].personName.givenName, tr);
    			createCell(result[i].personName.middleName, tr);
    			createCell(result[i].personName.familyName, tr);
    			createCell(result[i].age, tr);
    			
    			var td = $j(document.createElement('td'));
    			
    			var input = $j(document.createElement('input'));
    			$j(input).attr('type', 'hidden');
    			$j(input).attr('name', 'hiddenId' + i);
    			$j(input).attr('value', result[i].patientId);
    			$j(tr).append($j(input));
    			
    			$j(td).css('text-align', 'center');
    			var data = $j(document.createElement('img'));
    			if (result[i].gender == 'F')
    				$j(data).attr('src', "${pageContext.request.contextPath}/images/female.gif");
    			else
    				$j(data).attr('src', "${pageContext.request.contextPath}/images/male.gif");
    			$j(td).append($j(data));
    			$j(tr).append($j(td));
    			
    			if (result[i].birthdateEstimated)
    				createCell('~', tr);
    			else
    				createCell('', tr);
    			
    			createCell(parseDate(result[i].birthdate, '<openmrs:datePattern />'), tr);
    			
    			$j(tbody).append($j(tr));
    		}
    		
    		$j('#resultTableHeader').show();
    		$j('.filler').hide();
    		
    	} else {
    		$j('#resultTableHeader').hide();
    		$j('.filler').show();
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

        var personName = {
        	givenName: $j('input[name=names[0].givenName]').attr('value'),
        	middleName: $j('input[name=names[0].middleName]').attr('value'),
        	familyName: $j('input[name=names[0].familyName]').attr('value')
        }
        // alert(DWRUtil.toDescriptiveString(personName, 2));
        
        var personAddress = {
        	address1: $j('input[name=addresses[0].address1]').attr('value'),
        	address2: $j('input[name=addresses[0].address2]').attr('value'),
        	neighborhoodCell: $j('input[name=addresses[0].neighborhoodCell]').attr('value'),
        	cityVillage: $j('input[name=addresses[0].cityVillage]').attr('value'),
        	townshipDivision: $j('input[name=addresses[0].townshipDivision]').attr('value'),
        	countyDistrict: $j('input[name=addresses[0].countyDistrict]').attr('value'),
        	stateProvince: $j('input[name=addresses[0].stateProvince]').attr('value'),
        	region: $j('input[name=addresses[0].region]').attr('value'),
        	subregion: $j('input[name=addresses[0].subregion]').attr('value'),
        	country: $j('input[name=addresses[0].country]').attr('value'),
        	postalCode: $j('input[name=addresses[0].postalCode]').attr('value')
        }
        // alert(DWRUtil.toDescriptiveString(personAddress, 2));
        
        var patientIdentifier = {
        	identifier: $j('input[name=identifiers[0].identifier]').attr('value'),
        	identifierType: $j('input[name=identifiers[0].identifierType]').attr('value')
        }
        // alert(DWRUtil.toDescriptiveString(patientIdentifier, 2));
        
        
        if (attributes == null) {
        	prepareAttributes();
        }
        
        for(i=0; i<attributes.length; i++) {
            if (attributes[i].value == null || attributes[i].value == "")
                continue;
        	else
                attributes[i].value = DWRUtil.getValue(attributes[i].attributeType.personAttributeTypeId).toString();
        }
        // alert("Attributes: " + DWRUtil.toDescriptiveString(attributes, 2));
        
        var birthStr = $j('input:text[name=birthdateInput]').attr('value');
        var birthdate = null;
        if (typeof(birthStr) != 'undefined' && birthStr.length > 0)
        	birthdate = new Date(Date.parse(birthStr));
        else {
        	birthStr = $j('input:text[name=birthdate]').attr('value');
        	if (typeof(birthStr) != 'undefined' && birthStr.length > 0)
        		birthdate = new Date(Date.parse(birthStr));
        }
        
        var gender = $j('input:radio[name=gender]:checked').attr('value');
        if (!gender)
        	gender = null;
        	
        var ageStr = $j('input:text[name=ageInput]').attr('value');
        var age = null;
        if (typeof(ageStr) != 'undefined' && ageStr.length > 0) {
        	age = ageStr;
        } else if (birthdate != null)
        	age = getAge(birthdate);
        else
        	age = null;
        
        DWRAmrsRegistrationService.getPatients(personName, personAddress, patientIdentifier, attributes, gender, birthdate, age, handlePatientResult);
    }
    
    function prepareAttributes() {
    	attributes = new Array();
        
        <openmrs:forEachDisplayAttributeType personType="" displayType="listing" var="attrType">
        	type = new Object();
        	type.personAttributeTypeId = "${attrType.personAttributeTypeId}";
        	type.name = "${attrType.name}";
        	type.format = "${attrType.format}";
        	
        	attr = new Object();
        	attr.attributeType = type;
        	attributes[${varStatus.index}] = attr;
		</openmrs:forEachDisplayAttributeType>
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
	
	.resultTableExtended {
		display: none;
	}
	
</style>

<div>
	<h2><spring:message code="amrsregistration.edit.start"/></h2>
</div>

<div id="mask"></div>
<div id="amrsContent">
	<span>Fill in the patient information and press continue to proceed</span>
	<form id="patientForm" method="post" onSubmit="removeTemplate()" autocomplete="off">
	<div id="boxes"> 
		<div id="dialog" class="window">
			<div id="personContent"></div>
		</div>
	</div>
	<br /><br />
			
	<div id="floating" style="display: block;">
	    <table class="box" style="width: 80%; padding: 0px">
	    	<tr>
	    		<td><span style="border-bottom:1px solid lightgray;">Patient Search</span></td>
	    		<td colspan="4">&nbsp;</td>
	    	</tr>
			<c:choose>
				<c:when test="${fn:length(potentialMatches) > 0}">
			        <tr class="filler" style="display: none">
			        	<td colspan="8"><span id="searchMessage">No patients found.</span></td>
			        </tr>
			        <tr class="filler" style="display: none">
			        	<td colspan="8">&nbsp;</td>
			        </tr>
			        <tr class="filler" style="display: none">
			        	<td colspan="8">&nbsp;</td>
			        </tr>
				</c:when>
				<c:otherwise>
			        <tr class="filler" style="display: block">
			        	<td colspan="8"><span id="searchMessage">No patients found.</span></td>
			        </tr>
			        <tr class="filler" style="display: block">
			        	<td colspan="8">&nbsp;</td>
			        </tr>
			        <tr class="filler" style="display: block">
			        	<td colspan="8">&nbsp;</td>
			        </tr>
				</c:otherwise>
			</c:choose>
        	<tr id="resultTableHeader" style="display: none;">
	        	<td><spring:message code="amrsregistration.labels.ID" /></td>
	        	<td><spring:message code="amrsregistration.labels.givenNameLabel" /></td>
	        	<td><spring:message code="amrsregistration.labels.middleNameLabel" /></td>
	        	<td><spring:message code="amrsregistration.labels.familyNameLabel" /></td>
	        	<td><spring:message code="amrsregistration.labels.age" /></td>
	        	<td style="text-align: center;"><spring:message code="amrsregistration.labels.gender" /></td>
	        	<td>&nbsp;</td>
	        	<td><spring:message code="amrsregistration.labels.birthdate" /></td>
	        </tr>
	        <tbody id="resultTable">
				<c:choose>
					<c:when test="${fn:length(potentialMatches) > 0}">
			    		<c:forEach items="${potentialMatches}" var="patient" varStatus="varStatus">
			    			<c:choose>
			    				<c:when test="${varStatus.index % 2 == 0}">
					    			<c:choose>
					    				<c:when test="${varStatus.index > 3}">
					    					<tr class="evenRow resultTableExtended">
					    				</c:when>
					    				<c:otherwise>
					    					<tr class="evenRow">
					    				</c:otherwise>
					    			</c:choose>
			    				</c:when>
			    				<c:otherwise>
					    			<c:choose>
					    				<c:when test="${varStatus.index > 3}">
					    					<tr class="oddRow resultTableExtended">
					    				</c:when>
					    				<c:otherwise>
					    					<tr class="oddRow">
					    				</c:otherwise>
					    			</c:choose>
			    				</c:otherwise>
			    			</c:choose>
			    				<c:forEach items="${patient.identifiers}" var="identifier" varStatus="varStatus">
			    					<c:if test="${varStatus.index == 0}">
					    				<td class="match">
					    					<c:out value="${identifier.identifier}" />
					    				</td>
			        				</c:if>
			    				</c:forEach>
			    				<td class="match">
			    					<c:out value="${patient.personName.givenName}" />
			    				</td>
			    				<td class="match">
			    					<c:out value="${patient.personName.middleName}" />
			    				</td>
			    				<td class="match">
			    					<c:out value="${patient.personName.familyName}" />
			    				</td>
			    				<td class="match">
			    					<c:out value="${patient.age}" />
			    				</td>
			    				<td class="match" style="text-align: center;">
									<c:if test="${patient.gender == 'M'}"><img src="${pageContext.request.contextPath}/images/male.gif" alt='<spring:message code="Person.gender.male"/>' /></c:if>
									<c:if test="${patient.gender == 'F'}"><img src="${pageContext.request.contextPath}/images/female.gif" alt='<spring:message code="Person.gender.female"/>' /></c:if>
			    				</td>
			    				<td class="match">
			    					<c:if test="${patient.birthdateEstimated}">~</c:if>
			    				</td>
			    				<td class="match">
			    					<openmrs:formatDate date="${patient.birthdate}" />
			    				</td>
			    				<input type="hidden" name="hiddenId${varStatus.index}" value="${patient.patientId}" />
			    			</tr>
			    		</c:forEach>
					</c:when>
				</c:choose>
	        </tbody>
			<c:choose>
				<c:when test="${fn:length(potentialMatches) > 3}">
	    			<tr id="extendedToggle" style="display: block;">
				</c:when>
				<c:otherwise>
	    			<tr id="extendedToggle" style="display: none;">
				</c:otherwise>
			</c:choose>
	    		<td class="toggle">
					<a href="#" name="extendedToggle">more >></a>
				</td>
			</tr>
	    </table>
	</div>
	<br />

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
		<table id="namePositionParent">
			<tr>
				<thead>
					<openmrs:portlet url="nameLayout" id="namePortlet" size="columnHeaders" parameters="layoutShowTable=false|layoutShowExtended=false" />
				<td>
					<c:choose>
						<c:when test="${fn:length(patient.names) > 1}">
				   			<span id="namePreferredLabel" style="display: block"><spring:message code="general.preferred"/></span>
						</c:when>
						<c:otherwise>
				    		<span id="namePreferredLabel" style="display: none"><spring:message code="general.preferred"/></span>
						</c:otherwise>
					</c:choose>
				</td>
				</thead>
			</tr>
	        <c:forEach var="name" items="${patient.names}" varStatus="varStatus">
	            <spring:nestedPath path="patient.names[${varStatus.index}]">
					<openmrs:portlet url="nameLayout" id="namePortlet${varStatus.index}" size="inOneRow" parameters="layoutMode=edit|layoutShowTable=false|layoutShowExtended=false" />
	            </spring:nestedPath>
	            <script type="text/javascript">
	            	$j(document).ready(function () {
	            		var hidden = ${fn:length(patient.names) <= 1};
						var preferred = ${name.preferred};
	            		var position = ${varStatus.index};
	            		var tbody = $j('#namePositionParent').find('tbody:eq(1)');
	            		var nameContentX = $j(tbody).find('tr:eq(' + position + ')');
	            		$j(nameContentX).attr('id', 'nameContent' + position);
	            		createPreferred(preferred, 'name', position, nameContentX, hidden);
	            		
	            		// bind onkeyup for each of the address layout text field
	            		var allTextInputs = $j('#nameContent' + position + ' input[type=text]');
	            		$j(allTextInputs).bind('keyup', function(event){
	            			timeOutSearch(event);
	            		});
	            	});
	            </script>
	        </c:forEach>
	    	<tbody id="namePosition">
		</table>
		<div id="nameContent" style="display: none;">
			<spring:nestedPath path="emptyName">
				<table>
					<openmrs:portlet url="nameLayout" id="namePortlet" size="inOneRow" parameters="layoutMode=edit|layoutShowTable=false|layoutShowExtended=false" />
				</table>
			</spring:nestedPath>
		</div>
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
								<input type="text" name="birthdateInput" id="birthdate" size="11" value="" readonly="readonly" onclick="showCalendar(this)" onkeyup="timeOutSearch(event)"/>
								<spring:message code="Person.age.or"/>
								<input type="text" name="ageInput" id="age" size="5" value="" onkeyup="timeOutSearch(event)" />
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
								<spring:bind path="patient.birthdate">			
									<input type="text" 
											name="${status.expression}" size="10" id="birthdate"
											value="${status.value}"
											readonly="readonly"
											onchange="updateAge(); updateEstimated(this);"
											onclick="showCalendar(this)" onkeyup="timeOutSearch(event)" />
								</spring:bind>
								
								<span id="age"></span> &nbsp; 
								
								<span id="birthdateEstimatedCheckbox" class="listItemChecked" style="padding: 5px;">
									<spring:bind path="patient.birthdateEstimated">
										<label for="birthdateEstimatedInput"><spring:message code="Person.birthdateEstimated"/></label>
										<input type="hidden" name="_${status.expression}">
										<input type="checkbox" name="${status.expression}" value="true" 
											   <c:if test="${status.value == true}">checked</c:if> 
											   id="birthdateEstimatedInput" 
											   onclick="if (!this.checked) updateEstimated()" />
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
		<table id="identifierPositionParent">
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
					<c:choose>
						<c:when test="${fn:length(patient.identifiers) > 1}">
				    		<span id="identifierPreferredLabel" style="display: block"><spring:message code="general.preferred"/></span>
						</c:when>
						<c:otherwise>
				    		<span id="identifierPreferredLabel" style="display: none"><spring:message code="general.preferred"/></span>
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
	        <c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
	            <spring:nestedPath path="patient.identifiers[${varStatus.index}]">
	            	<c:if test="${amrsIdType != identifier.identifierType.name}">
	            		<%@ include file="portlets/patientIdentifier.jsp" %>
						<script type="text/javascript">
							var hidden = ${fn:length(patient.identifiers) <= 1};
							var preferred = ${identifier.preferred};
							var container = $j('#identifierContent${varStatus.index}');
							createPreferred(preferred, 'identifier', ${varStatus.index}, container, hidden);
			            </script>
	            	</c:if>
	            </spring:nestedPath>
	        </c:forEach>
	    	<tbody id="identifierPosition">
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
		<table>
			<c:forEach var="address" items="${patient.addresses}" varStatus="varStatus">
				<tr><td>
			    <spring:nestedPath path="patient.addresses[${varStatus.index}]">
			    	<openmrs:portlet url="addressLayout" id="addressPortlet${varStatus.index}" size="full" parameters="layoutShowTable=true|layoutShowExtended=false" />
			    </spring:nestedPath>
				</td></tr>
	            <script type="text/javascript">
	            	$j(document).ready(function () {
		            	var hidden = ${fn:length(patient.addresses) <= 1};
						var preferred = ${address.preferred};
	            		var position = ${varStatus.index};
	            		var nameContentX = $j('#addressPortlet' + position).find('table');
	            		$j(nameContentX).attr('id', 'addressContent' + position);
	            		createPreferred(preferred, 'address', position, nameContentX, hidden);
	            		
	            		// bind all inputs
	            		var allTextInputs = $j('#addressContent' + position + ' input[type=text]');
	            		$j(allTextInputs).bind('keyup', function(event){
	            			timeOutSearch(event);
	            		});
	            	});
	            </script>
			</c:forEach>
	        <tbody id="addressPosition" />
		</table>
        <div id="addressPositionClear" style="clear:both"/>
		<div id="addressContent" style="display: none;">
			<spring:nestedPath path="emptyAddress">
				<openmrs:portlet url="addressLayout" id="addressPortlet" size="full" parameters="layoutShowTable=true|layoutShowExtended=false" />
			</spring:nestedPath>
	    </div>
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
				<openmrs:forEachDisplayAttributeType personType="" displayType="listing" var="attrType">
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
<script type="text/javascript">
	// bind onkeyup for each of the address layout text field
	$j(document).ready(function() {
		var first = $j('#nameContent0 input[type=text]:eq(0)');
		first.focus();
	});
</script>

<%@ include file="/WEB-INF/template/footer.jsp" %>
