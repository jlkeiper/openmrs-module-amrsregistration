<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/admin/amrsregistration/start.form"/>

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/interface/DWRRemoteRegistrationService.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/engine.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/util.js"></openmrs:htmlInclude>

<script type="text/javascript">

    // Number of objects stored.  Needed for 'add new' purposes.
    // starts at -1 due to the extra 'blank' data div in the *Boxes dib
    var numObjs = new Array();
    numObjs["identifier"] = -1;
    numObjs["name"] = -1;
    numObjs["address"] = -1;

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

        if (result != null) {
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

    function patientSearch(thing) {
        var fName = document.getElementById("familyName");
        if (fName.value.length < 3) {
            return;
        }

        var mName = document.getElementById("middleName");

        var gName = document.getElementById("givenName");
        if (gName.value.length < 3) {
            return;
        }

        var name = {
            familyName:fName.value,
            givenName:gName.value
        }

        DWRRemoteRegistrationService.getPatients(name, null, null, null, null, null, handlePatientResult);
    }
</script>
<style>
    .staticElement {
        margin-left: 35%;
        width: 50%;
        position: fixed;
        float: right;
        top: 15%;
    }

    .tabBoxes {
        width: 80%;
        padding: 3px;
    }

    .addNew {
        margin-right: 20%;
        font-size: 10px;
        float: right;
        cursor: pointer;
    }

</style>

<h2><spring:message code="amrsregistration.edit.title"/></h2>
<span><spring:message code="amrsregistration.edit.details"/></span>
<br/>

<div id="floatingResult" class="staticElement" style="display:none">
    <br/>
    <b class="boxHeader"><spring:message code="amrsregistration.edit.results"/></b>

    <div class="box">
        <table border="0" cellspacing="2" cellpadding="2">
            <tr>
            	<th>Identifier</th>
            	<th>First Name</th>
            	<th>Last Name</th>
            	<th>DOB</th>
            </tr>
            <tbody id="resultTable"></tbody>
        </table>
    </div>
</div>
<br/>

<form id="identifierForm" method="post">

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
    &nbsp;
    <h3><spring:message code="Patient.information"/></h3>

    <div class="tabBox" id="pInformationBox">
        <div class="tabBoxes">
            <table>
                <spring:nestedPath path="patient">
                    test
                </spring:nestedPath>
            </table>
        </div>
    </div>

    <br/>
    &nbsp;
    <input type="submit" name="_cancel" value="<spring:message code='general.cancel'/>">
    &nbsp; &nbsp;
    <input type="submit" name="_target2" value="<spring:message code='general.submit'/>">
</form>
<br/>

<br/>

<%@ include file="/WEB-INF/template/footer.jsp" %>
