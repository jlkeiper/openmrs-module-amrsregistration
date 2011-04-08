package org.openmrs.module.amrsregistration;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.Relationship;
import org.openmrs.RelationshipType;


public class AmrsRegistration implements Serializable{

	/**
     * 
     */
    private static final long serialVersionUID = 1L;
    
    private List<Relationship> relationships;
    
    private Patient patient;

	/**
     * 
     */
    public AmrsRegistration() {
	    super();
    }

	/**
     * @param relationships
     * @param patient
     */
    public AmrsRegistration(List<Relationship> relationships, Patient patient) {
	    super();
	    this.relationships = relationships;
	    this.patient = patient;
    }
	
    /**
     * @return the relationships
     */
    public List<Relationship> getRelationships() {
    	return relationships;
    }
	
    /**
     * @param relationships the relationships to set
     */
    public void setRelationships(List<Relationship> relationships) {
    	this.relationships = relationships;
    }
	
    /**
     * @return the patient
     */
    public Patient getPatient() {
    	return patient;
    }
	
    /**
     * @param patient the patient to set
     */
    public void setPatient(Patient patient) {
    	this.patient = patient;
    }
    
    public void addRelationship(Relationship relationship) {
    	getRelationships().add(relationship);
    }
    
    // need to perform this to prevent no session exception
    public void initRelationship(Relationship r) {
    	if (getRelationships() == null)
    		setRelationships(new ArrayList<Relationship>());
    	Person personA = new Person(r.getPersonA());
    	Person personB = new Person(r.getPersonB());
    	
    	// only create a partial relationship type
    	// need to do lookup before saving or updating the relationship
    	RelationshipType type = new RelationshipType();
    	type.setRelationshipTypeId(r.getRelationshipType().getRelationshipTypeId());
    	type.setaIsToB(r.getRelationshipType().getaIsToB());
    	type.setbIsToA(r.getRelationshipType().getbIsToA());
    	
    	Relationship relationship = new Relationship(personA, personB, type);
    	
    	relationship.setRelationshipId(r.getRelationshipId());
    	relationship.setCreator(r.getCreator());
    	relationship.setDateCreated(r.getDateCreated());
    	
    	getRelationships().add(relationship);
    }

}
