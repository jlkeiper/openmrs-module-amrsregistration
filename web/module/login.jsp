<%@ include file="/WEB-INF/template/include.jsp" %>
<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/start.form"/>

<spring:message var="pageTitle" code="login.title" scope="page"/>
<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>

<%@ page import="org.openmrs.web.WebConstants" %>
<%
	pageContext.setAttribute("redirect", session.getAttribute(WebConstants.OPENMRS_LOGIN_REDIRECT_HTTPSESSION_ATTR));
	session.removeAttribute(WebConstants.OPENMRS_LOGIN_REDIRECT_HTTPSESSION_ATTR);
%>

<br/>

<form method="post" action="${pageContext.request.contextPath}/loginServlet" style="padding:15px; width: 300px;" autocomplete="off">
	<table>
		<tr>
			<td><spring:message code="User.username"/>:</td>
			<td><input type="text" name="uname" value="<request:parameter name="username" />" id="username" size="25" maxlength="50" /></td>
		</tr>
		<tr>
			<td><spring:message code="User.password"/>:</td>
			<td><input type="password" name="pw" value="" id="password" size="25" /></td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" value="<spring:message code="auth.login"/>" /></td>
		</tr>
		<tr>
			<td></td>
			<td><a class="forgotPasswordLink" href="${pageContext.request.contextPath}/forgotPassword.form"><spring:message code="User.password.forgot"/></a></td>
		</tr>
	</table>
	<br/>

	<c:choose>
		<c:when test="${not empty model.redirect}">
			<input type="hidden" name="redirect" value="${pageContext.request.contextPath}/module/amrsregistration/start.form" />
		</c:when>
		<c:when test="${redirect != ''}">
			<input type="hidden" name="redirect" value="${pageContext.request.contextPath}/module/amrsregistration/start.form" />
		</c:when>
		<c:otherwise>
			<input type="hidden" name="redirect" value="${pageContext.request.contextPath}/module/amrsregistration/start.form" />
		</c:otherwise>
	</c:choose>

	<!-- input type="hidden" name="refererURL" value='<request:header name="referer" />' / -->

</form>

<script type="text/javascript">
 document.getElementById('username').focus();
</script>



<openmrs:extensionPoint pointId="org.openmrs.login" type="html" />

<%-- @ include file="/WEB-INF/template/footer.jsp" --%>