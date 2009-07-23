<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRAmrsRegistrationService.js" />
<openmrs:htmlInclude file="/dwr/engine.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/scripts/common.js" />
<openmrs:htmlInclude file="/openmrs/moduleResources/amrsregistration/css/amrsregistration.css" />

<script type="text/javascript">
	$j = jQuery.noConflict();

	$j(document).ready(function() {
		$j('#amrsIdToggle').click(function() {
			if ($j(this).attr("checked")) {
				// disable all radio button
				$j('input:radio').attr('disabled', 'disabled');
				// enable amrs id
				$j('input:text[name=amrsIdentifier]').attr('disabled', '');
				$j('input:text[name=amrsIdentifier]').attr('value', '');
				$j('.match').unbind();
			} else {
				// enable all radio button
				$j('input:radio').attr('disabled', '');
				// disable amrs id
				$j('input:text[name=amrsIdentifier]').attr('disabled', 'disabled');
				$j('input:text[name=amrsIdentifier]').attr('value', 'disabled');
		
				$j('.match').click(function(){
					var tr = $j(this).parent();
					var input = $j(tr + ':input[type=radio]');
					getPatientByIdentifier($(input).attr('value'));
				});
				
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
			}
		});
		
		$j('.match').click(function(){
			var tr = $j(this).parent();
			var input = $j(tr + ':input[type=radio]');
			getPatientByIdentifier($(input).attr('value'));
		});
		
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
	});
	
	function cancel() {
		$j('#mask').hide();
		$j('.window').hide();
		$j('input:radio').removeAttr("checked");
	}
    
    function updateData(identifier) {
    	var formName = $j('#switchPatient').attr("id");
    	document.forms[formName].reset();
    	
    	var hiddenInput = $j(document.createElement("input"));
    	$j(hiddenInput).attr("type", "hidden");
    	$j(hiddenInput).attr("name", "idCardInput");
    	$j(hiddenInput).attr("id", "idCardInput");
    	$j(hiddenInput).attr("value", identifier);
    	$j('#boxes').append($j(hiddenInput));
    	
    	document.forms[formName].submit();
    }
	
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
    
    function getPatientByIdentifier(identifier) {
    	DWRAmrsRegistrationService.getPatientByIdentifier(identifier, renderPatientData);
    }
</script>
<%@ include file="portlets/dialogContent.jsp" %>
<style>
	input[type="text"]{
		 background-color: white;
		 font-weight: bold;
	}
</style>
<div id="mask"></div>
<spring:hasBindErrors name="patient">
	<c:forEach items="${errors.allErrors}" var="error">
		<br />
		<span class="error"><spring:message code="${error.code}"/></span>
	</c:forEach>
</spring:hasBindErrors>
<br />
<b class="boxHeader">Possible Matched Patient Data</b>
<div class="box">
<form id="switchPatient" name="switchPatient" method="post">
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
		    			<c:choose>
		    				<c:when test="${varStatus.index % 2 == 0}">
		    					<tr class="evenRow">
		    				</c:when>
		    				<c:otherwise>
		    					<tr class="oddRow">
		    				</c:otherwise>
		    			</c:choose>
		    				<c:forEach items="${person.identifiers}" var="identifier" varStatus="varStatus">
		    					<c:if test="${varStatus.index == 0}">
			    					<td align="center">
										<input type="hidden" name="_idCardInput">
										<input type="radio" name="idCardInput" value="${identifier.identifier}" onclick="getPatientByIdentifier(this.value)" />
	            					</td>
				    				<td class="match">
				    					<c:out value="${identifier.identifier}" />
				    				</td>
	            				</c:if>
		    				</c:forEach>
		    				<td class="match">
		    					<c:out value="${person.personName.givenName}" />
		    				</td>
		    				<td class="match">
		    					<c:out value="${person.personName.familyName}" />
		    				</td>
		    				<td class="match">
		    					<c:out value="${person.gender}" />
		    				</td>
		    				<td class="match">
		    					<openmrs:formatDate date="${person.birthdate}" />
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
	
	<div id="boxes"> 
		<div id="dialog" class="window">
			Patient Data |
			<a href="#" id="clear">Close</a>
			<div id="personContent"></div>
		</div>
	</div>
	
</form>
</div>
<br />

<form id="patientForm" method="post">
	<div id="patientHeader" class="boxHeader">
		<div id="patientHeaderPatientName">${patient.personName}</div>
		<div id="patientHeaderPreferredIdentifier">
			<span class="patientHeaderPatientIdentifier">
				<span id="patientHeaderPatientIdentifierType">
					${amrsIdType}:
				</span>
				<input style="background-color: inherit;"
					size="10"
					type="text"
					name="amrsIdentifier"
					<c:if test="${fn:length(potentialMatches) > 0}">
						value="disabled" disabled
					</c:if>
				/>
			</span>
		</div>
		<%@ include file="portlets/personInfo.jsp" %>
	</div>
	<br />
	
	<div class="boxHeader"><spring:message code="Patient.title"/></div>
	<div class="box">
		<table class="personName">
			<thead>
				<tr>
					<th><spring:message code="Person.names"/></th>
					<openmrs:forEachDisplayAttributeType personType="patient" displayType="viewing" var="attrType">
						<th><spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/></th>
					</openmrs:forEachDisplayAttributeType>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td valign="top">
						<c:forEach var="name" items="${patient.names}" varStatus="varStatus">
							<c:if test="${!name.voided}">
								<spring:nestedPath path="patient.names[${varStatus.index}]">
									<openmrs:portlet url="nameLayout" id="namePortlet" size="quickView" parameters="layoutShowExtended=true" />
								</spring:nestedPath>
							</c:if>
						</c:forEach>
					</td>
					<openmrs:forEachDisplayAttributeType personType="patient" displayType="viewing" var="attrType">
						<td valign="top">${patient.attributeMap[attrType.name]}</td>
					</openmrs:forEachDisplayAttributeType>
				</tr>
			</tbody>
		</table>
	</div>
	
	<br/>
	
	<div class="boxHeader"><spring:message code="Person.addresses"/></div>
	<div class="box">
		<table class="personAddress">
			<thead>
				<openmrs:portlet url="addressLayout" id="addressPortlet" size="columnHeaders" parameters="layoutShowTable=false|layoutShowExtended=true" />
			</thead>
			<tbody>
				<c:forEach var="address" items="${patient.addresses}" varStatus="varStatus">
					<c:if test="${!address.voided}">
						<spring:nestedPath path="patient.addresses[${varStatus.index}]">
							<openmrs:portlet url="addressLayout" id="addressPortlet" size="inOneRow" parameters="layoutMode=view|layoutShowTable=false|layoutShowExtended=true" />
						</spring:nestedPath>
					</c:if>
				</c:forEach>
			</tbody>
		</table>
	</div>
	<br />
	<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
    &nbsp; &nbsp;
	<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
	&nbsp; &nbsp;
    <input type="submit" name="_target3" value="<spring:message code='amrsregistration.button.save'/>">
</form>
<br />
<br />

<%@ include file="/WEB-INF/template/footer.jsp" %>