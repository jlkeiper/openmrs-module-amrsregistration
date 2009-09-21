<tr id="relationshipContent">
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
		<select name="relationshipTypeId" onchange="showActivePerson(this)">
			<openmrs:forEachRecord name="relationshipType">
				<option value="${record.relationshipTypeId}" class="bIsToA"
					<c:if test="${record == relationship.relationshipType && amrsRegistration.patient.personId == relationship.personA.personId}">selected</c:if>>
						${record.bIsToA}
				</option>
				<option value="${record.relationshipTypeId}" class="aIsToB"
					<c:if test="${record == relationship.relationshipType && amrsRegistration.patient.personId == relationship.personB.personId}">selected</c:if>>
						${record.aIsToB}
				</option>
			</openmrs:forEachRecord>
		</select>
	</td>
	<td style="white-space:nowrap;">
		&nbsp;
	</td>
	<td style="white-space:nowrap; display:none;" class="personA">
		<input type="text" name="personA" value="${relationship.personA.personName}" onkeyup="searchPersonWithTimeout(event, this)"/>
		<input type="hidden" name="personB" value="N/A" />
	</td>
	<td style="white-space:nowrap; display:block;" class="personB">
		<input type="hidden" name="personA" value="N/A" />
		<input type="text" name="personB" value="${relationship.personB.personName}" onkeyup="searchPersonWithTimeout(event, this)"/>
	</td>
	<td width="80%">&nbsp;</td>
	<td>&nbsp;</td>
	<td style="white-space:nowrap;">
		<input type="hidden" name="relationshipPersonId" value="N/A" />
		<input type="hidden" name="relationshipGivenName" value="N/A" />
		<input type="hidden" name="relationshipMiddleName" value="N/A" />
		<input type="hidden" name="relationshipFamilyName" value="N/A" />
		<input type="hidden" name="relationshipGender" value="N/A" />
		<input type="hidden" name="relationshipAge" value="N/A" />
		<input type="hidden" name="relationshipBirthdate" value="N/A" />
		<input type="button" value="Remove" class="addNew removeRelationship" onclick="return deleteRelationship(this);"/>
	</td>
<tr>
<tr id="personSearchResult" style="display:none" />
<tr id="createRelationshipPerson" style="display:none">
	<td colspan="4">
		<div id="relationshipPerson" style="border: 1px solid grey">
			<table>
				<tr>
					<td>Given</td>
					<td>
						<input type="text" value="" size="30" name="rGivenName"/>
					</td>
				</tr>
				<tr>
					<td>Middle</td>
					<td>
						<input type="text" value="" size="30" name="rMiddleName"/>
					</td>
				</tr>
				<tr>
					<td>Family Name</td>
					<td>
						<input type="text" value="" size="30" name="rFamilyName"/>
					</td>
				<tr>
					<td>Birthdate<br/><input type="hidden" value="dd/mm/yyyy" id="datepattern"/><i style="font-weight: normal; font-size: 0.8em;">(Format: dd/mm/yyyy)</i></td>
					<td valign="top">
						<input type="text" onclick="showCalendar(this)" value="" size="11" name="rDate" autocomplete="off"/>
						or Age
						<input type="text" value="" size="5" name="rAge"/>
					</td>
				</tr>
				<tr>
					<td>Gender</td>
					<td>
						<input type="radio" value="M" name="rGender"/>
						<label for="gender-M"> Male </label>
						<input type="radio" value="F" name="rGender"/>
						<label for="gender-F"> Female </label>
					</td>
				</tr>
				<tr>
					<td/>
					<td>
						<input type="button" value="Create Person" class="createNewPerson"/>
						<input type="button" value="Cancel" class="showHideCreatePerson"/>
					</td>
				</tr>
			</table>
		</div>
	</td>
	<td>&nbsp;</td>
</tr>