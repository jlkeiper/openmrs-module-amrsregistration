<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Register Patients" otherwise="/module/amrsregistration/login.htm" redirect="/module/amrsregistration/registration.form"/>

<%@ include file="/WEB-INF/template/headerMinimal.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRPatientService.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRAmrsRegistrationService.js" />
<openmrs:htmlInclude file="/dwr/engine.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/moduleResources/amrsregistration/scripts/jquery-1.3.2.min.js" />
<openmrs:htmlInclude file="/moduleResources/amrsregistration/scripts/common.js" />
<openmrs:htmlInclude file="/moduleResources/amrsregistration/scripts/jquery.tablesorter.min.js" />

<script type="text/javascript">
	$j(document).ready(function() {
		// the "i certify" checkbox
		// hide the potential matches, show the patient summary section, focus on the identifier text field
		$j('#amrsIdToggle').click(function() {
			if ($j(this).attr("checked")) {
				$j("#matchesSection").hide();
				$j("#patientSection").show();
				$j("#amrsIdentifier").focus();
			}
		});
		
		// selecting a patient from the potential matches
		// get the <tr> --> get the value of input element inside it and send it to server to get the patient object
		$j('.match').click(function(){
			var tr = $j(this).parent();
			var children = $j(tr).children(':input');
			var id = $j(children).attr('value');
			getPatientByIdentifier(jQuery.trim(id));
		});
		
		// show highlight effect on the selected row
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
		
		// make the potential matches table sortable object
        $j("#sortableTable").tablesorter();
	});
	
	function cancel() {
		// dismiss the mask (selecting from potential matches patient will show the mask)
		$j('#mask').hide();
		$j('.window').hide();
	}
    
    function updateData(identifier) {
    	// get the form and reset the form
    	var formName = $j('#switchPatient').attr("id");
    	document.forms[formName].reset();
    	// attach the patient id to the form
    	var hiddenInput = $j(document.createElement("input"));
    	$j(hiddenInput).attr("type", "hidden");
    	$j(hiddenInput).attr("name", "patientIdInput");
    	$j(hiddenInput).attr("id", "patientIdInput");
    	$j(hiddenInput).attr("value", identifier);
    	$j('.match').append($j(hiddenInput));
    	// submit the form
    	document.forms[formName].submit();
    }
    
    function getPatientByIdentifier(identifier) {
    	// get patient by patient id
    	DWRAmrsRegistrationService.getPatientByIdentifier(identifier, renderPatientData);
    }
</script>
<%@ include file="portlets/dialogContent.jsp" %>
<style>
	input[type="text"]{
		 background-color: white;
		 font-weight: bold;
	}
	
	.border {
		border: 1px solid lightgray;
	}
	
	.spacing {
		padding-right: 5em;
	}
	
	#idFormSection {
		text-align: center;
		width: 60%;
		border-bottom: 1px solid lightgray;
		margin-bottom: 5px;
	}

	#idFormSection input[type='text'] {
		font-size: 3em;
	}
	
</style>

<div id="amrsTitle">
	<h2>Assign AMRS ID<!--spring:message code="amrsregistration.edit.start"/--></h2>
</div>

<div id="mask"></div>

<div id="amrsContent">
<div id="boxes"> 
	<div id="dialog" class="window">
		<div id="personContent"></div>
	</div>
</div>

<c:choose>
	<c:when test="${fn:length(potentialMatches) > 0}">
		<div id="matchesSection">
			<span><spring:message code="amrsregistration.page.assign.description"/></span>
			<br />
			<br />
			<form id="switchPatient" name="switchPatient" method="post" autocomplete="off">
		        <table id="sortableTable" border="0" cellspacing="2" cellpadding="2" class="border">
		        	<thead>
		            <tr>
			        	<th><spring:message code="amrsregistration.labels.ID" /></th>
			        	<th><spring:message code="amrsregistration.labels.givenNameLabel" /></th>
			        	<th><spring:message code="amrsregistration.labels.middleNameLabel" /></th>
			        	<th><spring:message code="amrsregistration.labels.familyNameLabel" /></th>
			        	<th><spring:message code="amrsregistration.labels.age" /></th>
			        	<th style="text-align: center;"><spring:message code="amrsregistration.labels.gender" /></th>
			        	<th>&nbsp;</th>
			        	<th><spring:message code="amrsregistration.labels.birthdate" /></th>
		            </tr>
		            </thead>
		    		<c:forEach items="${potentialMatches}" var="patient" varStatus="varStatus" end="${maxReturned}">
		    			<c:choose>
		    				<c:when test="${varStatus.index % 2 == 0}">
		    					<tr class="evenRow">
		    				</c:when>
		    				<c:otherwise>
		    					<tr class="oddRow">
		    				</c:otherwise>
		    			</c:choose>
		    				<c:forEach items="${patient.identifiers}" var="identifier" varStatus="varStatus">
		    					<c:if test="${varStatus.index == 0}">
				    				<td class="match spacing">
				    					<c:out value="${identifier.identifier}" />
				    				</td>
	            				</c:if>
		    				</c:forEach>
		    				<td class="match spacing">
		    					<c:out value="${patient.personName.givenName}" />
		    				</td>
		    				<td class="match">
		    					<c:out value="${patient.personName.middleName}" />
		    				</td>
		    				<td class="match spacing">
		    					<c:out value="${patient.personName.familyName}" />
		    				</td>
		    				<td class="match spacing">
		    					<c:out value="${patient.age}" />
		    				</td>
		    				<td class="match spacing" style="text-align: center">
								<c:if test="${patient.gender == 'M'}"><img src="${pageContext.request.contextPath}/images/male.gif" alt='<spring:message code="Person.gender.male"/>' /></c:if>
								<c:if test="${patient.gender == 'F'}"><img src="${pageContext.request.contextPath}/images/female.gif" alt='<spring:message code="Person.gender.female"/>' /></c:if>
		    				</td>
		    				<td class="match">
		    					<c:if test="${patient.birthdateEstimated}">~</c:if>
		    				</td>
		    				<td class="match spacing">
		    					<openmrs:formatDate date="${patient.birthdate}" />
		    				</td>
			    			<input type="hidden" name="hiddenId" id="hiddenId" value="${patient.patientId}" />
		    			</tr>
		    		</c:forEach>
		        </table>
		        <br />
		        <c:if test="${!selectionOnly}">
		        	<input type="checkbox" id="amrsIdToggle" value="true" /><spring:message code="amrsregistration.page.assign.certify"/>
		        </c:if>
		        <br /><br />
			    &nbsp; &nbsp;
				<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
				&nbsp; &nbsp;
				<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
			</form>
			<br />
		</div>
		<div id=patientSection style="display: none">
	</c:when>
	<c:otherwise>
		<div id=patientSection style="display: block">
	</c:otherwise>
</c:choose>
	<span>Please assign an ID for the following patient</span>
	<br />
	<spring:hasBindErrors name="amrsRegistration">
		<c:forEach items="${errors.allErrors}" var="error">
			<br />
			<span class="error"><spring:message code="${error.code}" arguments="${error.arguments}" /></span>
		</c:forEach>
	</spring:hasBindErrors>
	<form id="patientForm" method="post" autocomplete="off">
		<div id="summaryHeading">
			<div id="headingName">${amrsRegistration.patient.personName}</div>
			<%@ include file="portlets/personInfo.jsp" %>
		</div>
        <c:forEach var="name" items="${amrsRegistration.patient.names}" varStatus="varStatus">
           <c:if test="${varStatus.index == 1 && name != amrsRegistration.patient.personName}">
               <div class="summaryInfo">
                   <div class="infoHeading">Other Name(s)</div>
                   <table>
                       <tr>
                           <td>
                               <c:forEach var="name" items="${amrsRegistration.patient.names}" varStatus="varStatus">
                                   <c:if test="${!name.voided && name != amrsRegistration.patient.personName}">
                                       <spring:nestedPath path="amrsRegistration.patient.names[${varStatus.index}]">
                                           <openmrs:portlet url="nameLayout" id="namePortlet" size="quickView" parameters="layoutShowExtended=true" />
                                       </spring:nestedPath>
                                   </c:if>
                               </c:forEach>
                           </td>
                       </tr>
                   </table>
               </div>
           </c:if>
        </c:forEach>
		<div class="summaryInfo">
			<div class="infoHeading"><spring:message code="Person.addresses"/></div>
			<table>
				<tr>
					<td>
						<c:forEach var="address" items="${amrsRegistration.patient.addresses}" varStatus="varStatus">
							<c:if test="${!address.voided}">
								<spring:nestedPath path="amrsRegistration.patient.addresses[${varStatus.index}]">
									<openmrs:portlet url="addressLayout" id="addressPortlet" size="inOneRow" parameters="layoutMode=view|layoutShowTable=false|layoutShowExtended=false" />
								</spring:nestedPath>
							</c:if>
						</c:forEach>
					</td>
				</tr>
			</table>
		</div>
		<c:if test="${displayAttributes}">
        <div class="summaryInfo">
            <div class="infoHeading">Attributes</div>
            <table>
                <openmrs:forEachDisplayAttributeType personType="" displayType="viewing" var="attrType">
                    <tr>
                        <td><spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/> :</td>
                        <td>${amrsRegistration.patient.attributeMap[attrType.name].hydratedObject}</td>
                    </tr>
                </openmrs:forEachDisplayAttributeType>
            </table>
        </div>
        </c:if>
        
		<c:if test="${fn:length(amrsRegistration.relationships) > 0}">
        <div class="summaryInfo">
        	<div class="infoHeading">Relationships</div>
        	<table>
				<c:forEach var="relationship" items="${amrsRegistration.relationships}" varStatus="varStatus">
					<tr>
						<td id="patientName" style="white-space:nowrap;">
							<c:choose>
								<c:when test="${not empty fn:trim(amrsRegistration.patient.personName)}">
									${amrsRegistration.patient.personName}'s
								</c:when>
								<c:otherwise>
									This patient's
								</c:otherwise>
							</c:choose>
						</td>
						<td style="white-space:nowrap;">
							<openmrs:forEachRecord name="relationshipType">
								<c:if test="${record == relationship.relationshipType}">
									<c:choose>
										<c:when test="${amrsRegistration.patient.personName == relationship.personA.personName}">
											${record.aIsToB}
										</c:when>
										<c:otherwise>
											${record.bIsToA}
										</c:otherwise>
									</c:choose>
								</c:if>
							</openmrs:forEachRecord>
						</td>
						<td style="white-space:nowrap;">
							is
						</td>
						<td style="white-space:nowrap;">
							<c:choose>
								<c:when test="${amrsRegistration.patient.personName == relationship.personA.personName}">
									${relationship.personB.personName}
								</c:when>
								<c:otherwise>
									${relationship.personA.personName}
								</c:otherwise>
							</c:choose>
						</td>
						<td width="80%">&nbsp;</td>
					<tr>
				</c:forEach>
			</table>
        </div>
    	</c:if>
		<div style="clear: both">&nbsp;</div>
		<div id="idFormSection">
			<span style="font: bold 2em verdana;">Assign New ID: </span><br />
			<input size="10" type="text" name="amrsIdentifier" id="amrsIdentifier" /><br />
			<span style="font: bold 0.8em verdana">(${amrsIdType})</span>
		<br />
		<br />
		<span style="font: bold 0.8em verdana;">Registration Location:</span>
		<openmrs:fieldGen
	type="org.openmrs.Location" formFieldName="locationId" val=""
	allowUserDefault="true" />
		<div style="clear: both">&nbsp;</div>
		</div>
		<input type="hidden" name="_page2" value="true" />
		&nbsp;
	    <input type="submit" name="_target3" value="<spring:message code='amrsregistration.button.continue'/>">
	    &nbsp; &nbsp;
		<input type="submit" name="_target1" value="<spring:message code='amrsregistration.button.edit'/>">
		&nbsp; &nbsp;
		<input type="submit" name="_cancel" value="<spring:message code='amrsregistration.button.startover'/>">
	</form>
	<br />
	<br />
</div>
</div>

<script type="text/javascript">
    focusOnTextBox("amrsIdentifier");
</script>

<%@ include file="/WEB-INF/template/footer.jsp" %>