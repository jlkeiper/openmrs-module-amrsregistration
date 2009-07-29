package org.openmrs.module.amrsregistration.web.controller;

import java.text.DateFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.PatientIdentifierType;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonAttributeType;
import org.openmrs.PersonName;
import org.openmrs.api.LocationService;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.amrsregistration.AmrsSearchManager;
import org.openmrs.patient.IdentifierValidator;
import org.openmrs.patient.UnallowedIdentifierException;
import org.openmrs.propertyeditor.ConceptEditor;
import org.openmrs.propertyeditor.LocationEditor;
import org.openmrs.propertyeditor.PatientIdentifierTypeEditor;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.beans.propertyeditors.CustomNumberEditor;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.ModelAndViewDefiningException;
import org.springframework.web.servlet.mvc.AbstractWizardFormController;
import org.springframework.web.servlet.view.RedirectView;

public class AmrsRegistrationFormController extends AbstractWizardFormController {
	
    private Log log = LogFactory.getLog(super.getClass());
	
	public AmrsRegistrationFormController() {
	}
	
	protected Object formBackingObject(HttpServletRequest request) throws ModelAndViewDefiningException {
		return getNewPatient();
	}
	
	/* (non-Javadoc)
	 * @see org.springframework.web.servlet.mvc.AbstractWizardFormController#referenceData(javax.servlet.http.HttpServletRequest, java.lang.Object, org.springframework.validation.Errors, int)
	 */
	@Override
	protected Map<String, Object> referenceData(HttpServletRequest request, Object command, Errors errors, int page) throws Exception {
		HashMap<String, Object> localHashMap = new HashMap<String, Object>();
		localHashMap.put("emptyIdentifier", new PatientIdentifier());
		localHashMap.put("emptyName", new PersonName());
		localHashMap.put("emptyAddress", new PersonAddress());
		localHashMap.put("amrsIdType", Context.getAdministrationService().getGlobalProperty("amrsregistration.idType"));
		
		Patient patient = (Patient) command;
		AmrsSearchManager searchManager = new AmrsSearchManager();
		List<Patient> persons = searchManager.getPatients(patient.getPersonName(), patient.getPersonAddress(), patient.getAttributes(), null, null, null, 10);
		// remove the exact match from the possible match (to prevent patient selected from the list to show again in the list)
		persons.remove(patient);
		
		String amrsId = ServletRequestUtils.getStringParameter(request, "amrsIdentifier", null);
		if (page == AmrsRegistrationConstants.ASSIGN_ID_PAGE) {			
			if (amrsId == null)
				// don't send potential matches for assign id page
				localHashMap.put("potentialMatches", persons);
		} else {
			localHashMap.put("potentialMatches", persons);
		}
		
		return localHashMap;
	}
	
	protected int getTargetPage(HttpServletRequest request, Object command, Errors errors, int page) {
		String idType = Context.getAdministrationService().getGlobalProperty("amrsregistration.idType");
		
		Patient patient = (Patient) command;
		Patient patientSearched = null;
		
		int targetPage = super.getTargetPage(request, command, errors, page);
		int currentPage = super.getCurrentPage(request);
		
		PatientService patientService = Context.getPatientService();
		String idCard = ServletRequestUtils.getStringParameter(request, "idCardInput", null);
		
		// only do search if the id card is not null and not empty
		if (idCard != null) {
			// get the scanned id and search for patients with that id
			String emptyString = "";
			List<PatientIdentifierType> types = new ArrayList<PatientIdentifierType>();
			List<Patient> patients = patientService.getPatients(emptyString, idCard, types, true);
			if (patients != null && !patients.isEmpty()) {
				// patient with matching id are found
				patientSearched = patients.get(0);
				copyPatient(patient, patientSearched);
				patient.getAttributeMap();
			} else {
				// no patient found with the matching id
				if (log.isDebugEnabled()) {
					log.debug("Searched for id: " + idCard + ", but no patient are found");
				}
				errors.reject("No patient with specified id are found in the system");
			}
		}
		
		// Check if it is really a back request, not a refresh page
		// This is done because in the "start page" the name of the "GO" button is "_target1" which told the controller
		// that the next page is the "edit page" (default behavior). But above code changes the flow from "start page" to
		// "review page", but the "_target1" is still inside the parameter.		
		if (targetPage < currentPage) {
			String back = ServletRequestUtils.getStringParameter(request, "_target" + targetPage, null);
			if (!"Edit Patient".equalsIgnoreCase(back)) {
				targetPage = currentPage;
			}
		}
		
		switch (targetPage) {
			case 0:
				break;
			case 1:
				// coming from first page and not a get patient data
				if (idCard != null) {
					// found a patient
					if (patientSearched != null){
						// default to found patient, but no required id type
						targetPage = AmrsRegistrationConstants.ASSIGN_ID_PAGE;
						for (PatientIdentifier identifier : patient.getIdentifiers()) {
							if (identifier.getIdentifierType().getName().equals(idType)) {
								// found the required id type, go to confirmation page
								targetPage = AmrsRegistrationConstants.REVIEW_PAGE;
								break;
							}
				        }
					}
				}
				break;
			case 2:
    			if (patient.getFamilyName() == null || patient.getFamilyName().length() <= 0) {
    				errors.reject("Please insert a family name for the patient.");
    			}
    			if (patient.getGender() == null) {
    				errors.reject("Please assign a gender for the patient");
    			}
				String birthdate = (patient.getBirthdate() == null) ? null : Context.getDateFormat().format(patient.getBirthdate());
				String date = ServletRequestUtils.getStringParameter(request, "birthdate", birthdate);
				String age = ServletRequestUtils.getStringParameter(request, "age", null);
				if ((date == null || date.length() <= 0) && (age == null || age.length() <= 0)) {
					errors.reject("Please assign birthdate or age for this patient");
				}
				updateBirthdate(patient, date, age);
				
				// remove from this list elements that already in the person attribute (list.remove(personattributeType)
		        List<PersonAttributeType> attributeTypes = Context.getPersonService().getAllPersonAttributeTypes();
				for (PersonAttribute attribute : patient.getAttributes()) {
					Integer id = attribute.getAttributeType().getPersonAttributeTypeId();
	                String value = ServletRequestUtils.getStringParameter(request, String.valueOf(id), attribute.getValue());
	                if (value != null) {
	                	attribute.setValue(value);
	                	attributeTypes.remove(attribute.getAttributeType());
	                }
                }
				
				// iterate over what is left in the list to see whether the user add a new element or not
				for (PersonAttributeType personAttributeType : attributeTypes) {
					Integer id = personAttributeType.getPersonAttributeTypeId();
	                String value = ServletRequestUtils.getStringParameter(request, String.valueOf(id), "");
	                if (value != null && value.length() > 0) {
		                PersonAttribute attribute = new PersonAttribute();
		                attribute.setAttributeType(personAttributeType);
		                attribute.setValue(value);
		                patient.addAttribute(attribute);
	                }
                }
				
				String[] ids = ServletRequestUtils.getStringParameters(request, "identifier");
				String[] idTypes = ServletRequestUtils.getStringParameters(request, "identifierType");
				String[] locations = ServletRequestUtils.getStringParameters(request, "location");
				String[] preferredIds = ServletRequestUtils.getStringParameters(request, "preferred");
				if (ids != null || idTypes != null) {
					int maxIds = 0;
					if (ids != null && ids.length > maxIds)
						maxIds = ids.length;
					if (idTypes != null && idTypes.length > maxIds)
						maxIds = idTypes.length;
					if (locations != null && locations.length > maxIds)
						maxIds = locations.length;
					
					LocationService locationService = Context.getLocationService();
					
					for (int j = 0; j < maxIds; j++) {
	                    PatientIdentifier identifier = new PatientIdentifier();
	                    identifier.setIdentifier(ids[j]);
	                    identifier.setIdentifierType(patientService.getPatientIdentifierType(Integer.valueOf(idTypes[j])));
	                    identifier.setLocation(locationService.getLocation(Integer.valueOf(locations[j])));
//						if (preferredIds != null && preferredIds.length > j)
//							identifier.setPreferred(new Boolean(true));
//						else
//							identifier.setPreferred(new Boolean(false));
						patient.addIdentifier(identifier);
                    }
				}

				String[] givenNames = ServletRequestUtils.getStringParameters(request, "givenName");
				String[] middleNames = ServletRequestUtils.getStringParameters(request, "middleName");
//				String[] familyNamePrefixes = ServletRequestUtils.getStringParameters(request, "familyNamePrefix");
				String[] familyNames = ServletRequestUtils.getStringParameters(request, "familyName");
//				String[] familyName2s = ServletRequestUtils.getStringParameters(request, "familyName2");
//				String[] familyNameSuffixes = ServletRequestUtils.getStringParameters(request, "familyNameSuffix");
				String[] degrees = ServletRequestUtils.getStringParameters(request, "degree");
//				String[] prefixes = ServletRequestUtils.getStringParameters(request, "prefix");
				String[] preferredNames = ServletRequestUtils.getStringParameters(request, "preferred");
				
				if (givenNames != null || middleNames != null ||
//						familyNamePrefixes != null || 
						familyNames != null ||
//						familyName2s != null || familyNameSuffixes != null ||
						degrees != null) {
//					|| prefixes != null) {
					
					int maxNames = 0;
					if (givenNames != null && givenNames.length > maxNames)
						maxNames = givenNames.length;
					if (middleNames != null && middleNames.length > maxNames)
						maxNames = middleNames.length;
//					if (familyNamePrefixes != null && familyNamePrefixes.length > maxNames)
//						maxNames = familyNamePrefixes.length;
					if (familyNames != null && familyNames.length > maxNames)
						maxNames = familyNames.length;
//					if (familyName2s != null && familyName2s.length > maxNames)
//						maxNames = familyName2s.length;
//					if (familyNameSuffixes != null && familyNameSuffixes.length > maxNames)
//						maxNames = familyNameSuffixes.length;
					if (degrees != null && degrees.length > maxNames)
						maxNames = degrees.length;
//					if (prefixes != null && prefixes.length > maxNames)
//						maxNames = prefixes.length;
					
					for (int j = 0; j < maxNames; j++) {
						PersonName name = new PersonName();
//						if (preferredNames != null && preferredNames.length > j)
//							name.setPreferred(new Boolean(true));
//						else
//							name.setPreferred(new Boolean(false));
						name.setGivenName(givenNames[j]);
						name.setMiddleName(middleNames[j]);
//						name.setFamilyNamePrefix(familyNamePrefixes[j]);
						name.setFamilyName(familyNames[j]);
//						name.setFamilyName2(familyName2s[j]);
//						name.setFamilyNameSuffix(familyNameSuffixes[j]);
//						name.setDegree(prefixes[j]);
						name.setDegree(degrees[j]);
						patient.addName(name);
                    }
				}
				
				String[] address1s = ServletRequestUtils.getStringParameters(request, "address1");
				String[] address2s = ServletRequestUtils.getStringParameters(request, "address2");
				String[] cells = ServletRequestUtils.getStringParameters(request, "neighborhoodCell");
				String[] cities = ServletRequestUtils.getStringParameters(request, "cityVillage");
				String[] townships = ServletRequestUtils.getStringParameters(request, "townshipDivision");
				String[] counties = ServletRequestUtils.getStringParameters(request, "countyDistrict");
				String[] states = ServletRequestUtils.getStringParameters(request, "stateProvince");
				String[] regions = ServletRequestUtils.getStringParameters(request, "region");
				String[] subregions = ServletRequestUtils.getStringParameters(request, "subregion");
				String[] countries = ServletRequestUtils.getStringParameters(request, "country");
				String[] postalCodes = ServletRequestUtils.getStringParameters(request, "postalCode");
				String[] preferredAddress = ServletRequestUtils.getStringParameters(request, "preferred");
				
				if (address1s != null || address1s != null ||
						cells != null || cities != null ||
						townships != null || counties != null ||
						states != null || regions != null ||
						subregions != null || countries != null ||
						postalCodes != null) {
					int maxAddress = 0;
					if(address1s != null && address1s.length > maxAddress)
						maxAddress = address1s.length;
					if(address1s != null && address1s.length > maxAddress)
						maxAddress = address1s.length;
					if(cells != null && cells.length > maxAddress)
						maxAddress = cells.length;
					if(cities != null && cities.length > maxAddress)
						maxAddress = cities.length;
					if(townships != null && townships.length > maxAddress)
						maxAddress = townships.length;
					if(counties != null && counties.length > maxAddress)
						maxAddress = counties.length;
					if(states != null && states.length > maxAddress)
						maxAddress = states.length;
					if(regions != null && regions.length > maxAddress)
						maxAddress = regions.length;
					if(subregions != null && subregions.length > maxAddress)
						maxAddress = subregions.length;
					if(countries != null && countries.length > maxAddress)
						maxAddress = countries.length;
					if(postalCodes != null && postalCodes.length > maxAddress)
						maxAddress = postalCodes.length;
					
					for (int j = 0; j < maxAddress; j++) {
						PersonAddress pa = new PersonAddress();
						pa.setAddress1(address1s[j]);
						pa.setAddress2(address2s[j]);
						pa.setNeighborhoodCell(cells[j]);
						pa.setCityVillage(cities[j]);
						pa.setTownshipDivision(townships[j]);
						pa.setCountyDistrict(counties[j]);
						pa.setStateProvince(states[j]);
						pa.setRegion(regions[j]);
						pa.setSubregion(subregions[j]);
						pa.setCountry(countries[j]);
						pa.setPostalCode(postalCodes[j]);
						pa.setCountyDistrict(counties[j]);
//						if (preferredAddress != null && preferredAddress.length > j)
//							pa.setPreferred(new Boolean(true));
//						else
//							pa.setPreferred(new Boolean(false));
						patient.addAddress(pa);
					}
				}
				
				// jump to page 3 when the identifier is found
				for (PatientIdentifier identifier : patient.getIdentifiers()) {
					if (identifier.getIdentifierType().getName().equals(idType)) {
						// found the required id type, go to confirmation page
						targetPage = AmrsRegistrationConstants.REVIEW_PAGE;
						break;
					}
		        }
				break;
			case 3:
				String amrsId = ServletRequestUtils.getStringParameter(request, "amrsIdentifier", null);
				PatientIdentifierType type = Context.getPatientService().getPatientIdentifierTypeByName(idType);
    			boolean validIdentifier = false;
				try {
	                IdentifierValidator validator = Context.getPatientService().getIdentifierValidator(type.getValidator());
	                validIdentifier = validator.isValid(amrsId);
                }
                catch (UnallowedIdentifierException e) {
					log.error("Bad identifier: '" + amrsId + "'");
                }
                
                if (!validIdentifier) {
    				errors.reject("AMRS Id assigned is invalid according to the identifier validator.");
                } else {
        			boolean foundAmrsId = false;
        			for (PatientIdentifier identifier : patient.getIdentifiers()) {
    	                if (identifier.getIdentifierType().equals(type)) {
    	                	foundAmrsId = true;
    	                	identifier.setIdentifier(amrsId);
    	                }
        			}
    				if (!foundAmrsId) {
						PatientIdentifier identifier = new PatientIdentifier();
						identifier.setIdentifier(amrsId);
						identifier.setIdentifierType(type);
						identifier.setLocation(Context.getLocationService().getDefaultLocation());
						patient.addIdentifier(identifier);
    				}
                }
    			break;
			
		}
		
		return targetPage;
	}

	/**
	 * Allows for other Objects to be used as values in input tags. Normally, only strings and lists
	 * are expected
	 * 
	 * @see org.springframework.web.servlet.mvc.BaseCommandController#initBinder(javax.servlet.http.HttpServletRequest,
	 *      org.springframework.web.bind.ServletRequestDataBinder)
	 */
	protected void initBinder(HttpServletRequest request, ServletRequestDataBinder binder) throws Exception {
		super.initBinder(request, binder);
		
		NumberFormat nf = NumberFormat.getInstance(Context.getLocale());
		binder.registerCustomEditor(java.lang.Integer.class, new CustomNumberEditor(java.lang.Integer.class, nf, true));
		binder.registerCustomEditor(java.util.Date.class, new CustomDateEditor(Context.getDateFormat(), true, 10));
		binder.registerCustomEditor(PatientIdentifierType.class, new PatientIdentifierTypeEditor());
		binder.registerCustomEditor(Location.class, new LocationEditor());
		binder.registerCustomEditor(Concept.class, "civilStatus", new ConceptEditor());
		binder.registerCustomEditor(Concept.class, "causeOfDeath", new ConceptEditor());
	}

    protected ModelAndView processCancel(
            HttpServletRequest request,
            HttpServletResponse response, Object command,
            BindException bindException) throws Exception {
        return new ModelAndView(new RedirectView(request
                .getContextPath()
                + "/module/amrsregistration/registration.form"));
    }

    protected ModelAndView processFinish(
            HttpServletRequest request,
            HttpServletResponse response, Object command,
            BindException bindException) throws Exception {
        Patient patient = (Patient)command;
        if (patient != null) {
            Context.getPatientService().savePatient(patient);
        }
        return new ModelAndView(new RedirectView(request
                .getContextPath()
                + "/module/amrsregistration/registration.form"));
    }

    private Patient getNewPatient() {
    	Patient patient = null;
    	
        Set<PersonName> names = new TreeSet<PersonName>();
        names.add(new PersonName());
        
        Set<PersonAddress> addresses = new TreeSet<PersonAddress>();
        addresses.add(new PersonAddress());
        
        Person localPerson = new Person();
        localPerson.setNames(names);
        localPerson.setAddresses(addresses);
        
        PatientIdentifier identifier = new PatientIdentifier();
        identifier.setIdentifier("");
        Set<PatientIdentifier> identifiers = new TreeSet<PatientIdentifier>();
        identifiers.add(identifier);
        
        patient = new Patient(localPerson);
        patient.setIdentifiers(identifiers);
        return patient;
        
    }
    
    private void copyPatient(Patient to, Patient from) {
    	to.setPersonId(from.getPersonId());
		
    	to.setAddresses(from.getAddresses());
    	to.setNames(from.getNames());
    	to.setAttributes(from.getAttributes());
		
    	to.setGender(from.getGender());
    	to.setBirthdate(from.getBirthdate());
    	to.setBirthdateEstimated(from.getBirthdateEstimated());
    	to.setDead(from.isDead());
    	to.setDeathDate(from.getDeathDate());
    	to.setCauseOfDeath(from.getCauseOfDeath());
		
    	to.setPersonCreator(from.getPersonCreator());
    	to.setPersonDateCreated(from.getPersonDateCreated());
    	to.setPersonChangedBy(from.getPersonChangedBy());
    	to.setPersonDateChanged(from.getPersonDateChanged());
    	to.setPersonVoided(from.isPersonVoided());
    	to.setPersonVoidedBy(from.getPersonVoidedBy());
    	to.setPersonDateVoided(from.getPersonDateVoided());
    	to.setPersonVoidReason(from.getPersonVoidReason());
		to.setPatientId(from.getPatientId());
		to.setIdentifiers(from.getIdentifiers());
    }
    
    private void updateBirthdate(Patient patient, String date, String age) {
    	Date birthdate = null;
		boolean birthdateEstimated = false;
		if (date != null && !date.equals("")) {
			try {
				// only a year was passed as parameter
				if (date.length() < 5) {
					Calendar c = Calendar.getInstance();
					c.set(Calendar.YEAR, Integer.valueOf(date));
					c.set(Calendar.MONTH, 0);
					c.set(Calendar.DATE, 1);
					birthdate = c.getTime();
					birthdateEstimated = true;
				}
				// a full birthdate was passed as a parameter
				else {
					birthdate = Context.getDateFormat().parse(date);
					birthdateEstimated = false;
				}
			}
			catch (ParseException e) {
				log.debug("Error getting date from birthdate", e);
			}
		} else if (age != null && !age.equals("")) {
			Calendar c = Calendar.getInstance();
			c.setTime(new Date());
			Integer d = c.get(Calendar.YEAR);
			d = d - Integer.parseInt(age);
			try {
				birthdate = DateFormat.getDateInstance(DateFormat.SHORT).parse("01/01/" + d);
				birthdateEstimated = true;
			}
			catch (ParseException e) {
				log.debug("Error getting date from age", e);
			}
		}
		if (birthdate != null)
			patient.setBirthdate(birthdate);
		patient.setBirthdateEstimated(birthdateEstimated);
    }
}
