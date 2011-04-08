package org.openmrs.module.amrsregistration.web.controller;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.mvc.SimpleFormController;

/**
 * Extraordinarily simple form controller for the AMRS Registration login page.
 * The login page uses the default openmrs loginServlet, so there is not much
 * (or anything really) to do here.
 */
public class AmrsRegistrationLoginController extends SimpleFormController {

    public String showPage(Boolean showLog, ModelMap model) throws Exception {

        return "/module/amrsregistration/login.htm";
    }

    
}
