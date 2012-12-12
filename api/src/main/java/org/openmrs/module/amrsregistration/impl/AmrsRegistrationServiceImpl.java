package org.openmrs.module.amrsregistration.impl;

import com.thoughtworks.xstream.XStream;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.lang.StringUtils;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;
import org.openmrs.Person;
import org.openmrs.Relationship;
import org.openmrs.User;
import org.openmrs.api.APIException;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.context.Context;
import org.openmrs.module.amrsregistration.AmrsRegistration;
import org.openmrs.module.amrsregistration.AmrsRegistrationConstants;
import org.openmrs.module.amrsregistration.AmrsRegistrationService;
import org.openmrs.module.amrsregistration.db.AmrsRegistrationDAO;
import org.openmrs.reporting.export.DataExportFunctions;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.transaction.annotation.Transactional;

public class AmrsRegistrationServiceImpl implements AmrsRegistrationService {

	private static Log log = LogFactory.getLog(AmrsRegistrationServiceImpl.class);
	private AmrsRegistrationDAO dao;
	private String registrationArchiveFileName = null;

	/**
	 * setter for local AMRS Registration DAO
	 *
	 * @param dao
	 */
	public void setDao(AmrsRegistrationDAO dao) {
		this.dao = dao;
	}

	/**
	 * This method will be used for remote registration.  Registered patient
	 * information will be placed into an xml file for the FormEntry processor.
	 *
	 * @param paramPatient
	 * @param paramString1
	 * @param paramString2
	 * @throws APIException
	 */
	public void renderRegistrationXML(Patient paramPatient, String paramString1,
	                                  String paramString2) throws APIException {

		File localFile1 = OpenmrsUtil.getDirectoryInApplicationDataDirectory("amrsregistration");
		File localFile2 = new File(localFile1, "registrationTemplate.xml");
		try {
			String str1 = OpenmrsUtil.getFileAsString(localFile2);

			Properties localProperties = new Properties();
			localProperties.setProperty("resource.loader", "class");
			localProperties.setProperty("class.resource.loader.description",
					"VelocityClasspathResourceLoader");
			localProperties.setProperty("class.resource.loader.class",
					"org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader");
			localProperties.setProperty("runtime.log.logsystem.class",
					"org.apache.velocity.runtime.log.NullLogSystem");

			Velocity.init(localProperties);
			VelocityContext localVelocityContext = new VelocityContext();
			localVelocityContext.put("locale", Context.getLocale());
			localVelocityContext.put("patient", Context.getPatientService().getPatient(paramPatient.getPatientId()));
			localVelocityContext.put("user", Context.getAuthenticatedUser());
			localVelocityContext.put("fn", new DataExportFunctions());
			localVelocityContext.put("dateEntered", new Date());
			localVelocityContext.put("sid", paramString1);
			localVelocityContext.put("uid", paramString2);
			StringWriter localStringWriter = new StringWriter();
			Velocity.evaluate(localVelocityContext, localStringWriter, super.getClass().getName(), str1);

			String str2 = Context.getAdministrationService().getGlobalProperty(
					"remoteformentry.pending_queue_dir");
			File localFile3 = OpenmrsUtil.getDirectoryInApplicationDataDirectory(str2);
			Date localDate = new Date();
			String str3 = "amrsregistration_" + localDate.toString();
			File localFile4 = new File(localFile3, str3);
			try {
				FileWriter localFileWriter = new FileWriter(localFile4);
				localFileWriter.write(localStringWriter.toString());
				localFileWriter.flush();
				localFileWriter.close();
			} catch (IOException localIOException) {
				log.error("Unable to write amrsregistration output file.",
						localIOException);
			}
		} catch (Exception localException) {
			log.error("Unable to create amrsregistration output file",
					localException);
			throw new APIException(localException);
		}
	}

	/**
	 * @see AmrsRegistrationService#renderRegistrationXML(org.openmrs.module.amrsregistration.AmrsRegistration)
	 */
	public String renderRegistrationXML(AmrsRegistration registration) throws APIException {
		XStream xstream = new XStream();
		return xstream.toXML(registration);
	}

	/**
	 * @see AmrsRegistrationService#saveRegistrationXMLToFile(java.lang.String)
	 */
	public void saveRegistrationXMLToFile(String xml) throws APIException {

		User creator = Context.getAuthenticatedUser();
		Date now = new Date();
		File queueDir = getRegistrationArchiveDir(now);
		File outFile = OpenmrsUtil.getOutFile(queueDir, now, creator);

		// write the queue's data to the file
		try {
			FileWriter writer = new FileWriter(outFile);
			writer.write(xml);
			writer.close();
		} catch (IOException io) {
			throw new APIException("Unable to save registration archive", io);
		}

	}

	/**
	 * Gets the directory where the user specified their archives were being
	 * stored
	 *
	 * @param d Date to specify the folder this should possibly be sorted into
	 * @return directory in which to store archived items
	 */
	private File getRegistrationArchiveDir(Date d) {
		// cache the global property location so we don't have to hit the db
		// everytime
		if (registrationArchiveFileName == null) {
			AdministrationService as = Context.getAdministrationService();
			registrationArchiveFileName = as.getGlobalProperty(
					AmrsRegistrationConstants.GP_ARCHIVE_DIR,
					AmrsRegistrationConstants.GP_ARCHIVE_DIR_DEFAULT);
		}

		// replace %Y %M %D in the folderName with the date
		String folderName = replaceVariables(registrationArchiveFileName, d);

		// get the file object for this potentially new file
		File registrationArchiveDir = OpenmrsUtil.getDirectoryInApplicationDataDirectory(folderName);

		if (log.isDebugEnabled()) {
			log.debug("Loaded formentry archive directory from global properties: "
					+ registrationArchiveDir.getAbsolutePath());
		}

		return registrationArchiveDir;
	}

	/**
	 * Replaces %Y in the string with the four digit year. Replaces %M with the
	 * two digit month Replaces %D with the two digit day Replaces %w with week
	 * of the year Replaces %W with week of the month
	 *
	 * @param str String filename containing variables to replace with date
	 *            strings
	 * @return String with variables replaced
	 */
	private String replaceVariables(String str, Date d) {

		Calendar calendar = Calendar.getInstance();
		if (d != null) {
			calendar.setTime(d);
		}

		int year = calendar.get(Calendar.YEAR);
		str = str.replace("%Y", Integer.toString(year));

		int month = calendar.get(Calendar.MONTH) + 1;
		String monthString = Integer.toString(month);
		if (month < 10) {
			monthString = "0" + monthString;
		}
		str = str.replace("%M", monthString);

		int day = calendar.get(Calendar.DATE);
		String dayString = Integer.toString(day);
		if (day < 10) {
			dayString = "0" + dayString;
		}
		str = str.replace("%D", dayString);

		int week = calendar.get(Calendar.WEEK_OF_YEAR);
		String weekString = Integer.toString(week);
		if (week < 10) {
			weekString = "0" + week;
		}
		str = str.replace("%w", weekString);

		int weekmonth = calendar.get(Calendar.WEEK_OF_MONTH);
		String weekmonthString = Integer.toString(weekmonth);
		if (weekmonth < 10) {
			weekmonthString = "0" + weekmonthString;
		}
		str = str.replace("%W", weekmonthString);

		return str;
	}

	/**
	 * @see AmrsRegistrationService#renderRegistration(java.lang.String)
	 */
	public AmrsRegistration renderRegistration(String xml) throws APIException {
		XStream xstream = new XStream();
		return (AmrsRegistration) xstream.fromXML(xml);
	}

	/**
	 * @see AmrsRegistrationService#register(org.openmrs.module.amrsregistration.AmrsRegistration)
	 */
	@Transactional
	public void register(AmrsRegistration registration) throws APIException {
		Patient patient = registration.getPatient();

		List<PatientIdentifier> identifiers = new ArrayList<PatientIdentifier>();
		for (PatientIdentifier identifier : patient.getIdentifiers()) {
			if (StringUtils.isNotBlank(identifier.getIdentifier())) {
				identifiers.add(identifier);
			}
		}

		Set<PatientIdentifier> patientIdentifiers = new TreeSet<PatientIdentifier>();
		patientIdentifiers.addAll(identifiers);
		patient.setIdentifiers(patientIdentifiers);

		for (PatientIdentifier identifier : patient.getIdentifiers()) {
			if (!AmrsRegistrationConstants.AMRS_TARGET_ID.equals(identifier.getIdentifierType().getName())) {
				identifier.setPreferred(false);
			} else {
				identifier.setPreferred(true);
			}
		}

		if (patient != null) {
			Patient savedPatient = Context.getPatientService().savePatient(patient);
			for (Relationship relationship : registration.getRelationships()) {
				if (isSimilar(savedPatient, relationship.getPersonA())) {
					relationship.setPersonA(savedPatient);
					Person otherPerson = relationship.getPersonB();
					if (otherPerson.getPersonId() == null) {
						Person personB = Context.getPersonService().savePerson(otherPerson);
						relationship.setPersonB(personB);
					}
				} else {
					relationship.setPersonB(savedPatient);
					Person otherPerson = relationship.getPersonA();
					if (otherPerson.getPersonId() == null) {
						Person personA = Context.getPersonService().savePerson(otherPerson);
						relationship.setPersonA(personA);
					}
				}
				Context.getPersonService().saveRelationship(relationship);
			}
		}
	}

	/**
	 * returns true of gender, birthdate and name are the same for two persons
	 *
	 * @param a Person A
	 * @param b Person B
	 * @return whether the two persons are similar
	 */
	private boolean isSimilar(Person a, Person b) {
		if (a != null && b != null) {
			return a.getGender().equals(b.getGender())
					&& a.getBirthdate().equals(b.getBirthdate())
					&& a.getPersonName().equals(b.getPersonName());
		}
		return false;
	}
}
