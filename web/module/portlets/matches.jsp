		    		<script type="text/javascript">
		    			$j(document).ready(function () {
		    				$j('.match').click(function() {
		    					alert("test");
		    				});
		    				$j('.match').hover(
		    					function() {
		    						var parent = $j(this).parent();
									$j(parent).css('background-color', 'grey');
									$j(parent).css('cursor', 'pointer');
		    					},
		    					function() {
		    						var parent = $j(this).parent();
				    				$j(parent).css('background-color', 'white');
				    				$j(parent).css('cursor', 'default');
		    					}
		    				);
		    				
		    			});
		    		</script>
		    		
		    		<c:forEach items="${potentialMatches}" var="person" varStatus="varStatus">
		    			<tr>
		    				<c:forEach items="${person.identifiers}" var="identifier" varStatus="varStatus">
		    					<c:if test="${varStatus.index == 0}">
				    				<td>
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
		    				<td>
		    					<c:out value="${person.gender}" />
		    				</td>
		    				<td>
		    					<openmrs:formatDate date="${person.birthdate}" />
		    				</td>
		    			</tr>
		    		</c:forEach>