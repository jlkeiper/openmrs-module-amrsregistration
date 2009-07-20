<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/start.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>

<h2><spring:message code="amrsregistration.start.title"/></h2>
<span><spring:message code="amrsregistration.start.review"/></span>
<br/><br/>

<form id="identifierForm" method="post">
<%@ include file="portlets/personInfo.jsp" %>
<br />

&nbsp;
<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
&nbsp; &nbsp;
<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
&nbsp; &nbsp;
<input type="submit" name="_finish" value="<spring:message code='amrsregistration.button.register'/>">
</form>
<br/>
<br />
<%@ include file="/WEB-INF/template/footer.jsp" %>
