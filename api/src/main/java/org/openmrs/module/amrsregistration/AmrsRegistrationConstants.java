package org.openmrs.module.amrsregistration;

import org.openmrs.api.context.Context;

public interface AmrsRegistrationConstants {
	
	public static final int START_PAGE = 0;
	
	public static final int EDIT_PAGE = 1;
	
	public static final int ASSIGN_ID_PAGE = 2;
	
	public static final int REVIEW_PAGE = 3;
	
	public static final String AMRS_TARGET_ID_KEY = "amrsregistration.idType";
	
	public static final String AMRS_TARGET_ID = Context.getAdministrationService().getGlobalProperty(AMRS_TARGET_ID_KEY);
        
        public static final String GP_ARCHIVE_DIR = "amrsregistration.archive_dir";
	
        public static final String GP_ARCHIVE_DIR_DEFAULT = "amrsregistration/archive/%Y/%M";

}
