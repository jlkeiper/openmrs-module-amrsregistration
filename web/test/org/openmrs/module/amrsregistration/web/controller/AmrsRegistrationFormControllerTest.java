package org.openmrs.module.amrsregistration.web.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.junit.Test;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.openmrs.test.Verifies;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.validation.BindException;

public class AmrsRegistrationFormControllerTest extends
		BaseModuleContextSensitiveTest {

	/**
	 * @see {@link AmrsRegistrationFormController#processFinish(HttpServletRequest,HttpServletResponse,Object,BindException)}
	 */
	@Test
	@Verifies(value = "should not throw a null pointer exception if command is null", method = "processFinish(HttpServletRequest,HttpServletResponse,Object,BindException)")
	public void processFinish_shouldNotThrowANullPointerExceptionIfCommandIsNull()
			throws Exception {

		MockHttpServletRequest request = new MockHttpServletRequest("GET", "");

		HttpServletResponse response = new MockHttpServletResponse();

		AmrsRegistrationFormController controller = (AmrsRegistrationFormController) applicationContext
				.getBean("amrsRegistrationWizardForm");

		BindException errors = new BindException(new Object(), "");

		controller.processFinish(request, response, null, errors);
	}
}