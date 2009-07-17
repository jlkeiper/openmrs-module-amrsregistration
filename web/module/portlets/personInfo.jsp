<c:if test="${empty INCLUDE_PERSON_GENDER || (INCLUDE_PERSON_GENDER == 'true')}">
	<tr>
		<td><spring:message code="Person.gender"/></td>
		<td><spring:bind path="patient.gender">
				<openmrs:forEachRecord name="gender">
					<input type="radio" name="gender" id="${record.key}" value="${record.key}" <c:if test="${record.key == status.value}">checked</c:if> />
						<label for="${record.key}"> <spring:message code="Person.gender.${record.value}"/> </label>
				</openmrs:forEachRecord>
			<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
			</spring:bind>
		</td>
	</tr>
</c:if>
<tr>
	<td>
		<spring:message code="Person.birthdate"/><br/>
		<i style="font-weight: normal; font-size: .8em;">(<spring:message code="general.format"/>: <openmrs:datePattern />)</i>
	</td>
	<td valign="top">
		<input type="text" name="addBirthdate" id="birthdate" size="11" value="" onClick="showCalendar(this)" />
		<spring:message code="Person.age.or"/>
		<input type="text" name="addAge" id="age" size="5" value="" />
	</td>
</tr>
<openmrs:forEachDisplayAttributeType personType="" displayType="all" var="attrType">
	<tr>
		<td><spring:message code="PersonAttributeType.${fn:replace(attrType.name, ' ', '')}" text="${attrType.name}"/></td>
		<td>
			<spring:bind path="attributeMap">
				<openmrs:fieldGen 
					type="${attrType.format}" 
					formFieldName="${attrType.personAttributeTypeId}" 
					val="${status.value[attrType.name].hydratedObject}" 
					parameters="optionHeader=[blank]|showAnswers=${attrType.foreignKey}" />
			</spring:bind>
		</td>
	</tr>
</openmrs:forEachDisplayAttributeType>
