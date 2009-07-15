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
	<td colspan="3">
		<script type="text/javascript">
			function updateEstimated(txtbox) {
				var input = document.getElementById("birthdateEstimatedInput");
				if (input) {
					input.checked = false;
					input.parentNode.className = "";
				}
				else if (txtbox)
					txtbox.parentNode.className = "listItemChecked";
			}
			
			function updateAge() {
				var birthdateBox = document.getElementById('birthdate');
				var ageBox = document.getElementById('age');
				try {
					var birthdate = parseSimpleDate(birthdateBox.value, '<openmrs:datePattern />');
					var age = getAge(birthdate);
					if (age > 0)
						ageBox.innerHTML = "(" + age + ' <spring:message code="Person.age.years"/>)';
					else if (age == 1)
						ageBox.innerHTML = '(1 <spring:message code="Person.age.year"/>)';
					else if (age == 0)
						ageBox.innerHTML = '( < 1 <spring:message code="Person.age.year"/>)';
					else
						ageBox.innerHTML = '( ? )';
					ageBox.style.display = "";
				} catch (err) {
					ageBox.innerHTML = "";
					ageBox.style.display = "none";
				}
			}
		</script>
		<spring:bind path="patient.birthdate">			
			<input type="text" 
					name="birthdate" size="10" id="birthdate"
					value="${status.value}"
					onChange="updateAge(); updateEstimated(this);"
					onClick="showCalendar(this)" />
			<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if> 
		</spring:bind>
		
		<span id="age"></span> &nbsp; 
		
		<span id="birthdateEstimatedCheckbox" class="listItemChecked" style="padding: 5px;">
			<spring:bind path="birthdateEstimated">
				<label for="birthdateEstimatedInput"><spring:message code="Person.birthdateEstimated"/></label>
				<input type="hidden" name="_birthdateEstimated">
				<input type="checkbox" name="birthdateEstimated" value="true" 
					   <c:if test="${status.value == true}">checked</c:if> 
					   id="birthdateEstimatedInput" 
					   onclick="if (!this.checked) updateEstimated()" />
				<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
			</spring:bind>
		</span>
		
		<script type="text/javascript">
			if (document.getElementById("birthdateEstimatedInput").checked == false)
				updateEstimated();
			updateAge();
		</script>
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
