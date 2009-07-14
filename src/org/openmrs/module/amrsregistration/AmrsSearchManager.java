package org.openmrs.module.amrsregistration;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.api.context.Context;

/**
 * Manages search fields for AmrsRegistrationService method(s).
 * Handles which fields are searched, in what order, and how
 * many results should be returned.
 *
 * TODO: Ideally it would be nice to let the user manage
 * what criteria constitutes a valid search and allow this
 * class to manage the search based on the user defined criteria.
 */
public class AmrsSearchManager {

    private AmrsRegistrationService getAmrsRegistrationService() {
        return (AmrsRegistrationService)Context.getService(AmrsRegistrationService.class);
    }

    /**
     * Manages search order and valid criteria for AmrsRegistrationService.getPersons()
     * 
     * @param personName
     * @param personAddress
     * @param personAttributes
     * @param gender
     * @param birthDate
     * @param age
     * @param limit
     * @return
     */
    public List<Person> getPersons(PersonName personName,
            PersonAddress personAddress, Set<PersonAttribute> personAttributes,
            String gender, Date birthDate, Integer age, Integer limit) {
        List<Person> persons = new ArrayList<Person>();
        if (getSearchablePersonName(personName) == null) {
            return persons;
        }
        // TODO: Add limit to AmrsRegistrationService.getPersons()
        return getAmrsRegistrationService().getPersons(personName, personAddress,
                personAttributes, gender, birthDate, age);
    }

    /**
     * Determines whether the PersonName has sufficient information
     * to search; returns the same PersonName if so, otherwise returns null.
     * @param personName
     * @return
     */
    private PersonName getSearchablePersonName(PersonName personName) {
        if (personName == null) {
            return null;
        }
        if (personName.getFamilyName() == null || personName.getFamilyName().length() < 3) {
            return null;
        }
        if (personName.getGivenName() == null || personName.getGivenName().length() < 3) {
            return null;
        }
        return personName;
    }

}
