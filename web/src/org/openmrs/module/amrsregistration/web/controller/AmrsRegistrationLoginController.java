package org.openmrs.module.amrsregistration.web.controller;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.mvc.SimpleFormController;
import org.openmrs.api.context.Context;


public class AmrsRegistrationLoginController extends SimpleFormController {

    public String showPage(Boolean showLog, ModelMap model) throws Exception {


        if (showLog != null && showLog == true) {
        }

        return "/module/amrsregistration/login.htm";
    }

    
}
