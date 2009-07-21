<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/login.htm" redirect="/module/amrsregistration/start.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />

<script type="text/javascript">

	$(document).ready(function() {
		$('#amrsIdToggle').click(function() {
			if ($(this).attr("checked")) {
				// disable all radio button
				$('input:radio').attr("disabled", "disabled");
				// enable amrs id
				$('input:text[name=amrsIdentifier]').attr("disabled", "");
				$('input:text[name=amrsIdentifier]').attr("value", "");
			} else {
				// enable all radio button
				$('input:radio').attr("disabled", "");
				// disable amrs id
				$('input:text[name=amrsIdentifier]').attr("disabled", "disabled");
				$('input:text[name=amrsIdentifier]').attr("value", "disabled");
			}
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
	
	function updatePatient(element) {
		if (confirm("Are you sure you would like to use this patient instead of the one you've entered? \n" +
					"[Warning: This will replace all data you've entered with the one from the server]\n" +
					"[Warning: You will be redirected to confirmation page if the selected patient already have AMRS ID]")) {
			var form = element.form;
			form.submit();
		} else {
			$('input:radio').removeAttr("checked");
		}
	}
</script>
<style>
	input[type="text"]{
		 background-color: white;
		 font-weight: bold;
	}
</style>
<spring:hasBindErrors name="patient">
	<c:forEach items="${errors.allErrors}" var="error">
		<br />
		<span class="error"><spring:message code="${error.code}"/></span>
	</c:forEach>
</spring:hasBindErrors>
<br />
<b class="boxHeader">Possible Matched Patient Data</b>
<div class="box">
<form id="switchPatient" method="post">
	<c:choose>
		<c:when test="${fn:length(potentialMatches) > 0}">
		    <div>
		        <table border="0" cellspacing="2" cellpadding="2">
		            <tr>
		            	<th>Use this patient?</th>
		            	<th>Identifier</th>
		            	<th>First Name</th>
		            	<th>Last Name</th>
		            	<th>Gender</th>
		            	<th>DOB</th>
		            </tr>
		    		<c:forEach items="${potentialMatches}" var="person" varStatus="varStatus">
		    			<tr>
		    				<c:forEach items="${person.identifiers}" var="identifier" varStatus="varStatus">
		    					<c:if test="${varStatus.index == 0}">
			    				<td align="center">
									<input type="hidden" name="_idCardInput">
									<input type="radio" name="idCardInput" value="${identifier.identifier}" onclick="updatePatient(this)" />
	            				</td>
			    				<td>
	            				</c:if>
			    					<input type="text" name="matchedIdentifier" value="${identifier.identifier}" disabled />
		    				</c:forEach>
			    				</td>
		    				<td>
		    					<input type="text" name="matchedGivenname" value="${person.personName.givenName}" disabled />
		    				</td>
		    				<td>
		    					<input type="text" name="matchedLastname" value="${person.personName.familyName}" disabled />
		    				</td>
		    				<td>
		    					<input type="text" name="matchedGender" value="${person.gender}" disabled />
		    				</td>
		    				<td>
		    					<input type="text" name="matchedDob" value="<openmrs:formatDate date="${person.birthdate}" />" disabled />
		    				</td>
		    			</tr>
		    		</c:forEach>
		        </table>
		        <input type="checkbox" id="amrsIdToggle" value="true" /> I certify that none of the above is the patient that I'm looking for
		    </div>
		</c:when>
		<c:otherwise>
			No potential matches found
		</c:otherwise>
	</c:choose>
</form>
</div>
<br />
<form id="patientForm" method="post">
	<%@ include file="portlets/personInfo.jsp" %>
	<br />
	<b class="boxHeader">AMRS Identifier Section</b>
	<div class="box">
		<table>
			<tr>
				<th>AMRS Identifier</th>
				<td>
					<input style="background-color: inherit;"
						type="text"
						name="amrsIdentifier"
						<c:if test="${fn:length(potentialMatches) > 0}">
							value="disabled" disabled
						</c:if>
					/>
				</td>
			</tr>
		</table>
	</div>
	<br />
	<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
    &nbsp; &nbsp;
	<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
	&nbsp; &nbsp;
    <input type="submit" name="_target3" value="<spring:message code='amrsregistration.button.save'/>">
	<br />
	<br />
</form>

<%@ include file="/WEB-INF/template/footer.jsp" %>