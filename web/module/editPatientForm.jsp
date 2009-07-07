<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/admin/amrsregistration/start.form" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" ></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/interface/DWRRemoteRegistrationService.js" ></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/engine.js" ></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/util.js" ></openmrs:htmlInclude>

<script type="text/javascript">
    function handleSetResult(result) {
        alert(result[0].patientId + ", " + result[0].identifier);
        var tmpResult = document.getElementById("tmpResult");
        tmpResult.value = result[1].identifier;
    }

    function handlePatientResult(result) {
        //alert(result);
        //alert(result[0].patientId + ", " + result[0].identifier);
        //document.getElementById("resultId").value = result[0].identifier;
        //document.getElementById("resultFname").value = result[0].familyName;
        //document.getElementById("resultGname").value = result[0].givenName;
        //document.getElementById("tmpResult").value = result[0].givenName;
        document.getElementById("resultId").value = result[0].identifiers[0].identifier;
        document.getElementById("resultFname").value = result[0].personName.familyName;
        document.getElementById("resultGname").value = result[0].personName.givenName;
        document.getElementById("tmpResult").value = result[0].personName.givenName;
    }

    function patientSearch(thing) {
        var fName = document.getElementById("familyName_0");
        var mName = document.getElementById("middleName_0");
        var gName = document.getElementById("givenName_0");
        var searchStr = fName;
        //alert("hi, " + fName.value);
        //DWRPatientService.findPatients(fName.value, false, handleSetResult);
        //DWRRemoteRegistrationService.sayHello(fName.value, function(str) { alert("Hi, " + str) });
        //DWRRemoteRegistrationService.getPersonName(fName.value, function(pname) {
        //    alert(pname.familyName + ", " + pname.givenName);
        //});
        var name = {
            familyName:fName.value,
            givenName:gName.value
        }
        //DWRRemoteRegistrationService.getPatients(name, null, null, null, null, null, function(str) {alert(str[0].personName.familyName);});
        //DWRRemoteRegistrationService.getPatients(name, null, null, null, null, null, function(str) {alert(str[0].personName.familyName);});
        DWRRemoteRegistrationService.getPatients(name, null, null, null, null, null, handlePatientResult);
    }
</script>

<h2><spring:message code="amrsregistration.edit.title"/></h2>
<span><spring:message code="amrsregistration.edit.details"/></span>
<br/><br/>
<b class="boxHeader"><spring:message code="amrsregistration.edit.results"/></b>
<div class="box">
    Hello, <input type="text" name="tmpResult" id="tmpResult" value="${tmpResult}"/>
    <table border="0" cellspacing="2" cellpadding="2">
        <tr>
            <td align="left" valign="top">
                <input type="text" name="resultId" id="resultId" value="${resultId}"/>
            </td>
            <td>
                <input type="text" name="resultGname" id="resultGname" value="${resultGname}"/>
            </td>
            <td>
                <input type="text" name="resultFname" id="resultFname" value="${resultFname}"/>
            </td>
        </tr>
    </table>
</div>
<br/>
<form id="identifierForm" method="post">
        <%@ include file="portlets/patientName.jsp"%>
    <br/>
        <%@ include file="portlets/patientAddress.jsp" %>
    <br/>
        <%@ include file="portlets/patientIdentifier.jsp" %>
    <table>
        <tr>
            <td>
                hi
            </td>
        </tr>
    </table>
    &nbsp;
    <input type="submit" name="_cancel" value="<spring:message code='general.cancel'/>">
    &nbsp; &nbsp;
    <input type="submit" name="_target2" value="<spring:message code='general.submit'/>">
</form>
<br/>

<br/>

<%@ include file="/WEB-INF/template/footer.jsp"%>
