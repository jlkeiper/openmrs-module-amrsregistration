    <tr id="identifierContent${varStatus.index}">
        <td class="spacing">
            <spring:bind path="identifier">
                <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
            </spring:bind>
        </td>
        <td class="spacing">
            <spring:bind path="identifierType">
                <select id="${status.expression}" name="${status.expression}">
                    <openmrs:forEachRecord name="patientIdentifierType">
                    	<c:if test="${amrsIdType != record.name}">
	                        <option value="${record.patientIdentifierTypeId}"
	                        <c:if test="${record.patientIdentifierTypeId == status.value}">selected</c:if> >
	                        	${record.name}
	                        </option>
                        </c:if>
                    </openmrs:forEachRecord>
                </select>
            </spring:bind>
        </td>
		<td class="spacing">
			<spring:bind path="location">
				<select id="${status.expression}" name="${status.expression}">
					<openmrs:forEachRecord name="location">
						<option value="${record.locationId}" <c:if test="${record.locationId == status.value}">selected</c:if>>
							${record.name}
						</option>
					</openmrs:forEachRecord>
				</select>
				<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
			</spring:bind>
		</td>
	</tr>
