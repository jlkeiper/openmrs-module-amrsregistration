
<openmrs:htmlInclude file="/moduleResources/amrsregistration/css/amrsregistration.css" />
<div id="amrsUserBar">
	<openmrs:authentication>
		<c:if test="${authenticatedUser != null}">
			<span id="userLoggedInAs" class="firstChild">
				<spring:message code="header.logged.in"/> ${authenticatedUser.personName}
			</span>
			<span class="first">
				<a href="${pageContext.request.contextPath}/admin"><spring:message code="admin.title.short"/></a>
			</span>
			<span id="userLogout">
				<a href='${pageContext.request.contextPath}/moduleServlet/amrsregistration/amrsRegistrationLogout'><spring:message code="header.logout" /></a>
			</span>
		</c:if>
		<c:if test="${authenticatedUser == null}">
			<span id="userLoggedOut" class="firstChild">
				<spring:message code="header.logged.out"/>
			</span>
			<span id="userLogIn">
				<a href='${pageContext.request.contextPath}/module/amrsregistration/login.htm'><spring:message code="header.login"/></a>
			</span>
		</c:if>
	</openmrs:authentication>
</div>
