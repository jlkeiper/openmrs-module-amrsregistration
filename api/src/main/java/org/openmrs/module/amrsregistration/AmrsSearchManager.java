package org.openmrs.module.amrsregistration;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateUtils;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.api.PatientService;
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
    public static Integer MAX_RETURNED_PATIENTS = 10;

    @SuppressWarnings("unused")
    private AmrsRegistrationService getAmrsRegistrationService() {
        return (AmrsRegistrationService)Context.getService(AmrsRegistrationService.class);
    }
    
    public List<Patient> getPatients(PersonName personName, PersonAddress personAddress, PatientIdentifier identifier,
    		Set<PersonAttribute> personAttributes, String gender, Date birthdate, Integer age, Integer limit) {
    	
    	PatientService patientService = Context.getPatientService();
    	List<Patient> patients = new ArrayList<Patient>();
    	
    	if (isIdentifierSearchable(identifier))
    		patients = patientService.getPatients(identifier.getIdentifier());
    	
    	if (patients.size() < 3) {
    		if (isNameSearchable(personName)) {
    			List<Patient> namePatients = patientService.getPatients(personName.toString());
    			namePatients.removeAll(patients);
    			
    			if (namePatients.size() > MAX_RETURNED_PATIENTS) {
    				// too much result, need to filter out the result
    				List<Patient> ageGenderPatients = new ArrayList<Patient>();
    				// limit by gender and birth date
    				
    				//TODO: need to add validation to the birth date and age and gender here
    				for (Patient patient : namePatients) {
        				if (isFilterableByGender(gender) && !StringUtils.equals(patient.getGender(), gender)) {
        					continue;
        				}
        				
        				// the age is not within the range (age +/- 1 year)
        				if (isFilterableByAge(age) && !(patient.getAge() >= age - 2 && patient.getAge() <= age + 2)) {
        					continue;
        				}
        				
        				// the birthdate is not within the range
	                    if (isFilterableByBirthdate(birthdate)) {
	        				Date oneYearAhead = DateUtils.addYears(birthdate, 1);
	        				Date oneYearBehind = DateUtils.addYears(birthdate, -1);
	                    	if(!(birthdate.before(oneYearAhead) && birthdate.after(oneYearBehind))) {
	                    		continue;
	                    	}
	                    }
                    	ageGenderPatients.add(patient);
                    }
    				if (ageGenderPatients.size() <= MAX_RETURNED_PATIENTS) 
    					return ageGenderPatients;
    				else {
    					List<Patient> maxSizePatient = new ArrayList<Patient>();
    					for (int i = 0; i < MAX_RETURNED_PATIENTS + 1; i++) {
	                        maxSizePatient.add(ageGenderPatients.get(i));
                        }
    					return maxSizePatient;
    				}
    			} else
    				return namePatients;
    		}	
    	}
    	return patients;
    }
    
    private boolean isNameSearchable(PersonName name) {
    	boolean searchable = false;
    	
    	if(name != null) {
    		if (StringUtils.isNotBlank(name.getGivenName()) && name.getGivenName().length() > 3)
    			searchable = true;
    		else if (StringUtils.isNotBlank(name.getFamilyName()) && name.getFamilyName().length() > 3)
    			searchable = true;
    	}
    	
    	return searchable;
    }
    
    private boolean isIdentifierSearchable(PatientIdentifier identifier) {
    	boolean searchable = false;
    	
    	if (identifier != null) {
    		if (StringUtils.isNotBlank(identifier.getIdentifier())) {
    			searchable = true;
    		}
    	}
    	
    	return searchable;
    }
    
    private boolean isFilterableByGender(String gender) {
    	return StringUtils.isNotBlank(gender);
    }
    
    private boolean isFilterableByAge(Integer age) {
    	return (age != null);
    }
    
    private boolean isFilterableByBirthdate(Date birthdate) {
    	return (birthdate != null);
    }

	public List<Person> getPeople(String partialName) {
		List<Person> returnedPersons = new ArrayList<Person>();
		List<Person> persons = Context.getPersonService().getPeople(partialName, false);
		int counter = 0;
		for (Person person : persons) {
			returnedPersons.add(person);
			
			counter ++;
	        if (counter > MAX_RETURNED_PATIENTS)
	        	break;
        }
		return returnedPersons;
    }
}
