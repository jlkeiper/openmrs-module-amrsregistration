package org.openmrs.module.amrsregistration.db.hibernate;

import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.Expression;
import org.hibernate.criterion.MatchMode;
import org.hibernate.criterion.Order;
import org.openmrs.Person;
import org.openmrs.PersonAddress;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonName;
import org.openmrs.api.db.DAOException;
import org.openmrs.module.amrsregistration.db.AmrsRemoteRegistrationDAO;

public class HibernateAmrsRemoteRegistrationDAO implements AmrsRemoteRegistrationDAO {
    protected final Log log = LogFactory.getLog(super.getClass());
    private SessionFactory sessionFactory;

    public void setSessionFactory(SessionFactory paramSessionFactory) {
        this.sessionFactory = paramSessionFactory;
    }

    @SuppressWarnings("unchecked")
    public List<Person> getPersons(PersonName paramPersonName,
            PersonAddress paramPersonAddress, Set<PersonAttribute> paramSet,
            String paramString, Date paramDate, Integer paramInteger)
            throws DAOException {
        Object localObject2;
        Criteria localCriteria = this.sessionFactory.getCurrentSession()
                .createCriteria(Person.class, "person").setResultTransformer(
                        Criteria.DISTINCT_ROOT_ENTITY).createAlias("names",
                        "names", 1).createAlias("addresses", "addresses", 1)
                .createAlias("attributes", "attributes", 1).createAlias(
                        "attributes.attributeType", "attributeType", 1);

        if (paramPersonName != null) {
            if ((paramPersonName.getPrefix() != null)
                    && (!(paramPersonName.getPrefix().isEmpty()))) {
                localCriteria.add(Expression.like("names.prefix",
                        paramPersonName.getPrefix(), MatchMode.START));
            }
            if ((paramPersonName.getGivenName() != null)
                    && (paramPersonName.getGivenName().length() > 2)) {
                localCriteria.add(Expression.like("names.givenName",
                        paramPersonName.getGivenName(), MatchMode.START));
            }
            if ((paramPersonName.getMiddleName() != null)
                    && (paramPersonName.getMiddleName().length() > 2)) {
                localCriteria.add(Expression.like("names.middleName",
                        paramPersonName.getMiddleName(), MatchMode.START));
            }
            if ((paramPersonName.getFamilyNamePrefix() != null)
                    && (!(paramPersonName.getFamilyNamePrefix().isEmpty()))) {
                localCriteria
                        .add(Expression.like("names.familyNamePrefix",
                                paramPersonName.getFamilyNamePrefix(),
                                MatchMode.START));
            }
            if ((paramPersonName.getFamilyName() != null)
                    && (paramPersonName.getFamilyName().length() > 2)) {
                localCriteria.add(Expression.like("names.familyName",
                        paramPersonName.getFamilyName(), MatchMode.START));
            }
            if ((paramPersonName.getFamilyName2() != null)
                    && (paramPersonName.getFamilyName2().length() > 2)) {
                localCriteria.add(Expression.like("names.familyName2",
                        paramPersonName.getFamilyName2(), MatchMode.START));
            }
        }

        if (paramPersonAddress != null) {
            if ((paramPersonAddress.getAddress1() != null)
                    && (paramPersonAddress.getAddress1().length() > 2)) {
                localCriteria.add(Expression.like("addresses.address1",
                        paramPersonAddress.getAddress1(), MatchMode.START));
            }
            if ((paramPersonAddress.getAddress2() != null)
                    && (paramPersonAddress.getAddress2().length() > 2)) {
                localCriteria.add(Expression.like("addresses.address2",
                        paramPersonAddress.getAddress2(), MatchMode.START));
            }
            if ((paramPersonAddress.getCityVillage() != null)
                    && (paramPersonAddress.getCityVillage().length() > 2)) {
                localCriteria.add(Expression.like("addresses.cityVillage",
                        paramPersonAddress.getCityVillage(), MatchMode.START));
            }
            if ((paramPersonAddress.getNeighborhoodCell() != null)
                    && (paramPersonAddress.getNeighborhoodCell().length() > 2)) {
                localCriteria.add(Expression.like("addresses.neighborhoodCell",
                        paramPersonAddress.getNeighborhoodCell(),
                        MatchMode.START));
            }
            if ((paramPersonAddress.getCountyDistrict() != null)
                    && (paramPersonAddress.getCountyDistrict().length() > 2)) {
                localCriteria.add(Expression
                        .like("addresses.countyDistrict", paramPersonAddress
                                .getCountyDistrict(), MatchMode.START));
            }
            if ((paramPersonAddress.getTownshipDivision() != null)
                    && (paramPersonAddress.getTownshipDivision().length() > 2)) {
                localCriteria.add(Expression.like("addresses.townshipDivision",
                        paramPersonAddress.getTownshipDivision(),
                        MatchMode.START));
            }
            if ((paramPersonAddress.getRegion() != null)
                    && (paramPersonAddress.getRegion().length() > 2)) {
                localCriteria.add(Expression.like("addresses.region",
                        paramPersonAddress.getRegion(), MatchMode.START));
            }
            if ((paramPersonAddress.getSubregion() != null)
                    && (paramPersonAddress.getSubregion().length() > 2)) {
                localCriteria.add(Expression.like("addresses.subregion",
                        paramPersonAddress.getSubregion(), MatchMode.START));
            }
            if ((paramPersonAddress.getStateProvince() != null)
                    && (paramPersonAddress.getStateProvince().length() > 1)) {
                localCriteria
                        .add(Expression.like("addresses.stateProvince",
                                paramPersonAddress.getStateProvince(),
                                MatchMode.START));
            }
            if ((paramPersonAddress.getCountry() != null)
                    && (paramPersonAddress.getCountry().length() > 1)) {
                localCriteria.add(Expression.like("addresses.country",
                        paramPersonAddress.getCountry(), MatchMode.START));
            }
            if ((paramPersonAddress.getPostalCode() != null)
                    && (paramPersonAddress.getPostalCode().length() > 2)) {
                localCriteria.add(Expression.like("addresses.postalCode",
                        paramPersonAddress.getPostalCode(), MatchMode.START));
            }
            if ((paramPersonAddress.getLatitude() != null)
                    && (paramPersonAddress.getLatitude().length() > 1)) {
                localCriteria.add(Expression.like("addresses.latitude",
                        paramPersonAddress.getLatitude(), MatchMode.START));
            }
            if ((paramPersonAddress.getLongitude() != null)
                    && (paramPersonAddress.getLongitude().length() > 1)) {
                localCriteria.add(Expression.like("addresses.longitude",
                        paramPersonAddress.getLongitude(), MatchMode.START));
            }
        }

        if ((paramSet != null) && (!(paramSet.isEmpty()))) {
            for (Iterator<PersonAttribute> attributeIterator = paramSet.iterator(); attributeIterator.hasNext();) {
                localObject2 = (PersonAttribute) attributeIterator
                        .next();
                if ((((PersonAttribute) localObject2).getValue() != null)
                        && (!(((PersonAttribute) localObject2).getValue()
                                .isEmpty()))) {
                    localCriteria.add(Expression.and(Expression.eq(
                            "attributeType.name",
                            ((PersonAttribute) localObject2).getAttributeType()
                                    .getName()), Expression.like(
                            "attributes.value",
                            ((PersonAttribute) localObject2).getValue(),
                            MatchMode.START)));
                }

            }

        }

        if ((paramString != null) && (!(paramString.isEmpty()))) {
            localCriteria.add(Expression.eq("person.gender", paramString));
        }

        Object localObject1 = Boolean.valueOf((paramInteger != null)
                && (paramInteger.intValue() >= 0)
                && (paramInteger.intValue() < 200));
        if ((paramDate != null) || (((Boolean) localObject1).booleanValue())) {
            localObject2 = Calendar.getInstance();
            Calendar localCalendar = Calendar.getInstance();
            if (((Boolean) localObject1).booleanValue())
                localCalendar.add(1, 0 - paramInteger.intValue());
            else {
                localCalendar.setTime(paramDate);
            }
            localCalendar.clear(10);
            localCalendar.clear(11);
            localCalendar.clear(12);
            localCalendar.clear(13);
            localCalendar.clear(14);
            localCalendar.clear(9);
            if (((Boolean) localObject1).booleanValue()) {
                localCalendar.add(6, 1);
                ((Calendar) localObject2).setTime(localCalendar.getTime());
                ((Calendar) localObject2).add(1, -1);
            } else {
                ((Calendar) localObject2).setTime(localCalendar.getTime());
                localCalendar.add(6, 1);
            }
            localCriteria.add(Expression.and(Expression.ge("person.birthdate",
                    ((Calendar) localObject2).getTime()), Expression.lt(
                    "person.birthdate", localCalendar.getTime())));
        }

        localCriteria.addOrder(Order.asc("names.familyName"));

        return localCriteria.list();
    }
}
