package org.openmrs.module.amrsregistration.test;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Date;
import java.util.Properties;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;

import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.reporting.export.DataExportFunctions;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.openmrs.util.OpenmrsUtil;

public class VelocityTest extends BaseModuleContextSensitiveTest {
    @Before
    public void runBeforeEachTest() throws Exception {
        authenticate();
    }

    public Boolean useInMemoryDatabase() {
        return Boolean.valueOf(false);
    }

    @Test
    public void shouldUseVelocityContextToCreateXml() {
        try {
            File localFile1 = new File(
                    "test/org/openmrs/module/amrsregistration/include/registrationTemplate.xml");
            String str = OpenmrsUtil.getFileAsString(localFile1);

            Properties localProperties = new Properties();
            localProperties.setProperty("resource.loader", "class");
            localProperties.setProperty("class.resource.loader.description",
                    "VelocityClasspathResourceLoader");
            localProperties
                    .setProperty("class.resource.loader.class",
                            "org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader");
            localProperties.setProperty("runtime.log.logsystem.class",
                    "org.apache.velocity.runtime.log.NullLogSystem");

            Velocity.init(localProperties);
            VelocityContext localVelocityContext = new VelocityContext();
            localVelocityContext.put("locale", Context.getLocale());
            localVelocityContext.put("patient", Context.getPatientService()
                    .getPatient(Integer.valueOf(364)));
            localVelocityContext.put("user", Context.getAuthenticatedUser());
            localVelocityContext.put("fn", new DataExportFunctions());
            localVelocityContext.put("dateEntered", new Date());
            StringWriter localStringWriter = new StringWriter();
            Velocity.evaluate(localVelocityContext, localStringWriter, super
                    .getClass().getName(), str);

            File localFile2 = new File("out/remoteRegistrationTest.xml");
            try {
                FileWriter localFileWriter = new FileWriter(localFile2);
                localFileWriter.write(localStringWriter.toString());
                localFileWriter.flush();
                localFileWriter.close();
            } catch (IOException localIOException2) {
                Assert.fail(localIOException2.getMessage());
                System.out.println("Unable to write output file: "
                        + localIOException2.getMessage());
            }
        } catch (IOException localIOException1) {
            Assert.fail(localIOException1.getMessage());
            throw new APIException("Cannot get xsl file. ", localIOException1);
        } catch (TransformerConfigurationException localTransformerConfigurationException) {
            Assert.fail(localTransformerConfigurationException.getMessage());
            throw new APIException("Error generating report",
                    localTransformerConfigurationException);
        } catch (TransformerException localTransformerException) {
            Assert.fail(localTransformerException.getMessage());
            throw new APIException("Error generating report",
                    localTransformerException);
        } catch (Exception localException) {
            Assert.fail(localException.getMessage());
        }
    }
}
