package org.openmrs.module.amrsregistration;

import org.openmrs.api.APIException;

public interface AmrsRegistrationService {

	/**
	 * Generate an XML file as a record of this registration event.
	 *
	 * @param registration the registration event to be encoded
	 * @throws APIException
	 */
	public String renderRegistrationXML(AmrsRegistration registration) throws APIException;

	/**
	 * Saves an XML file to an archive.
	 *
	 * @param xml the file to be saved
	 * @throws APIException
	 */
	public void saveRegistrationXMLToFile(String xml) throws APIException;

	/**
	 * Reads an XML file and interprets it into an AmrsRegistration object.
	 *
	 * @param xml source file for registration event
	 * @return the rendered registration object
	 * @throws APIException
	 */
	public AmrsRegistration renderRegistration(String xml) throws APIException;

	/**
	 * Saves a registration event.
	 *
	 * @param registration the registration event details
	 * @throws APIException
	 */
	public void register(AmrsRegistration registration) throws APIException;
}
