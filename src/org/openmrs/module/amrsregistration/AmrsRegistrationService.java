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
import org.openmrs.module.amrsregistration.db.AmrsRemoteRegistrationDAO;

public interface AmrsRegistrationService {
    public void setRemoteRegistrationDAO(
            AmrsRemoteRegistrationDAO paramAmrsRemoteRegistrationDAO);

    public void registerPatient(Patient paramPatient,
            String paramString1, String paramString2) throws APIException;

    public List<Person> getPersons(PersonName paramPersonName,
            PersonAddress paramPersonAddress, Set<PersonAttribute> paramSet,
            String paramString, Date paramDate, Integer paramInteger, Integer limit)
            throws APIException;
    public String sayHello() throws APIException;

    public List<Person> getPersons();
}
