package org.openmrs.module.amrsregistration.db;

import java.util.Date;
import java.util.List;
import java.util.Set;

import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.api.db.DAOException;

public interface AmrsRegistrationDAO {
    public List<Person> getPersons(PersonName paramPersonName,
            PersonAddress paramPersonAddress, Set<PersonAttribute> paramSet,
            String paramString, Date paramDate, Integer paramInteger, Integer limit)
            throws DAOException;
    public List<Person> getPersons() throws DAOException;
}
