<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<script type="text/javascript">
	
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
</script>

<h2><spring:message code="amrsregistration.start.title"/></h2>
<span><spring:message code="amrsregistration.start.review"/></span>
<br/><br/>

<form id="identifierForm" method="post">
<%@ include file="portlets/personInfo.jsp" %>
<br />

	<b class="boxHeader">AMRS Identifier Section</b>
	<div class="box">
		<table>
			<tr>
				<th>AMRS Identifier:</th>
            	<c:forEach var="identifier" items="${patient.identifiers}" varStatus="varStatus">
                    <c:if test="${amrsIdType == identifier.identifierType.name}">
						<td><span style="font-weight: bold;">${identifier.identifier}</span></td>
                    </c:if>
            	</c:forEach>
			</tr>
		</table>
	</div>
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
