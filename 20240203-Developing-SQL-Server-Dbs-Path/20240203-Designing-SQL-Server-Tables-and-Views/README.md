
<details><summary>

## Designing and Implementing Tables</summary>

Schema is similar a namespace. `dbo` is the default schema. If the schema it's not especified, the `dbo` will be the schema.  

Table requires a name. There is no table without column. Column requires names and data types. There are constraints.  
- Primary Key - Used to define the primary key which must be unique over all the rows the table will hold.  
- Nullability - The nullability constraint indicates whether it is acceptable for a column to ever have null value for some row. Since there are at least four names required, let's see what SQL Server names can be.  


Names in Sql Server should follow 4 rules for regular identifiers  
- Must begin with a *Letter*, *Underscore (_)*, *At sign (@) has special meaning* or *Number sign (#) has special meaning*.  
- After the first letter, it could contain *Letter*, *Decimal numbers* or *@,$,# or _*.   
- Regular identifiers must not be a T-SQL reserved word.  
- May not contain embedded spaces or special characters.  

Exception rules  
- Rule breakers enclosed in brackets *[]*.  
- An identifier cannot be longer than 128 characters.  

</details>



<details><summary>

###### Credit(s)/Other(s)/Reference(s)/Source(s)</summary>  

Paper: A relational model of data for large shared data bansk (Codd, Edgar Frank)

</details>