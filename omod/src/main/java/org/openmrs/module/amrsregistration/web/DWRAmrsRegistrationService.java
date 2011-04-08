package org.openmrs.module.amrsregistration.web;

import java.util.Date;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.math.NumberUtils;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.api.context.Context;
import org.openmrs.module.amrsregistration.AmrsSearchManager;
import org.openmrs.web.dwr.DWRPersonService;

public class DWRAmrsRegistrationService extends DWRPersonService {
	
	private AmrsSearchManager searchManager = new AmrsSearchManager();

    public List<Patient> getPatients(PersonName paramPersonName,
            PersonAddress paramPersonAddress,  PatientIdentifier identifier, Set<PersonAttribute> paramSet,
            String paramString, Date paramDate, Integer paramInteger) {
    	List<Patient> localList = searchManager.getPatients(
                paramPersonName, paramPersonAddress, identifier, paramSet, paramString,
                paramDate, paramInteger, 10);
        return localList;
    }
    
    public Patient getPatientByIdentifier(String identifier) {
		Patient matchedPatient = Context.getPatientService().getPatient(NumberUtils.toInt(identifier));
		return matchedPatient;
    }
    
    public List<Person> findPerson(String partialName) {
		return searchManager.getPeople(partialName);
    }
}
