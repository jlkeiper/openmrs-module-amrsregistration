    <tr id="identifierContent${varStatus.index}">
        <td class="spacing" style="white-space: nowrap">
            <spring:bind path="identifier">
                <c:choose>
                    <c:when test="${identifier.dateCreated != null}">
                        ${status.value}
                    </c:when>
                    <c:otherwise>
                        <input type="text" id="${status.expression}" name="${status.expression}" value="${status.value}" onkeyup="timeOutSearch(event)"/>
                    </c:otherwise>
                </c:choose>
            </spring:bind>
        </td>
        <td class="spacing" style="white-space: nowrap">
            <spring:bind path="identifierType">
                <c:choose>
                    <c:when test="${identifier.dateCreated != null}">
                        <openmrs:forEachRecord name="patientIdentifierType">
                            <c:if test="${record.patientIdentifierTypeId == status.value}">
                                ${record.name}
                            </c:if>
                        </openmrs:forEachRecord>
                    </c:when>
                    <c:otherwise>
                        <select id="${status.expression}" name="${status.expression}">
                            <option value=""></option>
                            <openmrs:forEachRecord name="patientIdentifierType">
                            	<c:if test="${amrsIdType != record.name}">
                                    <option value="${record.patientIdentifierTypeId}"
                                    <c:if test="${record.patientIdentifierTypeId == status.value}">selected</c:if> >
                                        ${record.name}
                                    </option>
                                </c:if>
                            </openmrs:forEachRecord>
                        </select>
                    </c:otherwise>
                </c:choose>
            </spring:bind>
        </td>
		<td class="spacing" style="white-space: nowrap">
			<spring:bind path="location">
                <c:choose>
                    <c:when test="${identifier.dateCreated != null}">
                        <openmrs:forEachRecord name="location">
                            <c:if test="${record.locationId == status.value}">
                                ${record.name}
                            </c:if>
                        </openmrs:forEachRecord>
                    </c:when>
                    <c:otherwise>
                        <select id="${status.expression}" name="${status.expression}">
                            <option value=""></option>
                            <openmrs:forEachRecord name="location">
                                <option value="${record.locationId}" <c:if test="${record.locationId == status.value}">selected</c:if>>
                                    ${record.name}
                                </option>
                            </openmrs:forEachRecord>
                        </select>
                        <c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
                    </c:otherwise>
                </c:choose>
			</spring:bind>
		</td>
            <c:choose>
                <c:when test="${fn:length(amrsRegistration.patient.identifiers) > 1}">
					<td style="display: block;">
                </c:when>
                <c:otherwise>
					<td style="display: none;">
                </c:otherwise>
            </c:choose>
            <spring:bind path="preferred">
                <input type="checkbox" id="identifierPreferred" name="identifierPreferred" value="${status.value}" <c:if test='${status.value == "true"}'>checked</c:if>">
            </spring:bind>
        </td>
        <td onclick='removeRow(this.parentNode)' id="rm_identifierContent">
            <a href="#delete"  style="color:red;">X</a>
        </td>
	</tr>
