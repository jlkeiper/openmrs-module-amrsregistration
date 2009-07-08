package org.openmrs.module.amrsregistration.test;

import java.util.List;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.Person;
import org.openmrs.PersonName;
import org.openmrs.module.amrsregistration.AmrsRegistrationService;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class AmrsRegistrationServiceTest extends
        BaseModuleContextSensitiveTest {
    @Before
    public void runBeforeEachTest() throws Exception {
        authenticate();
    }

    public Boolean useInMemoryDatabase() {
        return Boolean.valueOf(false);
    }

    @Test
    public void shouldGetPatientIdentifiersFromAPersonWhoIsAPatient() {
        Person localPerson = Context.getPersonService().getPerson(
                Integer.valueOf(10));
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

    @Test
    public void shouldGetPersonsUsingAnyPersonProperties() {
        Person localPerson1 = Context.getPersonService().getPerson(
                Integer.valueOf(364));
        AmrsRegistrationService localAmrsRegistrationService = (AmrsRegistrationService) Context
                .getService(AmrsRegistrationService.class);
        PersonName localPersonName = new PersonName();
        localPersonName.setGivenName("luc");
        List<Person> localList = localAmrsRegistrationService.getPersons(null, null,
                null, null, null, localPerson1.getAge());

        Assert.assertTrue(localList.size() > 0);
        Assert.assertNotNull(localList.get(0));
        System.out.println("apiPerson: " + localPerson1.getPersonId());
        System.out.println("modulePerson " + localPerson1.getPersonId());

        Assert.assertNotNull(localAmrsRegistrationService);
        for (Person localPerson2 : localList) {
            Patient localPatient = (Patient) localPerson2;
            System.out.println("id: " + localPatient.getPersonId() + ", name: "
                    + localPatient.getPersonName().getFamilyName() + ", "
                    + localPatient.getPersonName().getGivenName() + ", "
                    + localPatient.getPatientIdentifier());
        }

        System.out.println("results: " + localList.size());
    }
}
