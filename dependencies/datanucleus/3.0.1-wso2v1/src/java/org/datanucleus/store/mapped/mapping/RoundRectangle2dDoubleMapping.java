/**********************************************************************
Copyright (c) 2007 Thomas Marti and others. All rights reserved.
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
    ...
**********************************************************************/
package org.datanucleus.store.mapped.mapping;

import java.awt.geom.RoundRectangle2D;

import org.datanucleus.ClassLoaderResolver;
import org.datanucleus.ClassNameConstants;
import org.datanucleus.NucleusContext;
import org.datanucleus.metadata.AbstractMemberMetaData;
import org.datanucleus.store.ExecutionContext;
import org.datanucleus.store.mapped.DatastoreContainerObject;
import org.datanucleus.store.mapped.MappedStoreManager;

/**
 * Mapping for java.awt.geom.RoundRectangle2D.Double, maps the x, y, width, height, 
 * arc-width and arc-height values to double-precision datastore fields.
 */
public class RoundRectangle2dDoubleMapping extends SingleFieldMultiMapping
{
    /* (non-Javadoc)
     * @see org.datanucleus.store.mapping.JavaTypeMapping#initialize(AbstractMemberMetaData, DatastoreContainerObject, ClassLoaderResolver)
     */
    public void initialize(AbstractMemberMetaData fmd, DatastoreContainerObject container, ClassLoaderResolver clr)
    {
        super.initialize(fmd, container, clr);
        addDatastoreFields();
    }

    /* (non-Javadoc)
     * @see org.datanucleus.store.mapped.mapping.JavaTypeMapping#initialize(MappedStoreManager, java.lang.String)
     */
    public void initialize(MappedStoreManager storeMgr, String type)
    {
        super.initialize(storeMgr, type);
        addDatastoreFields();
    }

    protected void addDatastoreFields()
    {
        addDatastoreField(ClassNameConstants.DOUBLE); // X
        addDatastoreField(ClassNameConstants.DOUBLE); // Y
        addDatastoreField(ClassNameConstants.DOUBLE); // Width
        addDatastoreField(ClassNameConstants.DOUBLE); // Height
        addDatastoreField(ClassNameConstants.DOUBLE); // Arc-Width
        addDatastoreField(ClassNameConstants.DOUBLE); // Arc-Height
    }

    /* (non-Javadoc)
     * @see org.datanucleus.store.mapping.JavaTypeMapping#getJavaType()
     */
    public Class getJavaType()
    {
        return RoundRectangle2D.Double.class;
    }

    /**
     * Method to return the value to be stored in the specified datastore index given the overall
     * value for this java type.
     * @param index The datastore index
     * @param value The overall value for this java type
     * @return The value for this datastore index
     */
    public Object getValueForDatastoreMapping(NucleusContext nucleusCtx, int index, Object value)
    {
        RoundRectangle2D.Double rr = (RoundRectangle2D.Double)value;
        if (index == 0)
        {
            return rr.getX();
        }
        else if (index == 1)
        {
            return rr.getY();
        }
        else if (index == 2)
        {
            return rr.getWidth();
        }
        else if (index == 3)
        {
            return rr.getHeight();
        }
        else if (index == 4)
        {
            return rr.getArcWidth();
        }
        else if (index == 5)
        {
            return rr.getArcHeight();
        }
        throw new IndexOutOfBoundsException();
    }

    /* (non-Javadoc)
     * @see org.datanucleus.store.mapping.JavaTypeMapping#setObject(org.datanucleus.ObjectManager, java.lang.Object, int[], java.lang.Object)
     */
    public void setObject(ExecutionContext ec, Object preparedStatement, int[] exprIndex, Object value)
    {
    	RoundRectangle2D roundRectangle = (RoundRectangle2D)value;
        if (roundRectangle == null)
        {
    		for (int i = 0; i < exprIndex.length; i++) 
    		{
    			getDatastoreMapping(i).setObject(preparedStatement, exprIndex[i], null);					
			}
        }
        else
        {
            getDatastoreMapping(0).setDouble(preparedStatement,exprIndex[0],roundRectangle.getX());
            getDatastoreMapping(1).setDouble(preparedStatement,exprIndex[1],roundRectangle.getY());
            getDatastoreMapping(2).setDouble(preparedStatement,exprIndex[2],roundRectangle.getWidth());
            getDatastoreMapping(3).setDouble(preparedStatement,exprIndex[3],roundRectangle.getHeight());
            getDatastoreMapping(4).setDouble(preparedStatement,exprIndex[4],roundRectangle.getArcWidth());
            getDatastoreMapping(5).setDouble(preparedStatement,exprIndex[5],roundRectangle.getArcHeight());
        }
    }
    
    /* (non-Javadoc)
     * @see org.datanucleus.store.mapping.JavaTypeMapping#getObject(org.datanucleus.ObjectManager, java.lang.Object, int[])
     */
    public Object getObject(ExecutionContext ec, Object resultSet, int[] exprIndex)
    {
        // Check for null entries
        if (getDatastoreMapping(0).getObject(resultSet, exprIndex[0]) == null)
        {
            return null;
        }

        double x = getDatastoreMapping(0).getDouble(resultSet,exprIndex[0]);
        double y = getDatastoreMapping(1).getDouble(resultSet,exprIndex[1]);
        double width  = getDatastoreMapping(2).getDouble(resultSet,exprIndex[2]);
        double height = getDatastoreMapping(3).getDouble(resultSet,exprIndex[3]);
        double arcwidth  = getDatastoreMapping(4).getDouble(resultSet,exprIndex[4]);
        double archeight = getDatastoreMapping(5).getDouble(resultSet,exprIndex[5]);
        return new RoundRectangle2D.Double(x, y, width, height, arcwidth, archeight);
    }
}