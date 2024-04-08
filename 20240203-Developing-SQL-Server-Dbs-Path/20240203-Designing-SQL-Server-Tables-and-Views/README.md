
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


<details><summary> 

### Data Types
</summary>

### Textual Data  

|Type|Length|Data|Uses|  
|-|-|-|-|  
|char(n)|n = 1...8000 - Fixed Length|Non-unicode|This data type always takes n bytes per row. Use it if most of your columns will have the same or mostly the same length or if the length is less than 3. Doing so will ensure less wasted space when compared to the next type.|  
|varchar(n)|n = 1...8000 - Variable Length varchar(max)|Non-Unicode|This is an efficient data type for highly variable data only using the actual data length per row. Names and addresses usually fall into this category. varchar(max) can hold up to 2 GB per column. However, this data type can use more disk space leading to extra I/O. Use it sparingly|  
|nchar(n)| n = 1...4000 - Fixed Length| Unicode|The storage size used is two times n bytes. Use for uniform length or short length character data that requires Unicode. Most systems that store text in multiple languages need Unicode for example.|  
|nvarchar(n)| n = 1...4000 - Variable Length| Unicode|Use it as you would varchar(n) but for circumstances that require Unicode. Nvarchar(max) is similar to varchar(max) and can hold up to 1 GB of characters, since with Unicode data, 2 bytes are used for each character.|  

### Integer Data

|Type|Length|Usage|
|-|-|-|
|tinyint|0 to 255 1byte| They are handy when you know you have a small set of integer values to store.|
|smallint|-2^15 to 2^15 - 1 2bytes|A value of about -32k to +32k|
|int| -2^31 to 2^31 - 1 4bytes|A value of approximately plus or minus 2.1billion in English System.|
|bigint| -2^63 to 2^63 -1 8bytes|A value approximately of 9.2 sextillion in the English system.|


### Decimal Data

|Type|Length|Comment|
|-|-|-|
|decimal[(p,s)] and numeric[(p,s)]| -10^38 + 1 to 10^38 -1 5 to 17bytes| p = precision is the total number of digits that will be stored ignoring the decimal point s = scale is the number of digits that will be stored to the right of the decimal point. They are optional. The default is p = 18 and s = 0. Decimal and Numeric are synonyms|
|money| 4 decimal places -922337203685477,5808 to 922337203685477,5807 8bytes|SQL Server stores the numeric value only, not the currency symbol|
|smallmoney| 4 decimal places -214748,3648 to 214748,3647 4bytes|Same as money but with a precision of 10. Money types are unique to SQL Server|


### Date Data

|Type|Length|Comments|
|-|-|-|
|date|0001-01-01 to 9999-12-31 3bytes||
|time[(n)]|n = 0 to 7 5bytes|Store times of the day. n = number of fractional seconds to be stored. The default is 7, which stores times as precise as 100 nano seconds. Regardless of the fractional seconds, this type takes 5 bytes to store.|
|datetime|Jan 1, 1753 to Dec 31, 9999 8bytes|is an older data type in SQL Server with definite limits. The date part cannot hold any date before January 1, 1753, and the time part is in 1/1000 of a second, but due to rounding is not stored exactly at that precision. The system stored values are always rounded to increments of .0, .003, or .007 seconds.|
|smalldatetime|Jan 1, 1900 to Jun 6, 2079 4bytes|Does not store fractional seconds|
|datetime2(n)|0001-01-01 to 9999-12-31 6 to 8bytes|Is like the date type combined with the time type. And as with the time type, you can specify the precision of fractional seconds with a default of 7 digits or 100 nanoseconds. And depending on the precision, 6, 7, or 8 bytes are required to store this type.|
|datetimeoffset(n)|0001-01-01 to 9999-12-31 10bytes|Combines datetime2 with a time zone. The ranges of dates and times are the same as for the datetime2 type, and this type always takes 10 bytes to store.|

</details>

</details>



<details><summary>

###### Credit(s)/Other(s)/Reference(s)/Source(s)</summary>  

Paper: A relational model of data for large shared data bansk (Codd, Edgar Frank)

</details>