<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/start.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/interface/DWRAmrsRegistrationService.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/engine.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/util.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />

<script type="text/javascript">

    // Number of objects stored.  Needed for 'add new' purposes.
    // starts at -1 due to the extra 'blank' data div in the *Boxes dib
    var numObjs = new Array();
    numObjs["identifier"] = 0;
    numObjs["name"] = 0;
    numObjs["address"] = 0;
    
	searchTimeout = null;
	searchDelay = 1000;
    
    var attributes = null;
	
	// Jquery part for the modal dialog
	// modification script from queness.com
	$j = jQuery.noConflict();
	$j(document).ready(function() {
		
		//if close button is clicked
		$j('#clear').click(function (e) {
			//Cancel the link behavior
			e.preventDefault();
			
			$j('#mask').hide();
			$j('.window').hide();
		});
		
		//if mask is clicked
		$j('#mask').click(function () {
			$j(this).hide();
			$j('.window').hide();
		});
		
		$j(window).bind('resize', function() {
			//Get the screen height and width
			var maskHeight = $j(document).height();
			var maskWidth = $j(window).width();
			 
			//Set heigth and width to mask to fill up the whole screen
			$j('#mask').css({'width':maskWidth,'height':maskHeight});
			
			//Get the window height and width
			var winH = $j(window).height();
			var winW = $j(window).width();
			
			var id = "#dialog";
			
			//Set the popup window to center
			$j(id).css('top',  winH/2-(($j(id).height()/4) * 3));
			$j(id).css('left', winW/2-(($j(id).width()/4) * 3));
		});
		
	});
	
	function parseDate(d) {
		var str = '';
		if (d != null) {
			
			// get the month, day, year values
			var month = "";
			var day = "";
			var year = "";
			var date = d.getDate();
			
			if (date < 10)
				day += "0";
			day += date;
			var m = d.getMonth() + 1;
			if (m < 10)
				month += "0";
			month += m;
			if (d.getYear() < 1900)
				year = (d.getYear() + 1900);
			else
				year = d.getYear();
		
			var datePattern = '<openmrs:datePattern />';
			var sep = datePattern.substr(2,1);
			var datePatternStart = datePattern.substr(0,1).toLowerCase();
			
			if (datePatternStart == 'm') /* M-D-Y */
				str = month + sep + day + sep + year
			else if (datePatternStart == 'y') /* Y-M-D */
				str = year + sep + month + sep + day
			else /* (datePatternStart == 'd') D-M-Y */
				str = day + sep + month + sep + year
			
		}
		return str;
	}
	
	function cancel() {
		$j('#mask').hide();
		$j('.window').hide();
	}
	
	function replaceNull(nullInput) {
		if (nullInput == null)
			return "";
		else
			return nullInput
	}
	
    function renderPatientData(patient) {
    	// better using this one or using dom?
    	var content = '<table>';
    	    // name section
    	    content = content + '<tr><th>Name:</th>';
    	    var names = patient.names;
    	    for(i=0; i<names.length; i++) {
    	        var name = i + '. ' + replaceNull(names[i].prefix) + ' ' + replaceNull(names[i].givenName) + ' ';
    	            name = name + replaceNull(names[i].middleName) + ' ' + replaceNull(names[i].familyNamePrefix) + ' ';
    	            name = name + replaceNull(names[i].familyName) + ' ' + replaceNull(names[i].familyName2) + ' ';
	    			name = name + replaceNull(names[i].familyNameSuffix) + ' ' + replaceNull(names[i].degree);
    	        content = content + '<td>&nbsp</td>';
    	        content = content + '<td colspan="2">'+ name +'<td>';
    	        content = content + '</tr><tr><th>&nbsp</th>';
    	    }
    	    content = content + '<td>&nbsp</td><td>&nbsp</td><td>&nbsp</td></tr>';
    	    // birthday section
    	    content = content + '<tr><th>Birthdate:</th><td>&nbsp</td><td colspan="2">' + parseDate(patient.birthdate) + '</td></tr>';
    	    // gender section
    	    content = content + '<tr><th>Gender:</th><td>&nbsp</td><td colspan="2">' + patient.gender + '</td></tr>';
    	    // address section
    	    content = content + '<tr><th>Address:</th>';
    	    var addresses = patient.addresses;
    	    for(i=0; i<addresses.length; i++) {
    	    	var address = i + '. ' + replaceNull(addresses[i].address1) + ' ' + replaceNull(addresses[i].address2) + ' ' + replaceNull(addresses[i].neighborhoodCell) + '<br />';
	    			address = address + replaceNull(addresses[i].cityVillage) + ' ' + replaceNull(addresses[i].townshipDivision) + ' ' + replaceNull(addresses[i].countyDistrict) + '<br />';
	    			address = address + replaceNull(addresses[i].region) + ' ' + replaceNull(addresses[i].subregion) + '<br />';
	    			address = address + replaceNull(addresses[i].stateProvince) + ' ' + replaceNull(addresses[i].country) + ' ' + replaceNull(addresses[i].postalCode);
    	        content = content + '<td>&nbsp</td>';
    	        content = content + '<td colspan="2">'+ address +'<td>';
    	        content = content + '</td></tr><tr><th>&nbsp</th>';
    	    }
    	    
    	    // attributes section
    	
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
		
		// fancy stuff to create modal dialog
		
		//Get the window height and width
		var winH = $j(window).height();
		var winW = $j(window).width();
		
		var id = "#dialog";
		
		//Set the popup window to center
		$j(id).css('top',  winH/2-(($j(id).height()/4) * 3));
		$j(id).css('left', winW/2-(($j(id).width()/4) * 3));
		
		//transition effect
		$j(id).fadeIn(1000);
		
		//Get the screen height and width
		var maskHeight = $j(document).height();
		var maskWidth = $j(window).width();
		
		//Set heigth and width to mask to fill up the whole screen
		$j('#mask').css({'width':maskWidth,'height':maskHeight});
		
		//transition effect		
		$j('#mask').fadeIn(500);	
		$j('#mask').fadeTo("slow",0.8);
    }
    
    function getPatientByIdentifier(identifier) {
    	DWRAmrsRegistrationService.getPatientByIdentifier(identifier, renderPatientData);
    }
    
    function hidDiv() {
		floating = document.getElementById("floating");
		floating.style.display = "none";
    }
    
    function updateData(identifier) {
    	$j(document.forms[0].reset());
    	// $j(':submit[name!=_cancel]').attr("name", "_target1");
    	
    	var hiddenInput = $j(document.createElement("input"));
    	hiddenInput.attr("type", "hidden");
    	hiddenInput.attr("name", "idCardInput");
    	hiddenInput.attr("id", "idCardInput");
    	hiddenInput.attr("value", identifier);
    	$j('#pIds').append(hiddenInput);
    	
    	$j(document.forms[0].submit());
    }

    function addNew(type) {
        var newData = document.getElementById(type + "Data");
        if (newData != null) {
            var dataClone = newData.cloneNode(true);
            dataClone.id = type + numObjs[type] + "Data";
            dataClone.style.display = "";
            parent = newData.parentNode;
            parent.insertBefore(dataClone, newData);

            numObjs[type] = numObjs[type] + 1;
        }
    }
    
    function createColumn(tr, value) {
    	var td = document.createElement("td");
    	tr.appendChild(td);
    	
    	var input = document.createElement("input");
    	input.type = "text";
    	input.value = value;
    	
    	td.appendChild(input);
    }

    function handlePatientResult(result) {
        if (result.length > 0) {
            
            var tbody = document.getElementById("resultTable");
            var childNodes = tbody.childNodes;
            for (i=childNodes.length - 1; i >= 0; i --) {
            	e = childNodes.item(i);
            	tbody.removeChild(e);
            }
            
            for (i=0; i < result.length; i ++) {
            	var tr = document.createElement("tr");
            	tbody.appendChild(tr);
            	
            	createColumn(tr, result[i].identifiers[0].identifier);
            	createColumn(tr, result[i].personName.givenName);
            	createColumn(tr, result[i].personName.familyName);
            	createColumn(tr, parseDate(result[i].birthdate));
            	createColumn(tr, result[i].gender);
            	
            	// create link to get patient data and apply it to the page
            	var td = document.createElement("td");
            	tr.appendChild(td);
            	var anchor = document.createElement("a");
            	anchor.innerHTML="Use Data";
				anchor.href="javascript: getPatientByIdentifier(\'" + result[i].identifiers[0].identifier + "\')";
            	td.appendChild(anchor);
            }
            document.getElementById("floating").style.display = "block";
        } else {
            document.getElementById("floating").style.display = "none";
        }
    }
	
	function removeBlankData() {
		var obj = document.getElementById("identifierData");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("nameData");
		if (obj != null)
			obj.parentNode.removeChild(obj);
		obj = document.getElementById("addressData");
		if (obj != null)
			obj.parentNode.removeChild(obj);
	}
	
	function timeOutSearch(thing) {
		clearTimeout(searchTimeout);
		searchTimeout = setTimeout("patientSearch(\'thing\')", searchDelay);
	}

    function patientSearch(thing) {
        var gName = document.getElementById("names[0].givenName");
        var mName = document.getElementById("names[0].middleName");
        var fNamePrefix = document.getElementById("names[0].familyNamePrefix");
        var fName = document.getElementById("names[0].familyName");
        var fName2 = document.getElementById("names[0].familyName2");
        var fNameSuffix = document.getElementById("names[0].familyNameSuffix");
        var deg = document.getElementById("names[0].degree");
        var pref = document.getElementById("names[0].prefix");
        var prefName = document.getElementById("names[0].preferred");

        var personName = {
        	preferred: prefName.checked,
        	prefix: pref.value,
        	givenName: gName.value,
        	middleName: mName.value,
        	familyNamePrefix: fNamePrefix.value,
        	familyName: fName.value,
        	familyName2: fName2.value,
        	familyNameSuffix: fNameSuffix.value,
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
        var prefAdd = document.getElementById("addresses[0].preferred");
        
        var personAddress = {
        	preferred: prefAdd.checked,
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
        var preferredId = document.getElementById("identifiers[0].identifier.preferred");
        
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
        
        DWRAmrsRegistrationService.getPatients(personName, personAddress, attributes, null, null, null, handlePatientResult);
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
		var inputs = document.getElementsByName("input");
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

    #floating {
    	background-color: #ffffff;
    	top: 50px;
    	right: 50px;
        position: fixed;
        border: 1px double black;
    	font-size: 11px;
    }

    .tabBoxes {
        padding: 3px;
    }

    .addNew {
        margin-right: 10px;
        font-size: 10px;
        float: right;
        cursor: pointer;
    }

    .close {
        right: 5px;
        top: 5px;
        font-size: 10px;
        cursor: pointer;
    }
    
    #mask {
        position:absolute;
        left:0;
        top:0;
        z-index:9000;
        background-color:#000;
        display:none;
    }

    #boxes .window {
    	font-size: 11px;
        position:absolute;
        left:0;
        top:0;
        display:none;
        z-index:9999;
        padding:20px;
    }

    #boxes #dialog {
    	font-size: 11px;
        padding:10px;
        background-color:#ffffff;
    }
    
    #main {
    	position: relative;
    }

</style>

<div id="mask"></div>
<div id="main">

<h2><spring:message code="amrsregistration.edit.start"/></h2>
<span><spring:message code="amrsregistration.edit.details"/></span>
<br/>

<spring:hasBindErrors name="patient">
	<c:forEach items="${errors.allErrors}" var="error">
		<br />
		<span class="error"><spring:message code="${error.code}"/></span>
	</c:forEach>
</spring:hasBindErrors>
<form id="patientForm" method="post" onSubmit="removeBlankData()">
	<div id="floating" style="display: none;">
	    <div>
	        <table border="0" cellspacing="2" cellpadding="2">
	            <tr>
	            	<th>Identifier</th>
	            	<th>First Name</th>
	            	<th>Last Name</th>
	            	<th>Gender</th>
	            	<th>DOB</th>
	            	<th>Action</th>
	            </tr>
	            <tbody id="resultTable"></tbody>
	            <tr>
	            	<td>
	            		<span class="close"><a href="javascript:;" onclick="hidDiv()">close</a></span>
	            	</td>
	            <tr>
	        </table>
	    </div>
	</div>
	<br/>
	
	<div id="boxes"> 
		<div id="dialog" class="window">
			Patient Data |
			<a href="#" id="clear">Close</a>
			<div id="personContent"></div>
		</div>
	</div>

    <h3><spring:message code="Patient.names"/></h3>
    <div id="pNames">
        <div class="tabBoxes" id="nameDataBoxes">
            <c:forEach var="name" items="${patient.names}" varStatus="varStatus">
                <spring:nestedPath path="patient.names[${varStatus.index}]">
                    <div id="name${varStatus.index}Data" class="tabBox">
                        <%@ include file="portlets/patientName.jsp" %>
                    </div>
                </spring:nestedPath>
            </c:forEach>
        </div>
        <div id="nameData" class="tabBoxes" style="display:none">
            <spring:nestedPath path="emptyName">
                <%@ include file="portlets/patientName.jsp" %>
            </spring:nestedPath>
        </div>
        <div class="tabBar" id="pNmTabBar">
            <input type="button" onClick="return addNew('name');" class="addNew" id="name" value="Add New Name"/>
        </div>
    </div>
    <br style="clear: both"/>
    
    <h3><spring:message code="Patient.information"/></h3>
    <div class="tabBoxes">
	    <b class="boxHeader"><spring:message code="amrsregistration.edit.information"/></b>
	    <div class="box">
	    	<table>
				<spring:nestedPath path="patient">
					<c:if test="${empty INCLUDE_PERSON_GENDER || (INCLUDE_PERSON_GENDER == 'true')}">
						<tr>
							<td><spring:message code="Person.gender"/></td>
							<td><spring:bind path="patient.gender">
									<openmrs:forEachRecord name="gender">
										<input type="radio" name="gender" id="${record.key}" value="${record.key}" <c:if test="${record.key == status.value}">checked</c:if> />
											<label for="${record.key}"> <spring:message code="Person.gender.${record.value}"/> </label>
									</openmrs:forEachRecord>
								</spring:bind>
							</td>
						</tr>
					</c:if>
					<c:choose>
						<c:when test="${patient.birthdate == null}">
							<tr>
								<td>
									<spring:message code="Person.birthdate"/><br/>
									<i style="font-weight: normal; font-size: .8em;">(<spring:message code="general.format"/>: <openmrs:datePattern />)</i>
								</td>
								<td valign="top">
									<input type="text" name="birthdate" id="birthdate" size="11" value="" onClick="showCalendar(this)" />
									<spring:message code="Person.age.or"/>
									<input type="text" name="age" id="age" size="5" value="" />
								</td>
							</tr>
						</c:when>
						<c:otherwise>
							<tr>
								<td>
									<spring:message code="Person.birthdate"/><br/>
									<i style="font-weight: normal; font-size: .8em;">(<spring:message code="general.format"/>: <openmrs:datePattern />)</i>
								</td>
								<td>
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
												onChange="updateAge(); updateEstimated(this);"
												onClick="showCalendar(this)" />
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
							</tr>
						</c:otherwise>
					</c:choose>
				</spring:nestedPath>
			</table>
		</div>
	</div>
    <br style="clear: both"/>

    <h3><spring:message code="Patient.addresses"/></h3>
    <div id="pAddresses">
        <div class="tabBoxes" id="addressDataBoxes">
            <c:forEach var="address" items="${patient.addresses}" varStatus="varStatus">
                <spring:nestedPath path="patient.addresses[${varStatus.index}]">
                    <div id="address${varStatus.index}Data" class="tabBox">
                        <%@ include file="portlets/patientAddress.jsp" %>
                    </div>
                </spring:nestedPath>
            </c:forEach>
        </div>
        <div id="addressData" class="tabBoxes" style="display:none">
            <spring:nestedPath path="emptyAddress">
                <%@ include file="portlets/patientAddress.jsp" %>
            </spring:nestedPath>
        </div>
        <div class="tabBar" id="pAdTabBar">
            <input type="button" onClick="return addNew('address');" class="addNew" id="address"
                   value="Add New Addresses"/>
        </div>
    </div>
    <br style="clear: both"/>
    
    <h3><spring:message code="Patient.attributes"/></h3>
    <div class="tabBoxes">
	    <b class="boxHeader"><spring:message code="amrsregistration.edit.information"/></b>
	    <div class="box">
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
		</div>
	</div>
    <br style="clear: both"/>

    <h3><spring:message code="Patient.identifiers"/></h3>
    <div id="pIds">
        <div class="tabBoxes" id="identifierDataBoxes">
            <c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
                <spring:nestedPath path="patient.identifiers[${varStatus.index}]">
                    <div id="identifier${varStatus.index}Data" class="tabBox">
                    	<c:if test="${amrsIdType != identifier.identifierType.name}">
                    		<%@ include file="portlets/patientIdentifier.jsp" %>
                    	</c:if>
                    </div>
                </spring:nestedPath>
            </c:forEach>
        </div>
        <div id="identifierData" class="tabBoxes" style="display:none">
            <spring:nestedPath path="emptyIdentifier">
                <%@ include file="portlets/patientIdentifier.jsp" %>
            </spring:nestedPath>
        </div>
        <div class="tabBar" id="pIdTabBar">
            <input type="button" onClick="return addNew('identifier');" class="addNew" id="identifier"
                   value="Add New Identifier"/>
        </div>
    </div>
    <br style="clear: both"/>

    <br/>
    <input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
    &nbsp; &nbsp;
    <input type="submit" name="_target2" value="<spring:message code='amrsregistration.button.save'/>">
</form>
<br/>

<br/>
</div>

<%@ include file="/WEB-INF/template/footer.jsp" %>
