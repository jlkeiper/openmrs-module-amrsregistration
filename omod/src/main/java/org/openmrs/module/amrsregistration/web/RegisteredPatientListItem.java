package org.openmrs.module.amrsregistration.web;

import java.util.List;
import java.util.Set;
import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.web.dwr.PatientListItem;

public class RegisteredPatientListItem extends PatientListItem {
    private List<PersonName> names;
    private List<PersonAddress> addresses;
    private Set<PersonAttribute> personAttributes;

    public RegisteredPatientListItem(Person paramPerson) {
        super((Patient) paramPerson);
    }

    public RegisteredPatientListItem(Patient paramPatient) {
        super(paramPatient);
    }

    public List<PersonName> getNames() {
        return this.names;
    }

    public void setNames(List<PersonName> paramList) {
        this.names = paramList;
    }

    public List<PersonAddress> getAddresses() {
        return this.addresses;
    }

    public void setAddresses(List<PersonAddress> paramList) {
        this.addresses = paramList;
    }

    public void setPersonAttributes(Set<PersonAttribute> paramSet) {
        this.personAttributes = paramSet;
    }

    public Set<PersonAttribute> getPersonAttributes() {
        return this.personAttributes;
    }
}