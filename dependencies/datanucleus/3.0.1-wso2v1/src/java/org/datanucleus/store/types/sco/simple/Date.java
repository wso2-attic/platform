/**********************************************************************
Copyright (c) 2003 Mike Martin and others. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Contributors:
2003 Andy Jefferson - commented, javadocs
    ...
**********************************************************************/
package org.datanucleus.store.types.sco.simple;

import java.io.ObjectStreamException;

import javax.jdo.spi.PersistenceCapable;

import org.datanucleus.state.FetchPlanState;
import org.datanucleus.store.ObjectProvider;
import org.datanucleus.store.types.sco.SCO;

/**
 * A mutable second-class date object.
 */
public class Date extends java.util.Date implements SCO
{
    protected transient Object owner;
    protected transient ObjectProvider ownerSM;
    protected transient String fieldName;

    /**
     * Creates a <tt>Date</tt> object that represents the time at which it was allocated.
     * Assigns owning object and field name.
     * @param ownerSM the owning object
     * @param fieldName the owning field name
     */
    public Date(ObjectProvider ownerSM, String fieldName)
    {
        super();

        this.ownerSM = ownerSM;
        this.owner = ownerSM.getObject();
        this.fieldName = fieldName;
    }

    /**
     * Method to initialise the SCO for use.
     */
    public void initialise()
    {
    }

    /**
     * Method to initialise the SCO from an existing value.
     * @param o The Object
     * @param forInsert Whether the object needs inserting in the datastore with this value
     * @param forUpdate Whether to update the datastore with this value
     */
    public void initialise(Object o, boolean forInsert, boolean forUpdate)
    {
        super.setTime(((java.util.Date)o).getTime());
    }

    /**
     * Accessor for the unwrapped value that we are wrapping.
     * @return The unwrapped value
     */
    public Object getValue()
    {
        return new java.util.Date(getTime());
    }

    /**
     * Utility to unset the owner.
     **/
    public void unsetOwner()
    {
        ownerSM = null;
    }

    /**
     * Accessor for the owner.
     * @return The owner 
     **/
    public Object getOwner()
    {
        return (ownerSM != null ? ownerSM.getObject() : null);
    }

    /**
     * Accessor for the field name
     * @return The field name
     **/ 
    public String getFieldName()
    {
        return this.fieldName;
    }

    /**
     * Utility to mark the object as dirty
     **/
    public void makeDirty()
    {
        if (owner != null)
        {
            ((PersistenceCapable)owner).jdoMakeDirty(fieldName);
        }
    }

    /**
     * Method to detach a copy of this object.
     * @param state State for detachment process
     * @return The detached object
     */
    public Object detachCopy(FetchPlanState state)
    {
        return new java.util.Date(getTime());
    }

    /**
     * Method to attached the passed value.
     * @param value The new value
     */
    public void attachCopy(Object value)
    {
        long oldValue = getTime();
        initialise(value, false, true);

        // Check if the field has changed, and set the owner field as dirty if necessary
        long newValue = ((java.util.Date)value).getTime();
        if (oldValue != newValue)
        {
            makeDirty();
        }
    }

    /**
     * Creates and returns a copy of this object.
     *
     * <p>Mutable second-class Objects are required to provide a public
     * clone method in order to allow for copying PersistenceCapable
     * objects. In contrast to Object.clone(), this method must not throw a
     * CloneNotSupportedException.
     * @return A clone of the object
     */
    public Object clone()
    {
        Object obj = super.clone();

        ((Date)obj).unsetOwner();

        return obj;
    }

    /**
     * Mutator for the time.
     * @param time The time (millisecs)
     **/
    public void setTime(long time)
    {
        super.setTime(time);
        makeDirty();
    }

    /**
     * Sets the year of this <tt>Date</tt> object to be the specified 
     * value plus 1900. This <code>Date</code> object is modified so 
     * that it represents a point in time within the specified year, 
     * with the month, date, hour, minute, and second the same as 
     * before, as interpreted in the local time zone. (Of course, if 
     * the date was February 29, for example, and the year is set to a 
     * non-leap year, then the new date will be treated as if it were 
     * on March 1.)
     *
     * @param   year    the year value.
     * @see     java.util.Calendar
     * @deprecated As of JDK version 1.1,
     * replaced by <code>Calendar.set(Calendar.YEAR, year + 1900)</code>.
     */
    public void setYear(int year)
    {
        super.setYear(year);
        makeDirty();
    }

    /**
     * Sets the month of this date to the specified value. This 
     * <tt>Date</tt> object is modified so that it represents a point 
     * in time within the specified month, with the year, date, hour, 
     * minute, and second the same as before, as interpreted in the 
     * local time zone. If the date was October 31, for example, and 
     * the month is set to June, then the new date will be treated as 
     * if it were on July 1, because June has only 30 days.
     *
     * @param   month   the month value between 0-11.
     * @see     java.util.Calendar
     * @deprecated As of JDK version 1.1,
     * replaced by <code>Calendar.set(Calendar.MONTH, int month)</code>.
     */
    public void setMonth(int month)
    {
        super.setMonth(month);
        makeDirty();
    }

    /**
     * Sets the day of the month of this <tt>Date</tt> object to the 
     * specified value. This <tt>Date</tt> object is modified so that 
     * it represents a point in time within the specified day of the 
     * month, with the year, month, hour, minute, and second the same 
     * as before, as interpreted in the local time zone. If the date 
     * was April 30, for example, and the date is set to 31, then it 
     * will be treated as if it were on May 1, because April has only 
     * 30 days.
     *
     * @param   date   the day of the month value between 1-31.
     * @see     java.util.Calendar
     * @deprecated As of JDK version 1.1,
     * replaced by <code>Calendar.set(Calendar.DAY_OF_MONTH, int date)</code>.
     */
    public void setDate(int date)
    {
        super.setDate(date);
        makeDirty();
    }

    /**
     * Sets the hour of this <tt>Date</tt> object to the specified value. 
     * This <tt>Date</tt> object is modified so that it represents a point 
     * in time within the specified hour of the day, with the year, month, 
     * date, minute, and second the same as before, as interpreted in the 
     * local time zone.
     *
     * @param   hours   the hour value.
     * @see     java.util.Calendar
     * @deprecated As of JDK version 1.1,
     * replaced by <code>Calendar.set(Calendar.HOUR_OF_DAY, int hours)</code>.
     */
    public void setHours(int hours)
    {
        super.setHours(hours);
        makeDirty();
    }

    /**
     * Sets the minutes of this <tt>Date</tt> object to the specified value. 
     * This <tt>Date</tt> object is modified so that it represents a point 
     * in time within the specified minute of the hour, with the year, month, 
     * date, hour, and second the same as before, as interpreted in the 
     * local time zone.
     *
     * @param   minutes   the value of the minutes.
     * @see     java.util.Calendar
     * @deprecated As of JDK version 1.1,
     * replaced by <code>Calendar.set(Calendar.MINUTE, int minutes)</code>.
     */
    public void setMinutes(int minutes)
    {
        super.setMinutes(minutes);
        makeDirty();
    }

    /**
     * Sets the seconds of this <tt>Date</tt> to the specified value. 
     * This <tt>Date</tt> object is modified so that it represents a 
     * point in time within the specified second of the minute, with 
     * the year, month, date, hour, and minute the same as before, as 
     * interpreted in the local time zone.
     *
     * @param   seconds   the seconds value.
     * @see     java.util.Calendar
     * @deprecated As of JDK version 1.1,
     * replaced by <code>Calendar.set(Calendar.SECOND, int seconds)</code>. 
     */
    public void setSeconds(int seconds)
    {
        super.setSeconds(seconds);
        makeDirty();
    }

	/**
	 * The writeReplace method is called when ObjectOutputStream is preparing to write the object to the stream. The
	 * ObjectOutputStream checks whether the class defines the writeReplace method. If the method is defined, the
	 * writeReplace method is called to allow the object to designate its replacement in the stream. The object returned
	 * should be either of the same type as the object passed in or an object that when read and resolved will result in
	 * an object of a type that is compatible with all references to the object.
	 * 
	 * @return the replaced object
	 * @throws ObjectStreamException
	 */
	protected Object writeReplace() throws ObjectStreamException
	{
		return new java.util.Date(this.getTime());
	}     
}