package org.openmrs.module.amrsregistration;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.module.Activator;

public class RegistrationActivator implements Activator {
    private Log log;

    public RegistrationActivator() {
        this.log = LogFactory.getLog(super.getClass());
    }

    public void startup() {
        this.log.info("Starting Remote Registration Module");
    }

    public void shutdown() {
        this.log.info("Shutting down Remote Registration Module");
    }
}
