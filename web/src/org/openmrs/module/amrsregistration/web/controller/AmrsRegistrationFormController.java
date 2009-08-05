package org.openmrs.module.amrsregistration.web.controller;

import java.text.DateFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
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
import org.openmrs.propertyeditor.ConceptEditor;
import org.openmrs.propertyeditor.LocationEditor;
import org.openmrs.propertyeditor.PatientIdentifierTypeEditor;
import org.openmrs.validator.PatientIdentifierValidator;
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
	
    private Log log = LogFactory.getLog(AmrsRegistrationFormController.class);
	
	public AmrsRegistrationFormController() {
	}
	
	protected Object formBackingObject(HttpServletRequest request) throws ModelAndViewDefiningException {
		return getNewPatient();
	}
	
	/**
	 * @see org.springframework.web.servlet.mvc.AbstractWizardFormController#referenceData(javax.servlet.http.HttpServletRequest, java.lang.Object, org.springframework.validation.Errors, int)
	 */
	@Override
	protected Map<String, Object> referenceData(HttpServletRequest request, Object command, Errors errors, int page) throws Exception {
		HashMap<String, Object> localHashMap = new HashMap<String, Object>();
		
		if (page != AmrsRegistrationConstants.START_PAGE) {
			localHashMap.put("amrsIdType", AmrsRegistrationConstants.AMRS_TARGET_ID);
			if (page == AmrsRegistrationConstants.EDIT_PAGE) {
				localHashMap.put("emptyIdentifier", new PatientIdentifier());
				localHashMap.put("emptyName", new PersonName());
				localHashMap.put("emptyAddress", new PersonAddress());
				
				Patient patient = (Patient) command;
				AmrsSearchManager searchManager = new AmrsSearchManager();
				List<Patient> patients = searchManager.getPatients(patient.getPersonName(),
					patient.getPersonAddress(), patient.getPatientIdentifier(), patient.getAttributes(), patient.getGender(),
					patient.getBirthdate(), patient.getAge(), 10);
				request.setAttribute("potentialMatches", patients);
			}
		} else {
			PatientIdentifierType type = Context.getPatientService().getPatientIdentifierTypeByName(AmrsRegistrationConstants.AMRS_TARGET_ID);
			if (type == null) {
				errors.reject("amrsregistration.page.start.undefinedTarget",
					new Object[]{AmrsRegistrationConstants.AMRS_TARGET_ID},
					"Target identifier is not specified");
				errors.reject("amrsregistration.page.start.targetSpecify",
					new Object[]{AmrsRegistrationConstants.AMRS_TARGET_ID_KEY},
					"Please specify target in the global properties");
			}
		}
		
		return localHashMap;
	}
	
	/**
     * @see org.springframework.web.servlet.mvc.AbstractWizardFormController#postProcessPage(javax.servlet.http.HttpServletRequest, java.lang.Object, org.springframework.validation.Errors, int)
     */
    @Override
    protected void postProcessPage(HttpServletRequest request, Object command, Errors errors, int page) throws Exception {
    	Patient patient = (Patient) command;
    	
    	if (page == AmrsRegistrationConstants.EDIT_PAGE) {

			String idCard = ServletRequestUtils.getStringParameter(request, "patientIdInput", null);
    		if (idCard == null) {
        		
        		// remove from this list elements that already in the person attribute (list.remove(personattributeType)
                List<PersonAttributeType> attributeTypes = Context.getPersonService().getAllPersonAttributeTypes(false);
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
                    String value = ServletRequestUtils.getStringParameter(request, String.valueOf(id), StringUtils.EMPTY);
                    if (value != null && value.length() > 0) {
                        PersonAttribute attribute = new PersonAttribute();
                        attribute.setAttributeType(personAttributeType);
                        attribute.setValue(value);
                        patient.addAttribute(attribute);
                    }
                }

        		String namePreferred = ServletRequestUtils.getStringParameter(request, "namePreferred", StringUtils.EMPTY);
        		int selectedName = NumberUtils.toInt(namePreferred);
        		
        		boolean preferredNameCreated = true;
        		if (selectedName < patient.getNames().size()) {
        			// preferred is one of the name in the patient
        			// iterate the name and move the preferred to other place
        			preferredNameCreated = false;
        			int counter = 0;
        			for (PersonName name : patient.getNames()) {
        				if (counter == selectedName)
        					name.setPreferred(Boolean.TRUE);
        				else
        					name.setPreferred(Boolean.FALSE);
        				counter ++;
                    }
        		} else
        			selectedName = selectedName - patient.getNames().size();
        		
        		String identifierPreferred = ServletRequestUtils.getStringParameter(request, "identifierPreferred", StringUtils.EMPTY);
        		int selectedIdentifier = NumberUtils.toInt(identifierPreferred);

        		boolean preferredIdentifierCreated = true;
        		if (selectedIdentifier < patient.getIdentifiers().size()) {
        			// preferred is one of the name in the patient
        			// iterate the name and move the preferred to other place
        			preferredIdentifierCreated = false;
        			int counter = 0;
        			for (PatientIdentifier identifier: patient.getIdentifiers()) {
        				if (counter == selectedIdentifier)
        					identifier.setPreferred(Boolean.TRUE);
        				else
        					identifier.setPreferred(Boolean.FALSE);
        				counter ++;
                    }
        		} else
        			selectedIdentifier = selectedIdentifier - patient.getIdentifiers().size();
        		
        		String addressPreferred = ServletRequestUtils.getStringParameter(request, "addressPreferred", StringUtils.EMPTY);
        		int selectedAddress = NumberUtils.toInt(addressPreferred);
        		boolean preferredAddressCreated = true;
        		if (selectedAddress < patient.getAddresses().size()) {
        			// preferred is one of the name in the patient
        			// iterate the name and move the preferred to other place
        			preferredAddressCreated = false;
        			int counter = 0;
        			for (PersonAddress address: patient.getAddresses()) {
        				if (counter == selectedAddress)
        					address.setPreferred(Boolean.TRUE);
        				else
        					address.setPreferred(Boolean.FALSE);
        				counter ++;
                    }
        		} else
        			selectedAddress = selectedAddress - patient.getAddresses().size();
        		
        		String[] ids = ServletRequestUtils.getStringParameters(request, "identifier");
        		String[] idTypes = ServletRequestUtils.getStringParameters(request, "identifierType");
        		String[] locations = ServletRequestUtils.getStringParameters(request, "location");
        		
        		if (ids != null || idTypes != null) {
        			int maxIds = 0;
        			if (ids != null && ids.length > maxIds)
        				maxIds = ids.length;
        			
        			LocationService locationService = Context.getLocationService();
        			
        			for (int j = 0; j < maxIds; j++) {
                        PatientIdentifier identifier = new PatientIdentifier();
                        identifier.setIdentifier(ids[j]);
                        
                        Integer idType = NumberUtils.createInteger(idTypes[j]);
                        identifier.setIdentifierType(Context.getPatientService().getPatientIdentifierType(idType));
                        
                        Integer location = NumberUtils.createInteger(locations[j]);
                        identifier.setLocation(locationService.getLocation(location));
                        if (preferredIdentifierCreated && selectedIdentifier == j)
                        	identifier.setPreferred(Boolean.TRUE);
        				patient.addIdentifier(identifier);
                    }
        		}

        		String[] givenNames = ServletRequestUtils.getStringParameters(request, "givenName");
        		String[] middleNames = ServletRequestUtils.getStringParameters(request, "middleName");
        		String[] familyNames = ServletRequestUtils.getStringParameters(request, "familyName");
        		
        		if (givenNames != null || middleNames != null ||
        				familyNames != null) {
        			
        			int maxNames = 0;
        			if (givenNames != null && givenNames.length > maxNames)
        				maxNames = givenNames.length;
        			if (middleNames != null && middleNames.length > maxNames)
        				maxNames = middleNames.length;
        			if (familyNames != null && familyNames.length > maxNames)
        				maxNames = familyNames.length;
        			
        			for (int j = 0; j < maxNames; j++) {
        				PersonName name = new PersonName();
        				name.setGivenName(givenNames[j]);
        				name.setMiddleName(middleNames[j]);
        				name.setFamilyName(familyNames[j]);
        				if (preferredNameCreated && selectedName == j)
        					name.setPreferred(Boolean.TRUE);
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
                        if (preferredAddressCreated && selectedAddress == j)
                        	pa.setPreferred(Boolean.TRUE);
        				patient.addAddress(pa);
        			}
        		}
    		}
    	}
    	
    	if (page == AmrsRegistrationConstants.ASSIGN_ID_PAGE) {
			String amrsId = ServletRequestUtils.getStringParameter(request, "amrsIdentifier", null);
			if (amrsId != null) {
				PatientIdentifierType type = Context.getPatientService().getPatientIdentifierTypeByName(AmrsRegistrationConstants.AMRS_TARGET_ID);
            	boolean foundAmrsId = false;
				try {
	                PatientIdentifierValidator.validateIdentifier(amrsId, type);
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
                        PatientIdentifierValidator.validateIdentifier(identifier);
                		patient.addIdentifier(identifier);
	                }
                }
                catch (Exception e) {
        			errors.reject(e.getMessage());
                }
			}
    	}
		
		if (getTargetPage(request, page) == AmrsRegistrationConstants.EDIT_PAGE) {
			int nonTargetedIdentifier = 0;
			for (PatientIdentifier identifier : patient.getIdentifiers()) {
				PatientIdentifierType identifierType = identifier.getIdentifierType();
				if (identifierType != null) {
						if (!identifier.isVoided() &&
								!AmrsRegistrationConstants.AMRS_TARGET_ID.equals(identifierType.getName())) {
							nonTargetedIdentifier ++;
						}
				} else
					// assume null type to be non target identifier
					nonTargetedIdentifier ++;
            }
			if (nonTargetedIdentifier <= 0) {
		        PatientIdentifier identifier = new PatientIdentifier();
		        identifier.setIdentifier("");
		        patient.addIdentifier(identifier);
			}
		}
    }

	/**
     * @see org.springframework.web.servlet.mvc.AbstractWizardFormController#onBindAndValidate(javax.servlet.http.HttpServletRequest, java.lang.Object, org.springframework.validation.BindException, int)
     */
    @SuppressWarnings("unchecked")
    @Override
    protected void onBindAndValidate(HttpServletRequest request, Object command, BindException errors, int page)
                                                                                                                throws Exception {
    	Patient patient = (Patient) command;
		
		if (page == AmrsRegistrationConstants.EDIT_PAGE) {
			String date = ServletRequestUtils.getStringParameter(request, "birthdateInput", "");
			String age = ServletRequestUtils.getStringParameter(request, "ageInput", null);
			updateBirthdate(patient, date, age);
			
			boolean[] addresses = new boolean[patient.getAddresses().size()];
			boolean[] names = new boolean[patient.getNames().size()];
			boolean[] ids = new boolean[patient.getIdentifiers().size()];
			
			int counter = NumberUtils.max(addresses.length, names.length, ids.length);
			for (int i = 0; i < counter; i++) {
	            if (i < addresses.length)
	            	addresses[i] = false;
	            if (i < names.length)
	            	names[i] = false;
	            if (i < ids.length)
	            	ids[i] = false;
            }

			boolean updateNeeded = false;
			Enumeration paramNames = request.getParameterNames();
			while (paramNames.hasMoreElements()) {
				String paramName = (String) paramNames.nextElement();
				for (int i = 0; i < counter; i++) {
					if (paramName.startsWith("identifiers[" + i + "]")) {
						ids[i] = true;
						updateNeeded = true;
					}
					if (paramName.startsWith("addresses[" + i + "]")) {
						addresses[i] = true;
						updateNeeded = true;
					}
					if (paramName.startsWith("names[" + i + "]")) {
						names[i] = true;
						updateNeeded = true;
					}
                }
			}
			
			if (updateNeeded) {
				
				int deleteCounter = 0;
				for (PersonName name : patient.getNames()) {
		            if (!names[deleteCounter]) {
		            	if (name.getPersonNameId() != null)
		            		errors.reject("amrsregistration.page.edit.namesWithId");
		            	else
		            		patient.removeName(name);
		            }
		            deleteCounter ++;
				}
				
				deleteCounter = 0;
				for (PersonAddress address : patient.getAddresses()) {
		            if (!addresses[deleteCounter]) {
		            	if (address.getPersonAddressId() != null)
		            		errors.reject("amrsregistration.page.edit.addressWithId");
		            	else
		            		patient.removeAddress(address);
		            }
		            deleteCounter ++;
				}
				
				// handle the target identifier
				deleteCounter = 0;
				for (PatientIdentifier identifier : patient.getIdentifiers())
		            if (!ids[deleteCounter]) {
		            	if (StringUtils.isBlank(identifier.getIdentifier()))
		            		patient.removeIdentifier(identifier);
		            deleteCounter ++;
				}
			}
		}
    	
	    super.onBindAndValidate(request, command, errors, page);
    }

	protected int getTargetPage(HttpServletRequest request, Object command, Errors errors, int page) {		
		
		int targetPage = super.getTargetPage(request, command, errors, page);
		
		Patient patient = (Patient) command;
		
		PatientService patientService = Context.getPatientService();
		
		if (page == AmrsRegistrationConstants.START_PAGE) {
			String idCard = ServletRequestUtils.getStringParameter(request, "idCardInput", null);
			if (idCard != null) {
				List<Patient> patients = patientService.getPatients(StringUtils.EMPTY, idCard, null, true);
				if (patients != null && patients.size() > 0) {
					// default to found patient, but no required id type
					targetPage = AmrsRegistrationConstants.ASSIGN_ID_PAGE;
					if (patients.size() > 1) {
						request.setAttribute("potentialMatches", patients);
						request.setAttribute("selectionOnly", Boolean.TRUE);
					}
					else {
						Patient matchedPatient = patients.get(0);
						copyPatient(patient, matchedPatient);
						patient.getAttributeMap();
						if (targetIdentifierExists(patient))
							targetPage = AmrsRegistrationConstants.REVIEW_PAGE;
					}
				} else
					errors.reject("amrsregistration.page.start.error", new Object[] {idCard}, "No patient found in the system");
			}
		} else if (page == AmrsRegistrationConstants.EDIT_PAGE) {
			String patientId = ServletRequestUtils.getStringParameter(request, "patientIdInput", null);
			if (patientId != null) {
				Patient matchedPatient = patientService.getPatient(NumberUtils.toInt(patientId));
				if (matchedPatient != null) {
					copyPatient(patient, matchedPatient);
					patient.getAttributeMap();
				}
			}
			
			targetPage = AmrsRegistrationConstants.ASSIGN_ID_PAGE;
			if (targetIdentifierExists(patient))
				targetPage = AmrsRegistrationConstants.REVIEW_PAGE;
			
			validate(command, errors, false);
			
		} else if (page == AmrsRegistrationConstants.ASSIGN_ID_PAGE) {
			String patientId = ServletRequestUtils.getStringParameter(request, "patientIdInput", null);
			if (patientId != null) {
				Patient matchedPatient = patientService.getPatient(NumberUtils.toInt(patientId));
				if (matchedPatient != null) {
					copyPatient(patient, matchedPatient);
					patient.getAttributeMap();
					
					targetPage = AmrsRegistrationConstants.ASSIGN_ID_PAGE;
					if (targetIdentifierExists(patient))
						targetPage = AmrsRegistrationConstants.REVIEW_PAGE;
				}
			}
		}
		
		return targetPage;
	}
	
	private boolean targetIdentifierExists(Patient patient) {
		boolean exist = false;
		for (PatientIdentifier identifier : patient.getIdentifiers()) {
			PatientIdentifierType identifierType = identifier.getIdentifierType();
			if (identifierType != null &&
					!identifier.isVoided() &&
					AmrsRegistrationConstants.AMRS_TARGET_ID.equals(identifierType.getName())) {
				// found the required id type, go to confirmation page
				exist = true;
				break;
			}
        }
		return exist;
	}
	
	

	@Override
    protected void validatePage(Object command, Errors errors, int page, boolean finish) {
		// only validate when process finish is being called
		if (finish && page == AmrsRegistrationConstants.EDIT_PAGE) {
			validate(command, errors, finish);
		}
		
		if (finish && page == AmrsRegistrationConstants.ASSIGN_ID_PAGE) {
			Patient patient = (Patient) command;
			PatientIdentifierValidator validator = new PatientIdentifierValidator();
			for (PatientIdentifier identifier: patient.getIdentifiers()) {
				PatientIdentifierType identifierType = identifier.getIdentifierType();
				if (!identifier.isVoided() &&
						identifierType != null &&
						AmrsRegistrationConstants.AMRS_TARGET_ID.equals(identifierType.getName()))
					validator.validate(identifier, errors);
			}
		}
	}
	
	
	
	private void validate(Object command, Errors errors, boolean finish) {
		
		Patient patient = (Patient) command;
		
		boolean foundInvalid = false;
		for (PersonName name: patient.getNames()) {
			
			// if all fields for the name is empty then check if the name already has an id
			// if yes, then that name can only be voided
			// if no, then we can remove the name
    		if (StringUtils.isBlank(name.getFamilyName()) &&
    				StringUtils.isBlank(name.getGivenName()) &&
    				StringUtils.isBlank(name.getMiddleName())) {
    			if (name.getPersonNameId() != null)
    				foundInvalid = true;
    			else {
    				if (patient.getNames().size() > 1)
    					patient.removeName(name);
    				else
    					foundInvalid = true;
    			}
    		}
        }
		
		// show message for empty name with id
		if (foundInvalid) {
			errors.reject("amrsregistration.page.edit.invalidName");
		}
		
		if (patient.getBirthdate() == null)
			errors.rejectValue("birthdate", "amrsregistration.page.edit.invalidDate");
		else {
			if (patient.getBirthdate().after(new Date()))
    			errors.rejectValue("birthdate", "amrsregistration.page.edit.futureDate");
		}
		
		if (StringUtils.isEmpty(patient.getGender()))
			errors.rejectValue("gender", "amrsregistration.page.edit.invalidGender");
		
		if (finish) {
			// only validate when processing finish, otherwise this will always shows error in edit page
			PatientIdentifierValidator validator = new PatientIdentifierValidator();
			for (PatientIdentifier identifier: patient.getIdentifiers()) {
				PatientIdentifierType identifierType = identifier.getIdentifierType();
				if (!identifier.isVoided() &&
						identifierType != null &&
						!StringUtils.isBlank(identifier.getIdentifier()) &&
						!AmrsRegistrationConstants.AMRS_TARGET_ID.equals(identifierType.getName()))
					validator.validate(identifier, errors);
						
			}
		}
		
		foundInvalid = false;
		for (PersonAddress address: patient.getAddresses()) {
    		if (StringUtils.isBlank(address.getSubregion()) ||
    				StringUtils.isBlank(address.getRegion()))
    			
    			// TODO: probably need to do validation like above (name)
    			foundInvalid = true;
        }
		
		if (foundInvalid)
			errors.reject("amrsregistration.page.edit.invalidAddress");
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
    	
        Set<PatientIdentifier> identifiers = new TreeSet<PatientIdentifier>();
		for (PatientIdentifier identifier : patient.getIdentifiers()) {
            if(StringUtils.isBlank(identifier.getIdentifier()))
            	identifiers.add(identifier);
        }
		patient.getIdentifiers().removeAll(identifiers);
		
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
		if (birthdate != null) {
			patient.setBirthdate(birthdate);
			patient.setBirthdateEstimated(birthdateEstimated);
		}
    }
}
