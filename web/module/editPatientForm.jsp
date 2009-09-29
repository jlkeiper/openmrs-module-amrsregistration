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
<openmrs:htmlInclude file="/moduleResources/amrsregistration/scripts/jquery.tablesorter.min.js" />

<%@ include file="portlets/dialogContent.jsp" %>
<script type="text/javascript">

    // Number of objects stored.  Needed for 'add new' purposes.
    var numObjs = new Array();
    numObjs["identifier"] = ${fn:length(amrsRegistration.patient.activeIdentifiers)};
    numObjs["name"] = ${fn:length(amrsRegistration.patient.names)};
    numObjs["address"] = ${fn:length(amrsRegistration.patient.addresses)};

    relationshipCounter = ${fn:length(amrsRegistration.relationships)};
        
    // Search time out variable. Need to clear this variable to cancel the server request, thus
    // preventing multiple request being submitted to the server.
    // Reset when:
    // - dwr return a result
    // - user entered more alpha-numeric or delete or backspace character
	searchTimeout = null;
	// how long should we wait after keystroke before dwr submit the request
	searchDelay = 1000;
    
    // variable that will hold the attributes shown in the screen and their values
    var attributes = null;

    // variable for assigning rowID for patient name section.
    var nameRow = -1;
    
    $j(document).ready(function() {
		// selecting a patient from the potential matches
		// get the <tr> --> get the value of input element inside it and send it to server to get the patient object
		$j('.match').click(function(){
			var tr = $j(this).parent();
			var children = $j(tr).children(':input');
			var id = $j(children).attr('value');
			getPatientByIdentifier(jQuery.trim(id));
		});
		// show highlight effect on the selected row
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
		// more or less toggle function
		$j('a[name=extendedToggle]').click(function(e) {
			e.preventDefault();
			// toggle the extended match result row
			$j('.resultTableExtended').toggle();
			// show more or less link
			if ($j('.resultTableExtended').is(':hidden')) {
				$j(this).html('more >>');
			} else {
				$j(this).html('<< less');
			}
		});
		
		// don't bold the <th> content
        $j('th').css('font', '1em verdana');
        // remove top border to prevent overlapping border
        $j('th').css('border-top', '0px');
		
		// make the search result table sortable
        $j("#tableSorter").tablesorter();
        
        // show the potential matches
		<c:if test="${fn:length(potentialMatches) > 0}">$j('#resultTableHeader').show();</c:if>
		
    });
    
    function getPatientByIdentifier(identifier) {
    	DWRAmrsRegistrationService.getPatientByIdentifier(identifier, renderPatientData);
    }
	
	function cancel() {
		// dismiss the mask (selecting from potential matches patient will show the mask)
		$j('#mask').hide();
		$j('.window').hide();
	}
    
    function updateData(identifier) {
    	// get the form and reset the form
    	$j(document.forms[0].reset());
    	// attach the patient id to the form
    	var hiddenInput = $j(document.createElement("input"));
    	$j(hiddenInput).attr("type", "hidden");
    	$j(hiddenInput).attr("name", "patientIdInput");
    	$j(hiddenInput).attr("id", "patientIdInput");
    	$j(hiddenInput).attr("value", identifier);
    	$j('#boxes').append($j(hiddenInput));
    	// submit the form
    	$j(document.forms[0].submit());
    }
		
	function createPreferred(preferred, type, id, container, hidden) {
		// container of the preferred will be <tr> for id and name
		// <table> for address
		var element = null;
			
		var input = $j(document.createElement('input'));
		$j(input).attr('type', 'radio');
		$j(input).attr('name', type + 'Preferred');
		$j(input).attr('value', id);
		$j(input).attr('valign', 'top');
		//if(preferred) {
			$j(input).attr('checked', 'checked');
		//}
			
		if (type == 'address') {
			// for address, element is a row
			element = $j(document.createElement('tr'));
			
			td = $j(document.createElement('td'));
			$j(td).attr('colspan', '2');
            $j(td).attr('width', '100');
			
			$j(element).append(td);
			
			$j(td).append(input);
			
			var label = $j(document.createTextNode('Preferred'));
			$j(td).append(label);
			
			$j(container).prepend(element);
        } else if (type == 'name') {
            element = $j(document.createElement('tr'));

            td = $j(document.createElement('td'));
            $j(td).attr('colspan', '2');

            $j(element).append(td);

            $j(td).append(input);

            var tbody = document.getElementById('namePositionExtra');

            //var row = tbody.getElementsByTagName('tr').length;

            var elemId = 'namePreferred' + id;

            $j(element).attr('id', elemId);

            $j('#namePositionExtra').append(element);

		} else {
			// for identifier and name, the element is a cell
			element = $j(document.createElement('td'));
			
			$j(element).append(input);
			
			$j(container).append(element);
		}
		
		if (hidden)
			$j(element).hide();
	}
		
	function createDelete(type, id, container) {
		// container of the preferred will be <tr> for id and name
		// <table> for address
		var element = null;
			
		var anchor = $j(document.createElement('a'));
		$j(anchor).attr('href', '#delete');
		$j(anchor).attr('id', type + id);
		$j(anchor).attr('style', 'color:red');
		$j(anchor).html('X');
        //$j(anchor.parentNode).attr("onclick", "removeRow(this.parentNode, '" + type + "')");

		if (type == 'address') {
			// for address, element is a row
			element = $j(document.createElement('td'));
			
			//td = $j(document.createElement('td'));
			//s$j(element).attr('colspan', '2');
            $j(element).attr('style', 'text-align: right');
            $j(element).attr('align', 'right');

			///$j(element).append(td);
            $j(anchor).attr("onclick", "removeRow(" + id + ", '" + type + "')");

			$j(element).append(anchor);

			//var label = $j(document.createTextNode('Preferred'));
			//$j(td).append(label);

			$j(container).append(element);
        } else if (type == 'name') {
            // for identifier and name, the element is a cell
            element = $j(document.createElement('td'));

            $j(element).append(anchor);

            var tbody = document.getElementById('namePositionExtra');

            //var row = tbody.getElementsByTagName('tr').length - 1;

            var elemId = 'rm_namePositionParentRow' + id;
            var elemOnClick = "removeRow(this.parentNode, '" + type + "')";

            $j(element).attr('id', elemId);
            $j(element).attr('onClick', elemOnClick);

            $j('#namePreferred' + id).append(element);
		} else {
			// for identifier and name, the element is a cell
			element = $j(document.createElement('td'));
			
			$j(element).append(anchor);

            if (type == 'identifier') {

                var onclick = "removeRow('identifierContent" + id + "', '" + type + "')";
                $(element).attr('onclick', onclick);
            }

            $j(container).append(element);

		}
	}

    function removeRow(tableRow, type) {
        if (type == 'name') {
            if (tableRow.id.search('namePreferred') > -1) {
                var nameContentId = tableRow.id.replace('namePreferred', 'nameContent');
                var nameContent = document.getElementById(nameContentId);
                $j(nameContent).remove();
            }
        }
        if (type == 'address') {
            $j('#addressContent' + tableRow).remove();
        } else {
            var row = $j(tableRow).get(0);
            $j(row).remove();
        }
        // If this is the last item left, set as preferred.
        if ($j("input[name=" + type + "Preferred]:visible").length < 2) {
            $j.each($j("input[name=" + type + "Preferred]:visible"), function(i, n) {
                n.checked = true;
            });
        }
    }

	function getTemplateType(type) {
		// the following are the id of the template for name, address and identifier
		// this element must exist and must be bind to an emptyName, emptyAddress and emptyIdentifier
		if (type == 'name')
			return $j('#nameContent').find('tr');
		if (type == 'address')
			return $j('#addressContent').find('table');
		if (type == 'identifier')
			return $j('#identifierContent');
	}
	
	function duplicateElement(type, id) {
		// clone the template and add preferred section
		var templateClone = getTemplateType(type).clone(true);

        if (type == 'identifier') {
            $j(templateClone).find('td').show();
            $j(templateClone).find("#addNewIdentifierData").replaceWith("<td></td>");
            $j("#identifierPreferredLabel").show();
            $j(templateClone).find("#identifierPreferred").attr("checked", "checked");
            $j(templateClone).find("#identifierPreferred").attr("id", "identifierPreferred" + id);
        }

        if (type == 'address') {
            $j.each($j(templateClone).find('tr'), function(i, n) {
                $j(n).find('td:first').remove();
            });
            $j.each($j(templateClone).find('td'), function(i, n) {
                if ($j(n).find('input').length < 1) {
                    n.innerHTML='';
                }
            });            
        }
        $j.each($j(templateClone).find('input'), function(i, n) {
            if (n.id != ('identifierPreferred' + id)) {
                return n.parentNode.innerHTML=n.value;
            }
        });
        $j.each($j(templateClone).find('select'), function(i, n) {
            n.selectedIndex = $j('#' + type + 'Content').find('select').get(i).selectedIndex;
            n.parentNode.innerHTML = n.options[n.selectedIndex].text; 
        });
		if (type == 'name') {
			createPreferred(false, type, id, templateClone, false);
			createDelete(type, id, templateClone);
        }

		// custom mods for address
		if (type == 'address') {
            $j(templateClone).attr('style', 'display=""');
            $j(templateClone).attr('width', '100%');
			createPreferred(false, type, id, templateClone, false);
            createDelete(type, id, templateClone.find('tr:first'));
			var td = $j(document.createElement('td'));
            $j(td).attr('style', 'border: thin outset lightgray');
			td.append(templateClone);
			return td;
		}
		return templateClone;
	}
	
	function createElement(type, id) {
		// method that will be called when "add new" button is pressed
		var element = duplicateElement(type, id);
		$j(element).attr('id', type + 'Content' + id);
		return element;
	}

    function addNew(type) {
    	// remove the error message
        $j('#' + type + 'Error').empty();
        
        // get the total number of element in the page (also used for id)
    	var prevIdSuffix = numObjs[type] - 1;

    	var allowCreate = false;

		// always allow creating new element where the number is less than 0
    	if (prevIdSuffix < 0) {
    		allowCreate = true;
    	} else {
    		// when more than 0, then get all input element and check whethere one of them is filled
    		var allInputType = $j('#' + type + 'Content' + ' input[type=text]');
    		if (allInputType.length > 0) {
        		
    	    	for (i = 0; i < allInputType.length; i++) {
    	    		var o = allInputType[i];
    	    		str = jQuery.trim(o.value);
    	    		// if one of the input element is not empty then allow creating new element
    	    		if (str.length > 0) {
    	    			// allow creating new object when a non blank element is found
    	    			allowCreate = true;
    	    			break;
    	    		}
    	    	}
    		} else {
        		allowCreate = true;
    		}
		}
    	
        if (allowCreate) {
        	// create a new element using the above function
            var newElement = createElement(type, (numObjs[type]++));

            // put the new element to the correct position
            // each type will have their own template and position id
            // address: --> template: addressContent
            //          --> position: addressPosition
            //          --> added element: addressContentXX
            // In general, for each type they will have:
            // template: <type>Content
            // position: <type>Position
            // added element: <type>ContentXX
            if (type == 'address') {
                var appended = false;
                $j.each($j('#' + type + 'Position').children('tr'), function(i, n) {
                    if ($j(n).children('td').length < 3 && !appended) {
                        $j(n).append(newElement);
                        appended = true;
                    }
                });
                if (!appended) {
                    var tr = $j(document.createElement('tr'));
                    $j(tr).append(newElement);
                    $j('#' + type + 'Position').append(tr);
                }
            } else {
                $j('#' + type + 'Position').append(newElement);
            }
            // clear inputs
            $j('#' + type + 'Content').find('input[type=text],select').val("");

            //if (prevIdSuffix == 0) {
            if (type != 'identifier') {
            	// alert('show flag');
            	
            	// show the preferred label and the preferred radio button when the total number of element more than 1
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
            
        }
        
        if (!allowCreate){
        	$j('#' + type + 'Error').html('<span style="color: red;">Please fill in values before adding ' + type + '.</span>');
        }
    }
	
	function removeTemplate() {
		// remove name, id and address template when submitting
		var obj = document.getElementById("identifierContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("nameContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("addressContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		// remove the relationship templates
		obj = document.getElementById("relationshipContent");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("personSearchResult");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("createRelationshipPerson");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		
		// remove added element but still blank from the form
		for (key in numObjs)
			deleteRow(key, true);
	}
	
	function deleteLastRow (type) {
		deleteRow(type, false);
	}
	
	function deleteRow(type, submit) {
		
		// remove blank name, id and address that is added but never get filled
		// the check only for the last element because we're not allowing adding
		// new one when the previous one still blank (see addNew)
		
		var prevIdSuffix = numObjs[type] - 1;
		message = "";
    		
		if (prevIdSuffix > 0) {
			// check all input to see if it's blank
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
	    		var success = $j('#' + type + "Content" + prevIdSuffix).remove();
	    		numObjs[type] = numObjs[type] - 1;
	    		prevIdSuffix = prevIdSuffix - 1;
	    		// hide radio button when there's only one row left
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
    	
    	if (!submit) {
    		// clear all element when the user press remove but there's only one element on the screen
    		if (prevIdSuffix <= 0)
    			$j('#' + type + 'Content' + prevIdSuffix + ' input[type=text]').attr("value", "");
    		if (message.length > 0)
	    		$j('#' + type + 'Error').html(message);
	    }
	}
	
	function createCell(content, row) {
		var column = $j(document.createElement('td'));
		var data = $j(document.createTextNode(content));
		$j(column).append($j(data));
		$j(row).append($j(column));
	}
    
    function handlePatientResult(result) {
		clearTimeout(searchTimeout);
    	
    	// clear the tbody from previous search result
		var tbody = $j('#resultTable');
		$j(tbody).empty();
		
		// hide extended toggle, more than ${maxReturned}, result table header
		$j('#extendedToggle').hide();
		$j('#moreMatches').hide();
		$j('#resultTableHeader').hide();
		// show filler (3 blank row and a no patient found text)
    	$j('.filler').show();
		
    	if (result.length > 0) {
    		
    		// check if the max result is returned or not
    		returnedPatient = result.length;
    		if (returnedPatient > ${maxReturned}) {
    			returnedPatient = ${maxReturned};
    			$j('#moreMatches').show();
    		}
    		
    		// loop through all result and display it
    		for(i = 0; i < returnedPatient; i ++) {
    			// create new row
    			var tr = $j(document.createElement('tr'));
    			// zebra like row
    			if (i % 2 == 0)
    				$j(tr).addClass("evenRow");
    			else
    				$j(tr).addClass("oddRow");
    			
    			// mark the fourth element to be an extended result that can be toggled
    			if (i > 2) {
    				$j(tr).addClass('resultTableExtended');
					$j('#extendedToggle').show();
    			}
    			
    			// bind highlight effect
    			$j(tr).hover(
    				function() {
						$j(this).addClass("searchHighlight");
    				},
    				function() {
						$j(this).removeClass("searchHighlight");
    				}
    			);
    			// bind click to show the selected patient
    			$j(tr).click(function() {
					var children = $j(this).children(':input');
					var id = $j(children).attr('value');
					getPatientByIdentifier(jQuery.trim(id));
    			});
    			
    			// create each cell for identifier, given, middle, family name, age, gender, and birthdate (+ estimated)
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
    		
    		// show the table and hide the filler
    		$j('#resultTableHeader').show();
    		$j('.filler').hide();
        
            // let the plugin know that we made a update 
            $j("#tableSorter").trigger("update");
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
	
	function clickTimeOutSearch() {
		clearTimeout(searchTimeout);
		searchTimeout = setTimeout("patientSearch()", searchDelay);
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
        	givenName: $j('input[name=givenName]').attr('value'),
        	middleName: $j('input[name=middleName]').attr('value'),
        	familyName: $j('input[name=familyName]').attr('value')
        }
        // alert(DWRUtil.toDescriptiveString(personName, 2));
        
        var personAddress = {
        	address1: $j('input[name=address1]').attr('value'),
        	address2: $j('input[name=address2]').attr('value'),
        	neighborhoodCell: $j('input[name=neighborhoodCell]').attr('value'),
        	cityVillage: $j('input[name=cityVillage]').attr('value'),
        	townshipDivision: $j('input[name=townshipDivision]').attr('value'),
        	countyDistrict: $j('input[name=countyDistrict]').attr('value'),
        	stateProvince: $j('input[name=stateProvince]').attr('value'),
        	region: $j('input[name=region]').attr('value'),
        	subregion: $j('input[name=subregion]').attr('value'),
        	country: $j('input[name=country]').attr('value'),
        	postalCode: $j('input[name=postalCode]').attr('value')
        }
        // alert(DWRUtil.toDescriptiveString(personAddress, 2));
        
        var patientIdentifier = {
        	identifier: $j('input[name=identifier]').attr('value'),
        	identifierType: $j('select[name=identifierType]').attr('value')
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
        	birthStr = $j('input:text[name=patient\\.birthdate]').attr('value');
        	if (typeof(birthStr) != 'undefined' && birthStr.length > 0)
        		birthdate = new Date(Date.parse(birthStr));
        }
        
        var gender = $j('input:radio[name=patient\\.gender]:checked').attr('value');
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

    function clearAgeOrDOB(inputField) {
        var dob = document.getElementById("birthdateInput");
        var dobMsg = document.getElementById("birthdateTitle");
        var age = document.getElementById("ageInput");
        var ageMsg = document.getElementById("ageTitle");
        var orMsg = document.getElementById("orTitle");
        orMsg.style.color = "#CCCCCC";
        if (inputField.id == "birthdateInput") {
            dob.style.backgroundColor="white";
            dobMsg.style.color="black";
            age.style.backgroundColor="#D3D3D3"
            ageMsg.style.color="#CCCCCC"
            age.value="";
        }
        else if (inputField.id == "ageInput") {
            age.style.backgroundColor="white";
            ageMsg.style.color="black";
            dob.style.backgroundColor="#D3D3D3";
            dobMsg.style.color="#CCCCCC";
            dob.value="";
        }
    }

    function changeNameHeaderHack() {
        var headers = document.getElementsByTagName("th");
        for (var i=0; i<headers.length; i++) {
            if (headers[i].innerHTML == "Given") {
                headers[i].innerHTML = "First Name";
            } else if (headers[i].innerHTML == "Middle") {
                headers[i].innerHTML = "Middle Name";
            }
        }
    }


</script>

<style>
    #table-header {
        align: left;
        font-weight: bold;
    }

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
	<span><spring:message code="amrsregistration.page.edit.title"></spring:message></span>
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
	    		<td>Patient Search</td>
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
		</table>
        <table id="tableSorter" class="box" style="width: 80%; padding: 0px; border-top:0px;">
			<thead>
        	<tr id="resultTableHeader" style="display: none;">
	        	<th><spring:message code="amrsregistration.labels.ID" /></th>
	        	<th><spring:message code="amrsregistration.labels.givenNameLabel" /></th>
	        	<th><spring:message code="amrsregistration.labels.middleNameLabel" /></th>
	        	<th><spring:message code="amrsregistration.labels.familyNameLabel" /></th>
	        	<th><spring:message code="amrsregistration.labels.age" /></th>
	        	<th style="text-align: center;"><spring:message code="amrsregistration.labels.gender" /></th>
	        	<th>&nbsp;</th>
	        	<th><spring:message code="amrsregistration.labels.birthdate" /></th>
	        </tr>
	        </thead>
	        <tbody id="resultTable">
				<c:choose>
					<c:when test="${fn:length(potentialMatches) > 0}">
			    		<c:forEach items="${potentialMatches}" var="patient" varStatus="varStatus" end="${maxReturned}">
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
	    </table>
        <c:choose>
            <c:when test="${fn:length(potentialMatches) > 3}">
                <table id="extendedToggle" class="box" style="width: 80%; padding: 0px; border-top:0px; display: block;">
					<c:choose>
						<c:when test="${fn:length(potentialMatches) > maxReturned}">
					    	<tr id="moreMatches" style="display: block">
					    		<td class="toggle">
			    					<spring:message code="amrsregistration.page.edit.moreMatches" arguments="${maxReturned}"></spring:message>
								</td>
							</tr>
						</c:when>
						<c:otherwise>
					    	<tr id="moreMatches" style="display: none">
					    		<td class="toggle">
			    					<spring:message code="amrsregistration.page.edit.moreMatches" arguments="${maxReturned}"></spring:message>
								</td>
							</tr>
						</c:otherwise>
					</c:choose>
			    	<tr>
			    		<td class="toggle">
							<a href="#" name="extendedToggle">more >></a>
						</td>
					</tr>
			    </table>
            </c:when>
            <c:otherwise>
                <table id="extendedToggle" class="box" style="width: 80%; padding: 0px; border-top:0px; display: none;">
			    	<tr id="moreMatches" style="display: none">
			    		<td class="toggle">
			    			<spring:message code="amrsregistration.page.edit.moreMatches" arguments="${maxReturned}"></spring:message>
						</td>
					</tr>
			    	<tr>
			    		<td class="toggle">
							<a href="#" name="extendedToggle">more >></a>
						</td>
					</tr>
			    </table>
            </c:otherwise>
        </c:choose>
	</div>
	<br />

	<spring:hasBindErrors name="amrsRegistration">
		<c:forEach items="${errors.allErrors}" var="error">
			<br />
			<span class="error"><spring:message code="${error.code}"/></span>
		</c:forEach>
	</spring:hasBindErrors>
	
	<table id="centeredContent">
		<tr>
			<th class="header">Names</th>
			<td class="input" align="left" width="120" space-before="0">
                <table width="100%">
                    <col width="80%"/>
                    <col width="10%"/>
                    <tr>
                        <td valign="top">
                            <!-- Patient Names Section -->
                            <table id="namePositionParent">
                            <tr>
                                <td width="245" style="font-weight: bold;">
                                    First Name
                                </td >
                                <td width="240" style="font-weight: bold;">
                                    Middle Name
                                </td>
                                <td width="270" style="font-weight: bold;">
                                    Family Name
                                </td>
                            </tr>
                                <c:forEach var="name" items="${amrsRegistration.patient.names}" varStatus="varStatus">
                                <tr>
                                    <td>
                                        <c:if test="${name.givenName != null}">
                                            <spring:nestedPath path="amrsRegistration.patient.names[${varStatus.index}]">
                                            <tr id="nameContent${varStatus.index}">
                                                <spring:bind path="givenName">
                                                    <td>
                                                        ${status.value}
                                                    </td>
                                                </spring:bind>
                                                <spring:bind path="middleName">
                                                    <td>
                                                        ${status.value}
                                                   </td>
                                                </spring:bind>
                                                <spring:bind path="familyName">
                                                    <td>
                                                        ${status.value}
                                                    </td>
                                                </spring:bind>
                                            </tr>
                                            </spring:nestedPath>
                                        </c:if>
                                     </td>
                                 </tr>
                                </c:forEach>
                                <tbody id="namePosition">
                            </table>
                            <div id="nameContent">
                                <spring:nestedPath path="emptyName">
                                    <table>
                                        <openmrs:portlet url="nameLayout" id="namePortlet" size="inOneRow" parameters="layoutMode=edit|layoutShowTable=false|layoutShowExtended=false" />
                                    </table>
                                    <script type="text/javascript">
                                        // bind all inputs
                                        var allTextInputs = $j('#namePortlet input[type=text]');
                                        $j(allTextInputs).bind('keyup', function(event){
                                            timeOutSearch(event);
                                        });
                                    </script>
                                </spring:nestedPath>
                            </div>
                            <div class="tabBar" id="nameTabBar">
                                <span id="nameError" class="newError"></span>
                            </div>
                            <!-- End of Patient Names Section -->
                        </td>
                        <td valign="top" border="0px" >
                          <table  valign="top" border="0px" >
                              <thead>
                              <tr valign="top" height="20">
                                  <td id="namePreferredLabel" valign="top" border-top="0px" style="font-weight: bold; display: none;">
                                      <spring:message code="general.preferred"/>
                                  </td>
                              </tr>
                              <tr>
                                  <td><div></div></td>
                              </tr>
                              </thead>
                              <tbody id="namePositionExtra">
                              <c:forEach var="name" items="${amrsRegistration.patient.names}" varStatus="varStatus">
                                <spring:nestedPath path="amrsRegistration.patient.names[${varStatus.index}]">
                                    <tr id="namePreferred${varStatus.index}" <c:if test="${varStatus.index == 0 && (name.givenName == null || name.givenName == '') && (name.familyName == null || name.familyName == '')}">style="display: none;"</c:if> >
                                        <c:if test="${varStatus.index == 1}">
                                            <script type="text/javascript">
                                                $j('#namePreferredLabel').attr("style", "font-weight: bold; display: ''");    
                                            </script>
                                        </c:if>
                                        <td colspan="2">
                                            <spring:bind path="preferred">
                                                <input type="radio" name="namePreferred" value="${status.value}" <c:if test='${status.value == "true"}'>checked</c:if>">
                                            </spring:bind>
                                        </td>
                                        <td id="rm_namePositionParentRow${varStatus.index}" name="nameLayoutRow" onClick="removeRow(this.parentNode, 'name')" >
                                           <a href="#delete"  style="color:red;">X</a>
                                        </td>
                                    </tr>
                                </spring:nestedPath>
                              </c:forEach>
                              </tbody>
                          </table>
                            <div class="tabBar" id="nameTabBar">
                                <input type="button" onClick="return addNew('name');" class="addNew" id="name" value="Add New Name"/>
                            </div>
                        </td>
                    </tr>
                </table>
			</td>
		</tr>
		<tr>
			<th class="header">Demographics</th>
			<td class="input">
    
<!-- Gender and Birthdate Section -->
    	<table>
    		<tr>
				<td style="font-weight: bold;"><spring:message code="Person.gender"/></td>
				<td style="font-weight: bold;" id="birthdateTitle">
					<spring:message code="Person.birthdate"/>
					<i style="font-weight: normal; font-size: .8em;">(<spring:message code="general.format"/>: <openmrs:datePattern />)</i>
				</td>
    		</tr>
			<spring:nestedPath path="amrsRegistration.patient">
				<tr>
				<c:if test="${empty INCLUDE_PERSON_GENDER || (INCLUDE_PERSON_GENDER == 'true')}">
						<td style="padding-right: 3.6em;">
							<spring:bind path="amrsRegistration.patient.gender">
								<openmrs:forEachRecord name="gender">
									<input type="radio" name="${status.expression}" id="${record.key}" value="${record.key}" <c:if test="${record.key == status.value}">checked</c:if> onclick="clickTimeOutSearch()" />
										<label for="${record.key}"> <spring:message code="Person.gender.${record.value}"/> </label>
								</openmrs:forEachRecord>
							</spring:bind>
						</td>
				</c:if>
				<c:choose>
					<c:when test="${amrsRegistration.patient.birthdate == null}">
							<td style="padding-right: 4em;">
								<input type="text" name="birthdateInput" id="birthdateInput" size="11" value=""  onclick="showCalendar(this)" onkeyup="timeOutSearch(event)" onchange="clearAgeOrDOB(this)"/>
								<span style="font-weight: bold;" id="orTitle"><spring:message code="general.or"/></span>
								<span style="font-weight: bold;" id="ageTitle"><spring:message code="Person.age"/></span>
								<input type="text" name="ageInput" id="ageInput" size="5" value="" onkeyup="timeOutSearch(event)" onchange="clearAgeOrDOB(this)"/>
							</td>
					</c:when>
					<c:otherwise>
							<td style="padding-right: 4em;">
								<script type="text/javascript">
									function updateEstimated(txtbox) {
										var input = document.getElementById("patient.birthdateEstimated");
										if (input) {
											input.checked = false;
											input.parentNode.className = "";
										}
										else if (txtbox)
											txtbox.parentNode.className = "listItemChecked";
									}
									
									function updateAge() {
										var birthdateBox = document.getElementById('patient.birthdate');
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
								<spring:bind path="amrsRegistration.patient.birthdate">			
									<input type="text" 
											name="${status.expression}" size="10" id="${status.expression}"
											value="${status.value}"
											readonly="readonly"
											onchange="updateAge(); updateEstimated(this);"
											onclick="showCalendar(this)" onkeyup="timeOutSearch(event)" />
								</spring:bind>
								
								<span id="age"></span> &nbsp; 
								
								<span id="birthdateEstimatedCheckbox" class="listItemChecked" style="padding: 5px;">
									<spring:bind path="amrsRegistration.patient.birthdateEstimated">
										<label for="birthdateEstimatedInput"><spring:message code="Person.birthdateEstimated"/></label>
										<input type="hidden" name="_${status.expression}">
										<input type="radio" name="${status.expression}" value="true"
											   <c:if test="${status.value == true}">checked</c:if> 
											   id="${status.expression}" 
											   onclick="if (!this.checked) updateEstimated()" />
									</spring:bind>
								</span>
								
								<script type="text/javascript">
									if (document.getElementById("patient.birthdateEstimated").checked == false)
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
		<table id="identifierPositionParent" width="100%">
            <thead>
            <tr>
                <td style="font-weight: bold;" width="190">
                    <spring:message code="amrsregistration.labels.ID"/>
                </td>
                <td style="font-weight: bold;" width="275">
                    <spring:message code="PatientIdentifier.identifierType"/>
                </td>
                <td style="font-weight: bold;" width="250" >
                    <spring:message code="PatientIdentifier.location"/>
                </td>
                <td style="font-weight: bold;" name="addedIdentifierData">
                    <span name="addedIdentifierData" id="identifierPreferredLabel" style="display: none;"><spring:message code="general.preferred"/></span>
                </td>
            </tr>
            </thead>
            <tbody id="identifierPosition">
            <c:forEach var="identifier" items="${amrsRegistration.patient.activeIdentifiers}" varStatus="varStatus">
                <spring:nestedPath path="amrsRegistration.patient.identifiers[${varStatus.index}]">
                    <c:if test="${varStatus.index == 1}">
                        <script type="text/javascript">
                            $j("#identifierPreferredLabel").attr("style", "display: ''");
                        </script>
                    </c:if>
                        <%@ include file="portlets/patientIdentifier.jsp" %>
                </spring:nestedPath>
            </c:forEach>
            </tbody>
      	</table>
        <spring:nestedPath path="emptyIdentifier">
            <table id="emptyIdentifierTable">
                <%@ include file="portlets/patientIdentifier.jsp" %>
            </table>
            <script type="text/javascript">
                // bind all inputs
                var allTextInputs = $j('#emptyIdentifierTable input[type=text]');
                $j(allTextInputs).bind('keyup', function(event){
                    timeOutSearch(event);
                });
            </script>
        </spring:nestedPath>
        <div class="tabBar" id="identifierTabBar">
			<span id="identifierError" class="newError"></span>
        </div>
<!-- End of Patient Identifier Section -->
	
			</td>
		</tr>
		<tr>
			<th class="header">Addresses</th>
			<td class="input">

<!-- Patient Address Section -->
		<table>
            <col width="33%"/>
            <col width="33%"/>
            <col width="34%"/>
            <tbody id="addressPosition">
			<c:forEach var="address" items="${amrsRegistration.patient.addresses}" varStatus="varStatus">
                <c:if test="${varStatus.index % 3 == 0}"><tr valign="top"></c:if>
                <c:if test="${varStatus.index > 1}">
                    <td  id="addressContent${varStatus.index}" style='border: thin outset lightgray'>
                        <spring:nestedPath path="amrsRegistration.patient.addresses[${varStatus.index}]">
                            <openmrs:portlet url="addressLayout" id="addressPortlet${varStatus.index}" size="compact" parameters="layoutMode=view|layoutShowTable=true|layoutShowExtended=false" />
                        </spring:nestedPath>
                    </td>
                </c:if>
                <script type="text/javascript">
                    $j(document).ready(function () {
                        var hidden = ${fn:length(amrsRegistration.patient.addresses) <= 1};
                        var preferred = ${address.preferred};
                        var position = ${varStatus.index};
                        var nameContentX = $j('#addressPortlet' + position).find('table');
                        $j(nameContentX).attr('width', '100%');
                        createPreferred(preferred, 'address', position, nameContentX, hidden);
                        createDelete('address', position, nameContentX.find('tr:first'));

                        // bind all inputs
                        //var allTextInputs = $j('#addressContent' + position + ' input[type=text]');
                        //$j(allTextInputs).bind('keyup', function(event){
                        //    timeOutSearch(event);
                        //});
                    });
                </script>
			</c:forEach>
            </tbody>
        </table>
        <table >
            <tr>
                <td>
                    <div id="addressContent">
                        <spring:nestedPath path="emptyAddress">
                            <openmrs:portlet url="addressLayout" id="addressPortlet" size="full" parameters="layoutMode=edit|layoutShowTable=true|layoutShowExtended=false" />
                        </spring:nestedPath>
                        <script type="text/javascript">
                            // bind all inputs
                            var allTextInputs = $j('#addressPortlet input[type=text]');
                            $j(allTextInputs).bind('keyup', function(event){
                                timeOutSearch(event);
                            });
                        </script>
                    </div>
                </td>
            </tr>
		</table>
        <div id="addressPositionClear" style="clear:both"></div>
	    <div class="tabBar" id="addressTabBar">
			<span id="addressError" class="newError"></span>
	        <input type="button" onClick="return addNew('address');" class="addNew" id="address" value="Add New Address"/>
	    </div>
<!-- End of Patient Address Section -->
	
			</td>
		</tr>
		<c:if test="${displayAttributes}">
		<tr>
			<th class="header footer">Attributes</th>
			<td class="input footer">
    
<!-- Patient Attributes Section -->
    	<table>
			<spring:nestedPath path="amrsRegistration.patient">
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
		</c:if>
		<tr>
			<th class="header footer">Relationship(s)</th>
			<td class="input footer">
<!-- Relationship Section -->
		<table>
			<c:forEach var="relationship" items="${amrsRegistration.relationships}" varStatus="varStatus">
			<tr id="relationshipContent${varStatus.index}">
				<td id="patientName" style="white-space:nowrap;">
					<c:choose>
						<c:when test="${not empty fn:trim(amrsRegistration.patient.personName)}">
							${amrsRegistration.patient.personName}'s
						</c:when>
						<c:otherwise>
							This patient's
						</c:otherwise>
					</c:choose>
				</td>
				<td style="white-space:nowrap;">
					<openmrs:forEachRecord name="relationshipType">
						<c:if test="${record == relationship.relationshipType}">
							<c:choose>
								<c:when test="${amrsRegistration.patient.personName == relationship.personA.personName}">
									${record.aIsToB}
								</c:when>
								<c:otherwise>
									${record.bIsToA}
								</c:otherwise>
							</c:choose>
						</c:if>
					</openmrs:forEachRecord>
				</td>
				<td style="white-space:nowrap;">
					is
				</td>
				<td style="white-space:nowrap;">
					<c:choose>
						<c:when test="${amrsRegistration.patient.personName == relationship.personA.personName}">
							${relationship.personB.personName}
						</c:when>
						<c:otherwise>
							${relationship.personA.personName}
						</c:otherwise>
					</c:choose>
				</td>
				<td width="80%">&nbsp;</td>
				<td>&nbsp;</td>
				<td style="white-space:nowrap;">
					<input type="hidden" name="commandRelationship" value="${relationship.relationshipId}|${relationship.relationshipType}|${relationship.personA.personName}|${relationship.personB.personName}" />
					<input type="button" value="Remove" class="addNew removeRelationship" onclick="return deleteRelationship(this);"/>
				</td>
			</tr>
			</c:forEach>
			<tbody id="relationshipPosition" />
		</table>
		<spring:nestedPath path="emptyRelationship">
			<table style="display: none;">
				<%@ include file="portlets/patientRelationship.jsp" %>
			</table>
		</spring:nestedPath>
		<div class="tabBar" id="relationshipTabBar">
			<span id="relationshipError" class="newError"></span>
			<input type="button" onclick="return addNewRelationship();" class="addNew" value="Add New Relationship"/>
		</div>
		<script type="text/javascript">
			function addNewRelationship() {
				// only allow creating a new relationship when user is finish with searching or creating new person
				if ($j('#personSearchResult').is(':hidden') && $j('#createRelationshipPerson').is(':hidden')) {
					// each person will have the relationship content, the search result and the create person stub area
					
					// relationship content: id --> relationshipContent<row> --> relationshipContent1, relationshipContent2
					var clone = $j('#relationshipContent').clone(true);
					$j(clone).attr('id', 'relationshipContent' + relationshipCounter);
					$j('#relationshipPosition').append(clone);
					// person search result: class --> relationshipSearchResult1, relationshipSearchResult2
					// each relationship will have multiple relationshipSearchResult row will the same class
					// relationshipContent1 --> relationshipSearchResult1, relationshipSearchResult1, ... relationshipSearchResult1
					clone = $j('#personSearchResult').clone(true);
					$j(clone).attr('id', 'personSearchResult' + relationshipCounter);
					$j('#relationshipPosition').append(clone);
					// create person: id --> createRelationshipPerson<row> --> createRelationshipPerson1, createRelationshipPerson2
					clone = $j('#createRelationshipPerson').clone(true);
					$j(clone).attr('id', 'createRelationshipPerson' + relationshipCounter);
					$j('#relationshipPosition').append(clone);
	
					relationshipCounter = relationshipCounter + 1;
				} else {
					$j('#relationshipError').html('Please finish searching or creating the person before adding new relationship');
				}
			}

			// function to save hidden the new person in the relationship section
			function saveHiddenPerson(personId, givenName, middleName, familyName, age, gender, birthdate, position) {
				// get the row position
				var id = '#relationshipContent' + position;
				// set all the hidden value
				$j(id + ' input[type=hidden][name=relationshipPersonId]').attr('value', personId);
				$j(id + ' input[type=hidden][name=relationshipGivenName]').attr('value', givenName);
				$j(id + ' input[type=hidden][name=relationshipMiddleName]').attr('value', middleName);
				$j(id + ' input[type=hidden][name=relationshipFamilyName]').attr('value', familyName);
				$j(id + ' input[type=hidden][name=relationshipAge]').attr('value', age);
				$j(id + ' input[type=hidden][name=relationshipGender]').attr('value', gender);
				$j(id + ' input[type=hidden][name=relationshipBirthdate]').attr('value', birthdate);

				// display the person full name in the text field
				var personName = "";
				if (givenName!= null && givenName.length > 0)
					personName = personName + givenName + ' ';
				if (middleName != null && middleName.length > 0)
					personName = personName + middleName + ' ';
				if (familyName != null && familyName.length > 0)
					personName = personName + familyName;
				$j(id + ' input[type=text]').attr('value', personName);
			}
			
			$j(document).ready(function () {

				// function that will be run when the cancel button on the create person stub is clicked
				// this function will hide the create person stub and show the person search result
				// in this case, there's no search result, so the create person stub link will be shown again 
				$j('.showHideCreatePerson').click(function() {
					// get the row where the create person stub is located
					var divParent = $j(this).parents('div');
					var containerPositionId = $j(divParent).parent().parent().attr('id');
					var position = containerPositionId.substring('createRelationshipPerson'.length);
					// toggle search result and create person when the cancel in the create person is pressed
					$j('.personSearchResult' + position).toggle();
					$j('#createRelationshipPerson' + position).toggle();
				});

				// function that will be run when the create person button in the create person stub area is clicked
				// the function will store all the person stub details inside the hidden field. the hidden field then
				// will be processed by the controller.
				$j('.createNewPerson').click(function() {
					// get the row where the create person stub is located
					var divParent = $j(this).parents('div');
					var containerPositionId = $j(divParent).parent().parent().attr('id');
					var position = containerPositionId.substring('createRelationshipPerson'.length);

					// get all the data for the person stub
					var givenName = $j('#createRelationshipPerson' + position + ' input[type=text][name=rGivenName]').attr('value');
					var middleName = $j('#createRelationshipPerson' + position + ' input[type=text][name=rMiddleName]').attr('value');
					var familyName = $j('#createRelationshipPerson' + position + ' input[type=text][name=rFamilyName]').attr('value');
					var age = $j('#createRelationshipPerson' + position + ' input[type=text][name=rAge]').attr('value');
					var gender = $j('#createRelationshipPerson' + position + ' input[type=radio][name=rGender]').attr('value');
					var birthdate = $j('#createRelationshipPerson' + position + ' input[type=text][name=rDate]').attr('value');
					saveHiddenPerson('N/A', givenName, middleName, familyName, age, gender, birthdate, position);

					// hide the create person stub area
					$j('#createRelationshipPerson' + position).hide();
				});
				
			});

			// delete a relationship
			function deleteRelationship(element) {
				// get the row position of the deleted row
				var removedElement = $j(element).parent().parent();
				var containerPositionId = $j(removedElement).attr('id');
				var position = containerPositionId.substring('relationshipContent'.length);
				// hide search result and create person
				$j('.personSearchResult' + position).hide();
				$j('#createRelationshipPerson' + position).hide();

				// hide all error message
				$j('#relationshipError').html('');
				$j('#relationshipContent' + position).remove();
			}

			// toggle function to show which person to be shown to the user
			// which person to be shown depends on the type of the relationship
			// when an aIsToB type is shown then the current patient is the person B in the relationship
			// when a bIsToA type is shown then the current patient is the person A in the relationship
			function showActivePerson(element) {
				// get the row position where the changes is coming from (select onchange event)
				var row = $j(element).parent().parent();
				var rowId = $j(row).attr('id');
				var position = rowId.substring('relationshipContent'.length);
				// logic to determince which of the field to be shown personA or personB
				var selected = $j('#relationshipContent' + position).find('select[name=relationshipTypeId] option:selected');
				var hidden = $j(row).find('td[class=personB]');
				var show = $j(row).find('td[class=personA]');
				if ($j(selected).attr('class') == 'aIsToB') {
					hidden = $j(row).find('td[class=personA]');
					show = $j(row).find('td[class=personB]');
				}

				$j(hidden).toggle();
				$j(show).toggle();
			}

			// timeout search variable
			var relationshipTimeoutSearch;
			// row position of the search originated
			var handlerPosition;

			// function to search for a person based on the name typed in to the relationship text field
			function searchPersonWithTimeout(e, element) {
				c = e.keyCode;

				// get the row position from which the search is originated
				// get the id of the row --> tr --> td --> textfield (where the search is coming from)
				var containerPositionId = $j(element).parent().parent().attr('id');
				handlerPosition = containerPositionId.substring('relationshipContent'.length);
				
				if (isAlphaNumericCharacter(c) || isDashCharacter(c) || isBackspaceDelete(c)) {
					clearTimeout(relationshipTimeoutSearch);
					relationshipTimeoutSearch = setTimeout("searchPerson(\"" + element.value + "\")", 1000);
				}
			}

			function searchPerson(value) {
				DWRAmrsRegistrationService.findPerson(value, handlePersonResult);
			}

			// function to handle the search result when you type a person name in the relationship part
			function handlePersonResult(persons) {
				// global var: handlerPosition: row of the relationship.
				// each row of the relationship will have a separate search and create person area
				// so, this var will help us to make sure that we're working on the correct search or create person area
				// convention: each row will have in search result will have --> personSearchResult<ROWNUM> class
				// search result for the second relationship will have --> personSearchResult2 class
				
				// get the location where the search result will be appended
				var tbody = $j('#personSearchResult' + handlerPosition);
				// remove all previous search result from the list
				$j('.personSearchResult' + handlerPosition).remove();

				// if there's no search result, display a link to create a new person stub
				if (persons.length == 0) {
					// create a new row and assign the class name
	    			var tr = $j(document.createElement('tr'));
	    			$j(tr).addClass('personSearchResult' + handlerPosition);
	    			// create a column where we will put the anchor link
	    			var td = $j(document.createElement('td'));
	    			$j(td).attr('colspan', '6');

	    			// create the anchor tag
	    			var anchor = $j(document.createElement('a'));
	    			$j(anchor).attr('href', '#');
	    			$j(anchor).html('Create New Person');
	    			$j(anchor).click(function(e) {
		    			// when you click the create person link, show the create person stub area
						e.preventDefault();
						// get the row position from the tr tag. the hierarchy is tr --> td --> a
						var containerPositionId = $j(this).parent().parent().attr('class');
						var position = containerPositionId.substring('personSearchResult'.length);
						// hide the row
						$j('.personSearchResult' + position).toggle();
						// show create person stub area
						$j('#createRelationshipPerson' + position).toggle();
		    		});

	    			$(td).append(anchor);
	    			$(tr).append(td);
	    			$(tbody).after(tr);
				}
	    		
	    		// loop through all result and display it
	    		for(i = 0; i < persons.length; i ++) {
	    			// create new row
	    			var tr = $j(document.createElement('tr'));
	    			// zebra like row
	    			if (i % 2 == 0)
	    				$j(tr).addClass("evenRow");
	    			else
	    				$j(tr).addClass("oddRow");

	    			// add marker that this row is a person search result row
    				$j(tr).addClass('personSearchResult' + handlerPosition);
	    			
	    			// bind highlight effect
	    			$j(tr).hover(
	    				function() {
							$j(this).addClass("searchHighlight");
	    				},
	    				function() {
							$j(this).removeClass("searchHighlight");
	    				}
	    			);
	    			
	    			// create each cell for given, middle, family name, age
	    			createCell(persons[i].personName.givenName, tr);
	    			createCell(persons[i].personName.middleName, tr);
	    			createCell(persons[i].personName.familyName, tr);
	    			createCell(persons[i].age, tr);

	    			// create person id hidden input
	    			var td = $j(document.createElement('td'));
	    			
	    			var input = $j(document.createElement('input'));
	    			$j(input).attr('type', 'hidden');
	    			$j(input).attr('name', 'hiddenId' + i);
	    			$j(input).attr('value', persons[i].personId);
	    			$j(tr).append($j(input));

	    			// create the gender column
	    			$j(td).css('text-align', 'center');
	    			var data = $j(document.createElement('img'));
	    			if (persons[i].gender == 'F')
	    				$j(data).attr('src', "${pageContext.request.contextPath}/images/female.gif");
	    			else
	    				$j(data).attr('src', "${pageContext.request.contextPath}/images/male.gif");
	    			$j(td).append($j(data));
	    			$j(tr).append($j(td));

	    			// create the birthdate column
	    			createCell(parseDate(persons[i].birthdate, '<openmrs:datePattern />'), tr);

	    			// when a row is selected, assign the person name to the text field and then store the value
	    			// in the hidden field. the hidden field will be processed by the controller
	    			$j(tr).click(function() {
		    			// get child element of this tr that is an input (for personId)
						var children = $j(this).children(':input');
						var personId = jQuery.trim($j(children).attr('value'));

						// other element are stored under td
						// 1 => given name
						// 2 => middle name
						// 3 => family name
						// 4 => age
						// 5 => gender --> need some processing since it's actually an image
						// 7 => birthdate
						var givenName = $j(this).children('td:eq(0)').html();
						var middleName = $j(this).children('td:eq(1').html();
						var familyName = $j(this).children('td:eq(2)').html();
						var age = $j(this).children('td:eq(3)').html();

						var genderImageLoc = $j(this).children('td:eq(4)').children().attr('src');
						var gender = 'F';
						if (genderImageLoc.match('male')) {
							gender = 'M';
						}
						
						var birthdate = $j(this).children('td:eq(6)').html();

						// get the row position of this tr from the class attribute
						// format of the class will be: "[odd|even] personSearchResult<row> searchHighlight"
						// so, we need to substring until personSearchResult
						// and then substring again until the first white-space
						var cssClass = $j(this).attr('class');
						var subLength = cssClass.indexOf('personSearchResult') + 'personSearchResult'.length;
						var cssClassHighlight = cssClass.substring(subLength);
						var position = cssClassHighlight.substring(0, cssClassHighlight.indexOf(' '));
						// save the value to the hidden field
						saveHiddenPerson(personId, givenName, middleName, familyName, age, gender, birthdate, position);
						// dismiss the search result
						$j('.personSearchResult' + position).remove();
	    			});
	    			$j(tbody).after($j(tr));
	    		}
			}
		</script>
<!-- End of Relationship Section -->
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

    changeNameHeaderHack();
</script>

<%@ include file="/WEB-INF/template/footer.jsp" %>
