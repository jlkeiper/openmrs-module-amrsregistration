package org.openmrs.module.amrsregistration;

import java.util.Date;
import java.util.List;
import java.util.Set;
import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.api.APIException;
import org.openmrs.module.amrsregistration.db.AmrsRegistrationDAO;

public interface AmrsRegistrationService {
    public void setRemoteRegistrationDAO(
            AmrsRegistrationDAO paramAmrsRegistrationDAO);

    /**
     * This method will be used for remote registration.  Registered patient
     * information will be placed into an xml file for the FormEntry processor.
     * @param paramPatient
     * @param paramString1
     * @param paramString2
     * @throws APIException
     */
    public void registerPatient(Patient paramPatient,
            String paramString1, String paramString2) throws APIException;

    /**
     * Find Persons using all possible Person parameters.
     * @param paramPersonName
     * @param paramPersonAddress
     * @param paramSet
     * @param paramString
     * @param paramDate
     * @param paramInteger
     * @param limit  Optionally limit the number of results to return.
     * @return
     * @throws APIException
     */
    public List<Person> getPersons(PersonName paramPersonName,
            PersonAddress paramPersonAddress, Set<PersonAttribute> paramSet,
            String paramString, Date paramDate, Integer paramInteger, Integer limit)
            throws APIException;
    public String sayHello() throws APIException;

    public List<Person> getPersons();
}
