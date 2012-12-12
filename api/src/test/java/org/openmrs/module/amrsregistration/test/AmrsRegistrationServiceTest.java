package org.openmrs.module.amrsregistration.test;


import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class AmrsRegistrationServiceTest extends BaseModuleContextSensitiveTest {

	@Test
	@Ignore("need to get this running with test data")
	public void shouldGetPatientIdentifiersFromAPersonWhoIsAPatient() {
		Person localPerson = Context.getPersonService().getPerson(
				Integer.valueOf(364));
		if (localPerson.isPatient()) {
			Patient localPatient = (Patient) localPerson;
			System.out.println("Identifiers:");
			for (PatientIdentifier localPatientIdentifier : localPatient
					.getIdentifiers()) {
				System.out.println(localPatientIdentifier.getIdentifier());
			}
			Assert.assertNotNull(localPatient.getIdentifiers());
		}
	}
}
