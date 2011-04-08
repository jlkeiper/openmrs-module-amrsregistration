/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.amrsregistration.db;

import org.openmrs.api.db.DAOException;


public class OverabundantResultSetException extends DAOException {

    private static final long serialVersionUID = -185144341535149876L;

    public OverabundantResultSetException() {
    }

    public OverabundantResultSetException(String message) {
        super(message);
    }

    public OverabundantResultSetException(String message, Throwable cause) {
        super(message, cause);
    }

    public OverabundantResultSetException(Throwable cause) {
        super(cause);
    }
    
}
