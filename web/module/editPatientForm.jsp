<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/admin/amrsregistration/start.form"/>

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/interface/DWRAmrsRegistrationService.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/engine.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/util.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />

<script type="text/javascript">

    // Number of objects stored.  Needed for 'add new' purposes.
    // starts at -1 due to the extra 'blank' data div in the *Boxes dib
    var numObjs = new Array();
    numObjs["identifier"] = -1;
    numObjs["name"] = -1;
    numObjs["address"] = -1;
    
    var attributes = null;
    
    function hidDiv() {
		floating = document.getElementById("floatingResult");
		floating.style.display = "none";
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
    
    function handleSetResult(result) {
        alert(result[0].patientId + ", " + result[0].identifier);
        var tmpResult = document.getElementById("tmpResult");
        tmpResult.value = result[1].identifier;
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
            floating = document.getElementById("floatingResult");
            floating.style.display = "";
            
            var tbody = document.getElementById("resultTable");
            for (i=0; i<tbody.childNodes.length; i ++) {
            	tbody.removeChild();
            }
            
            for (i=0; i < result.length; i ++) {
            	var tr = document.createElement("tr");
            	tbody.appendChild(tr);
            	
            	createColumn(tr, result[0].identifiers[0].identifier);
            	createColumn(tr, result[0].personName.givenName);
            	createColumn(tr, result[0].personName.familyName);
            	createColumn(tr, result[0].birthdate);
            }
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

    function patientSearch(thing) {
        var gName = document.getElementById("givenName_0");
        var mName = document.getElementById("middleName_0");
        var fNamePrefix = document.getElementById("familyNamePrefix_0");
        var fName = document.getElementById("familyName_0");
        var fName2 = document.getElementById("familyName2_0");
        var fNameSuffix = document.getElementById("familyNameSuffix_0");
        var deg = document.getElementById("degree_0");
        var pref = document.getElementById("prefix_0");
        var prefName = document.getElementById("personName.preferred_0");

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
        
        var add1 = document.getElementById("address1_0");
        var add2 = document.getElementById("address2_0");
        var cell = document.getElementById("neighborhoodCell_0");
        var city = document.getElementById("cityVillage_0");
        var township = document.getElementById("townshipDivision_0");
        var county = document.getElementById("countyDistrict_0");
        var state = document.getElementById("stateProvince_0");
        var reg = document.getElementById("region_0");
        var subreg = document.getElementById("subregion_0");
        var cntry = document.getElementById("country_0");
        var postCode = document.getElementById("postalCode_0");
        var prefAdd = document.getElementById("personAddress.preferred_0");
        
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
        
        var id = document.getElementById("identifier_0");
        var idType = document.getElementById("identifierType_0");
        var preferredId = document.getElementById("identifier.preferred_0");
        
        var patientIdentifier = {
        	identifier: id.value,
        	identifierType: idType.value
        }
        
        // convert to js date object before passing it to dwr
        var birthStr = DWRUtil.getValue("birthdate");
        var birthdate = null;
        // need to validate the date entered by user here
        if (birthStr != null && birthStr.length > 0)
        	birthdate = new Date(Date.parse(birthStr));
        
        // the id element of the gender turn out to be "M" and "F"
        var gender = null;
        var male = document.getElementById("M");
        var female = document.getElementById("F");
        if (male != null && male.checked) {
        	gender = "M";
        } else if (female != null && female.checked) {
        	gender = "F";
        }
        
        if (attributes == null) {
        	prepareAttributes();
        }
        
        for(i=0; i<attributes.length; i++) {
        	attributes[i].value = DWRUtil.getValue(attributes[i].attributeType.personAttributeTypeId).toString();
        }
        // alert("Attributes: " + DWRUtil.toDescriptiveString(attributes, 2));
        
        DWRAmrsRegistrationService.getPatients(personName, personAddress, attributes, gender, birthdate, null, handlePatientResult);
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
</script>
<style>
    .staticElement {
    	background-color: #ffffff;
        margin-left: 35%;
        position: fixed;
        float: right;
        top: 10%;
        border: 1px double black
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
        position:absolute;
        float: left;
        font-size: 10px;
        float: left;
        cursor: pointer;
    }

</style>

<h2><spring:message code="amrsregistration.edit.title"/></h2>
<span><spring:message code="amrsregistration.edit.details"/></span>
<br/>

<div id="floatingResult" class="staticElement" style="display: none;">
    <div>
        <table border="0" cellspacing="2" cellpadding="2">
            <tr>
            	<th>Identifier</th>
            	<th>First Name</th>
            	<th>Last Name</th>
            	<th>DOB</th>
            </tr>
            <tbody id="resultTable"></tbody>
        </table>
        <span class="close"><a href="javascript:;" onclick="hidDiv()">close</a></span>
    </div>
</div>
<br/>

<form id="identifierForm" method="post" onSubmit="removeBlankData()">

    <h3><spring:message code="Patient.identifiers"/></h3>
    <spring:hasBindErrors name="patient.identifiers">
        <span class="error">${error.errorMessage}</span><br/>
    </spring:hasBindErrors>
    <div id="pIds">
        <div class="tabBoxes" id="identifierDataBoxes">
            <c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
                <spring:nestedPath path="patient.identifiers[${varStatus.index}]">
                    <div id="identifier${varStatus.index}Data" class="tabBox">
                        <%@ include file="portlets/patientIdentifier.jsp" %>
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

    <h3><spring:message code="Patient.names"/></h3>
    <spring:hasBindErrors name="patient.names">
        <span class="error">${error.errorMessage}</span><br/>
    </spring:hasBindErrors>
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
        <div class="tabBar" id="pIdTabBar">
            <input type="button" onClick="return addNew('name');" class="addNew" id="name" value="Add New Name"/>
        </div>
    </div>
    <br style="clear: both"/>

    <h3><spring:message code="Patient.addresses"/></h3>
    <spring:hasBindErrors name="patient.addresses">
        <span class="error">${error.errorMessage}</span><br/>
    </spring:hasBindErrors>
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
        <div class="tabBar" id="pIdTabBar">
            <input type="button" onClick="return addNew('address');" class="addNew" id="address"
                   value="Add New Addresses"/>
        </div>
    </div>
    <br style="clear: both"/>
    
    <h3><spring:message code="Patient.information"/></h3>
    <spring:hasBindErrors name="patient">
        <span class="error">${error.errorMessage}</span><br/>
    </spring:hasBindErrors>
    <div class="tabBoxes">
	    <b class="boxHeader"><spring:message code="amrsregistration.edit.information"/></b>
	    <div class="box">
	    	<table>
				<spring:nestedPath path="patient">
					<%@ include file="portlets/personInfo.jsp" %>
				</spring:nestedPath>
			</table>
		</div>
	</div>

    <br/>
    <input type="submit" name="_cancel" value="<spring:message code='general.cancel'/>">
    &nbsp; &nbsp;
    <input type="submit" name="_target2" value="<spring:message code='general.submit'/>">
</form>
<br/>

<br/>

<%@ include file="/WEB-INF/template/footer.jsp" %>
