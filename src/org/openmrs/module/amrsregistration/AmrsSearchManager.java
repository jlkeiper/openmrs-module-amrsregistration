package org.openmrs.module.amrsregistration;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.openmrs.Patient;
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

    private Integer limit = 200;

    private AmrsRegistrationService getAmrsRegistrationService() {
        return (AmrsRegistrationService)Context.getService(AmrsRegistrationService.class);
    }

    /**
     * Set the limit on number of results returned.
     * @param limit
     */
    public void setLimit(Integer limit) {
        this.limit = limit;
    }

    /**
     * Get the limit for number of results to be returned.
     * @return
     */
    public Integer getLimit() {
        return this.limit;
    }

    /**
     * Manages search order and valid criteria for AmrsRegistrationService.getPersons()
     * Ignores class property getLimit() for limiting number of resurn results.
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
        
        int rotateCounter = 0;
        int maxCounter = 3;
        
        while(persons.size() == 0 && rotateCounter < maxCounter) {
            persons = getAmrsRegistrationService().getPersons(personName, personAddress,
                personAttributes, gender, birthDate, age, limit);
//        	rotateName(personName);
        	rotateCounter ++;
        }
        
        return persons;
    }
    
    private void rotateName(PersonName name) {
    	String temp = name.getGivenName();
    	name.setGivenName(name.getFamilyName());
    	name.setFamilyName(name.getMiddleName());
    	name.setMiddleName(temp);
    }

    /**
     * Get Persons limiting the results by #getLimit()
     * @param personName
     * @param personAddress
     * @param personAttributes
     * @param gender
     * @param birthDate
     * @param age
     * @return
     */
    public List<Person> getPersons(PersonName personName,
            PersonAddress personAddress, Set<PersonAttribute> personAttributes,
            String gender, Date birthDate, Integer age) {
        return getPersons(personName, personAddress, personAttributes, gender, birthDate, age, getLimit());
    }

    /**
     * Manages search order and valid criteria for AmrsRegistrationService.getPatients()
     * Ignores class property getLimit() for limiting number of resurn results.
     * @param personName
     * @param personAddress
     * @param personAttributes
     * @param gender
     * @param birthDate
     * @param age
     * @param limit
     * @return
     */
    public List<Patient> getPatients(PersonName personName,
        PersonAddress personAddress, Set<PersonAttribute> personAttributes,
        String gender, Date birthDate, Integer age, Integer limit) {
    	List<Person> persons = getPersons(personName,
            personAddress, personAttributes,
            gender, birthDate, age, limit);
    	List<Patient> patients = new ArrayList<Patient>();
    	for (Person person : persons) {
	        Patient patient = (Patient) person;
	        patients.add(patient);
        }
    	return patients;
    }

    /**
     * Get Patients limiting the results by #getLimit()
     * @param personName
     * @param personAddress
     * @param personAttributes
     * @param gender
     * @param birthDate
     * @param age
     * @return
     */
    public List<Patient> getPatients(PersonName personName,
        PersonAddress personAddress, Set<PersonAttribute> personAttributes,
        String gender, Date birthDate, Integer age) {
        return getPatients(personName, personAddress, personAttributes, gender, birthDate, age, getLimit());
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
